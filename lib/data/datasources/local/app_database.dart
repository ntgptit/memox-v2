import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../../core/constants/app_constants.dart';
import 'database_schema_support.dart';
import 'tables/decks_table.dart';
import 'tables/flashcard_progress_table.dart';
import 'tables/flashcard_tags_table.dart';
import 'tables/flashcards_table.dart';
import 'tables/folders_table.dart';
import 'tables/study_attempts_table.dart';
import 'tables/study_session_items_table.dart';
import 'tables/study_sessions_table.dart';
import 'tables/tts_settings_records_table.dart';

part 'app_database.g.dart';
part 'migrations/app_database_migrations.dart';

@DriftDatabase(
  tables: <Type>[
    Folders,
    Decks,
    Flashcards,
    FlashcardProgress,
    FlashcardTags,
    StudySessions,
    StudySessionItems,
    StudyAttempts,
    TtsSettingsRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  static const int currentSchemaVersion = 9;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
      await _createSchemaIndexes(migrator);
    },
    onUpgrade: (Migrator migrator, int from, int to) async {
      await _runSchemaMigrations(this, migrator, from);
      await _createSchemaIndexes(migrator);
    },
    beforeOpen: (OpeningDetails details) async {
      await _enableForeignKeys(this);
      await _createSchemaIndexes(Migrator(this));
    },
  );

  Future<void> ensureOpen() async {
    await customSelect('SELECT 1 AS ready').getSingle();
  }

  static QueryExecutor _openConnection() => driftDatabase(
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
