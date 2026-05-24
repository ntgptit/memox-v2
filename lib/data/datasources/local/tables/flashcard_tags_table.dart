// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import 'flashcards_table.dart';

/// Join table backing `FlashcardEntity.tags`.
///
/// Each (flashcardId, tag) pair is unique. Tag deletion cascades on flashcard
/// removal so we never leak orphan rows.
class FlashcardTags extends Table {
  @override
  String get tableName => 'flashcard_tags';

  TextColumn get flashcardId => text()
      .named('flashcard_id')
      .references(Flashcards, #id, onDelete: KeyAction.cascade)();

  TextColumn get tag => text().check(tag.trim().length.isBiggerOrEqualValue(1))();

  @override
  Set<Column> get primaryKey => <Column>{flashcardId, tag};
}
