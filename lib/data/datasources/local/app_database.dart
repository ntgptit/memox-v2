import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../../core/constants/app_constants.dart';
import 'database_schema_support.dart';
import 'tables/decks_table.dart';
import 'tables/flashcard_progress_table.dart';
import 'tables/flashcards_table.dart';
import 'tables/folders_table.dart';
import 'tables/study_attempts_table.dart';
import 'tables/study_session_items_table.dart';
import 'tables/study_sessions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: <Type>[
    Folders,
    Decks,
    Flashcards,
    FlashcardProgress,
    StudySessions,
    StudySessionItems,
    StudyAttempts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  static const int currentSchemaVersion = 6;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
      await _createIndexes();
    },
    onUpgrade: (Migrator migrator, int from, int to) async {
      if (from < 2) {
        await _rebuildLegacyFlashcardProgressIfNeeded(migrator);
        await _resetLegacyStudyTablesIfNeeded(migrator);
      }
      if (from < 3) {
        await _migrateFlashcardsForSchemaV3(migrator);
      }
      if (from < 4) {
        await _normalizeStudyAttemptResultsForSchemaV4(migrator);
      }
      if (from < 5) {
        await _allowInitialPassedReviewResultForSchemaV5(migrator);
      }
      if (from < 6) {
        await _repairMissingFlashcardProgressForSchemaV6(migrator);
      }
      await _createIndexes();
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await _createIndexes();
    },
  );

  Future<void> ensureOpen() async {
    await customSelect('SELECT 1 AS ready').getSingle();
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: AppConstants.localDatabaseName,
      native: DriftNativeOptions(
        shareAcrossIsolates: true,
        setup: (database) {
          database.execute('PRAGMA foreign_keys = ON');
          database.execute('PRAGMA journal_mode = WAL');
        },
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  }

  Future<void> _createIndexes() async {
    for (final statement in _indexStatements) {
      await customStatement(statement);
    }
  }

  Future<void> _rebuildLegacyFlashcardProgressIfNeeded(
    Migrator migrator,
  ) async {
    if (!await _hasTable('flashcard_progress')) {
      await migrator.createTable(flashcardProgress);
      return;
    }

    if (!await _hasRequiredFlashcardProgressColumns()) {
      await customStatement(
        'DROP INDEX IF EXISTS idx_flashcard_progress_due_at',
      );
      await customStatement(
        'DROP INDEX IF EXISTS idx_flashcard_progress_last_studied_at',
      );
      await customStatement('DROP TABLE flashcard_progress');
      await migrator.createTable(flashcardProgress);
      return;
    }

    final tableSql = await _tableSql('flashcard_progress') ?? '';
    if (!tableSql.contains("'correct'") && !tableSql.contains("'remembered'")) {
      return;
    }

    await customStatement('DROP INDEX IF EXISTS idx_flashcard_progress_due_at');
    await customStatement(
      'DROP INDEX IF EXISTS idx_flashcard_progress_last_studied_at',
    );
    await customStatement(
      'ALTER TABLE flashcard_progress RENAME TO flashcard_progress_legacy',
    );
    await migrator.createTable(flashcardProgress);
    await customStatement('''
      INSERT INTO flashcard_progress (
        flashcard_id,
        current_box,
        review_count,
        lapse_count,
        last_result,
        last_studied_at,
        due_at,
        created_at,
        updated_at
      )
      SELECT
        flashcard_id,
        current_box,
        review_count,
        lapse_count,
        CASE last_result
          WHEN 'correct' THEN 'perfect'
          WHEN 'remembered' THEN 'perfect'
          WHEN 'incorrect' THEN 'recovered'
          WHEN 'forgot' THEN 'forgot'
          ELSE last_result
        END,
        last_studied_at,
        due_at,
        created_at,
        updated_at
      FROM flashcard_progress_legacy
      ''');
    await customStatement('DROP TABLE flashcard_progress_legacy');
  }

  Future<bool> _hasRequiredFlashcardProgressColumns() async {
    return await _hasColumn('flashcard_progress', 'current_box') &&
        await _hasColumn('flashcard_progress', 'review_count') &&
        await _hasColumn('flashcard_progress', 'lapse_count') &&
        await _hasColumn('flashcard_progress', 'last_result') &&
        await _hasColumn('flashcard_progress', 'created_at') &&
        await _hasColumn('flashcard_progress', 'updated_at');
  }

  Future<void> _resetLegacyStudyTablesIfNeeded(Migrator migrator) async {
    if (!await _needsStudyTableReset()) {
      return;
    }

    await customStatement('DROP TABLE IF EXISTS study_attempts');
    await customStatement('DROP TABLE IF EXISTS study_session_items');
    await customStatement('DROP TABLE IF EXISTS study_sessions');
    await migrator.createTable(studySessions);
    await migrator.createTable(studySessionItems);
    await migrator.createTable(studyAttempts);
  }

  Future<void> _normalizeStudyAttemptResultsForSchemaV4(
    Migrator migrator,
  ) async {
    if (!await _hasTable('study_attempts')) {
      await migrator.createTable(studyAttempts);
      return;
    }

    final tableSql = await _tableSql('study_attempts') ?? '';
    if (!tableSql.contains("'remembered'") && !tableSql.contains("'forgot'")) {
      await customStatement('''
        UPDATE study_attempts
        SET result = CASE result
          WHEN 'remembered' THEN 'correct'
          WHEN 'forgot' THEN 'incorrect'
          ELSE result
        END
        ''');
      return;
    }

    await customStatement('PRAGMA foreign_keys = OFF');
    await customStatement(
      'ALTER TABLE study_attempts RENAME TO study_attempts_legacy',
    );
    await migrator.createTable(studyAttempts);
    await customStatement('''
      INSERT INTO study_attempts (
        id,
        session_id,
        session_item_id,
        flashcard_id,
        attempt_number,
        result,
        old_box,
        new_box,
        next_due_at,
        answered_at
      )
      SELECT
        id,
        session_id,
        session_item_id,
        flashcard_id,
        attempt_number,
        CASE result
          WHEN 'remembered' THEN 'correct'
          WHEN 'forgot' THEN 'incorrect'
          ELSE result
        END,
        old_box,
        new_box,
        next_due_at,
        answered_at
      FROM study_attempts_legacy
      ''');
    await customStatement('DROP TABLE study_attempts_legacy');
    await customStatement('PRAGMA foreign_keys = ON');
  }

  Future<void> _allowInitialPassedReviewResultForSchemaV5(
    Migrator migrator,
  ) async {
    if (!await _hasTable('flashcard_progress')) {
      await migrator.createTable(flashcardProgress);
      return;
    }

    final tableSql = await _tableSql('flashcard_progress') ?? '';
    if (!tableSql.contains("'initial_passed'")) {
      await customStatement(
        'DROP INDEX IF EXISTS idx_flashcard_progress_due_at',
      );
      await customStatement(
        'DROP INDEX IF EXISTS idx_flashcard_progress_last_studied_at',
      );
      await customStatement(
        'ALTER TABLE flashcard_progress RENAME TO flashcard_progress_legacy',
      );
      await migrator.createTable(flashcardProgress);
      await customStatement('''
        INSERT INTO flashcard_progress (
          flashcard_id,
          current_box,
          review_count,
          lapse_count,
          last_result,
          last_studied_at,
          due_at,
          created_at,
          updated_at
        )
        SELECT
          flashcard_id,
          current_box,
          review_count,
          lapse_count,
          last_result,
          last_studied_at,
          due_at,
          created_at,
          updated_at
        FROM flashcard_progress_legacy
        ''');
      await customStatement('DROP TABLE flashcard_progress_legacy');
    }
    await _migrateLegacyNewStudyPerfectResultsForSchemaV5();
  }

  Future<void> _migrateLegacyNewStudyPerfectResultsForSchemaV5() async {
    if (!await _hasTable('study_sessions') ||
        !await _hasTable('study_attempts') ||
        !await _hasColumn('study_sessions', 'study_type') ||
        !await _hasColumn('study_sessions', 'status') ||
        !await _hasColumn('study_attempts', 'flashcard_id') ||
        !await _hasColumn('study_attempts', 'new_box') ||
        !await _hasColumn('study_attempts', 'next_due_at')) {
      return;
    }

    await customStatement('''
      UPDATE flashcard_progress
      SET last_result = 'initial_passed'
      WHERE last_result = 'perfect'
        AND current_box = 2
        AND due_at IS NOT NULL
        AND EXISTS (
          SELECT 1
          FROM study_attempts AS attempts
          INNER JOIN study_sessions AS sessions
            ON sessions.id = attempts.session_id
          WHERE attempts.flashcard_id = flashcard_progress.flashcard_id
            AND sessions.study_type = 'new'
            AND sessions.status = 'completed'
            AND attempts.new_box = flashcard_progress.current_box
            AND attempts.next_due_at = flashcard_progress.due_at
        )
        AND NOT EXISTS (
          SELECT 1
          FROM study_attempts AS attempts
          INNER JOIN study_sessions AS sessions
            ON sessions.id = attempts.session_id
          WHERE attempts.flashcard_id = flashcard_progress.flashcard_id
            AND sessions.study_type = 'srs_review'
            AND sessions.status = 'completed'
            AND attempts.new_box = flashcard_progress.current_box
            AND attempts.next_due_at = flashcard_progress.due_at
        )
      ''');
  }

  Future<void> _repairMissingFlashcardProgressForSchemaV6(
    Migrator migrator,
  ) async {
    if (!await _hasTable('flashcards')) {
      return;
    }
    if (!await _hasTable('flashcard_progress')) {
      await migrator.createTable(flashcardProgress);
    }
    if (!await _hasColumn('flashcards', 'created_at') ||
        !await _hasColumn('flashcards', 'updated_at')) {
      return;
    }

    await customStatement('''
      INSERT INTO flashcard_progress (
        flashcard_id,
        current_box,
        review_count,
        lapse_count,
        last_result,
        last_studied_at,
        due_at,
        created_at,
        updated_at
      )
      SELECT
        flashcards.id,
        1,
        0,
        0,
        NULL,
        NULL,
        NULL,
        flashcards.created_at,
        flashcards.updated_at
      FROM flashcards
      LEFT JOIN flashcard_progress
        ON flashcard_progress.flashcard_id = flashcards.id
      WHERE flashcard_progress.flashcard_id IS NULL
      ''');
  }

  Future<bool> _needsStudyTableReset() async {
    if (!await _hasTable('study_sessions') ||
        !await _hasTable('study_session_items') ||
        !await _hasTable('study_attempts')) {
      return true;
    }
    if (await _hasColumn('study_sessions', 'study_mode')) {
      return true;
    }
    if (!await _hasColumn('study_sessions', 'study_flow')) {
      return true;
    }
    if (!await _hasColumn('study_session_items', 'study_mode')) {
      return true;
    }
    if (!await _hasColumn('study_session_items', 'mode_order')) {
      return true;
    }
    return !await _hasColumn('study_attempts', 'attempt_number');
  }

  Future<void> _migrateFlashcardsForSchemaV3(Migrator migrator) async {
    if (!await _hasTable('flashcards')) {
      await migrator.createTable(flashcards);
      return;
    }

    if (!await _hasRequiredFlashcardColumns()) {
      await _dropAndCreateFlashcardContentTables(migrator);
      return;
    }

    if (!await _hasColumn('flashcards', 'title')) {
      return;
    }

    // ignore: experimental_member_use
    await migrator.alterTable(TableMigration(flashcards));
  }

  Future<bool> _hasRequiredFlashcardColumns() async {
    return await _hasColumn('flashcards', 'id') &&
        await _hasColumn('flashcards', 'deck_id') &&
        await _hasColumn('flashcards', 'front') &&
        await _hasColumn('flashcards', 'back') &&
        await _hasColumn('flashcards', 'note') &&
        await _hasColumn('flashcards', 'sort_order') &&
        await _hasColumn('flashcards', 'created_at') &&
        await _hasColumn('flashcards', 'updated_at');
  }

  Future<void> _dropAndCreateFlashcardContentTables(Migrator migrator) async {
    await customStatement('PRAGMA foreign_keys = OFF');
    await customStatement('DROP TABLE IF EXISTS study_attempts');
    await customStatement('DROP TABLE IF EXISTS study_session_items');
    await customStatement('DROP TABLE IF EXISTS study_sessions');
    await customStatement('DROP TABLE IF EXISTS flashcard_progress');
    await customStatement(
      'DROP INDEX IF EXISTS idx_flashcards_deck_sort_order',
    );
    await customStatement('DROP TABLE IF EXISTS flashcards');
    await migrator.createTable(flashcards);
    await migrator.createTable(flashcardProgress);
    await migrator.createTable(studySessions);
    await migrator.createTable(studySessionItems);
    await migrator.createTable(studyAttempts);
    await customStatement('PRAGMA foreign_keys = ON');
  }

  Future<bool> _hasTable(String tableName) async {
    final row = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: <Variable<String>>[Variable<String>(tableName)],
    ).getSingleOrNull();
    return row != null;
  }

  Future<bool> _hasColumn(String tableName, String columnName) async {
    final rows = await customSelect('PRAGMA table_info($tableName)').get();
    return rows.any((row) => row.read<String>('name') == columnName);
  }

  Future<String?> _tableSql(String tableName) async {
    final row = await customSelect(
      "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: <Variable<String>>[Variable<String>(tableName)],
    ).getSingleOrNull();
    return row?.read<String>('sql');
  }

  static const List<String> _indexStatements = <String>[
    'CREATE INDEX IF NOT EXISTS idx_folders_parent_id ON folders (parent_id)',
    'CREATE INDEX IF NOT EXISTS idx_folders_parent_sort_order ON folders (parent_id, sort_order)',
    'CREATE INDEX IF NOT EXISTS idx_decks_folder_sort_order ON decks (folder_id, sort_order)',
    'CREATE INDEX IF NOT EXISTS idx_flashcards_deck_sort_order ON flashcards (deck_id, sort_order)',
    'CREATE INDEX IF NOT EXISTS idx_flashcard_progress_due_at ON flashcard_progress (due_at)',
    'CREATE INDEX IF NOT EXISTS idx_flashcard_progress_last_studied_at ON flashcard_progress (last_studied_at)',
    'CREATE INDEX IF NOT EXISTS idx_study_sessions_status_started_at ON study_sessions (status, started_at DESC)',
    'CREATE INDEX IF NOT EXISTS idx_study_sessions_entry_resume ON study_sessions (entry_type, entry_ref_id, status, started_at DESC)',
    'CREATE INDEX IF NOT EXISTS idx_study_session_items_queue ON study_session_items (session_id, status, mode_order, round_index, queue_position)',
    'CREATE INDEX IF NOT EXISTS idx_study_session_items_mode_round ON study_session_items (session_id, study_mode, mode_order, round_index)',
    'CREATE INDEX IF NOT EXISTS idx_study_attempts_session_answered_at ON study_attempts (session_id, answered_at DESC)',
    'CREATE INDEX IF NOT EXISTS idx_study_attempts_item ON study_attempts (session_item_id)',
  ];
}
