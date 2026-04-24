import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/enums/content_sort_mode.dart';
import 'package:memox/domain/value_objects/content_actions.dart';
import 'package:memox/domain/value_objects/content_queries.dart';

import '../../support/content_repository_harness.dart';

void main() {
  group('content repositories', () {
    late ContentRepositoryHarness harness;

    setUp(() {
      harness = ContentRepositoryHarness.create(
        ids: <String>[
          'folder-root-a',
          'folder-child-a',
          'folder-root-b',
          'deck-a',
          'deck-b',
          'flashcard-a',
          'flashcard-b',
          'flashcard-c',
          'flashcard-d',
          'duplicate-deck',
          'duplicate-card-1',
          'duplicate-card-2',
        ],
      );
    });

    tearDown(() async {
      await harness.dispose();
    });

    test(
      'creating a subfolder in an unlocked folder locks it to subfolders',
      () async {
        final root = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final rootId = root.valueOrNull!.id;

        final child = await harness.folderRepository.createSubfolder(
          parentFolderId: rootId,
          name: 'Japanese',
        );

        expect(child.isSuccess, isTrue);

        final storedRoot = await (harness.database.select(
          harness.database.folders,
        )..where((table) => table.id.equals(rootId))).getSingle();
        expect(storedRoot.contentMode, 'subfolders');
      },
    );

    test('creating a deck in an unlocked folder locks it to decks', () async {
      final root = await harness.folderRepository.createRootFolder('Languages');
      final rootId = root.valueOrNull!.id;

      final deck = await harness.deckRepository.createDeck(
        folderId: rootId,
        name: 'N5 Core',
      );

      expect(deck.isSuccess, isTrue);

      final storedRoot = await (harness.database.select(
        harness.database.folders,
      )..where((table) => table.id.equals(rootId))).getSingle();
      expect(storedRoot.contentMode, 'decks');
    });

    test(
      'deleting the last subfolder resets parent folder mode to unlocked',
      () async {
        final root = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final rootId = root.valueOrNull!.id;
        final child = await harness.folderRepository.createSubfolder(
          parentFolderId: rootId,
          name: 'Japanese',
        );

        final result = await harness.folderRepository.deleteFolder(
          child.valueOrNull!.id,
        );

        expect(result.isSuccess, isTrue);

        final storedRoot = await (harness.database.select(
          harness.database.folders,
        )..where((table) => table.id.equals(rootId))).getSingle();
        expect(storedRoot.contentMode, 'unlocked');
      },
    );

    test('moving a folder into its descendant is rejected', () async {
      final root = await harness.folderRepository.createRootFolder('Languages');
      final rootId = root.valueOrNull!.id;
      final child = await harness.folderRepository.createSubfolder(
        parentFolderId: rootId,
        name: 'Japanese',
      );

      final moveResult = await harness.folderRepository.moveFolder(
        folderId: rootId,
        targetParentId: child.valueOrNull!.id,
      );

      expect(moveResult.isFailure, isTrue);
    });

    test(
      'moving the last deck resets source folder and preserves flashcard progress',
      () async {
        final sourceFolder = await harness.folderRepository.createRootFolder(
          'Source',
        );
        final targetFolder = await harness.folderRepository.createRootFolder(
          'Target',
        );
        final sourceFolderId = sourceFolder.valueOrNull!.id;
        final targetFolderId = targetFolder.valueOrNull!.id;
        final deck = await harness.deckRepository.createDeck(
          folderId: sourceFolderId,
          name: 'Deck A',
        );
        final deckId = deck.valueOrNull!.id;

        final flashcard = await harness.flashcardRepository.createFlashcard(
          deckId: deckId,
          draft: const FlashcardDraft(
            title: 'Greeting',
            front: 'hello',
            back: 'xin chao',
          ),
        );

        final flashcardId = flashcard.valueOrNull!.id;
        await (harness.database.update(
          harness.database.flashcardProgress,
        )..where((table) => table.flashcardId.equals(flashcardId))).write(
          const FlashcardProgressCompanion(
            currentBox: Value(5),
            reviewCount: Value(12),
            lapseCount: Value(1),
            lastStudiedAt: Value(1713859200000),
            dueAt: Value(1713945600000),
          ),
        );

        final moveResult = await harness.deckRepository.moveDeck(
          deckId: deckId,
          targetFolderId: targetFolderId,
        );

        expect(moveResult.isSuccess, isTrue);

        final sourceStored = await (harness.database.select(
          harness.database.folders,
        )..where((table) => table.id.equals(sourceFolderId))).getSingle();
        final targetStored = await (harness.database.select(
          harness.database.folders,
        )..where((table) => table.id.equals(targetFolderId))).getSingle();
        final progressStored = await (harness.database.select(
          harness.database.flashcardProgress,
        )..where((table) => table.flashcardId.equals(flashcardId))).getSingle();
        final deckStored = await (harness.database.select(
          harness.database.decks,
        )..where((table) => table.id.equals(deckId))).getSingle();

        expect(sourceStored.contentMode, 'unlocked');
        expect(targetStored.contentMode, 'decks');
        expect(deckStored.folderId, targetFolderId);
        expect(progressStored.currentBox, 5);
        expect(progressStored.reviewCount, 12);
        expect(progressStored.dueAt, 1713945600000);
      },
    );

    test('duplicating a deck copies content and resets progress', () async {
      final folder = await harness.folderRepository.createRootFolder(
        'Languages',
      );
      final folderId = folder.valueOrNull!.id;
      final deck = await harness.deckRepository.createDeck(
        folderId: folderId,
        name: 'Deck A',
      );
      final deckId = deck.valueOrNull!.id;

      final first = await harness.flashcardRepository.createFlashcard(
        deckId: deckId,
        draft: const FlashcardDraft(front: 'hello', back: 'xin chao'),
      );
      final second = await harness.flashcardRepository.createFlashcard(
        deckId: deckId,
        draft: const FlashcardDraft(front: 'bye', back: 'tam biet'),
      );

      for (final flashcardId in <String>[
        first.valueOrNull!.id,
        second.valueOrNull!.id,
      ]) {
        await (harness.database.update(
          harness.database.flashcardProgress,
        )..where((table) => table.flashcardId.equals(flashcardId))).write(
          const FlashcardProgressCompanion(
            currentBox: Value(6),
            reviewCount: Value(20),
            lapseCount: Value(2),
            lastStudiedAt: Value(1713859200000),
            dueAt: Value(1713945600000),
          ),
        );
      }

      final duplicate = await harness.deckRepository.duplicateDeck(
        deckId: deckId,
        targetFolderId: folderId,
      );

      expect(duplicate.isSuccess, isTrue);

      final duplicatedDeckId = duplicate.valueOrNull!.id;
      final duplicatedCards = await (harness.database.select(
        harness.database.flashcards,
      )..where((table) => table.deckId.equals(duplicatedDeckId))).get();

      expect(duplicatedCards, hasLength(2));

      for (final card in duplicatedCards) {
        final progress = await (harness.database.select(
          harness.database.flashcardProgress,
        )..where((table) => table.flashcardId.equals(card.id))).getSingle();
        expect(progress.currentBox, 1);
        expect(progress.reviewCount, 0);
        expect(progress.lastStudiedAt, isNull);
        expect(progress.dueAt, isNull);
      }
    });

    test(
      'sort by last studied pushes never-studied flashcards to the end',
      () async {
        final folder = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final deck = await harness.deckRepository.createDeck(
          folderId: folder.valueOrNull!.id,
          name: 'Deck A',
        );
        final deckId = deck.valueOrNull!.id;

        final first = await harness.flashcardRepository.createFlashcard(
          deckId: deckId,
          draft: const FlashcardDraft(front: 'one', back: 'mot'),
        );
        final second = await harness.flashcardRepository.createFlashcard(
          deckId: deckId,
          draft: const FlashcardDraft(front: 'two', back: 'hai'),
        );
        final third = await harness.flashcardRepository.createFlashcard(
          deckId: deckId,
          draft: const FlashcardDraft(front: 'three', back: 'ba'),
        );

        await (harness.database.update(harness.database.flashcardProgress)
              ..where(
                (table) => table.flashcardId.equals(first.valueOrNull!.id),
              ))
            .write(
              const FlashcardProgressCompanion(lastStudiedAt: Value(2000)),
            );
        await (harness.database.update(harness.database.flashcardProgress)
              ..where(
                (table) => table.flashcardId.equals(second.valueOrNull!.id),
              ))
            .write(
              const FlashcardProgressCompanion(lastStudiedAt: Value(5000)),
            );

        final list = await harness.flashcardRepository.getFlashcards(
          deckId,
          const ContentQuery(sortMode: ContentSortMode.lastStudied),
        );

        expect(list.items.map((item) => item.flashcard.id).toList(), <String>[
          second.valueOrNull!.id,
          first.valueOrNull!.id,
          third.valueOrNull!.id,
        ]);
      },
    );

    test(
      'import with mixed valid and invalid lines does not write any flashcards',
      () async {
        final folder = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final deck = await harness.deckRepository.createDeck(
          folderId: folder.valueOrNull!.id,
          name: 'Deck A',
        );
        final deckId = deck.valueOrNull!.id;

        final preparation = await harness.flashcardRepository.prepareImport(
          format: ImportSourceFormat.csv,
          rawContent: 'title,front,back\nGreeting,hello,xin chao\nBroken,,',
        );

        expect(preparation.isSuccess, isTrue);
        expect(preparation.valueOrNull!.hasIssues, isTrue);

        final commit = await harness.flashcardRepository.commitImport(
          deckId: deckId,
          preparation: preparation.valueOrNull!,
        );

        expect(commit.isFailure, isTrue);

        final flashcards = await (harness.database.select(
          harness.database.flashcards,
        )..where((table) => table.deckId.equals(deckId))).get();
        expect(flashcards, isEmpty);
      },
    );

    test(
      'bulk move 200 flashcards stays transaction-safe and preserves progress',
      () async {
        final sourceFolder = await harness.folderRepository.createRootFolder(
          'Source',
        );
        final targetFolder = await harness.folderRepository.createRootFolder(
          'Target',
        );
        final sourceDeck = await harness.deckRepository.createDeck(
          folderId: sourceFolder.valueOrNull!.id,
          name: 'Deck A',
        );
        final targetDeck = await harness.deckRepository.createDeck(
          folderId: targetFolder.valueOrNull!.id,
          name: 'Deck B',
        );

        final sourceDeckId = sourceDeck.valueOrNull!.id;
        final targetDeckId = targetDeck.valueOrNull!.id;
        final flashcardIds = <String>[];

        for (var index = 0; index < 200; index++) {
          final created = await harness.flashcardRepository.createFlashcard(
            deckId: sourceDeckId,
            draft: FlashcardDraft(front: 'front-$index', back: 'back-$index'),
          );
          flashcardIds.add(created.valueOrNull!.id);
        }

        final moveResult = await harness.flashcardRepository.moveFlashcards(
          flashcardIds: flashcardIds,
          targetDeckId: targetDeckId,
        );

        expect(moveResult.isSuccess, isTrue);

        final movedCards = await (harness.database.select(
          harness.database.flashcards,
        )..where((table) => table.deckId.equals(targetDeckId))).get();
        final remainingCards = await (harness.database.select(
          harness.database.flashcards,
        )..where((table) => table.deckId.equals(sourceDeckId))).get();
        final progressRows = await (harness.database.select(
          harness.database.flashcardProgress,
        )..where((table) => table.flashcardId.isIn(flashcardIds))).get();

        expect(movedCards, hasLength(200));
        expect(remainingCards, isEmpty);
        expect(progressRows, hasLength(200));
      },
    );
  });
}
