// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import 'folders_table.dart';

class Decks extends Table {
  @override
  String get tableName => 'decks';

  TextColumn get id => text()();

  TextColumn get folderId => text()
      .named('folder_id')
      .references(Folders, #id, onDelete: KeyAction.cascade)();

  TextColumn get name =>
      text().check(name.trim().length.isBiggerOrEqualValue(1))();

  IntColumn get sortOrder =>
      integer().named('sort_order').check(sortOrder.isBiggerOrEqualValue(0))();

  IntColumn get createdAt => integer().named('created_at')();

  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column> get primaryKey => <Column>{id};
}
