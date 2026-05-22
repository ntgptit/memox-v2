import 'package:flutter_test/flutter_test.dart';

import '../robots/deck_robot.dart';
import '../robots/folder_robot.dart';
import '../robots/study_robot.dart';
import '../test_app.dart';

void registerDeckFlowTests() {
  group('Deck flow', () {
    testWidgets(
      'DT1 onInsert: creates a deck in an empty folder and locks it to decks',
      (tester) async {
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-korean',
              folderName: 'Korean',
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('Korean');
        await deckRobot.createDeck('Daily Words');

        await deckRobot.expectDeckVisible('Daily Words');
        await folderRobot.expectDeckCreationAvailableOnly();
        final folder = await app.findFolderByName('Korean');
        final deck = await app.findDeckByName('Daily Words');
        expect(folder.contentMode, 'decks');
        expect(deck.folderId, 'folder-korean');
      },
    );

    testWidgets(
      'DT2 onInsert: creates another deck in a folder that already contains decks',
      (tester) async {
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-korean',
              folderName: 'Korean',
            );
            await app.seedDeckInFolder(
              folderId: 'folder-korean',
              deckId: 'deck-daily',
              deckName: 'Daily Words',
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('Korean');
        await deckRobot.createDeck('Travel Words');

        await deckRobot.expectDecksInOrder(['Daily Words', 'Travel Words']);
        final decks = await app.listDecksInFolder('folder-korean');
        expect(decks.map((deck) => deck.name), ['Daily Words', 'Travel Words']);
      },
    );

    testWidgets(
      'DT3 onInsert: hides deck creation when the folder already contains a subfolder',
      (tester) async {
        await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-topik',
              folderName: 'TOPIK',
            );
            await app.seedSubfolder(
              parentFolderId: 'folder-topik',
              folderId: 'folder-grammar',
              folderName: 'Grammar',
            );
          },
        );
        final folderRobot = FolderRobot(tester);

        await folderRobot.openFolderFromLibrary('TOPIK');

        await folderRobot.expectSubfolderCreationAvailableOnly();
      },
    );

    testWidgets(
      'DT4 onInsert: keeps create deck confirm disabled for a blank name',
      (tester) async {
        await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-korean',
              folderName: 'Korean',
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('Korean');
        await deckRobot.openCreateDeckDialog();
        await deckRobot.enterDeckName('   ');

        await deckRobot.expectCreateDeckConfirmDisabled();
      },
    );

    testWidgets('DT5 onInsert: trims deck name before creating it', (
      tester,
    ) async {
      final app = await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(
            folderId: 'folder-korean',
            folderName: 'Korean',
          );
        },
      );
      final folderRobot = FolderRobot(tester);
      final deckRobot = DeckRobot(tester);

      await folderRobot.openFolderFromLibrary('Korean');
      await deckRobot.openCreateDeckDialog();
      await deckRobot.enterDeckName('  Korean Basics  ');
      await deckRobot.confirmDeckCreation(expectedName: 'Korean Basics');

      await deckRobot.expectDeckVisible('Korean Basics');
      await deckRobot.expectDeckAbsent('  Korean Basics  ');
      final deck = await app.findDeckByName('Korean Basics');
      expect(deck.name, 'Korean Basics');
    });

    testWidgets(
      'DT6 onInsert: duplicates a deck and copies its flashcards in the same folder',
      (tester) async {
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-korean',
              folderName: 'Korean',
            );
            await app.seedDeckWithFlashcardInFolder(
              folderId: 'folder-korean',
              deckId: 'deck-daily',
              deckName: 'Daily Words',
              flashcardId: 'flashcard-hello',
              front: 'annyeong',
              back: 'hello',
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('Korean');
        await deckRobot.duplicateVisibleDeckToCurrentFolder(
          sourceName: 'Daily Words',
          duplicatedName: 'Daily Words Copy',
        );

        final duplicate = await app.findDeckByName('Daily Words Copy');
        final cards = await app.listFlashcardsInDeck(duplicate.id);
        expect(duplicate.folderId, 'folder-korean');
        expect(cards, hasLength(1));
        expect(cards.single.front, 'annyeong');
        expect(cards.single.back, 'hello');
      },
    );

    testWidgets(
      'DT7 onInsert: duplicates flashcards without copying learned progress',
      (tester) async {
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-korean',
              folderName: 'Korean',
            );
            await app.seedDeckWithFlashcardInFolder(
              folderId: 'folder-korean',
              deckId: 'deck-daily',
              deckName: 'Daily Words',
              flashcardId: 'flashcard-hello',
              front: 'annyeong',
              back: 'hello',
              currentBox: 6,
              reviewCount: 12,
              lapseCount: 2,
              lastStudiedAt: app.clock.nowEpochMillis() - 5000,
              dueAt: app.clock.nowEpochMillis() - 1000,
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('Korean');
        await deckRobot.duplicateVisibleDeckToCurrentFolder(
          sourceName: 'Daily Words',
          duplicatedName: 'Daily Words Copy',
        );

        final duplicate = await app.findDeckByName('Daily Words Copy');
        final cards = await app.listFlashcardsInDeck(duplicate.id);
        final progress = await app.findProgressByFlashcardId(cards.single.id);
        expect(progress.currentBox, 1);
        expect(progress.reviewCount, 0);
        expect(progress.lapseCount, 0);
        expect(progress.lastStudiedAt, isNull);
        expect(progress.dueAt, isNull);
      },
    );

    testWidgets('DT8 onInsert: duplicates a deck into another valid folder', (
      tester,
    ) async {
      final app = await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(
            folderId: 'folder-korean',
            folderName: 'Korean',
          );
          await app.seedRootFolder(
            folderId: 'folder-archive',
            folderName: 'Archive',
          );
          await app.seedDeckWithFlashcardInFolder(
            folderId: 'folder-korean',
            deckId: 'deck-daily',
            deckName: 'Daily Words',
            flashcardId: 'flashcard-hello',
            front: 'annyeong',
            back: 'hello',
          );
        },
      );
      final folderRobot = FolderRobot(tester);
      final deckRobot = DeckRobot(tester);

      await folderRobot.openFolderFromLibrary('Korean');
      await deckRobot.duplicateVisibleDeckToDestination(
        sourceName: 'Daily Words',
        destinationName: 'Archive',
        duplicatedName: 'Daily Words Copy',
      );

      final duplicate = await app.findDeckByName('Daily Words Copy');
      expect(duplicate.folderId, 'folder-archive');
    });

    testWidgets('DT1 onDisplay: shows only decks from the current folder', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(folderId: 'folder-a', folderName: 'A');
          await app.seedRootFolder(folderId: 'folder-b', folderName: 'B');
          await app.seedDeckInFolder(
            folderId: 'folder-a',
            deckId: 'deck-a1',
            deckName: 'A1',
          );
          await app.seedDeckInFolder(
            folderId: 'folder-a',
            deckId: 'deck-a2',
            deckName: 'A2',
            sortOrder: 1,
          );
          await app.seedDeckInFolder(
            folderId: 'folder-b',
            deckId: 'deck-b1',
            deckName: 'B1',
          );
        },
      );
      final folderRobot = FolderRobot(tester);
      final deckRobot = DeckRobot(tester);

      await folderRobot.openFolderFromLibrary('A');

      await deckRobot.expectDeckVisible('A1');
      await deckRobot.expectDeckVisible('A2');
      await deckRobot.expectDeckAbsent('B1');
    });

    testWidgets(
      'DT2 onDisplay: shows empty deck state with deck creation available',
      (tester) async {
        await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-empty',
              folderName: 'Empty Folder',
            );
          },
        );
        final folderRobot = FolderRobot(tester);

        await folderRobot.openFolderFromLibrary('Empty Folder');

        await folderRobot.waitUntilVisible(find.text('This folder is empty'));
        await folderRobot.expectUnlockedCreateChoicesAvailable();
      },
    );

    testWidgets(
      'DT3 onDisplay: renders deck row name count open action and actions menu',
      (tester) async {
        await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-korean',
              folderName: 'Korean',
            );
            await app.seedDeckWithFlashcardInFolder(
              folderId: 'folder-korean',
              deckId: 'deck-daily',
              deckName: 'Daily Words',
              flashcardId: 'flashcard-hello',
              front: 'annyeong',
              back: 'hello',
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('Korean');

        await deckRobot.expectDeckRowBasics(name: 'Daily Words', cardCount: 1);
        await deckRobot.expectDeckActionsAvailable('Daily Words');
      },
    );

    testWidgets('DT1 onUpdate: renames a deck and changes updated_at', (
      tester,
    ) async {
      final app = await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(
            folderId: 'folder-korean',
            folderName: 'Korean',
          );
          await app.seedDeckInFolder(
            folderId: 'folder-korean',
            deckId: 'deck-old',
            deckName: 'Old Name',
          );
        },
      );
      final folderRobot = FolderRobot(tester);
      final deckRobot = DeckRobot(tester);
      final before = await app.findDeckByName('Old Name');
      app.clock.advance(const Duration(minutes: 1));

      await folderRobot.openFolderFromLibrary('Korean');
      await deckRobot.renameVisibleDeck(from: 'Old Name', to: 'New Name');

      expect(await app.findDeckByNameOrNull('Old Name'), isNull);
      final after = await app.findDeckByName('New Name');
      expect(after.id, before.id);
      expect(after.updatedAt, greaterThan(before.updatedAt));
    });

    testWidgets(
      'DT2 onUpdate: keeps rename deck confirm disabled for a blank name',
      (tester) async {
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-korean',
              folderName: 'Korean',
            );
            await app.seedDeckInFolder(
              folderId: 'folder-korean',
              deckId: 'deck-topik',
              deckName: 'TOPIK',
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('Korean');
        await deckRobot.openVisibleDeckRenameDialog('TOPIK');
        await deckRobot.enterDeckName('   ');

        await deckRobot.expectRenameConfirmDisabled();
        expect(await app.findDeckByNameOrNull('TOPIK'), isNotNull);
      },
    );

    testWidgets('DT3 onUpdate: cancels deck rename without saving changes', (
      tester,
    ) async {
      final app = await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(
            folderId: 'folder-korean',
            folderName: 'Korean',
          );
          await app.seedDeckInFolder(
            folderId: 'folder-korean',
            deckId: 'deck-daily',
            deckName: 'Daily Words',
          );
        },
      );
      final folderRobot = FolderRobot(tester);
      final deckRobot = DeckRobot(tester);

      await folderRobot.openFolderFromLibrary('Korean');
      await deckRobot.cancelRenameVisibleDeck(
        from: 'Daily Words',
        attemptedName: 'Daily Words II',
      );

      expect(await app.findDeckByNameOrNull('Daily Words II'), isNull);
      expect(await app.findDeckByNameOrNull('Daily Words'), isNotNull);
    });

    testWidgets('DT1 onDelete: deletes an empty deck', (tester) async {
      final app = await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(
            folderId: 'folder-korean',
            folderName: 'Korean',
          );
          await app.seedDeckInFolder(
            folderId: 'folder-korean',
            deckId: 'deck-empty',
            deckName: 'Empty Deck',
          );
        },
      );
      final folderRobot = FolderRobot(tester);
      final deckRobot = DeckRobot(tester);

      await folderRobot.openFolderFromLibrary('Korean');
      await deckRobot.deleteVisibleDeck('Empty Deck');

      expect(await app.findDeckByNameOrNull('Empty Deck'), isNull);
    });

    testWidgets(
      'DT2 onDelete: deleting a deck with flashcards cascades its cards and progress',
      (tester) async {
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-korean',
              folderName: 'Korean',
            );
            await app.seedDeckWithFlashcardInFolder(
              folderId: 'folder-korean',
              deckId: 'deck-daily',
              deckName: 'Daily Words',
              flashcardId: 'flashcard-hello',
              front: 'annyeong',
              back: 'hello',
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('Korean');
        await deckRobot.deleteVisibleDeck('Daily Words');

        expect(await app.findDeckByNameOrNull('Daily Words'), isNull);
        expect(await app.listFlashcardsInDeck('deck-daily'), isEmpty);
        expect(
          await app.findProgressByFlashcardIdOrNull('flashcard-hello'),
          isNull,
        );
      },
    );

    testWidgets('DT3 onDelete: cancels deck deletion', (tester) async {
      final app = await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(
            folderId: 'folder-korean',
            folderName: 'Korean',
          );
          await app.seedDeckInFolder(
            folderId: 'folder-korean',
            deckId: 'deck-daily',
            deckName: 'Daily Words',
          );
        },
      );
      final folderRobot = FolderRobot(tester);
      final deckRobot = DeckRobot(tester);

      await folderRobot.openFolderFromLibrary('Korean');
      await deckRobot.cancelDeleteVisibleDeck('Daily Words');

      await deckRobot.expectDeckVisible('Daily Words');
      expect(await app.findDeckByNameOrNull('Daily Words'), isNotNull);
    });

    testWidgets(
      'DT4 onDelete: deleting the last deck unlocks folder create choices',
      (tester) async {
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-korean',
              folderName: 'Korean',
            );
            await app.seedDeckInFolder(
              folderId: 'folder-korean',
              deckId: 'deck-daily',
              deckName: 'Daily Words',
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('Korean');
        await deckRobot.deleteVisibleDeck('Daily Words');

        await deckRobot.waitUntilVisible(find.text('This folder is empty'));
        await folderRobot.expectUnlockedCreateChoicesAvailable();
        final folder = await app.findFolderByName('Korean');
        expect(folder.contentMode, 'unlocked');
      },
    );

    testWidgets('DT1 onMove: reorders decks inside the same folder', (
      tester,
    ) async {
      final app = await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(
            folderId: 'folder-topik',
            folderName: 'TOPIK',
          );
          await app.seedDeckInFolder(
            folderId: 'folder-topik',
            deckId: 'deck-a',
            deckName: 'A',
            sortOrder: 0,
          );
          await app.seedDeckInFolder(
            folderId: 'folder-topik',
            deckId: 'deck-b',
            deckName: 'B',
            sortOrder: 1,
          );
          await app.seedDeckInFolder(
            folderId: 'folder-topik',
            deckId: 'deck-c',
            deckName: 'C',
            sortOrder: 2,
          );
        },
      );
      final folderRobot = FolderRobot(tester);
      final deckRobot = DeckRobot(tester);

      await folderRobot.openFolderFromLibrary('TOPIK');
      await deckRobot.expectDecksInOrder(['A', 'B', 'C']);
      await deckRobot.openCurrentFolderReorderMode();
      await deckRobot.dragDeckToTop('C');
      await deckRobot.saveReorder();

      await deckRobot.expectDecksInOrder(['C', 'A', 'B']);
      final decks = await app.listDecksInFolder('folder-topik');
      expect(decks.map((deck) => deck.name), ['C', 'A', 'B']);
      expect(decks.map((deck) => deck.sortOrder), [0, 1, 2]);
    });

    testWidgets(
      'DT2 onMove: reordering decks in one folder does not affect another folder',
      (tester) async {
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(folderId: 'folder-a', folderName: 'A');
            await app.seedRootFolder(folderId: 'folder-b', folderName: 'B');
            await app.seedDeckInFolder(
              folderId: 'folder-a',
              deckId: 'deck-a1',
              deckName: 'A1',
            );
            await app.seedDeckInFolder(
              folderId: 'folder-a',
              deckId: 'deck-a2',
              deckName: 'A2',
              sortOrder: 1,
            );
            await app.seedDeckInFolder(
              folderId: 'folder-a',
              deckId: 'deck-a3',
              deckName: 'A3',
              sortOrder: 2,
            );
            await app.seedDeckInFolder(
              folderId: 'folder-b',
              deckId: 'deck-b1',
              deckName: 'B1',
            );
            await app.seedDeckInFolder(
              folderId: 'folder-b',
              deckId: 'deck-b2',
              deckName: 'B2',
              sortOrder: 1,
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('A');
        await deckRobot.openCurrentFolderReorderMode();
        await deckRobot.dragDeckToTop('A3');
        await deckRobot.saveReorder();
        await folderRobot.tapBackToLibrary();
        await folderRobot.openFolderFromLibrary('B');

        await deckRobot.expectDecksInOrder(['B1', 'B2']);
        final decks = await app.listDecksInFolder('folder-b');
        expect(decks.map((deck) => deck.name), ['B1', 'B2']);
      },
    );

    testWidgets('DT3 onMove: moves a deck into an empty folder', (
      tester,
    ) async {
      final app = await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(folderId: 'folder-a', folderName: 'A');
          await app.seedRootFolder(folderId: 'folder-b', folderName: 'B');
          await app.seedDeckInFolder(
            folderId: 'folder-a',
            deckId: 'deck-daily',
            deckName: 'Daily Words',
          );
        },
      );
      final folderRobot = FolderRobot(tester);
      final deckRobot = DeckRobot(tester);

      await folderRobot.openFolderFromLibrary('A');
      await deckRobot.moveVisibleDeckTo(
        deckName: 'Daily Words',
        destinationName: 'B',
      );

      await deckRobot.expectDeckAbsent('Daily Words');
      await folderRobot.tapBackToLibrary();
      await folderRobot.openFolderFromLibrary('B');
      await deckRobot.expectDeckVisible('Daily Words');
      final deck = await app.findDeckByName('Daily Words');
      final target = await app.findFolderByName('B');
      expect(deck.folderId, 'folder-b');
      expect(target.contentMode, 'decks');
    });

    testWidgets(
      'DT4 onMove: moves a deck into a folder that already has decks',
      (tester) async {
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(folderId: 'folder-a', folderName: 'A');
            await app.seedRootFolder(folderId: 'folder-b', folderName: 'B');
            await app.seedDeckInFolder(
              folderId: 'folder-a',
              deckId: 'deck-daily',
              deckName: 'Daily Words',
            );
            await app.seedDeckInFolder(
              folderId: 'folder-b',
              deckId: 'deck-existing',
              deckName: 'Existing Deck',
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('A');
        await deckRobot.moveVisibleDeckTo(
          deckName: 'Daily Words',
          destinationName: 'B',
        );
        await folderRobot.tapBackToLibrary();
        await folderRobot.openFolderFromLibrary('B');

        await deckRobot.expectDecksInOrder(['Existing Deck', 'Daily Words']);
        expect((await app.findDeckByName('Daily Words')).folderId, 'folder-b');
      },
    );

    testWidgets(
      'DT5 onMove: excludes folders that already contain subfolders from deck move targets',
      (tester) async {
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(folderId: 'folder-a', folderName: 'A');
            await app.seedRootFolder(folderId: 'folder-b', folderName: 'B');
            await app.seedDeckInFolder(
              folderId: 'folder-a',
              deckId: 'deck-daily',
              deckName: 'Daily Words',
            );
            await app.seedSubfolder(
              parentFolderId: 'folder-b',
              folderId: 'folder-grammar',
              folderName: 'Grammar',
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('A');
        await deckRobot.openVisibleDeckMoveDialog('Daily Words');

        await deckRobot.expectMoveDestinationAbsent('B');
        expect((await app.findDeckByName('Daily Words')).folderId, 'folder-a');
      },
    );

    testWidgets(
      'DT6 onMove: moving a deck preserves its flashcards and progress',
      (tester) async {
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(folderId: 'folder-a', folderName: 'A');
            await app.seedRootFolder(folderId: 'folder-b', folderName: 'B');
            await app.seedDeckWithFlashcardInFolder(
              folderId: 'folder-a',
              deckId: 'deck-daily',
              deckName: 'Daily Words',
              flashcardId: 'flashcard-hello',
              front: 'annyeong',
              back: 'hello',
              currentBox: 5,
              reviewCount: 9,
              lastStudiedAt: app.clock.nowEpochMillis() - 4000,
              dueAt: app.clock.nowEpochMillis() - 1000,
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('A');
        await deckRobot.moveVisibleDeckTo(
          deckName: 'Daily Words',
          destinationName: 'B',
        );

        final deck = await app.findDeckByName('Daily Words');
        final cards = await app.listFlashcardsInDeck(deck.id);
        final progress = await app.findProgressByFlashcardId('flashcard-hello');
        expect(deck.folderId, 'folder-b');
        expect(cards.single.id, 'flashcard-hello');
        expect(progress.currentBox, 5);
        expect(progress.reviewCount, 9);
        expect(progress.dueAt, app.clock.nowEpochMillis() - 1000);
      },
    );

    testWidgets(
      'DT1 onExternalChange: keeps reordered deck order after app restart',
      (tester) async {
        final databaseFile = await createIntegrationTestDatabaseFile();
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          databaseFile: databaseFile,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-topik',
              folderName: 'TOPIK',
            );
            await app.seedDeckInFolder(
              folderId: 'folder-topik',
              deckId: 'deck-a',
              deckName: 'A',
              sortOrder: 0,
            );
            await app.seedDeckInFolder(
              folderId: 'folder-topik',
              deckId: 'deck-b',
              deckName: 'B',
              sortOrder: 1,
            );
            await app.seedDeckInFolder(
              folderId: 'folder-topik',
              deckId: 'deck-c',
              deckName: 'C',
              sortOrder: 2,
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('TOPIK');
        await deckRobot.openCurrentFolderReorderMode();
        await deckRobot.dragDeckToTop('C');
        await deckRobot.saveReorder();
        await restartTestApp(
          tester,
          app,
          surfaceSize: integrationTestCompactSurfaceSize,
        );

        await folderRobot.openFolderFromLibrary('TOPIK');
        await deckRobot.expectDecksInOrder(['C', 'A', 'B']);
      },
    );

    testWidgets(
      'DT1 onNavigate: opens deck detail and renders its flashcards',
      (tester) async {
        await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-korean',
              folderName: 'Korean',
            );
            await app.seedDeckWithFlashcardInFolder(
              folderId: 'folder-korean',
              deckId: 'deck-daily',
              deckName: 'Daily Words',
              flashcardId: 'flashcard-hello',
              front: 'annyeong',
              back: 'hello',
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('Korean');
        await deckRobot.openDeckWithFlashcard(
          deckName: 'Daily Words',
          flashcardFront: 'annyeong',
        );

        await deckRobot.waitUntilVisible(find.text('hello'));
      },
    );

    testWidgets(
      'DT2 onNavigate: opens an empty deck detail with flashcard empty state',
      (tester) async {
        await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedDeckWithoutFlashcards(
              folderId: 'folder-korean',
              deckId: 'deck-empty',
              folderName: 'Korean',
              deckName: 'Empty Deck',
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);

        await folderRobot.openFolderFromLibrary('Korean');
        await deckRobot.openDeck('Empty Deck');

        await deckRobot.waitUntilVisible(find.text('Add'));
        await deckRobot.waitUntilVisible(
          find.text(
            'Study is available after this deck has at least one flashcard.',
          ),
        );
      },
    );

    testWidgets(
      'DT3 onNavigate: starts New Study from one deck without taking another deck card',
      (tester) async {
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-korean',
              folderName: 'Korean',
            );
            await app.seedRootFolder(
              folderId: 'folder-japanese',
              folderName: 'Japanese',
            );
            await app.seedDeckWithFlashcardInFolder(
              folderId: 'folder-korean',
              deckId: 'deck-daily',
              deckName: 'Daily Words',
              flashcardId: 'flashcard-korean',
              front: 'annyeong',
              back: 'hello',
            );
            await app.seedDeckWithFlashcardInFolder(
              folderId: 'folder-japanese',
              deckId: 'deck-other',
              deckName: 'Other Words',
              flashcardId: 'flashcard-other',
              front: 'ohayo',
              back: 'morning',
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);
        final studyRobot = StudyRobot(tester);

        await folderRobot.openFolderFromLibrary('Korean');
        await deckRobot.tapVisibleDeckStudyAction('deck-daily');
        await studyRobot.startDefaultStudyFromEntry();

        await studyRobot.expectStudySessionVisible(
          front: 'annyeong',
          back: 'hello',
        );
        expect(await app.latestOriginalStudySessionFlashcardIds(), [
          'flashcard-korean',
        ]);
      },
    );

    testWidgets(
      'DT4 onNavigate: starts SRS Review from one deck with only due cards in that deck',
      (tester) async {
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            final dueAt = app.clock.nowEpochMillis() - 1000;
            await app.seedRootFolder(
              folderId: 'folder-korean',
              folderName: 'Korean',
            );
            await app.seedRootFolder(
              folderId: 'folder-japanese',
              folderName: 'Japanese',
            );
            await app.seedDeckWithFlashcardInFolder(
              folderId: 'folder-korean',
              deckId: 'deck-daily',
              deckName: 'Daily Words',
              flashcardId: 'flashcard-due',
              front: 'annyeong',
              back: 'hello',
              currentBox: 3,
              reviewCount: 2,
              dueAt: dueAt,
            );
            await app.seedFlashcardInDeck(
              deckId: 'deck-daily',
              flashcardId: 'flashcard-new',
              front: 'gamsa',
              back: 'thanks',
            );
            await app.seedDeckWithFlashcardInFolder(
              folderId: 'folder-japanese',
              deckId: 'deck-other',
              deckName: 'Other Words',
              flashcardId: 'flashcard-other-due',
              front: 'ohayo',
              back: 'morning',
              currentBox: 3,
              reviewCount: 2,
              dueAt: dueAt,
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);
        final studyRobot = StudyRobot(tester);

        await folderRobot.openFolderFromLibrary('Korean');
        await deckRobot.tapVisibleDeckStudyAction('deck-daily');
        await studyRobot.selectSrsReviewFlow();
        await studyRobot.startDefaultStudyFromEntry();

        await studyRobot.expectFillStudySessionVisible(prompt: 'hello');
        expect(await app.latestOriginalStudySessionFlashcardIds(), [
          'flashcard-due',
        ]);
      },
    );

    testWidgets(
      'DT5 onNavigate: shows validation when deck has no card eligible for selected study type',
      (tester) async {
        await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-korean',
              folderName: 'Korean',
            );
            await app.seedDeckWithFlashcardInFolder(
              folderId: 'folder-korean',
              deckId: 'deck-daily',
              deckName: 'Daily Words',
              flashcardId: 'flashcard-future',
              front: 'annyeong',
              back: 'hello',
              currentBox: 3,
              reviewCount: 2,
              dueAt:
                  app.clock.nowEpochMillis() +
                  const Duration(days: 2).inMilliseconds,
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final deckRobot = DeckRobot(tester);
        final studyRobot = StudyRobot(tester);

        await folderRobot.openFolderFromLibrary('Korean');
        await deckRobot.tapVisibleDeckStudyAction('deck-daily');
        await studyRobot.selectSrsReviewFlow();
        await studyRobot.startDefaultStudyFromEntry();

        await studyRobot.expectNoEligibleFlashcardsMessage();
      },
    );

    testWidgets('DT1 onSearchFilterSort: searches decks by name', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(
            folderId: 'folder-topik',
            folderName: 'TOPIK',
          );
          await app.seedDeckInFolder(
            folderId: 'folder-topik',
            deckId: 'deck-grammar',
            deckName: 'Grammar',
          );
          await app.seedDeckInFolder(
            folderId: 'folder-topik',
            deckId: 'deck-vocabulary',
            deckName: 'Vocabulary',
            sortOrder: 1,
          );
          await app.seedDeckInFolder(
            folderId: 'folder-topik',
            deckId: 'deck-reading',
            deckName: 'Reading',
            sortOrder: 2,
          );
        },
      );
      final folderRobot = FolderRobot(tester);
      final deckRobot = DeckRobot(tester);

      await folderRobot.openFolderFromLibrary('TOPIK');
      await deckRobot.searchDecks('vocab');

      await deckRobot.expectDeckVisible('Vocabulary');
      await deckRobot.expectDeckAbsent('Grammar');
      await deckRobot.expectDeckAbsent('Reading');
    });

    testWidgets('DT2 onSearchFilterSort: clears deck search results', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(
            folderId: 'folder-topik',
            folderName: 'TOPIK',
          );
          await app.seedDeckInFolder(
            folderId: 'folder-topik',
            deckId: 'deck-grammar',
            deckName: 'Grammar',
          );
          await app.seedDeckInFolder(
            folderId: 'folder-topik',
            deckId: 'deck-vocabulary',
            deckName: 'Vocabulary',
            sortOrder: 1,
          );
        },
      );
      final folderRobot = FolderRobot(tester);
      final deckRobot = DeckRobot(tester);

      await folderRobot.openFolderFromLibrary('TOPIK');
      await deckRobot.searchDecks('vocab');
      await deckRobot.expectDeckAbsent('Grammar');
      await deckRobot.clearDeckSearch();

      await deckRobot.expectDecksInOrder(['Grammar', 'Vocabulary']);
    });
  });
}
