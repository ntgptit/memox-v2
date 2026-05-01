import 'package:drift/drift.dart' show OrderingTerm, Value;
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
      'DT1 onInsert: creating a subfolder in an unlocked folder locks it to subfolders',
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

    test(
      'DT2 onInsert: creating a deck in an unlocked folder locks it to decks',
      () async {
        final root = await harness.folderRepository.createRootFolder(
          'Languages',
        );
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
      },
    );

    test(
      'DT4 onInsert: creating a deck in a subfolder-locked folder is rejected',
      () async {
        final root = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final rootId = root.valueOrNull!.id;
        await harness.folderRepository.createSubfolder(
          parentFolderId: rootId,
          name: 'Japanese',
        );

        final deck = await harness.deckRepository.createDeck(
          folderId: rootId,
          name: 'N5 Core',
        );

        expect(deck.isFailure, isTrue);

        final storedRoot = await (harness.database.select(
          harness.database.folders,
        )..where((table) => table.id.equals(rootId))).getSingle();
        final decks = await (harness.database.select(
          harness.database.decks,
        )..where((table) => table.folderId.equals(rootId))).get();

        expect(storedRoot.contentMode, 'subfolders');
        expect(decks, isEmpty);
      },
    );

    test(
      'DT5 onInsert: creating a subfolder in a deck-locked folder is rejected',
      () async {
        final root = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final rootId = root.valueOrNull!.id;
        await harness.deckRepository.createDeck(
          folderId: rootId,
          name: 'N5 Core',
        );

        final child = await harness.folderRepository.createSubfolder(
          parentFolderId: rootId,
          name: 'Japanese',
        );

        expect(child.isFailure, isTrue);

        final storedRoot = await (harness.database.select(
          harness.database.folders,
        )..where((table) => table.id.equals(rootId))).getSingle();
        final children = await (harness.database.select(
          harness.database.folders,
        )..where((table) => table.parentId.equals(rootId))).get();

        expect(storedRoot.contentMode, 'decks');
        expect(children, isEmpty);
      },
    );

    test(
      'DT6 onInsert: creating a manual flashcard trims content and initializes progress',
      () async {
        final folder = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final deck = await harness.deckRepository.createDeck(
          folderId: folder.valueOrNull!.id,
          name: 'Deck A',
        );

        final created = await harness.flashcardRepository.createFlashcard(
          deckId: deck.valueOrNull!.id,
          draft: const FlashcardDraft(
            front: '  hello  ',
            back: '  xin chao  ',
            note: '   ',
          ),
        );

        expect(created.isSuccess, isTrue);

        final card =
            await (harness.database.select(harness.database.flashcards)
                  ..where((table) => table.id.equals(created.valueOrNull!.id)))
                .getSingle();
        final progress = await (harness.database.select(
          harness.database.flashcardProgress,
        )..where((table) => table.flashcardId.equals(card.id))).getSingle();

        expect(card.front, 'hello');
        expect(card.back, 'xin chao');
        expect(card.note, isNull);
        expect(progress.currentBox, 1);
        expect(progress.reviewCount, 0);
        expect(progress.dueAt, isNull);
      },
    );

    test(
      'DT7 onInsert: committing a valid CSV import writes new cards in order',
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
          deckId: deckId,
          format: ImportSourceFormat.csv,
          rawContent: 'front,back,note\nhello,xin chao,\nbye,tam biet,note',
        );

        expect(preparation.isSuccess, isTrue);
        expect(preparation.valueOrNull!.canCommit, isTrue);

        final commit = await harness.flashcardRepository.commitImport(
          deckId: deckId,
          preparation: preparation.valueOrNull!,
        );

        expect(commit.valueOrNull, 2);

        final cards =
            await (harness.database.select(harness.database.flashcards)
                  ..where((table) => table.deckId.equals(deckId))
                  ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
                .get();
        final progressRows =
            await (harness.database.select(harness.database.flashcardProgress)
                  ..where(
                    (table) =>
                        table.flashcardId.isIn(cards.map((card) => card.id)),
                  ))
                .get();

        expect(cards.map((card) => card.front), <String>['hello', 'bye']);
        expect(cards.map((card) => card.back), <String>[
          'xin chao',
          'tam biet',
        ]);
        expect(progressRows.map((row) => row.currentBox), everyElement(1));
        expect(progressRows.map((row) => row.dueAt), everyElement(isNull));
      },
    );

    test(
      'DT8 onInsert: import skips exact file duplicates but keeps same front with different back',
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
          deckId: deckId,
          format: ImportSourceFormat.csv,
          rawContent:
              'front,back\nhello,xin chao\nhello,xin chao\nhello,greeting',
        );

        expect(preparation.isSuccess, isTrue);
        final value = preparation.valueOrNull!;
        expect(value.previewItems, hasLength(2));
        expect(value.previewItems.map((item) => item.draft.back), <String>[
          'xin chao',
          'greeting',
        ]);
        expect(value.skippedDuplicates, hasLength(1));
        expect(
          value.skippedDuplicates.single.source,
          FlashcardImportDuplicateSource.importFile,
        );
        expect(value.skippedDuplicates.single.sourceLabel, 'Line 3');

        final commit = await harness.flashcardRepository.commitImport(
          deckId: deckId,
          preparation: value,
        );

        expect(commit.valueOrNull, 2);

        final cards =
            await (harness.database.select(harness.database.flashcards)
                  ..where((table) => table.deckId.equals(deckId))
                  ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
                .get();

        expect(cards.map((card) => card.front), <String>['hello', 'hello']);
        expect(cards.map((card) => card.back), <String>[
          'xin chao',
          'greeting',
        ]);
      },
    );

    test(
      'DT9 onInsert: import skips exact deck duplicates but keeps same front with different back',
      () async {
        final folder = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final deck = await harness.deckRepository.createDeck(
          folderId: folder.valueOrNull!.id,
          name: 'Deck A',
        );
        final deckId = deck.valueOrNull!.id;
        await harness.flashcardRepository.createFlashcard(
          deckId: deckId,
          draft: const FlashcardDraft(front: 'hello', back: 'xin chao'),
        );

        final preparation = await harness.flashcardRepository.prepareImport(
          deckId: deckId,
          format: ImportSourceFormat.csv,
          rawContent: 'front,back\nhello,xin chao\nhello,greeting',
        );

        expect(preparation.isSuccess, isTrue);
        final value = preparation.valueOrNull!;
        expect(value.previewItems, hasLength(1));
        expect(value.previewItems.single.draft.back, 'greeting');
        expect(value.skippedDuplicates, hasLength(1));
        expect(
          value.skippedDuplicates.single.source,
          FlashcardImportDuplicateSource.deck,
        );
        expect(value.skippedDuplicates.single.sourceLabel, 'Line 2');

        final commit = await harness.flashcardRepository.commitImport(
          deckId: deckId,
          preparation: value,
        );

        expect(commit.valueOrNull, 1);

        final cards =
            await (harness.database.select(harness.database.flashcards)
                  ..where((table) => table.deckId.equals(deckId))
                  ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
                .get();

        expect(cards.map((card) => card.back), <String>[
          'xin chao',
          'greeting',
        ]);
      },
    );

    test(
      'DT1 onDelete: deleting the last subfolder resets parent folder mode to unlocked',
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

    test(
      'DT2 onDelete: deleting the last deck cascades flashcards and unlocks the parent',
      () async {
        final folder = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final folderId = folder.valueOrNull!.id;
        final deck = await harness.deckRepository.createDeck(
          folderId: folderId,
          name: 'Deck A',
        );
        final deckId = deck.valueOrNull!.id;
        final flashcard = await harness.flashcardRepository.createFlashcard(
          deckId: deckId,
          draft: const FlashcardDraft(front: 'hello', back: 'xin chao'),
        );
        final flashcardId = flashcard.valueOrNull!.id;

        final result = await harness.deckRepository.deleteDeck(deckId);

        expect(result.isSuccess, isTrue);

        final folderStored = await (harness.database.select(
          harness.database.folders,
        )..where((table) => table.id.equals(folderId))).getSingle();
        final deletedDeck = await (harness.database.select(
          harness.database.decks,
        )..where((table) => table.id.equals(deckId))).getSingleOrNull();
        final deletedCard = await (harness.database.select(
          harness.database.flashcards,
        )..where((table) => table.id.equals(flashcardId))).getSingleOrNull();
        final deletedProgress =
            await (harness.database.select(harness.database.flashcardProgress)
                  ..where((table) => table.flashcardId.equals(flashcardId)))
                .getSingleOrNull();

        expect(folderStored.contentMode, 'unlocked');
        expect(deletedDeck, isNull);
        expect(deletedCard, isNull);
        expect(deletedProgress, isNull);
      },
    );

    test(
      'DT3 onDelete: deleting an empty flashcard selection is a no-op',
      () async {
        final folder = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final deck = await harness.deckRepository.createDeck(
          folderId: folder.valueOrNull!.id,
          name: 'Deck A',
        );
        final card = await harness.flashcardRepository.createFlashcard(
          deckId: deck.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'hello', back: 'xin chao'),
        );

        final result = await harness.flashcardRepository.deleteFlashcards(
          const <String>[],
        );

        expect(result.isSuccess, isTrue);

        final cards = await harness.database
            .select(harness.database.flashcards)
            .get();
        final progress = await harness.database
            .select(harness.database.flashcardProgress)
            .get();

        expect(cards.map((item) => item.id), <String>[card.valueOrNull!.id]);
        expect(progress.map((item) => item.flashcardId), <String>[
          card.valueOrNull!.id,
        ]);
      },
    );

    test(
      'DT4 onDelete: bulk deleting selected flashcards keeps unselected cards',
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

        final result = await harness.flashcardRepository.deleteFlashcards([
          first.valueOrNull!.id,
          third.valueOrNull!.id,
        ]);

        expect(result.isSuccess, isTrue);

        final remainingCards = await harness.database
            .select(harness.database.flashcards)
            .get();
        final remainingProgress = await harness.database
            .select(harness.database.flashcardProgress)
            .get();

        expect(remainingCards.map((item) => item.id), <String>[
          second.valueOrNull!.id,
        ]);
        expect(remainingProgress.map((item) => item.flashcardId), <String>[
          second.valueOrNull!.id,
        ]);
      },
    );

    test(
      'DT1 onUpdate: updating learned flashcard keeps progress by policy',
      () async {
        final folder = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final deck = await harness.deckRepository.createDeck(
          folderId: folder.valueOrNull!.id,
          name: 'Deck A',
        );
        final card = await harness.flashcardRepository.createFlashcard(
          deckId: deck.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'hello', back: 'xin chao'),
        );
        final flashcardId = card.valueOrNull!.id;
        await _setLearnedProgress(harness, flashcardId: flashcardId);

        final result = await harness.flashcardRepository.updateFlashcard(
          flashcardId: flashcardId,
          draft: const FlashcardDraft(front: 'hello updated', back: 'updated'),
          progressPolicy: FlashcardProgressEditPolicy.keepProgress,
        );

        expect(result.isSuccess, isTrue);

        final storedCard = await (harness.database.select(
          harness.database.flashcards,
        )..where((table) => table.id.equals(flashcardId))).getSingle();
        final progress = await (harness.database.select(
          harness.database.flashcardProgress,
        )..where((table) => table.flashcardId.equals(flashcardId))).getSingle();
        final editorCard = await harness.flashcardRepository.getFlashcard(
          flashcardId,
        );

        expect(storedCard.front, 'hello updated');
        expect(storedCard.back, 'updated');
        expect(progress.currentBox, 5);
        expect(progress.reviewCount, 12);
        expect(progress.lapseCount, 2);
        expect(progress.lastResult, 'perfect');
        expect(progress.lastStudiedAt, 1713859200000);
        expect(progress.dueAt, 1713945600000);
        expect(editorCard.hasLearningProgress, isTrue);
      },
    );

    test(
      'DT2 onUpdate: updating learned flashcard can reset progress by policy',
      () async {
        final folder = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final deck = await harness.deckRepository.createDeck(
          folderId: folder.valueOrNull!.id,
          name: 'Deck A',
        );
        final card = await harness.flashcardRepository.createFlashcard(
          deckId: deck.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'hello', back: 'xin chao'),
        );
        final flashcardId = card.valueOrNull!.id;
        await _setLearnedProgress(harness, flashcardId: flashcardId);

        final result = await harness.flashcardRepository.updateFlashcard(
          flashcardId: flashcardId,
          draft: const FlashcardDraft(front: 'new front', back: 'new back'),
          progressPolicy: FlashcardProgressEditPolicy.resetProgress,
        );

        expect(result.isSuccess, isTrue);

        final storedCard = await (harness.database.select(
          harness.database.flashcards,
        )..where((table) => table.id.equals(flashcardId))).getSingle();
        final progress = await (harness.database.select(
          harness.database.flashcardProgress,
        )..where((table) => table.flashcardId.equals(flashcardId))).getSingle();
        final editorCard = await harness.flashcardRepository.getFlashcard(
          flashcardId,
        );

        expect(storedCard.front, 'new front');
        expect(storedCard.back, 'new back');
        expect(progress.currentBox, 1);
        expect(progress.reviewCount, 0);
        expect(progress.lapseCount, 0);
        expect(progress.lastResult, isNull);
        expect(progress.lastStudiedAt, isNull);
        expect(progress.dueAt, isNull);
        expect(editorCard.hasLearningProgress, isFalse);
      },
    );

    test(
      'DT1 repositoryFlow: moving a folder into its descendant is rejected',
      () async {
        final root = await harness.folderRepository.createRootFolder(
          'Languages',
        );
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
      },
    );

    test(
      'DT2 repositoryFlow: moving the last deck resets source folder and preserves flashcard progress',
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
          draft: const FlashcardDraft(front: 'hello', back: 'xin chao'),
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

    test(
      'DT3 repositoryFlow: duplicating a deck copies content and resets progress',
      () async {
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
      },
    );

    test(
      'DT4 repositoryFlow: moving a folder into itself is rejected',
      () async {
        final root = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final rootId = root.valueOrNull!.id;

        final moveResult = await harness.folderRepository.moveFolder(
          folderId: rootId,
          targetParentId: rootId,
        );

        expect(moveResult.isFailure, isTrue);

        final storedRoot = await (harness.database.select(
          harness.database.folders,
        )..where((table) => table.id.equals(rootId))).getSingle();
        expect(storedRoot.parentId, isNull);
      },
    );

    test(
      'DT5 repositoryFlow: moving a folder into a deck-locked folder is rejected',
      () async {
        final source = await harness.folderRepository.createRootFolder(
          'Source',
        );
        final target = await harness.folderRepository.createRootFolder(
          'Target',
        );
        await harness.deckRepository.createDeck(
          folderId: target.valueOrNull!.id,
          name: 'Target Deck',
        );

        final moveResult = await harness.folderRepository.moveFolder(
          folderId: source.valueOrNull!.id,
          targetParentId: target.valueOrNull!.id,
        );

        expect(moveResult.isFailure, isTrue);

        final storedSource =
            await (harness.database.select(harness.database.folders)
                  ..where((table) => table.id.equals(source.valueOrNull!.id)))
                .getSingle();
        expect(storedSource.parentId, isNull);
      },
    );

    test(
      'DT6 repositoryFlow: exporting a deck includes content but omits SRS fields',
      () async {
        final folder = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final deck = await harness.deckRepository.createDeck(
          folderId: folder.valueOrNull!.id,
          name: 'Deck A',
        );
        final flashcard = await harness.flashcardRepository.createFlashcard(
          deckId: deck.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'hello', back: 'xin chao'),
        );
        await (harness.database.update(harness.database.flashcardProgress)
              ..where(
                (table) => table.flashcardId.equals(flashcard.valueOrNull!.id),
              ))
            .write(
              const FlashcardProgressCompanion(
                currentBox: Value(6),
                reviewCount: Value(20),
                lastStudiedAt: Value(1713859200000),
                dueAt: Value(1713945600000),
              ),
            );

        final exported = await harness.deckRepository.exportDeck(
          deck.valueOrNull!.id,
        );

        expect(exported.isSuccess, isTrue);
        expect(exported.valueOrNull!.content, contains('front,back,note'));
        expect(
          exported.valueOrNull!.content,
          contains('"hello","xin chao",""'),
        );
        expect(exported.valueOrNull!.content, isNot(contains('current_box')));
        expect(exported.valueOrNull!.content, isNot(contains('1713945600000')));
      },
    );

    test(
      'DT1 onSearchFilterSort: sort by last studied pushes never-studied flashcards to the end',
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
      'DT2 onSearchFilterSort: folder search returns matching nested folder with breadcrumb',
      () async {
        final root = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final child = await harness.folderRepository.createSubfolder(
          parentFolderId: root.valueOrNull!.id,
          name: 'Japanese',
        );

        final overview = await harness.folderRepository.getLibraryOverview(
          const ContentQuery(searchTerm: 'japan'),
        );

        expect(overview.folders.map((item) => item.folder.id), <String>[
          child.valueOrNull!.id,
        ]);
        expect(overview.folders.single.breadcrumb, <String>[
          'Languages',
          'Japanese',
        ]);
      },
    );

    test(
      'DT1 getLibraryOverview: splits daily pool counts for dashboard',
      () async {
        final root = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        await harness.folderRepository.createRootFolder('Archive');
        final deck = await harness.deckRepository.createDeck(
          folderId: root.valueOrNull!.id,
          name: 'N5 Core',
        );
        final overdue = await harness.flashcardRepository.createFlashcard(
          deckId: deck.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'overdue', back: 'late'),
        );
        final dueToday = await harness.flashcardRepository.createFlashcard(
          deckId: deck.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'today', back: 'due'),
        );
        final future = await harness.flashcardRepository.createFlashcard(
          deckId: deck.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'future', back: 'later'),
        );
        await harness.flashcardRepository.createFlashcard(
          deckId: deck.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'new', back: 'fresh'),
        );
        final now = harness.clock.nowEpochMillis();
        await _setProgressDueAt(
          harness,
          flashcardId: overdue.valueOrNull!.id,
          dueAt: now - const Duration(days: 2).inMilliseconds,
        );
        await _setProgressDueAt(
          harness,
          flashcardId: dueToday.valueOrNull!.id,
          dueAt: now,
        );
        await _setProgressDueAt(
          harness,
          flashcardId: future.valueOrNull!.id,
          dueAt: now + const Duration(days: 1).inMilliseconds,
        );

        final overview = await harness.folderRepository.getLibraryOverview(
          const ContentQuery(),
        );

        expect(overview.overdueCount, 1);
        expect(overview.dueTodayCount, 1);
        expect(overview.newCardCount, 1);
        expect(overview.totalFolderCount, 2);
      },
    );

    test(
      'DT2 getLibraryOverview: returns folder structural and study availability counts',
      () async {
        final root = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final child = await harness.folderRepository.createSubfolder(
          parentFolderId: root.valueOrNull!.id,
          name: 'Japanese',
        );
        final deck = await harness.deckRepository.createDeck(
          folderId: child.valueOrNull!.id,
          name: 'N5 Core',
        );
        final overdue = await harness.flashcardRepository.createFlashcard(
          deckId: deck.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'overdue', back: 'late'),
        );
        final dueToday = await harness.flashcardRepository.createFlashcard(
          deckId: deck.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'today', back: 'due'),
        );
        final future = await harness.flashcardRepository.createFlashcard(
          deckId: deck.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'future', back: 'later'),
        );
        await harness.flashcardRepository.createFlashcard(
          deckId: deck.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'new', back: 'fresh'),
        );
        final now = harness.clock.nowEpochMillis();
        await _setProgressDueAt(
          harness,
          flashcardId: overdue.valueOrNull!.id,
          dueAt: now - const Duration(days: 2).inMilliseconds,
        );
        await _setProgressDueAt(
          harness,
          flashcardId: dueToday.valueOrNull!.id,
          dueAt: now,
        );
        await _setProgressDueAt(
          harness,
          flashcardId: future.valueOrNull!.id,
          dueAt: now + const Duration(days: 1).inMilliseconds,
        );

        final overview = await harness.folderRepository.getLibraryOverview(
          const ContentQuery(),
        );
        final folder = overview.folders.singleWhere(
          (item) => item.folder.id == root.valueOrNull!.id,
        );

        expect(folder.subfolderCount, 1);
        expect(folder.deckCount, 1);
        expect(folder.itemCount, 4);
        expect(folder.dueCardCount, 2);
        expect(folder.newCardCount, 1);
      },
    );

    test(
      'DT1 getDeckHighlights: returns recent decks before fallback decks',
      () async {
        final root = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final rootId = root.valueOrNull!.id;

        final recentOlder = await harness.deckRepository.createDeck(
          folderId: rootId,
          name: 'Recent older',
        );
        final recentOlderCard = await harness.flashcardRepository
            .createFlashcard(
              deckId: recentOlder.valueOrNull!.id,
              draft: const FlashcardDraft(front: 'old', back: 'cu'),
            );

        harness.clock.advance(const Duration(minutes: 1));
        final fallbackOlder = await harness.deckRepository.createDeck(
          folderId: rootId,
          name: 'Fallback older',
        );
        await harness.flashcardRepository.createFlashcard(
          deckId: fallbackOlder.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'fallback old', back: 'cu'),
        );

        harness.clock.advance(const Duration(minutes: 1));
        final fallbackNewest = await harness.deckRepository.createDeck(
          folderId: rootId,
          name: 'Fallback newest',
        );
        await harness.flashcardRepository.createFlashcard(
          deckId: fallbackNewest.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'fallback new', back: 'moi'),
        );

        harness.clock.advance(const Duration(minutes: 1));
        final recentNewest = await harness.deckRepository.createDeck(
          folderId: rootId,
          name: 'Recent newest',
        );
        final recentNewestCard = await harness.flashcardRepository
            .createFlashcard(
              deckId: recentNewest.valueOrNull!.id,
              draft: const FlashcardDraft(front: 'new', back: 'moi'),
            );

        harness.clock.advance(const Duration(minutes: 1));
        await harness.deckRepository.createDeck(
          folderId: rootId,
          name: 'Empty deck',
        );

        await _setHighlightProgress(
          harness,
          flashcardId: recentOlderCard.valueOrNull!.id,
          lastStudiedAt: 2000,
          currentBox: 2,
          dueAt: harness.clock.nowEpochMillis() + Duration.millisecondsPerDay,
        );
        await _setHighlightProgress(
          harness,
          flashcardId: recentNewestCard.valueOrNull!.id,
          lastStudiedAt: 5000,
          currentBox: 4,
          dueAt: harness.clock.nowEpochMillis(),
        );

        final highlights = await harness.deckRepository.getDeckHighlights(
          limit: 3,
        );

        expect(highlights, hasLength(3));
        expect(highlights.map((item) => item.deck.name), <String>[
          'Recent newest',
          'Recent older',
          'Fallback newest',
        ]);
        expect(
          highlights.map((item) => item.deck.name),
          isNot(contains('Empty deck')),
        );
        expect(highlights.first.dueTodayCount, 1);
        expect(highlights.first.masteryPercent, 43);
      },
    );

    test(
      'DT3 onSearchFilterSort: sort by last studied pushes never-studied decks to the end',
      () async {
        final folder = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final folderId = folder.valueOrNull!.id;
        final studiedDeck = await harness.deckRepository.createDeck(
          folderId: folderId,
          name: 'Studied',
        );
        final newDeck = await harness.deckRepository.createDeck(
          folderId: folderId,
          name: 'New',
        );
        final studiedCard = await harness.flashcardRepository.createFlashcard(
          deckId: studiedDeck.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'hello', back: 'xin chao'),
        );
        await harness.flashcardRepository.createFlashcard(
          deckId: newDeck.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'bye', back: 'tam biet'),
        );
        await (harness.database.update(harness.database.flashcardProgress)
              ..where(
                (table) =>
                    table.flashcardId.equals(studiedCard.valueOrNull!.id),
              ))
            .write(
              const FlashcardProgressCompanion(lastStudiedAt: Value(5000)),
            );

        final decks = await harness.deckRepository.getDecksInFolder(
          folderId,
          const ContentQuery(sortMode: ContentSortMode.lastStudied),
        );

        expect(decks.map((item) => item.deck.id), <String>[
          studiedDeck.valueOrNull!.id,
          newDeck.valueOrNull!.id,
        ]);
      },
    );

    test(
      'DT4 onSearchFilterSort: flashcard search matches back text and keeps deck breadcrumb',
      () async {
        final folder = await harness.folderRepository.createRootFolder(
          'Languages',
        );
        final deck = await harness.deckRepository.createDeck(
          folderId: folder.valueOrNull!.id,
          name: 'Deck A',
        );
        final deckId = deck.valueOrNull!.id;
        await harness.flashcardRepository.createFlashcard(
          deckId: deckId,
          draft: const FlashcardDraft(front: 'hello', back: 'xin chao'),
        );
        final target = await harness.flashcardRepository.createFlashcard(
          deckId: deckId,
          draft: const FlashcardDraft(front: 'bye', back: 'tam biet'),
        );

        final list = await harness.flashcardRepository.getFlashcards(
          deckId,
          const ContentQuery(searchTerm: 'tam'),
        );

        expect(list.items.map((item) => item.flashcard.id), <String>[
          target.valueOrNull!.id,
        ]);
        expect(list.breadcrumb.map((item) => item.label), <String>[
          'Languages',
          'Deck A',
        ]);
      },
    );

    test(
      'DT3 onInsert: import with mixed valid and invalid lines does not write any flashcards',
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
          deckId: deckId,
          format: ImportSourceFormat.csv,
          rawContent: 'front,back\nhello,xin chao\nBroken,',
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
      'DT1 onMove: bulk move 200 flashcards stays transaction-safe and preserves progress',
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

    test(
      'DT2 onMove: moving an empty flashcard selection is a no-op',
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
        final card = await harness.flashcardRepository.createFlashcard(
          deckId: sourceDeck.valueOrNull!.id,
          draft: const FlashcardDraft(front: 'hello', back: 'xin chao'),
        );

        final moveResult = await harness.flashcardRepository.moveFlashcards(
          flashcardIds: const <String>[],
          targetDeckId: targetDeck.valueOrNull!.id,
        );

        expect(moveResult.isSuccess, isTrue);

        final sourceCards =
            await (harness.database.select(harness.database.flashcards)..where(
                  (table) => table.deckId.equals(sourceDeck.valueOrNull!.id),
                ))
                .get();
        final targetCards =
            await (harness.database.select(harness.database.flashcards)..where(
                  (table) => table.deckId.equals(targetDeck.valueOrNull!.id),
                ))
                .get();

        expect(sourceCards.map((item) => item.id), <String>[
          card.valueOrNull!.id,
        ]);
        expect(targetCards, isEmpty);
      },
    );

    test(
      'DT3 onMove: reordering flashcards changes order without changing deck or progress',
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
                (table) => table.flashcardId.equals(second.valueOrNull!.id),
              ))
            .write(const FlashcardProgressCompanion(currentBox: Value(4)));

        final result = await harness.flashcardRepository.reorderFlashcards(
          deckId: deckId,
          orderedFlashcardIds: [
            third.valueOrNull!.id,
            first.valueOrNull!.id,
            second.valueOrNull!.id,
          ],
        );

        expect(result.isSuccess, isTrue);

        final cards =
            await (harness.database.select(harness.database.flashcards)
                  ..where((table) => table.deckId.equals(deckId))
                  ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
                .get();
        final progress =
            await (harness.database.select(harness.database.flashcardProgress)
                  ..where(
                    (table) => table.flashcardId.equals(second.valueOrNull!.id),
                  ))
                .getSingle();

        expect(cards.map((item) => item.id), <String>[
          third.valueOrNull!.id,
          first.valueOrNull!.id,
          second.valueOrNull!.id,
        ]);
        expect(cards.map((item) => item.deckId), everyElement(deckId));
        expect(progress.currentBox, 4);
      },
    );
  });
}

Future<void> _setProgressDueAt(
  ContentRepositoryHarness harness, {
  required String flashcardId,
  required int dueAt,
}) {
  final now = harness.clock.nowEpochMillis();
  return (harness.database.update(
    harness.database.flashcardProgress,
  )..where((table) => table.flashcardId.equals(flashcardId))).write(
    FlashcardProgressCompanion(
      currentBox: const Value(2),
      reviewCount: const Value(1),
      dueAt: Value(dueAt),
      updatedAt: Value(now),
    ),
  );
}

Future<void> _setHighlightProgress(
  ContentRepositoryHarness harness, {
  required String flashcardId,
  required int lastStudiedAt,
  required int currentBox,
  required int dueAt,
}) {
  final now = harness.clock.nowEpochMillis();
  return (harness.database.update(
    harness.database.flashcardProgress,
  )..where((table) => table.flashcardId.equals(flashcardId))).write(
    FlashcardProgressCompanion(
      currentBox: Value(currentBox),
      reviewCount: const Value(1),
      lastStudiedAt: Value(lastStudiedAt),
      dueAt: Value(dueAt),
      updatedAt: Value(now),
    ),
  );
}

Future<void> _setLearnedProgress(
  ContentRepositoryHarness harness, {
  required String flashcardId,
}) {
  return (harness.database.update(
    harness.database.flashcardProgress,
  )..where((table) => table.flashcardId.equals(flashcardId))).write(
    const FlashcardProgressCompanion(
      currentBox: Value(5),
      reviewCount: Value(12),
      lapseCount: Value(2),
      lastResult: Value('perfect'),
      lastStudiedAt: Value(1713859200000),
      dueAt: Value(1713945600000),
    ),
  );
}
