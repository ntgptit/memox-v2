import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/datasources/local/daos/study_attempt_dao.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/datasources/local/daos/study_session_item_dao.dart';
import 'package:memox/data/datasources/local/local_transaction_runner.dart';
import 'package:memox/data/repositories/study_repo_impl.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';

import '../../support/content_repository_harness.dart';

/// P0-2 fix: bury/suspend must drop the current card from the active session
/// (not requeue it). Exercises `dropCurrentItemFromSession`.
void main() {
  late AppDatabase database;
  late StudyRepoImpl repo;
  final now = DateTime.utc(2026, 4, 24, 9);

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    repo = StudyRepoImpl(
      database: database,
      studySessionDao: StudySessionDao(database),
      studySessionItemDao: StudySessionItemDao(database),
      studyAttemptDao: StudyAttemptDao(database),
      folderDao: FolderDao(database),
      transactionRunner: LocalTransactionRunner(database),
      clock: TestClock(now),
      idGenerator: SequenceIdGenerator(),
      shuffleRandom: Random(7),
      logger: _SilentLogger(),
    );
  });

  tearDown(() async => database.close());

  const settings = StudySettingsSnapshot(
    batchSize: 20,
    shuffleFlashcards: false,
    shuffleAnswers: false,
    prioritizeOverdue: false,
  );

  Future<void> seedCard(String id) async {
    await database
        .into(database.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: 'deck-1',
            front: 'front $id',
            back: 'back $id',
            sortOrder: 0,
            createdAt: now.millisecondsSinceEpoch,
            updatedAt: now.millisecondsSinceEpoch,
          ),
        );
    await database
        .into(database.flashcardProgress)
        .insert(
          FlashcardProgressCompanion.insert(
            flashcardId: id,
            currentBox: 2,
            reviewCount: 1,
            lapseCount: 0,
            dueAt: Value(now.millisecondsSinceEpoch - 1000),
            createdAt: now.millisecondsSinceEpoch,
            updatedAt: now.millisecondsSinceEpoch,
          ),
        );
  }

  StudyFlashcardRef ref(String id) => StudyFlashcardRef(
    id: id,
    deckId: 'deck-1',
    front: 'front $id',
    back: 'back $id',
    sourcePool: SessionItemSourcePool.due,
  );

  Future<void> seedDeck() async {
    await database
        .into(database.folders)
        .insert(
          FoldersCompanion.insert(
            id: 'folder-1',
            name: 'F',
            contentMode: 'decks',
            sortOrder: 0,
            createdAt: now.millisecondsSinceEpoch,
            updatedAt: now.millisecondsSinceEpoch,
          ),
        );
    await database
        .into(database.decks)
        .insert(
          DecksCompanion.insert(
            id: 'deck-1',
            folderId: 'folder-1',
            name: 'D',
            sortOrder: 0,
            createdAt: now.millisecondsSinceEpoch,
            updatedAt: now.millisecondsSinceEpoch,
          ),
        );
  }

  const deckContext = StudyContext(
    entryType: StudyEntryType.deck,
    entryRefId: 'deck-1',
    studyType: StudyType.newStudy,
    settings: settings,
  );

  test(
    'dropping the current card advances to the next and never requeues it',
    () async {
      await seedDeck();
      await seedCard('c1');
      await seedCard('c2');

      final started = await repo.startSession(
        context: deckContext,
        flow: StudyFlow.newFillOnly,
        modes: const <StudyMode>[StudyMode.fill],
        batch: <StudyFlashcardRef>[ref('c1'), ref('c2')],
      );
      expect(started.currentItem?.flashcard.id, 'c1');

      final afterDrop = await repo.dropCurrentItemFromSession(
        sessionId: started.session.id,
        modes: const <StudyMode>[StudyMode.fill],
      );

      // Advances to the next card; dropped card is gone from the session.
      expect(afterDrop.currentItem?.flashcard.id, 'c2');
      expect(
        afterDrop.sessionFlashcards.map((card) => card.id),
        isNot(contains('c1')),
      );
      final pendingIds = afterDrop.currentRoundItems
          .where((item) => item.status == SessionItemStatus.pending)
          .map((item) => item.flashcard.id);
      expect(pendingIds, isNot(contains('c1')));
    },
  );

  test('no attempt is recorded when a card is dropped', () async {
    await seedDeck();
    await seedCard('c1');
    await seedCard('c2');
    final started = await repo.startSession(
      context: deckContext,
      flow: StudyFlow.newFillOnly,
      modes: const <StudyMode>[StudyMode.fill],
      batch: <StudyFlashcardRef>[ref('c1'), ref('c2')],
    );

    await repo.dropCurrentItemFromSession(
      sessionId: started.session.id,
      modes: const <StudyMode>[StudyMode.fill],
    );

    final attempts = await StudyAttemptDao(
      database,
    ).listAttempts(started.session.id);
    expect(attempts, isEmpty);
  });

  test(
    'dropping the last pending card transitions the session to finalize',
    () async {
      await seedDeck();
      await seedCard('c1');
      final started = await repo.startSession(
        context: deckContext,
        flow: StudyFlow.newFillOnly,
        modes: const <StudyMode>[StudyMode.fill],
        batch: <StudyFlashcardRef>[ref('c1')],
      );

      final afterDrop = await repo.dropCurrentItemFromSession(
        sessionId: started.session.id,
        modes: const <StudyMode>[StudyMode.fill],
      );

      expect(afterDrop.session.status, SessionStatus.readyToFinalize);
      expect(afterDrop.canFinalize, isTrue);
    },
  );

  test(
    'a dropped card does not reappear in a later mode of the same session',
    () async {
      await seedDeck();
      await seedCard('c1');
      await seedCard('c2');
      const modes = <StudyMode>[
        StudyMode.review,
        StudyMode.match,
        StudyMode.guess,
        StudyMode.recall,
        StudyMode.fill,
      ];
      final started = await repo.startSession(
        context: deckContext,
        flow: StudyFlow.newFullCycle,
        modes: modes,
        batch: <StudyFlashcardRef>[ref('c1'), ref('c2')],
      );
      expect(started.currentItem?.studyMode, StudyMode.review);

      // Drop c1 during Review, then answer c2 to finish the Review round and
      // advance into Match.
      await repo.dropCurrentItemFromSession(
        sessionId: started.session.id,
        modes: modes,
      );
      final afterAnswer = await repo.answerCurrentItem(
        sessionId: started.session.id,
        grade: AttemptGrade.correct,
        modes: modes,
      );

      expect(afterAnswer.currentItem?.studyMode, StudyMode.match);
      expect(afterAnswer.currentItem?.flashcard.id, 'c2');
      expect(
        afterAnswer.sessionFlashcards.map((card) => card.id),
        isNot(contains('c1')),
      );
    },
  );
}

final class _SilentLogger implements AppLogger {
  @override
  void noSuchMethod(Invocation invocation) {}
}
