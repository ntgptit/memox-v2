// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import 'decks_table.dart';

class Flashcards extends Table {
  @override
  String get tableName => 'flashcards';

  TextColumn get id => text()();

  TextColumn get deckId => text()
      .named('deck_id')
      .references(Decks, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text().nullable().check(
    title.isNull() | title.trim().length.isBiggerOrEqualValue(1),
  )();

  TextColumn get front =>
      text().check(front.trim().length.isBiggerOrEqualValue(1))();

  TextColumn get back =>
      text().check(back.trim().length.isBiggerOrEqualValue(1))();

  TextColumn get note => text().nullable()();

  IntColumn get sortOrder =>
      integer().named('sort_order').check(sortOrder.isBiggerOrEqualValue(0))();

  IntColumn get createdAt => integer().named('created_at')();

  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column> get primaryKey => <Column>{id};
}
