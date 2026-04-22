// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../database_schema_support.dart';

class Folders extends Table {
  @override
  String get tableName => 'folders';

  TextColumn get id => text()();

  TextColumn get parentId => text()
      .named('parent_id')
      .nullable()
      .references(Folders, #id, onDelete: KeyAction.cascade)();

  TextColumn get name =>
      text().check(name.trim().length.isBiggerOrEqualValue(1))();

  TextColumn get contentMode => text()
      .named('content_mode')
      .check(contentMode.isIn(DatabaseEnumValues.folderContentModes))();

  IntColumn get sortOrder =>
      integer().named('sort_order').check(sortOrder.isBiggerOrEqualValue(0))();

  IntColumn get createdAt => integer().named('created_at')();

  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column> get primaryKey => <Column>{id};

  @override
  List<String> get customConstraints => const <String>[
    'CHECK (parent_id IS NULL OR parent_id != id)',
  ];
}
