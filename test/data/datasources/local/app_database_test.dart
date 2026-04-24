import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase(executor: NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('creates the full schema v1', () async {
      final tableNames = await database
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .map((row) => row.read<String>('name'))
          .get();

      expect(
        tableNames,
        containsAll(<String>[
          'folders',
          'decks',
          'flashcards',
          'flashcard_progress',
          'study_sessions',
          'study_session_items',
          'study_attempts',
        ]),
      );
    });

    test('resets pre-release study tables during v2 migration', () async {
      await database.close();
      database = AppDatabase(
        executor: NativeDatabase.memory(
          setup: (sqlite) {
            for (final statement in _legacyV1Statements) {
              sqlite.execute(statement);
            }
          },
        ),
      );

      final items = await database.select(database.studySessionItems).get();
      final itemColumns = await database
          .customSelect('PRAGMA table_info(study_session_items)')
          .map((row) => row.read<String>('name'))
          .get();
      final attemptColumns = await database
          .customSelect('PRAGMA table_info(study_attempts)')
          .map((row) => row.read<String>('name'))
          .get();
      final progressColumns = await database
          .customSelect('PRAGMA table_info(flashcard_progress)')
          .map((row) => row.read<String>('name'))
          .get();
      final indexRows = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'index' "
            "AND name = 'idx_study_session_items_mode_round'",
          )
          .get();

      expect(items, isEmpty);
      expect(itemColumns, containsAll(<String>['study_mode', 'mode_order']));
      expect(attemptColumns, contains('attempt_number'));
      expect(
        progressColumns,
        containsAll(<String>['current_box', 'review_count', 'last_result']),
      );
      expect(indexRows, hasLength(1));
    });

    test('deleting a deck cascades to flashcards and progress', () async {
      final now = DateTime.utc(2026, 4, 22).millisecondsSinceEpoch;

      await database
          .into(database.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'folder-1',
              name: 'Languages',
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
              name: 'Korean Basics',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await database
          .into(database.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: 'card-1',
              deckId: 'deck-1',
              front: 'annyeonghaseyo',
              back: 'xin chao',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await database
          .into(database.flashcardProgress)
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: 'card-1',
              currentBox: 1,
              reviewCount: 0,
              lapseCount: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await (database.delete(
        database.decks,
      )..where((table) => table.id.equals('deck-1'))).go();

      final remainingFlashcards = await database
          .select(database.flashcards)
          .get();
      final remainingProgress = await database
          .select(database.flashcardProgress)
          .get();

      expect(remainingFlashcards, isEmpty);
      expect(remainingProgress, isEmpty);
    });
  });
}

const List<String> _legacyV1Statements = <String>[
  '''
  CREATE TABLE folders (
    id TEXT PRIMARY KEY,
    parent_id TEXT,
    sort_order INTEGER NOT NULL
  )
  ''',
  '''
  CREATE TABLE decks (
    id TEXT PRIMARY KEY,
    folder_id TEXT,
    sort_order INTEGER NOT NULL
  )
  ''',
  '''
  CREATE TABLE flashcards (
    id TEXT PRIMARY KEY,
    deck_id TEXT NOT NULL,
    sort_order INTEGER NOT NULL
  )
  ''',
  '''
  CREATE TABLE flashcard_progress (
    flashcard_id TEXT PRIMARY KEY,
    due_at INTEGER,
    last_studied_at INTEGER
  )
  ''',
  '''
  CREATE TABLE study_sessions (
    id TEXT PRIMARY KEY,
    entry_type TEXT NOT NULL,
    entry_ref_id TEXT,
    study_type TEXT NOT NULL,
    study_flow TEXT NOT NULL,
    batch_size INTEGER NOT NULL,
    shuffle_flashcards INTEGER NOT NULL,
    shuffle_answers INTEGER NOT NULL,
    prioritize_overdue INTEGER NOT NULL,
    status TEXT NOT NULL,
    started_at INTEGER NOT NULL,
    ended_at INTEGER,
    restarted_from_session_id TEXT
  )
  ''',
  '''
  CREATE TABLE study_session_items (
    id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    flashcard_id TEXT NOT NULL,
    mode_order INTEGER NOT NULL,
    round_index INTEGER NOT NULL,
    queue_position INTEGER NOT NULL,
    source_pool TEXT NOT NULL,
    status TEXT NOT NULL,
    completed_at INTEGER
  )
  ''',
  '''
  CREATE TABLE study_attempts (
    id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    session_item_id TEXT NOT NULL,
    flashcard_id TEXT NOT NULL,
    answered_at INTEGER NOT NULL
  )
  ''',
  '''
  INSERT INTO study_sessions (
    id,
    entry_type,
    entry_ref_id,
    study_type,
    study_flow,
    batch_size,
    shuffle_flashcards,
    shuffle_answers,
    prioritize_overdue,
    status,
    started_at
  ) VALUES (
    'new-session',
    'deck',
    'deck-1',
    'new',
    'new_full_cycle',
    10,
    0,
    0,
    0,
    'in_progress',
    1
  )
  ''',
  '''
  INSERT INTO study_sessions (
    id,
    entry_type,
    entry_ref_id,
    study_type,
    study_flow,
    batch_size,
    shuffle_flashcards,
    shuffle_answers,
    prioritize_overdue,
    status,
    started_at
  ) VALUES (
    'review-session',
    'today',
    NULL,
    'srs_review',
    'srs_fill_review',
    10,
    0,
    0,
    0,
    'in_progress',
    1
  )
  ''',
  '''
  INSERT INTO study_session_items (
    id,
    session_id,
    flashcard_id,
    mode_order,
    round_index,
    queue_position,
    source_pool,
    status
  ) VALUES (
    'item-new',
    'new-session',
    'card-1',
    3,
    1,
    1,
    'new',
    'pending'
  )
  ''',
  '''
  INSERT INTO study_session_items (
    id,
    session_id,
    flashcard_id,
    mode_order,
    round_index,
    queue_position,
    source_pool,
    status
  ) VALUES (
    'item-review',
    'review-session',
    'card-2',
    1,
    1,
    1,
    'due',
    'pending'
  )
  ''',
  'PRAGMA user_version = 1',
];
