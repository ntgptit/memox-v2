// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../database_schema_support.dart';
import 'flashcards_table.dart';
import 'study_session_items_table.dart';
import 'study_sessions_table.dart';

class StudyAttempts extends Table {
  @override
  String get tableName => 'study_attempts';

  TextColumn get id => text()();

  TextColumn get sessionId => text()
      .named('session_id')
      .references(StudySessions, #id, onDelete: KeyAction.cascade)();

  TextColumn get sessionItemId => text()
      .named('session_item_id')
      .references(StudySessionItems, #id, onDelete: KeyAction.cascade)();

  TextColumn get flashcardId => text()
      .named('flashcard_id')
      .references(Flashcards, #id, onDelete: KeyAction.cascade)();

  IntColumn get attemptNumber => integer()
      .named('attempt_number')
      .check(attemptNumber.isBiggerOrEqualValue(1))();

  TextColumn get result =>
      text().check(result.isIn(DatabaseEnumValues.rawStudyResults))();

  IntColumn get oldBox => integer()
      .named('old_box')
      .nullable()
      .check(oldBox.isNull() | oldBox.isBetweenValues(1, 8))();

  IntColumn get newBox => integer()
      .named('new_box')
      .nullable()
      .check(newBox.isNull() | newBox.isBetweenValues(1, 8))();

  IntColumn get nextDueAt => integer().named('next_due_at').nullable()();

  IntColumn get answeredAt => integer().named('answered_at')();

  @override
  Set<Column> get primaryKey => <Column>{id};
}
