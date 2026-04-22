// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../database_schema_support.dart';

class StudySessions extends Table {
  @override
  String get tableName => 'study_sessions';

  TextColumn get id => text()();

  TextColumn get entryType => text()
      .named('entry_type')
      .check(entryType.isIn(DatabaseEnumValues.studyEntryTypes))();

  TextColumn get entryRefId => text().named('entry_ref_id').nullable()();

  TextColumn get studyType => text()
      .named('study_type')
      .check(studyType.isIn(DatabaseEnumValues.studyTypes))();

  TextColumn get studyMode => text()
      .named('study_mode')
      .check(studyMode.isIn(DatabaseEnumValues.studyModes))();

  IntColumn get batchSize =>
      integer().named('batch_size').check(batchSize.isBiggerOrEqualValue(1))();

  IntColumn get shuffleFlashcards => integer()
      .named('shuffle_flashcards')
      .check(shuffleFlashcards.isIn(const <int>[0, 1]))();

  IntColumn get shuffleAnswers => integer()
      .named('shuffle_answers')
      .check(shuffleAnswers.isIn(const <int>[0, 1]))();

  IntColumn get prioritizeOverdue => integer()
      .named('prioritize_overdue')
      .check(prioritizeOverdue.isIn(const <int>[0, 1]))();

  TextColumn get status =>
      text().check(status.isIn(DatabaseEnumValues.sessionStatuses))();

  IntColumn get startedAt => integer().named('started_at')();

  IntColumn get endedAt => integer().named('ended_at').nullable()();

  TextColumn get restartedFromSessionId => text()
      .named('restarted_from_session_id')
      .nullable()
      .references(StudySessions, #id)();

  @override
  Set<Column> get primaryKey => <Column>{id};

  @override
  List<String> get customConstraints => const <String>[
    'CHECK (ended_at IS NULL OR ended_at >= started_at)',
    "CHECK ((entry_type = 'today' AND entry_ref_id IS NULL) OR (entry_type IN ('deck', 'folder') AND entry_ref_id IS NOT NULL))",
    "CHECK ((status = 'in_progress' AND ended_at IS NULL) OR (status != 'in_progress' AND ended_at IS NOT NULL))",
    'CHECK (restarted_from_session_id IS NULL OR restarted_from_session_id != id)',
  ];
}
