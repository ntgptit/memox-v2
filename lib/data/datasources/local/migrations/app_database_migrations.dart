// ignore_for_file: experimental_member_use

part of '../app_database.dart';

Future<void> _runSchemaMigrations(
  AppDatabase database,
  Migrator migrator,
  int from,
) async {
  final runner = _AppDatabaseMigrationRunner(database, migrator);
  await runner.run(from);
}

Future<void> _createSchemaIndexes(Migrator migrator) async {
  for (final index in _schemaIndexes) {
    await migrator.createIndex(index);
  }
}

Future<void> _enableForeignKeys(AppDatabase database) async {
  await database.customStatement(_Pragma.foreignKeysOn);
}

final class _AppDatabaseMigrationRunner {
  const _AppDatabaseMigrationRunner(this.database, this.migrator);

  final AppDatabase database;
  final Migrator migrator;

  Future<void> run(int from) async {
    if (from < 2) {
      await _rebuildLegacyFlashcardProgressIfNeeded();
      await _resetLegacyStudyTablesIfNeeded();
    }
    if (from < 3) {
      await _migrateFlashcardsForSchemaV3();
    }
    if (from < 4) {
      await _normalizeStudyAttemptResultsForSchemaV4();
    }
    if (from < 5) {
      await _allowInitialPassedReviewResultForSchemaV5();
    }
    if (from < 6) {
      await _repairMissingFlashcardProgressForSchemaV6();
    }
    if (from < 7) {
      await _addFlashcardAuthorFieldsForSchemaV7();
    }
    if (from < 8) {
      await _allowSingleModeStudyFlowsForSchemaV8();
    }
    if (from < 9) {
      await _createTtsSettingsForSchemaV9();
    }
    if (from < 10) {
      await _addBurySuspendColumnsForSchemaV10();
    }
    if (from < 11) {
      await _lowercaseFlashcardTagsForSchemaV11();
    }
    if (from < 12) {
      await _allowRecoveredStudyAttemptResultForSchemaV12();
    }
  }

  /// Schema v12: Fill hint/override attempts can be persisted as
  /// `recovered`, a passing-but-not-perfect grade.
  Future<void> _allowRecoveredStudyAttemptResultForSchemaV12() async {
    if (!await _hasTable(_TableName.studyAttempts)) {
      await migrator.createTable(database.studyAttempts);
      return;
    }
    final tableSql = await _tableSql(_TableName.studyAttempts) ?? '';
    if (!tableSql.contains("'recovered'")) {
      await _alterTable(TableMigration(database.studyAttempts));
    }
  }

  /// Schema v11: tags become case-insensitive with lowercased storage
  /// (`docs/business/tags/tag-system.md`). Collapse case-variant duplicates per
  /// card first, then lowercase the survivors. Card rows are untouched.
  Future<void> _lowercaseFlashcardTagsForSchemaV11() async {
    if (!await _hasTable(_TableName.flashcardTags)) {
      await migrator.createTable(database.flashcardTags);
      return;
    }
    await database.customStatement(_dedupeFlashcardTagsCaseVariantsSql);
    await database.customStatement(_lowercaseFlashcardTagsSql);
  }

  /// Schema v10: add `flashcard_progress.buried_until` (nullable) and
  /// `is_suspended` (default false). Both have safe defaults so existing
  /// progress rows stay valid. Spec: `docs/business/study-actions/bury-suspend.md`.
  Future<void> _addBurySuspendColumnsForSchemaV10() async {
    if (!await _hasTable(_TableName.flashcardProgress)) {
      await migrator.createTable(database.flashcardProgress);
      return;
    }
    if (!await _hasColumn(_TableName.flashcardProgress, 'buried_until')) {
      await migrator.addColumn(
        database.flashcardProgress,
        database.flashcardProgress.buriedUntil,
      );
    }
    if (!await _hasColumn(_TableName.flashcardProgress, 'is_suspended')) {
      await migrator.addColumn(
        database.flashcardProgress,
        database.flashcardProgress.isSuspended,
      );
    }
  }

  Future<void> _rebuildLegacyFlashcardProgressIfNeeded() async {
    if (!await _hasTable(_TableName.flashcardProgress)) {
      await migrator.createTable(database.flashcardProgress);
      return;
    }

    if (!await _hasRequiredFlashcardProgressColumns()) {
      await _dropFlashcardProgressIndexes();
      await migrator.deleteTable(_TableName.flashcardProgress);
      await migrator.createTable(database.flashcardProgress);
      return;
    }

    final tableSql = await _tableSql(_TableName.flashcardProgress) ?? '';
    if (!tableSql.contains("'correct'") && !tableSql.contains("'remembered'")) {
      return;
    }

    await _dropFlashcardProgressIndexes();
    await _alterTable(
      TableMigration(
        database.flashcardProgress,
        columnTransformer: <GeneratedColumn, Expression>{
          database.flashcardProgress.lastResult: const CustomExpression<String>(
            _legacyFlashcardProgressResultExpression,
          ),
        },
        newColumns: _flashcardProgressBurySuspendColumns(database),
      ),
    );
  }

  /// Columns introduced in schema v10. Declared as `newColumns` on any earlier
  /// `flashcard_progress` table-recreate migration so Drift fills their
  /// defaults instead of copying them from the (older) source table.
  static List<GeneratedColumn<Object>> _flashcardProgressBurySuspendColumns(
    AppDatabase database,
  ) => <GeneratedColumn<Object>>[
    database.flashcardProgress.buriedUntil,
    database.flashcardProgress.isSuspended,
  ];

  Future<bool> _hasRequiredFlashcardProgressColumns() async =>
      await _hasColumn(_TableName.flashcardProgress, 'current_box') &&
      await _hasColumn(_TableName.flashcardProgress, 'review_count') &&
      await _hasColumn(_TableName.flashcardProgress, 'lapse_count') &&
      await _hasColumn(_TableName.flashcardProgress, 'last_result') &&
      await _hasColumn(_TableName.flashcardProgress, 'created_at') &&
      await _hasColumn(_TableName.flashcardProgress, 'updated_at');

  Future<void> _resetLegacyStudyTablesIfNeeded() async {
    if (!await _needsStudyTableReset()) {
      return;
    }

    await _dropStudyTables();
    await migrator.createTable(database.studySessions);
    await migrator.createTable(database.studySessionItems);
    await migrator.createTable(database.studyAttempts);
  }

  Future<void> _normalizeStudyAttemptResultsForSchemaV4() async {
    if (!await _hasTable(_TableName.studyAttempts)) {
      await migrator.createTable(database.studyAttempts);
      return;
    }

    final tableSql = await _tableSql(_TableName.studyAttempts) ?? '';
    if (!tableSql.contains("'remembered'") && !tableSql.contains("'forgot'")) {
      await _normalizeLegacyStudyAttemptRows();
      return;
    }

    await _alterTable(
      TableMigration(
        database.studyAttempts,
        columnTransformer: <GeneratedColumn, Expression>{
          database.studyAttempts.result: const CustomExpression<String>(
            _legacyStudyAttemptResultExpression,
          ),
        },
      ),
    );
  }

  Future<void> _normalizeLegacyStudyAttemptRows() async {
    await (database.update(
          database.studyAttempts,
        )..where((table) => table.result.equals(_LegacyStudyResult.remembered)))
        .write(
          const StudyAttemptsCompanion(
            result: Value(_StudyAttemptResult.correct),
          ),
        );
    await (database.update(
      database.studyAttempts,
    )..where((table) => table.result.equals(_LegacyStudyResult.forgot))).write(
      const StudyAttemptsCompanion(
        result: Value(_StudyAttemptResult.incorrect),
      ),
    );
  }

  Future<void> _allowInitialPassedReviewResultForSchemaV5() async {
    if (!await _hasTable(_TableName.flashcardProgress)) {
      await migrator.createTable(database.flashcardProgress);
      return;
    }

    final tableSql = await _tableSql(_TableName.flashcardProgress) ?? '';
    if (!tableSql.contains("'initial_passed'")) {
      await _dropFlashcardProgressIndexes();
      await _alterTable(
        TableMigration(
          database.flashcardProgress,
          newColumns: _flashcardProgressBurySuspendColumns(database),
        ),
      );
    }
    await _migrateLegacyNewStudyPerfectResultsForSchemaV5();
  }

  Future<void> _migrateLegacyNewStudyPerfectResultsForSchemaV5() async {
    if (!await _hasTable(_TableName.studySessions) ||
        !await _hasTable(_TableName.studyAttempts) ||
        !await _hasColumn(_TableName.studySessions, 'study_type') ||
        !await _hasColumn(_TableName.studySessions, 'status') ||
        !await _hasColumn(_TableName.studyAttempts, 'flashcard_id') ||
        !await _hasColumn(_TableName.studyAttempts, 'new_box') ||
        !await _hasColumn(_TableName.studyAttempts, 'next_due_at')) {
      return;
    }

    await database.customStatement(_migrateLegacyNewStudyPerfectResultsSql);
  }

  Future<void> _addFlashcardAuthorFieldsForSchemaV7() async {
    await _ensureFlashcardAuthorColumns();
    if (!await _hasTable(_TableName.flashcardTags)) {
      await migrator.createTable(database.flashcardTags);
    }
  }

  Future<void> _allowSingleModeStudyFlowsForSchemaV8() async {
    if (!await _hasTable(_TableName.studySessions)) {
      await migrator.createTable(database.studySessions);
      return;
    }
    final tableSql = await _tableSql(_TableName.studySessions) ?? '';
    if (!tableSql.contains("'new_review_only'")) {
      await _alterTable(TableMigration(database.studySessions));
    }
  }

  Future<void> _createTtsSettingsForSchemaV9() async {
    if (!await _hasTable(_TableName.ttsSettings)) {
      await migrator.createTable(database.ttsSettingsRecords);
    }
  }

  Future<void> _ensureFlashcardAuthorColumns() async {
    if (!await _hasTable(_TableName.flashcards)) {
      await migrator.createTable(database.flashcards);
      return;
    }
    if (!await _hasColumn(_TableName.flashcards, 'example')) {
      await migrator.addColumn(
        database.flashcards,
        database.flashcards.example,
      );
    }
    if (!await _hasColumn(_TableName.flashcards, 'pronunciation')) {
      await migrator.addColumn(
        database.flashcards,
        database.flashcards.pronunciation,
      );
    }
    if (!await _hasColumn(_TableName.flashcards, 'hint')) {
      await migrator.addColumn(database.flashcards, database.flashcards.hint);
    }
  }

  Future<void> _repairMissingFlashcardProgressForSchemaV6() async {
    if (!await _hasTable(_TableName.flashcards)) {
      return;
    }
    if (!await _hasTable(_TableName.flashcardProgress)) {
      await migrator.createTable(database.flashcardProgress);
    }
    if (!await _hasColumn(_TableName.flashcards, 'created_at') ||
        !await _hasColumn(_TableName.flashcards, 'updated_at')) {
      return;
    }

    await database.customStatement(_repairMissingFlashcardProgressSql);
  }

  Future<bool> _needsStudyTableReset() async {
    if (!await _hasTable(_TableName.studySessions) ||
        !await _hasTable(_TableName.studySessionItems) ||
        !await _hasTable(_TableName.studyAttempts)) {
      return true;
    }
    if (await _hasColumn(_TableName.studySessions, 'study_mode')) {
      return true;
    }
    if (!await _hasColumn(_TableName.studySessions, 'study_flow')) {
      return true;
    }
    if (!await _hasColumn(_TableName.studySessionItems, 'study_mode')) {
      return true;
    }
    if (!await _hasColumn(_TableName.studySessionItems, 'mode_order')) {
      return true;
    }
    return !await _hasColumn(_TableName.studyAttempts, 'attempt_number');
  }

  Future<void> _migrateFlashcardsForSchemaV3() async {
    if (!await _hasTable(_TableName.flashcards)) {
      await migrator.createTable(database.flashcards);
      return;
    }

    if (!await _hasRequiredFlashcardColumns()) {
      await _dropAndCreateFlashcardContentTables();
      return;
    }

    if (!await _hasColumn(_TableName.flashcards, 'title')) {
      return;
    }

    await _alterTable(TableMigration(database.flashcards));
  }

  Future<bool> _hasRequiredFlashcardColumns() async =>
      await _hasColumn(_TableName.flashcards, 'id') &&
      await _hasColumn(_TableName.flashcards, 'deck_id') &&
      await _hasColumn(_TableName.flashcards, 'front') &&
      await _hasColumn(_TableName.flashcards, 'back') &&
      await _hasColumn(_TableName.flashcards, 'note') &&
      await _hasColumn(_TableName.flashcards, 'sort_order') &&
      await _hasColumn(_TableName.flashcards, 'created_at') &&
      await _hasColumn(_TableName.flashcards, 'updated_at');

  Future<void> _dropAndCreateFlashcardContentTables() async {
    await _runWithoutForeignKeys(() async {
      await _dropStudyTables();
      await migrator.deleteTable(_TableName.flashcardProgress);
      await migrator.drop(_SchemaIndex.flashcardsDeckSortOrder);
      await migrator.deleteTable(_TableName.flashcards);
      await migrator.createTable(database.flashcards);
      await migrator.createTable(database.flashcardProgress);
      await migrator.createTable(database.studySessions);
      await migrator.createTable(database.studySessionItems);
      await migrator.createTable(database.studyAttempts);
    });
  }

  Future<void> _dropStudyTables() async {
    await migrator.deleteTable(_TableName.studyAttempts);
    await migrator.deleteTable(_TableName.studySessionItems);
    await migrator.deleteTable(_TableName.studySessions);
  }

  Future<void> _dropFlashcardProgressIndexes() async {
    await migrator.drop(_SchemaIndex.flashcardProgressDueAt);
    await migrator.drop(_SchemaIndex.flashcardProgressLastStudiedAt);
  }

  Future<void> _alterTable(TableMigration migration) async {
    await _runWithoutForeignKeys(() async {
      await migrator.alterTable(migration);
    });
  }

  Future<void> _runWithoutForeignKeys(Future<void> Function() action) async {
    await database.customStatement(_Pragma.foreignKeysOff);
    try {
      await action();
    } finally {
      await database.customStatement(_Pragma.foreignKeysOn);
    }
  }

  Future<bool> _hasTable(String tableName) async {
    final row = await database
        .customSelect(
          _SchemaIntrospection.tableExistsSql,
          variables: <Variable<String>>[Variable<String>(tableName)],
        )
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> _hasColumn(String tableName, String columnName) async {
    final rows = await database
        .customSelect('PRAGMA table_info($tableName)')
        .get();
    return rows.any((row) => row.read<String>('name') == columnName);
  }

  Future<String?> _tableSql(String tableName) async {
    final row = await database
        .customSelect(
          _SchemaIntrospection.tableSqlSql,
          variables: <Variable<String>>[Variable<String>(tableName)],
        )
        .getSingleOrNull();
    return row?.read<String>('sql');
  }
}

abstract final class _TableName {
  const _TableName._();

  static const String flashcards = 'flashcards';
  static const String flashcardProgress = 'flashcard_progress';
  static const String flashcardTags = 'flashcard_tags';
  static const String studyAttempts = 'study_attempts';
  static const String studySessionItems = 'study_session_items';
  static const String studySessions = 'study_sessions';
  static const String ttsSettings = 'tts_settings';
}

abstract final class _Pragma {
  const _Pragma._();

  static const String foreignKeysOn = 'PRAGMA foreign_keys = ON';
  static const String foreignKeysOff = 'PRAGMA foreign_keys = OFF';
}

abstract final class _SchemaIntrospection {
  const _SchemaIntrospection._();

  static const String tableExistsSql =
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?";
  static const String tableSqlSql =
      "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = ?";
}

abstract final class _LegacyStudyResult {
  const _LegacyStudyResult._();

  static const String remembered = 'remembered';
  static const String forgot = 'forgot';
}

abstract final class _StudyAttemptResult {
  const _StudyAttemptResult._();

  static const String correct = 'correct';
  static const String incorrect = 'incorrect';
}
