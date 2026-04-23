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

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
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

  static const List<String> _indexStatements = <String>[
    'CREATE INDEX IF NOT EXISTS idx_folders_parent_id ON folders (parent_id)',
    'CREATE INDEX IF NOT EXISTS idx_folders_parent_sort_order ON folders (parent_id, sort_order)',
    'CREATE INDEX IF NOT EXISTS idx_decks_folder_sort_order ON decks (folder_id, sort_order)',
    'CREATE INDEX IF NOT EXISTS idx_flashcards_deck_sort_order ON flashcards (deck_id, sort_order)',
    'CREATE INDEX IF NOT EXISTS idx_flashcard_progress_due_at ON flashcard_progress (due_at)',
    'CREATE INDEX IF NOT EXISTS idx_flashcard_progress_last_studied_at ON flashcard_progress (last_studied_at)',
    'CREATE INDEX IF NOT EXISTS idx_study_sessions_status_started_at ON study_sessions (status, started_at DESC)',
    'CREATE INDEX IF NOT EXISTS idx_study_session_items_queue ON study_session_items (session_id, status, round_index, queue_position)',
    'CREATE INDEX IF NOT EXISTS idx_study_attempts_session_answered_at ON study_attempts (session_id, answered_at DESC)',
  ];
}
