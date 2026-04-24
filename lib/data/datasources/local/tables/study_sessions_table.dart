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

  TextColumn get studyFlow => text()
      .named('study_flow')
      .check(studyFlow.isIn(DatabaseEnumValues.studyFlows))();

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
    "CHECK ((status IN ('draft', 'in_progress') AND ended_at IS NULL) OR (status IN ('ready_to_finalize', 'completed', 'failed_to_finalize', 'cancelled')))",
    "CHECK ((study_type = 'new' AND study_flow = 'new_full_cycle') OR (study_type = 'srs_review' AND study_flow = 'srs_fill_review'))",
    'CHECK (restarted_from_session_id IS NULL OR restarted_from_session_id != id)',
  ];
}
