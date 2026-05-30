import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Schema v11: existing `flashcard_tags` rows are lowercased and de-duplicated
/// per card on upgrade, without touching the cards themselves.
void main() {
  test('v11 migration lowercases + dedupes tags and preserves cards', () async {
    final dir = Directory.systemTemp.createTempSync('memox_tag_migration');
    final file = File('${dir.path}/memox.sqlite');
    addTearDown(() {
      try {
        if (dir.existsSync()) dir.deleteSync(recursive: true);
      } on FileSystemException {
        // Windows can briefly hold the sqlite file handle after close.
      }
    });

    // First open builds the current schema. Seed a card plus legacy
    // un-normalized tag rows (the composite PK lets case variants coexist),
    // then pin user_version back to 10 to force the 10 -> 11 upgrade on reopen.
    final db1 = AppDatabase(executor: NativeDatabase(file));
    await db1.ensureOpen();
    await db1.customStatement(
      'INSERT INTO folders (id, name, content_mode, sort_order, created_at, '
      "updated_at) VALUES ('f', 'Folder', 'decks', 0, 0, 0)",
    );
    await db1.customStatement(
      'INSERT INTO decks (id, folder_id, name, sort_order, created_at, '
      "updated_at) VALUES ('d', 'f', 'Deck', 0, 0, 0)",
    );
    await db1.customStatement(
      'INSERT INTO flashcards (id, deck_id, front, back, sort_order, '
      "created_at, updated_at) VALUES ('c', 'd', 'front', 'back', 0, 0, 0)",
    );
    await db1.customStatement(
      "INSERT INTO flashcard_tags (flashcard_id, tag) VALUES ('c', 'Verb')",
    );
    await db1.customStatement(
      "INSERT INTO flashcard_tags (flashcard_id, tag) VALUES ('c', 'verb')",
    );
    await db1.customStatement(
      "INSERT INTO flashcard_tags (flashcard_id, tag) VALUES ('c', 'NOUN')",
    );
    await db1.customStatement('PRAGMA user_version = 10');
    await db1.close();

    final db2 = AppDatabase(executor: NativeDatabase(file));
    addTearDown(db2.close);
    await db2.ensureOpen();

    final rows = await db2
        .customSelect('SELECT tag FROM flashcard_tags ORDER BY tag')
        .get();
    final tags = rows.map((row) => row.read<String>('tag')).toList();

    // 'Verb' + 'verb' collapse to a single 'verb'; 'NOUN' -> 'noun'.
    expect(tags, <String>['noun', 'verb']);

    final card = await db2
        .customSelect("SELECT front FROM flashcards WHERE id = 'c'")
        .getSingle();
    expect(card.read<String>('front'), 'front');
  });
}
