// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../database_schema_support.dart';
import 'flashcards_table.dart';
import 'study_sessions_table.dart';

class StudySessionItems extends Table {
  @override
  String get tableName => 'study_session_items';

  TextColumn get id => text()();

  TextColumn get sessionId => text()
      .named('session_id')
      .references(StudySessions, #id, onDelete: KeyAction.cascade)();

  TextColumn get flashcardId => text()
      .named('flashcard_id')
      .references(Flashcards, #id, onDelete: KeyAction.cascade)();

  TextColumn get studyMode => text()
      .named('study_mode')
      .check(studyMode.isIn(DatabaseEnumValues.studyModes))();

  IntColumn get modeOrder =>
      integer().named('mode_order').check(modeOrder.isBiggerOrEqualValue(1))();

  IntColumn get roundIndex => integer()
      .named('round_index')
      .check(roundIndex.isBiggerOrEqualValue(1))();

  IntColumn get queuePosition => integer()
      .named('queue_position')
      .check(queuePosition.isBiggerOrEqualValue(1))();

  TextColumn get sourcePool => text()
      .named('source_pool')
      .check(sourcePool.isIn(DatabaseEnumValues.sessionItemSourcePools))();

  TextColumn get status =>
      text().check(status.isIn(DatabaseEnumValues.sessionItemStatuses))();

  IntColumn get completedAt => integer().named('completed_at').nullable()();

  @override
  Set<Column> get primaryKey => <Column>{id};

  @override
  List<String> get customConstraints => const <String>[
    "CHECK ((status = 'completed' AND completed_at IS NOT NULL) OR (status IN ('pending', 'abandoned') AND completed_at IS NULL))",
  ];
}
