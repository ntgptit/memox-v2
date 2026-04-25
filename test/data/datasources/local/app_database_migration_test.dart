import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

void main() {
  test('DT1 onNavigate: repairs pre-release study schema during v2 migration', () async {
    final database = AppDatabase(
      executor: NativeDatabase.memory(setup: _createLegacyPreReleaseSchema),
    );
    addTearDown(database.close);

    await database.ensureOpen();

    final progress = await database.select(database.flashcardProgress).get();
    expect(progress.single.lastResult, 'perfect');

    final itemColumns = await _columnNames(database, 'study_session_items');
    expect(itemColumns, containsAll(<String>['study_mode', 'mode_order']));

    final attemptColumns = await _columnNames(database, 'study_attempts');
    expect(attemptColumns, contains('attempt_number'));

    final flashcardColumns = await _columnNames(database, 'flashcards');
    expect(flashcardColumns, isNot(contains('title')));
    final flashcard = await database.select(database.flashcards).getSingle();
    expect(flashcard.front, 'front');
    expect(flashcard.back, 'back');

    await database
        .into(database.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: 'session-current',
            entryType: 'deck',
            entryRefId: const Value('deck-1'),
            studyType: 'srs_review',
            studyFlow: 'srs_fill_review',
            batchSize: 1,
            shuffleFlashcards: 0,
            shuffleAnswers: 0,
            prioritizeOverdue: 1,
            status: 'in_progress',
            startedAt: 1,
          ),
        );
  });
}

Future<List<String>> _columnNames(
  AppDatabase database,
  String tableName,
) async {
  final rows = await database
      .customSelect('PRAGMA table_info($tableName)')
      .get();
  return rows.map((row) => row.read<String>('name')).toList(growable: false);
}

void _createLegacyPreReleaseSchema(dynamic database) {
  const statements = <String>[
    'PRAGMA foreign_keys = OFF',
    '''
    CREATE TABLE folders (
      id TEXT NOT NULL PRIMARY KEY,
      parent_id TEXT NULL REFERENCES folders (id) ON DELETE CASCADE,
      name TEXT NOT NULL CHECK (length(trim(name)) >= 1),
      content_mode TEXT NOT NULL CHECK (content_mode IN ('unlocked', 'subfolders', 'decks')),
      sort_order INTEGER NOT NULL CHECK (sort_order >= 0),
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      CHECK (parent_id IS NULL OR parent_id != id)
    )
    ''',
    '''
    CREATE TABLE decks (
      id TEXT NOT NULL PRIMARY KEY,
      folder_id TEXT NOT NULL REFERENCES folders (id) ON DELETE CASCADE,
      name TEXT NOT NULL CHECK (length(trim(name)) >= 1),
      sort_order INTEGER NOT NULL CHECK (sort_order >= 0),
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
    ''',
    '''
    CREATE TABLE flashcards (
      id TEXT NOT NULL PRIMARY KEY,
      deck_id TEXT NOT NULL REFERENCES decks (id) ON DELETE CASCADE,
      title TEXT NULL CHECK (title IS NULL OR length(trim(title)) >= 1),
      front TEXT NOT NULL CHECK (length(trim(front)) >= 1),
      back TEXT NOT NULL CHECK (length(trim(back)) >= 1),
      note TEXT NULL,
      sort_order INTEGER NOT NULL CHECK (sort_order >= 0),
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
    ''',
    '''
    CREATE TABLE flashcard_progress (
      flashcard_id TEXT NOT NULL PRIMARY KEY REFERENCES flashcards (id) ON DELETE CASCADE,
      current_box INTEGER NOT NULL CHECK (current_box BETWEEN 1 AND 8),
      review_count INTEGER NOT NULL CHECK (review_count >= 0),
      lapse_count INTEGER NOT NULL CHECK (lapse_count >= 0),
      last_result TEXT NULL CHECK (last_result IS NULL OR last_result IN ('correct', 'incorrect', 'remembered', 'forgot')),
      last_studied_at INTEGER NULL,
      due_at INTEGER NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
    ''',
    '''
    CREATE TABLE study_sessions (
      id TEXT NOT NULL PRIMARY KEY,
      entry_type TEXT NOT NULL CHECK (entry_type IN ('deck', 'folder', 'today')),
      entry_ref_id TEXT NULL,
      study_type TEXT NOT NULL CHECK (study_type IN ('new', 'due', 'mixed')),
      study_mode TEXT NOT NULL CHECK (study_mode IN ('review', 'match', 'guess', 'recall')),
      batch_size INTEGER NOT NULL CHECK (batch_size >= 1),
      shuffle_flashcards INTEGER NOT NULL CHECK (shuffle_flashcards IN (0, 1)),
      shuffle_answers INTEGER NOT NULL CHECK (shuffle_answers IN (0, 1)),
      prioritize_overdue INTEGER NOT NULL CHECK (prioritize_overdue IN (0, 1)),
      status TEXT NOT NULL CHECK (status IN ('in_progress', 'completed', 'ended_early', 'restarted')),
      started_at INTEGER NOT NULL,
      ended_at INTEGER NULL,
      restarted_from_session_id TEXT NULL REFERENCES study_sessions (id),
      CHECK (ended_at IS NULL OR ended_at >= started_at),
      CHECK ((entry_type = 'today' AND entry_ref_id IS NULL) OR (entry_type IN ('deck', 'folder') AND entry_ref_id IS NOT NULL)),
      CHECK ((status = 'in_progress' AND ended_at IS NULL) OR (status != 'in_progress' AND ended_at IS NOT NULL)),
      CHECK (restarted_from_session_id IS NULL OR restarted_from_session_id != id)
    )
    ''',
    '''
    CREATE TABLE study_session_items (
      id TEXT NOT NULL PRIMARY KEY,
      session_id TEXT NOT NULL REFERENCES study_sessions (id) ON DELETE CASCADE,
      flashcard_id TEXT NOT NULL REFERENCES flashcards (id) ON DELETE CASCADE,
      round_index INTEGER NOT NULL CHECK (round_index >= 1),
      queue_position INTEGER NOT NULL CHECK (queue_position >= 0),
      source_pool TEXT NOT NULL CHECK (source_pool IN ('new', 'due', 'overdue', 'retry')),
      status TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'abandoned')),
      completed_at INTEGER NULL,
      CHECK ((status = 'completed' AND completed_at IS NOT NULL) OR (status IN ('pending', 'abandoned') AND completed_at IS NULL))
    )
    ''',
    '''
    CREATE TABLE study_attempts (
      id TEXT NOT NULL PRIMARY KEY,
      session_id TEXT NOT NULL REFERENCES study_sessions (id) ON DELETE CASCADE,
      session_item_id TEXT NOT NULL REFERENCES study_session_items (id) ON DELETE CASCADE,
      flashcard_id TEXT NOT NULL REFERENCES flashcards (id) ON DELETE CASCADE,
      result TEXT NOT NULL CHECK (result IN ('correct', 'incorrect', 'remembered', 'forgot')),
      old_box INTEGER NULL CHECK (old_box IS NULL OR old_box BETWEEN 1 AND 8),
      new_box INTEGER NULL CHECK (new_box IS NULL OR new_box BETWEEN 1 AND 8),
      next_due_at INTEGER NULL,
      answered_at INTEGER NOT NULL
    )
    ''',
    "INSERT INTO folders (id, name, content_mode, sort_order, created_at, updated_at) VALUES ('folder-1', 'Folder', 'decks', 0, 1, 1)",
    "INSERT INTO decks (id, folder_id, name, sort_order, created_at, updated_at) VALUES ('deck-1', 'folder-1', 'Deck', 0, 1, 1)",
    "INSERT INTO flashcards (id, deck_id, front, back, sort_order, created_at, updated_at) VALUES ('card-1', 'deck-1', 'front', 'back', 0, 1, 1)",
    "INSERT INTO flashcard_progress (flashcard_id, current_box, review_count, lapse_count, last_result, last_studied_at, due_at, created_at, updated_at) VALUES ('card-1', 3, 1, 0, 'correct', 1, 1, 1, 1)",
    "INSERT INTO study_sessions (id, entry_type, entry_ref_id, study_type, study_mode, batch_size, shuffle_flashcards, shuffle_answers, prioritize_overdue, status, started_at) VALUES ('session-legacy', 'deck', 'deck-1', 'due', 'review', 1, 0, 0, 1, 'in_progress', 1)",
    "INSERT INTO study_session_items (id, session_id, flashcard_id, round_index, queue_position, source_pool, status) VALUES ('item-legacy', 'session-legacy', 'card-1', 1, 0, 'due', 'pending')",
    'PRAGMA user_version = 1',
  ];

  for (final statement in statements) {
    database.execute(statement);
  }
}
