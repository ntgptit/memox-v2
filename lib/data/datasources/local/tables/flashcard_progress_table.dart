// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../database_schema_support.dart';
import 'flashcards_table.dart';

class FlashcardProgress extends Table {
  @override
  String get tableName => 'flashcard_progress';

  TextColumn get flashcardId => text()
      .named('flashcard_id')
      .references(Flashcards, #id, onDelete: KeyAction.cascade)();

  IntColumn get currentBox =>
      integer().named('current_box').check(currentBox.isBetweenValues(1, 8))();

  IntColumn get reviewCount => integer()
      .named('review_count')
      .check(reviewCount.isBiggerOrEqualValue(0))();

  IntColumn get lapseCount => integer()
      .named('lapse_count')
      .check(lapseCount.isBiggerOrEqualValue(0))();

  TextColumn get lastResult => text()
      .named('last_result')
      .nullable()
      .check(
        lastResult.isNull() |
            lastResult.isIn(DatabaseEnumValues.rawStudyResults),
      )();

  IntColumn get lastStudiedAt =>
      integer().named('last_studied_at').nullable()();

  IntColumn get dueAt => integer().named('due_at').nullable()();

  IntColumn get createdAt => integer().named('created_at')();

  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column> get primaryKey => <Column>{flashcardId};
}
