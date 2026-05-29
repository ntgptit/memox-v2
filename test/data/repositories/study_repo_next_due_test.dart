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

/// P0-1 Tier 1 repository scope-probe queries used by empty-scope pre-checks:
/// `countFlashcardsInScope`, `countDueCardsInScope`, `nextDueAt`.
void main() {
  late AppDatabase database;
  late TestClock clock;
  late StudyRepoImpl repo;

  // Fixed "now" so due-date arithmetic is deterministic across runs.
  final now = DateTime.utc(2026, 4, 24, 9);

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    clock = TestClock(now);
    repo = StudyRepoImpl(
      database: database,
      studySessionDao: StudySessionDao(database),
      studySessionItemDao: StudySessionItemDao(database),
      studyAttemptDao: StudyAttemptDao(database),
      folderDao: FolderDao(database),
      transactionRunner: LocalTransactionRunner(database),
      clock: clock,
      idGenerator: SequenceIdGenerator(),
      shuffleRandom: Random(7),
      logger: _SilentLogger(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  const settings = StudySettingsSnapshot(
    batchSize: 20,
    shuffleFlashcards: false,
    shuffleAnswers: false,
    prioritizeOverdue: false,
  );

  StudyContext deckContext(String deckId) => StudyContext(
    entryType: StudyEntryType.deck,
    entryRefId: deckId,
    studyType: StudyType.srsReview,
    settings: settings,
  );

  StudyContext folderContext(String folderId) => StudyContext(
    entryType: StudyEntryType.folder,
    entryRefId: folderId,
    studyType: StudyType.srsReview,
    settings: settings,
  );

  Future<void> insertFolder(String id, {String? parentId}) => database
      .into(database.folders)
      .insert(
        FoldersCompanion.insert(
          id: id,
          name: id,
          contentMode: parentId == null ? 'decks' : 'decks',
          parentId: Value(parentId),
          sortOrder: 0,
          createdAt: now.millisecondsSinceEpoch,
          updatedAt: now.millisecondsSinceEpoch,
        ),
      );

  Future<void> insertDeck(String id, String folderId) => database
      .into(database.decks)
      .insert(
        DecksCompanion.insert(
          id: id,
          folderId: folderId,
          name: id,
          sortOrder: 0,
          createdAt: now.millisecondsSinceEpoch,
          updatedAt: now.millisecondsSinceEpoch,
        ),
      );

  Future<void> insertCard(
    String id,
    String deckId, {
    required int? dueAt,
  }) async {
    await database
        .into(database.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: deckId,
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
            dueAt: Value(dueAt),
            createdAt: now.millisecondsSinceEpoch,
            updatedAt: now.millisecondsSinceEpoch,
          ),
        );
  }

  int days(int n) => now.add(Duration(days: n)).millisecondsSinceEpoch;

  test('nextDueAt returns the nearest future due date in deck scope '
      '(supports S4e/S4j next-due hint)', () async {
    await insertFolder('folder-1');
    await insertDeck('deck-1', 'folder-1');
    // One overdue card, two future cards at +2 and +5 days.
    await insertCard('card-due', 'deck-1', dueAt: days(-1));
    await insertCard('card-far', 'deck-1', dueAt: days(5));
    await insertCard('card-near', 'deck-1', dueAt: days(2));

    final nextDue = await repo.nextDueAt(deckContext('deck-1'));

    expect(nextDue, DateTime.fromMillisecondsSinceEpoch(days(2)));
  });

  test('nextDueAt returns null when no future due exists', () async {
    await insertFolder('folder-1');
    await insertDeck('deck-1', 'folder-1');
    await insertCard('card-due', 'deck-1', dueAt: days(-1));

    final nextDue = await repo.nextDueAt(deckContext('deck-1'));

    expect(nextDue, isNull);
  });

  test('countDueCardsInScope counts only cards due by end of today', () async {
    await insertFolder('folder-1');
    await insertDeck('deck-1', 'folder-1');
    await insertCard('card-due', 'deck-1', dueAt: days(-1));
    await insertCard('card-future', 'deck-1', dueAt: days(3));
    await insertCard('card-new', 'deck-1', dueAt: null);

    expect(await repo.countDueCardsInScope(deckContext('deck-1')), 1);
    expect(await repo.countFlashcardsInScope(deckContext('deck-1')), 3);
  });

  test('scope probe traverses folder subtree recursively', () async {
    await insertFolder('root');
    await insertFolder('child', parentId: 'root');
    await insertDeck('deck-root', 'root');
    await insertDeck('deck-child', 'child');
    await insertCard('c1', 'deck-root', dueAt: days(-1));
    await insertCard('c2', 'deck-child', dueAt: days(4));

    expect(await repo.countFlashcardsInScope(folderContext('root')), 2);
    expect(await repo.countDueCardsInScope(folderContext('root')), 1);
    expect(
      await repo.nextDueAt(folderContext('root')),
      DateTime.fromMillisecondsSinceEpoch(days(4)),
    );
  });

  Future<FlashcardProgressData> progressOf(String id) => (database.select(
    database.flashcardProgress,
  )..where((table) => table.flashcardId.equals(id))).getSingle();

  test(
    'BS1: setBuried persists buried_until without touching SRS state',
    () async {
      await insertFolder('folder-1');
      await insertDeck('deck-1', 'folder-1');
      await insertCard('c1', 'deck-1', dueAt: days(-1));

      await repo.setBuried(flashcardId: 'c1', buried: true);
      final buried = await progressOf('c1');
      expect(buried.buriedUntil, isNotNull);
      expect(buried.buriedUntil! > now.millisecondsSinceEpoch, isTrue);
      expect(buried.currentBox, 2);
      expect(buried.dueAt, days(-1));

      await repo.setBuried(flashcardId: 'c1', buried: false);
      expect((await progressOf('c1')).buriedUntil, isNull);
    },
  );

  test(
    'BS2: setSuspended toggles is_suspended without touching SRS state',
    () async {
      await insertFolder('folder-1');
      await insertDeck('deck-1', 'folder-1');
      await insertCard('c1', 'deck-1', dueAt: days(-1));

      await repo.setSuspended(flashcardId: 'c1', suspended: true);
      final suspended = await progressOf('c1');
      expect(suspended.isSuspended, isTrue);
      expect(suspended.currentBox, 2);
      expect(suspended.dueAt, days(-1));

      await repo.setSuspended(flashcardId: 'c1', suspended: false);
      expect((await progressOf('c1')).isSuspended, isFalse);
    },
  );

  test(
    'buried and suspended cards are excluded from the due batch; expired bury '
    'is eligible again',
    () async {
      await insertFolder('folder-1');
      await insertDeck('deck-1', 'folder-1');
      await insertCard('due-1', 'deck-1', dueAt: days(-1));
      await insertCard('due-2', 'deck-1', dueAt: days(-1));
      await insertCard('due-3', 'deck-1', dueAt: days(-1));

      await repo.setBuried(flashcardId: 'due-1', buried: true);
      await repo.setSuspended(flashcardId: 'due-2', suspended: true);

      final batch = await repo.loadDueCards(deckContext('deck-1'));
      expect(batch.map((card) => card.id), <String>['due-3']);
      expect(await repo.countDueCardsInScope(deckContext('deck-1')), 1);

      // Expire due-1's bury: now >= buried_until ⇒ eligible again.
      await (database.update(database.flashcardProgress)
            ..where((table) => table.flashcardId.equals('due-1')))
          .write(FlashcardProgressCompanion(buriedUntil: Value(days(-1))));

      final reopened = await repo.loadDueCards(deckContext('deck-1'));
      expect(reopened.map((card) => card.id).toSet(), <String>{
        'due-1',
        'due-3',
      });
    },
  );

  test('suspended cards are excluded from the new-card batch', () async {
    await insertFolder('folder-1');
    await insertDeck('deck-1', 'folder-1');
    await insertCard('new-1', 'deck-1', dueAt: null);
    await insertCard('new-2', 'deck-1', dueAt: null);
    await repo.setSuspended(flashcardId: 'new-1', suspended: true);

    final batch = await repo.loadNewCards(
      const StudyContext(
        entryType: StudyEntryType.deck,
        entryRefId: 'deck-1',
        studyType: StudyType.newStudy,
        settings: settings,
      ),
    );
    expect(batch.map((card) => card.id), <String>['new-2']);
  });

  test('counts suspended and active-buried cards in scope', () async {
    await insertFolder('folder-1');
    await insertDeck('deck-1', 'folder-1');
    await insertCard('a', 'deck-1', dueAt: days(-1));
    await insertCard('b', 'deck-1', dueAt: days(-1));
    await insertCard('c', 'deck-1', dueAt: days(-1));
    await repo.setSuspended(flashcardId: 'a', suspended: true);
    await repo.setBuried(flashcardId: 'b', buried: true);

    expect(await repo.countSuspendedInScope(deckContext('deck-1')), 1);
    expect(await repo.countActiveBuriedInScope(deckContext('deck-1')), 1);
  });
}

final class _SilentLogger implements AppLogger {
  @override
  void noSuchMethod(Invocation invocation) {}
}
