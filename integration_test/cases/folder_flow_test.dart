import 'package:flutter_test/flutter_test.dart';

import '../robots/deck_robot.dart';
import '../robots/folder_robot.dart';
import '../robots/study_robot.dart';
import '../test_app.dart';

void registerFolderFlowTests() {
  group('Folder flow', () {
    testWidgets(
      'DT1 onDisplay: shows root empty state with create folder action',
      (tester) async {
        await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
        );
        final folderRobot = FolderRobot(tester);

        await folderRobot.expectRootEmptyState();
      },
    );

    testWidgets('DT1 onInsert: creates a root folder from the folder dialog', (
      tester,
    ) async {
      final app = await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
      );
      final folderRobot = FolderRobot(tester);

      await folderRobot.createRootFolder('TOPIK');

      final folder = await app.findFolderByName('TOPIK');
      expect(folder.parentId, isNull);
      expect(folder.name, 'TOPIK');
    });

    testWidgets(
      'DT2 onInsert: keeps create folder confirm disabled for a blank name',
      (tester) async {
        await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
        );
        final folderRobot = FolderRobot(tester);

        await folderRobot.openCreateFolderDialog();

        await folderRobot.expectCreateFolderConfirmDisabled();
      },
    );

    testWidgets(
      'DT3 onInsert: trims the folder name before creating root folder',
      (tester) async {
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
        );
        final folderRobot = FolderRobot(tester);

        await folderRobot.openCreateFolderDialog();
        await folderRobot.enterFolderName('  Korean Vocabulary  ');
        await folderRobot.confirmFolderCreation();

        await folderRobot.waitUntilAbsent(find.text('Folder name'));
        await folderRobot.expectFolderVisible('Korean Vocabulary');
        await folderRobot.expectFolderAbsent('  Korean Vocabulary  ');
        final folder = await app.findFolderByName('Korean Vocabulary');
        expect(folder.name, 'Korean Vocabulary');
      },
    );

    testWidgets(
      'DT4 onInsert: creates a subfolder inside an empty root folder',
      (tester) async {
        await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-topik',
              folderName: 'TOPIK',
            );
          },
        );
        final folderRobot = FolderRobot(tester);

        await folderRobot.openFolder('TOPIK');
        await folderRobot.createSubfolder('Grammar');

        await folderRobot.expectFolderVisible('Grammar');
      },
    );

    testWidgets(
      'DT2 onDisplay: keeps subfolder add action and hides deck add action after subfolder exists',
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

        await folderRobot.expectFolderVisible('Grammar');
        await folderRobot.expectSubfolderCreationAvailableOnly();
      },
    );

    testWidgets(
      'DT3 onDisplay: renders multiple subfolders in creation order',
      (tester) async {
        await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-topik',
              folderName: 'TOPIK',
            );
          },
        );
        final folderRobot = FolderRobot(tester);

        await folderRobot.openFolder('TOPIK');
        await folderRobot.createSubfolder('Grammar');
        await folderRobot.createSubfolder('Vocabulary');
        await folderRobot.createSubfolder('Reading');

        await folderRobot.expectFoldersInOrder([
          'Grammar',
          'Vocabulary',
          'Reading',
        ]);
      },
    );

    testWidgets('DT5 onInsert: creates a deck inside an empty root folder', (
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

      await folderRobot.openFolder('Korean');
      await deckRobot.createDeck('Daily Words');

      await folderRobot.expectFolderVisible('Daily Words');
      final deck = await app.findDeckByName('Daily Words');
      expect(deck.folderId, 'folder-korean');
    });

    testWidgets(
      'DT4 onDisplay: keeps deck add action and hides subfolder add action after deck exists',
      (tester) async {
        await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-korean',
              folderName: 'Korean',
            );
            await app.seedDeckInFolder(
              folderId: 'folder-korean',
              deckId: 'deck-daily-words',
              deckName: 'Daily Words',
            );
          },
        );
        final folderRobot = FolderRobot(tester);

        await folderRobot.openFolderFromLibrary('Korean');

        await folderRobot.expectFolderVisible('Daily Words');
        await folderRobot.expectDeckCreationAvailableOnly();
      },
    );

    testWidgets('DT1 onUpdate: renames a root folder from its action menu', (
      tester,
    ) async {
      final app = await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(
            folderId: 'folder-old-name',
            folderName: 'Old Name',
          );
        },
      );
      final folderRobot = FolderRobot(tester);

      await folderRobot.renameRootFolder(from: 'Old Name', to: 'New Name');

      expect(await app.findFolderByNameOrNull('Old Name'), isNull);
      expect((await app.findFolderByName('New Name')).id, 'folder-old-name');
    });

    testWidgets(
      'DT2 onUpdate: keeps rename confirm disabled for a blank folder name',
      (tester) async {
        await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          seedData: (app) async {
            await app.seedRootFolder(
              folderId: 'folder-topik',
              folderName: 'TOPIK',
            );
          },
        );
        final folderRobot = FolderRobot(tester);

        await folderRobot.openRootFolderRenameDialog('TOPIK');
        await folderRobot.enterFolderName('');

        await folderRobot.expectRenameConfirmDisabled();
      },
    );

    testWidgets(
      'DT3 onUpdate: keeps subfolder data after renaming the parent folder',
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
        await folderRobot.renameCurrentFolder(from: 'TOPIK', to: 'TOPIK II');

        await folderRobot.expectFolderVisible('Grammar');
      },
    );

    testWidgets('DT1 onDelete: cancels root folder deletion', (tester) async {
      await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(
            folderId: 'folder-topik',
            folderName: 'TOPIK',
          );
        },
      );
      final folderRobot = FolderRobot(tester);

      await folderRobot.cancelDeleteRootFolder('TOPIK');

      await folderRobot.expectFolderVisible('TOPIK');
    });

    testWidgets('DT2 onDelete: deletes an empty root folder', (tester) async {
      final app = await pumpTestApp(
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

      await folderRobot.deleteRootFolder('Empty Folder');

      expect(await app.findFolderByNameOrNull('Empty Folder'), isNull);
    });

    testWidgets(
      'DT3 onDelete: deletes the full subtree when deleting a parent folder',
      (tester) async {
        final app = await pumpTestApp(
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

        await folderRobot.deleteRootFolder('TOPIK');

        await folderRobot.expectFolderAbsent('Grammar');
        expect(await app.findFolderByNameOrNull('TOPIK'), isNull);
        expect(await app.findFolderByNameOrNull('Grammar'), isNull);
      },
    );

    testWidgets(
      'DT4 onDelete: deleting the last subfolder unlocks the parent create choices',
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
        await folderRobot.deleteVisibleFolderRow('Grammar');

        await folderRobot.waitUntilVisible(find.text('This folder is empty'));
        await folderRobot.expectUnlockedCreateChoicesAvailable();
      },
    );

    testWidgets('DT1 onMove: reorders subfolders with drag and save', (
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
          await app.seedSubfolder(
            parentFolderId: 'folder-topik',
            folderId: 'folder-a',
            folderName: 'A',
            sortOrder: 0,
          );
          await app.seedSubfolder(
            parentFolderId: 'folder-topik',
            folderId: 'folder-b',
            folderName: 'B',
            sortOrder: 1,
          );
          await app.seedSubfolder(
            parentFolderId: 'folder-topik',
            folderId: 'folder-c',
            folderName: 'C',
            sortOrder: 2,
          );
        },
      );
      final folderRobot = FolderRobot(tester);

      await folderRobot.openFolderFromLibrary('TOPIK');
      await folderRobot.expectFoldersInOrder(['A', 'B', 'C']);
      await folderRobot.openCurrentFolderReorderMode();
      await folderRobot.dragFolderToTop('C');
      await folderRobot.saveReorder();

      await folderRobot.expectFoldersInOrder(['C', 'A', 'B']);
    });

    testWidgets('DT2 onMove: moves a subfolder to another parent', (
      tester,
    ) async {
      final app = await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(folderId: 'folder-a', folderName: 'A');
          await app.seedRootFolder(folderId: 'folder-b', folderName: 'B');
          await app.seedSubfolder(
            parentFolderId: 'folder-a',
            folderId: 'folder-grammar',
            folderName: 'Grammar',
          );
        },
      );
      final folderRobot = FolderRobot(tester);

      await folderRobot.openFolderFromLibrary('A');
      await folderRobot.moveVisibleFolderTo(
        folderName: 'Grammar',
        destinationName: 'B',
      );

      await folderRobot.expectFolderAbsent('Grammar');
      await folderRobot.waitUntilVisible(find.text('This folder is empty'));
      await folderRobot.tapBackToLibrary();
      await folderRobot.openFolderFromLibrary('B');
      await folderRobot.expectFolderVisible('Grammar');
      expect((await app.findFolderByName('Grammar')).parentId, 'folder-b');
    });

    testWidgets('DT3 onMove: excludes the moving folder from move targets', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(folderId: 'folder-a', folderName: 'A');
        },
      );
      final folderRobot = FolderRobot(tester);

      await folderRobot.openRootFolderMoveDialog('A');

      await folderRobot.expectMoveDestinationAbsent('A');
      await folderRobot.expectNoValidMoveDestinationFound();
    });

    testWidgets('DT4 onMove: excludes descendants from move targets', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(folderId: 'folder-a', folderName: 'A');
          await app.seedSubfolder(
            parentFolderId: 'folder-a',
            folderId: 'folder-b',
            folderName: 'B',
          );
          await app.seedSubfolder(
            parentFolderId: 'folder-b',
            folderId: 'folder-c',
            folderName: 'C',
          );
        },
      );
      final folderRobot = FolderRobot(tester);

      await folderRobot.openRootFolderMoveDialog('A');

      await folderRobot.expectMoveDestinationAbsent('B');
      await folderRobot.expectMoveDestinationAbsent('C');
      await folderRobot.expectNoValidMoveDestinationFound();
    });

    testWidgets('DT5 onMove: excludes deck-mode folders from move targets', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        surfaceSize: integrationTestCompactSurfaceSize,
        seedData: (app) async {
          await app.seedRootFolder(
            folderId: 'folder-deck',
            folderName: 'Deck Folder',
          );
          await app.seedDeckInFolder(
            folderId: 'folder-deck',
            deckId: 'deck-daily-words',
            deckName: 'Daily Words',
          );
          await app.seedRootFolder(folderId: 'folder-a', folderName: 'A');
          await app.seedSubfolder(
            parentFolderId: 'folder-a',
            folderId: 'folder-grammar',
            folderName: 'Grammar',
          );
        },
      );
      final folderRobot = FolderRobot(tester);

      await folderRobot.openFolderFromLibrary('A');
      await folderRobot.openVisibleFolderMoveDialog('Grammar');

      await folderRobot.expectMoveDestinationAbsent('Deck Folder');
    });

    testWidgets('DT1 onNavigate: opens a deep child folder through the tree', (
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
          await app.seedSubfolder(
            parentFolderId: 'folder-topik',
            folderId: 'folder-grammar',
            folderName: 'Grammar',
          );
          await app.seedSubfolder(
            parentFolderId: 'folder-grammar',
            folderId: 'folder-level-4',
            folderName: 'Level 4',
          );
        },
      );
      final folderRobot = FolderRobot(tester);

      await folderRobot.openFolderFromLibrary('TOPIK');
      await folderRobot.openVisibleFolder('Grammar');
      await folderRobot.openVisibleFolder('Level 4');

      await folderRobot.expectCurrentFolder('Level 4');
      await folderRobot.waitUntilVisible(find.text('This folder is empty'));
    });

    testWidgets('DT2 onNavigate: back returns from child folder to parent', (
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
          await app.seedSubfolder(
            parentFolderId: 'folder-topik',
            folderId: 'folder-grammar',
            folderName: 'Grammar',
          );
        },
      );
      final folderRobot = FolderRobot(tester);

      await folderRobot.openFolderFromLibrary('TOPIK');
      await folderRobot.openVisibleFolder('Grammar');
      await folderRobot.tapBackToFolder('TOPIK');

      await folderRobot.expectCurrentFolder('TOPIK');
      await folderRobot.expectFolderVisible('Grammar');
    });

    testWidgets(
      'DT3 onNavigate: current folder title and breadcrumb show the opened folder',
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
        await folderRobot.openVisibleFolder('Grammar');

        await folderRobot.expectCurrentFolder('Grammar');
        await folderRobot.expectFolderVisible('TOPIK');
      },
    );

    testWidgets(
      'DT4 onNavigate: starts study from a folder with a direct deck card',
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
              deckId: 'deck-daily-words',
              deckName: 'Daily Words',
              flashcardId: 'flashcard-daily',
              front: 'annyeong',
              back: 'hello',
            );
          },
        );
        final folderRobot = FolderRobot(tester);
        final studyRobot = StudyRobot(tester);

        await folderRobot.tapRootFolderStudyAction('folder-korean');
        await studyRobot.startDefaultStudyFromEntry();

        await studyRobot.expectStudySessionVisible(
          front: 'annyeong',
          back: 'hello',
        );
        expect(await app.latestOriginalStudySessionFlashcardIds(), [
          'flashcard-daily',
        ]);
      },
    );

    testWidgets('DT5 onNavigate: starts study from a parent folder subtree', (
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
          await app.seedSubfolder(
            parentFolderId: 'folder-topik',
            folderId: 'folder-grammar',
            folderName: 'Grammar',
          );
          await app.seedSubfolder(
            parentFolderId: 'folder-topik',
            folderId: 'folder-vocabulary',
            folderName: 'Vocabulary',
            sortOrder: 1,
          );
          await app.seedDeckWithFlashcardInFolder(
            folderId: 'folder-grammar',
            deckId: 'deck-grammar',
            deckName: 'Grammar Deck',
            flashcardId: 'flashcard-grammar',
            front: 'grammar front',
            back: 'grammar back',
            flashcardSortOrder: 0,
          );
          await app.seedDeckWithFlashcardInFolder(
            folderId: 'folder-vocabulary',
            deckId: 'deck-vocabulary',
            deckName: 'Vocabulary Deck',
            flashcardId: 'flashcard-vocabulary',
            front: 'vocabulary front',
            back: 'vocabulary back',
            flashcardSortOrder: 1,
          );
        },
      );
      final folderRobot = FolderRobot(tester);
      final studyRobot = StudyRobot(tester);

      await folderRobot.tapRootFolderStudyAction('folder-topik');
      await studyRobot.startDefaultStudyFromEntry();

      await studyRobot.expectStudySessionVisible(
        front: 'grammar front',
        back: 'grammar back',
      );
      expect(await app.latestOriginalStudySessionFlashcardIds(), [
        'flashcard-grammar',
        'flashcard-vocabulary',
      ]);
    });

    testWidgets(
      'DT6 onNavigate: shows validation when folder has no eligible cards',
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
        final studyRobot = StudyRobot(tester);

        await folderRobot.tapRootFolderStudyAction('folder-empty');
        await studyRobot.startDefaultStudyFromEntry();

        await studyRobot.expectNoEligibleFlashcardsMessage();
      },
    );

    testWidgets(
      'DT1 onExternalChange: keeps reordered subfolder order after app restart',
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
            await app.seedSubfolder(
              parentFolderId: 'folder-topik',
              folderId: 'folder-a',
              folderName: 'A',
              sortOrder: 0,
            );
            await app.seedSubfolder(
              parentFolderId: 'folder-topik',
              folderId: 'folder-b',
              folderName: 'B',
              sortOrder: 1,
            );
            await app.seedSubfolder(
              parentFolderId: 'folder-topik',
              folderId: 'folder-c',
              folderName: 'C',
              sortOrder: 2,
            );
          },
        );
        final folderRobot = FolderRobot(tester);

        await folderRobot.openFolderFromLibrary('TOPIK');
        await folderRobot.openCurrentFolderReorderMode();
        await folderRobot.dragFolderToTop('C');
        await folderRobot.saveReorder();
        await restartTestApp(
          tester,
          app,
          surfaceSize: integrationTestCompactSurfaceSize,
        );

        await folderRobot.openFolderFromLibrary('TOPIK');
        await folderRobot.expectFoldersInOrder(['C', 'A', 'B']);
      },
    );

    testWidgets(
      'DT2 onExternalChange: keeps a created root folder after app restart',
      (tester) async {
        final databaseFile = await createIntegrationTestDatabaseFile();
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          databaseFile: databaseFile,
        );
        final folderRobot = FolderRobot(tester);

        await folderRobot.createRootFolder('TOPIK');
        await restartTestApp(
          tester,
          app,
          surfaceSize: integrationTestCompactSurfaceSize,
        );

        await folderRobot.expectFolderVisible('TOPIK');
      },
    );

    testWidgets(
      'DT3 onExternalChange: keeps a created folder tree after app restart',
      (tester) async {
        final databaseFile = await createIntegrationTestDatabaseFile();
        final app = await pumpTestApp(
          tester,
          surfaceSize: integrationTestCompactSurfaceSize,
          databaseFile: databaseFile,
        );
        final folderRobot = FolderRobot(tester);

        await folderRobot.createRootFolder('TOPIK');
        await folderRobot.openFolderFromLibrary('TOPIK');
        await folderRobot.createSubfolder('Grammar');
        await folderRobot.openVisibleFolder('Grammar');
        await folderRobot.createSubfolder('Advanced Grammar');
        await restartTestApp(
          tester,
          app,
          surfaceSize: integrationTestCompactSurfaceSize,
        );

        await folderRobot.openFolderFromLibrary('TOPIK');
        await folderRobot.openVisibleFolder('Grammar');
        await folderRobot.expectFolderVisible('Advanced Grammar');
      },
    );
  });
}
