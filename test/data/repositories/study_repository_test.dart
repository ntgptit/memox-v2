import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/errors/app_exception.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/datasources/local/daos/study_attempt_dao.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/datasources/local/daos/study_session_item_dao.dart';
import 'package:memox/data/datasources/local/local_transaction_runner.dart';
import 'package:memox/data/repositories/study_repo_impl.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/strategy/study_strategy.dart';
import 'package:memox/domain/study/strategy/study_strategy_factory.dart';
import 'package:memox/domain/study/usecases/study_usecases.dart';

import '../../support/content_repository_harness.dart';

void main() {
  group('StudyRepository', () {
    late _StudyHarness harness;

    setUp(() {
      harness = _StudyHarness.create();
    });

    tearDown(() async {
      await harness.dispose();
    });

    test('DT1 onNavigate: runs New Study through five modes and finalizes to box 2', () async {
      await harness.seedDeckWithCards(cardCount: 2);

      var snapshot = await harness.start.execute(
        const StudyContext(
          entryType: StudyEntryType.deck,
          entryRefId: 'deck-1',
          studyType: StudyType.newStudy,
          settings: StudySettingsSnapshot(
            batchSize: 2,
            shuffleFlashcards: false,
            shuffleAnswers: false,
            prioritizeOverdue: true,
          ),
        ),
      );

      while (snapshot.currentItem != null) {
        snapshot = await harness.answer.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
          grade: AttemptGrade.remembered,
        );
      }

      expect(snapshot.session.status, SessionStatus.readyToFinalize);

      snapshot = await harness.finalize.execute(
        sessionId: snapshot.session.id,
        studyType: snapshot.session.studyType,
      );

      expect(snapshot.session.status, SessionStatus.completed);
      final progressRows = await harness.database
          .select(harness.database.flashcardProgress)
          .get();
      expect(progressRows.map((row) => row.currentBox), everyElement(2));
      expect(progressRows.map((row) => row.dueAt), everyElement(isNotNull));
    });

    test('DT1 repositoryFlow: skip requeues without passing the item', () async {
      await harness.seedDeckWithCards(cardCount: 1);

      final started = await harness.start.execute(
        const StudyContext(
          entryType: StudyEntryType.deck,
          entryRefId: 'deck-1',
          studyType: StudyType.newStudy,
          settings: StudySettingsSnapshot(
            batchSize: 1,
            shuffleFlashcards: false,
            shuffleAnswers: false,
            prioritizeOverdue: true,
          ),
        ),
      );
      final skipped = await harness.skip.execute(started.session.id);

      expect(skipped.session.status, SessionStatus.inProgress);
      expect(
        skipped.currentItem?.flashcard.id,
        started.currentItem?.flashcard.id,
      );
      expect(skipped.summary.completedAttempts, 0);
    });

    test('DT1 onUpdate: does not mark completed session failed on stale finalize', () async {
      await harness.seedDeckWithCards(cardCount: 1);

      var snapshot = await harness.start.execute(
        const StudyContext(
          entryType: StudyEntryType.deck,
          entryRefId: 'deck-1',
          studyType: StudyType.newStudy,
          settings: StudySettingsSnapshot(
            batchSize: 1,
            shuffleFlashcards: false,
            shuffleAnswers: false,
            prioritizeOverdue: true,
          ),
        ),
      );

      while (snapshot.currentItem != null) {
        snapshot = await harness.answer.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
          grade: AttemptGrade.remembered,
        );
      }

      snapshot = await harness.finalize.execute(
        sessionId: snapshot.session.id,
        studyType: snapshot.session.studyType,
      );
      expect(snapshot.session.status, SessionStatus.completed);

      await expectLater(
        () => harness.finalize.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
        ),
        throwsA(isA<ValidationException>()),
      );

      final persistedSession = await (harness.database.select(
        harness.database.studySessions,
      )..where((table) => table.id.equals(snapshot.session.id))).getSingle();
      expect(persistedSession.status, SessionStatus.completed.storageValue);
    });

    test('DT2 onUpdate: does not cancel a completed session', () async {
      await harness.seedDeckWithCards(cardCount: 1);

      var snapshot = await harness.start.execute(
        const StudyContext(
          entryType: StudyEntryType.deck,
          entryRefId: 'deck-1',
          studyType: StudyType.newStudy,
          settings: StudySettingsSnapshot(
            batchSize: 1,
            shuffleFlashcards: false,
            shuffleAnswers: false,
            prioritizeOverdue: true,
          ),
        ),
      );

      while (snapshot.currentItem != null) {
        snapshot = await harness.answer.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
          grade: AttemptGrade.remembered,
        );
      }

      snapshot = await harness.finalize.execute(
        sessionId: snapshot.session.id,
        studyType: snapshot.session.studyType,
      );

      await expectLater(
        () => harness.cancel.execute(snapshot.session.id),
        throwsA(isA<ValidationException>()),
      );

      final persistedSession = await (harness.database.select(
        harness.database.studySessions,
      )..where((table) => table.id.equals(snapshot.session.id))).getSingle();
      expect(persistedSession.status, SessionStatus.completed.storageValue);
    });

    test(
      'DT3 onUpdate: restart cancels the previous session and links the new one',
      () async {
        await harness.seedDeckWithCards(cardCount: 2);

        final first = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.newStudy,
            settings: StudySettingsSnapshot(
              batchSize: 1,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        final restarted = await harness.restart.execute(
          sessionId: first.session.id,
          context: const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.newStudy,
            settings: StudySettingsSnapshot(
              batchSize: 1,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        final previous = await (harness.database.select(
          harness.database.studySessions,
        )..where((table) => table.id.equals(first.session.id))).getSingle();

        expect(previous.status, SessionStatus.cancelled.storageValue);
        expect(restarted.session.status, SessionStatus.inProgress);
        expect(restarted.session.restartedFromSessionId, first.session.id);
      },
    );

    test('DT1 onRefreshRetry: SRS Review treats forgot as retry and finalizes to box 1', () async {
      await harness.seedDeckWithCards(cardCount: 1, due: true, currentBox: 4);

      var snapshot = await harness.start.execute(
        const StudyContext(
          entryType: StudyEntryType.deck,
          entryRefId: 'deck-1',
          studyType: StudyType.srsReview,
          settings: StudySettingsSnapshot(
            batchSize: 1,
            shuffleFlashcards: false,
            shuffleAnswers: false,
            prioritizeOverdue: true,
          ),
        ),
      );

      snapshot = await harness.answer.execute(
        sessionId: snapshot.session.id,
        studyType: snapshot.session.studyType,
        grade: AttemptGrade.forgot,
      );
      expect(snapshot.currentItem, isNotNull);
      expect(snapshot.session.status, SessionStatus.inProgress);

      snapshot = await harness.answer.execute(
        sessionId: snapshot.session.id,
        studyType: snapshot.session.studyType,
        grade: AttemptGrade.correct,
      );
      expect(snapshot.session.status, SessionStatus.readyToFinalize);

      await harness.finalize.execute(
        sessionId: snapshot.session.id,
        studyType: snapshot.session.studyType,
      );

      final progress = await (harness.database.select(
        harness.database.flashcardProgress,
      )..where((table) => table.flashcardId.equals('card-1'))).getSingle();
      expect(progress.currentBox, 1);
      expect(progress.lastResult, ReviewResult.forgot.storageValue);
    });
  });
}

final class _StudyHarness {
  _StudyHarness._({
    required this.database,
    required this.start,
    required this.answer,
    required this.skip,
    required this.cancel,
    required this.restart,
    required this.finalize,
  });

  factory _StudyHarness.create() {
    final database = AppDatabase(executor: NativeDatabase.memory());
    final clock = TestClock(DateTime.utc(2026, 4, 24, 9));
    final idGenerator = SequenceIdGenerator();
    final transactionRunner = LocalTransactionRunner(database);
    final repo = StudyRepoImpl(
      database: database,
      studySessionDao: StudySessionDao(database),
      studySessionItemDao: StudySessionItemDao(database),
      studyAttemptDao: StudyAttemptDao(database),
      folderDao: FolderDao(database),
      transactionRunner: transactionRunner,
      clock: clock,
      idGenerator: idGenerator,
    );
    final factory = StudyStrategyFactory(const <StudyStrategy>[
      NewStudyStrategy(),
      SrsReviewStrategy(),
    ]);
    return _StudyHarness._(
      database: database,
      start: StartStudySessionUseCase(
        repository: repo,
        strategyFactory: factory,
      ),
      answer: AnswerFlashcardUseCase(
        repository: repo,
        strategyFactory: factory,
      ),
      skip: SkipFlashcardUseCase(repo),
      cancel: CancelStudySessionUseCase(repo),
      restart: RestartStudySessionUseCase(
        repository: repo,
        strategyFactory: factory,
      ),
      finalize: FinalizeStudySessionUseCase(
        repository: repo,
        strategyFactory: factory,
      ),
    );
  }

  final AppDatabase database;
  final StartStudySessionUseCase start;
  final AnswerFlashcardUseCase answer;
  final SkipFlashcardUseCase skip;
  final CancelStudySessionUseCase cancel;
  final RestartStudySessionUseCase restart;
  final FinalizeStudySessionUseCase finalize;

  Future<void> seedDeckWithCards({
    required int cardCount,
    bool due = false,
    int currentBox = 1,
  }) async {
    final now = DateTime.utc(2026, 4, 24, 9).millisecondsSinceEpoch;
    await database
        .into(database.folders)
        .insert(
          FoldersCompanion.insert(
            id: 'folder-1',
            name: 'Study',
            contentMode: 'decks',
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.decks)
        .insert(
          DecksCompanion.insert(
            id: 'deck-1',
            folderId: 'folder-1',
            name: 'Deck',
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
    for (var index = 0; index < cardCount; index++) {
      final cardId = 'card-${index + 1}';
      await database
          .into(database.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: cardId,
              deckId: 'deck-1',
              front: 'front $index',
              back: 'back $index',
              sortOrder: index,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await database
          .into(database.flashcardProgress)
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: cardId,
              currentBox: currentBox,
              reviewCount: 0,
              lapseCount: 0,
              dueAt: Value(due ? now - Duration.millisecondsPerDay : null),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }

  Future<void> dispose() => database.close();
}
