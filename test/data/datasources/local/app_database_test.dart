import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase(executor: NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('creates the full schema v1', () async {
      final tableNames = await database
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .map((row) => row.read<String>('name'))
          .get();

      expect(
        tableNames,
        containsAll(<String>[
          'folders',
          'decks',
          'flashcards',
          'flashcard_progress',
          'study_sessions',
          'study_session_items',
          'study_attempts',
        ]),
      );
    });

    test('deleting a deck cascades to flashcards and progress', () async {
      final now = DateTime.utc(2026, 4, 22).millisecondsSinceEpoch;

      await database
          .into(database.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'folder-1',
              name: 'Languages',
              contentMode: 'decks',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await database
          .into(database.decks)
          .insert(
            DecksCompanion.insert(
              id: 'deck-1',
              folderId: 'folder-1',
              name: 'Korean Basics',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await database
          .into(database.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: 'card-1',
              deckId: 'deck-1',
              front: 'annyeonghaseyo',
              back: 'xin chao',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await database
          .into(database.flashcardProgress)
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: 'card-1',
              currentBox: 1,
              reviewCount: 0,
              lapseCount: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await (database.delete(
        database.decks,
      )..where((table) => table.id.equals('deck-1'))).go();

      final remainingFlashcards = await database
          .select(database.flashcards)
          .get();
      final remainingProgress = await database
          .select(database.flashcardProgress)
          .get();

      expect(remainingFlashcards, isEmpty);
      expect(remainingProgress, isEmpty);
    });
  });
}
