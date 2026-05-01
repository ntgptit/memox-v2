import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/router/route_names.dart';

import '../robots/deck_robot.dart';
import '../robots/flashcard_robot.dart';
import '../robots/folder_robot.dart';
import '../robots/memox_robot.dart';
import '../test_app.dart';

void deckFlowTests() {
  group('Deck flow', () {
    testWidgets(
      'DT4 onOpen: renders not-found error for missing flashcard list deck',
      (tester) async {
        await pumpTestApp(
          tester,
          initialLocation:
              '${RoutePaths.library}/deck/e2e-missing-deck/flashcards',
        );

        await MemoxRobot(tester).expectErrorState(
          title: 'Something went wrong',
          message: 'Deck not found.',
        );

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('DT4 onInsert: creates a deck inside an unlocked folder flow', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E Deck Folder');
      await folder.openFolder('E2E Deck Folder');

      final deck = DeckRobot(tester);
      await deck.createDeck('E2E Deck');

      expect(find.text('E2E Deck'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT5 onInsert: creates another deck in a deck-mode folder', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E Multi Deck Folder');
      await folder.openFolder('E2E Multi Deck Folder');

      final deck = DeckRobot(tester);
      await deck.createDeck('E2E First Deck');
      await deck.createDeck('E2E Second Deck');

      expect(find.text('E2E First Deck'), findsOneWidget);
      expect(find.text('E2E Second Deck'), findsOneWidget);
      expect(find.text('New subfolder'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT6 onInsert: cancels deck creation without changing folder', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E Deck Cancel Folder');
      await folder.openFolder('E2E Deck Cancel Folder');

      final deck = DeckRobot(tester);
      await deck.cancelDeckCreation('E2E Cancelled Deck');

      expect(find.text('This folder is empty'), findsOneWidget);
      expect(find.text('E2E Cancelled Deck'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'DT2 onDisplay: opens a deck flashcard list from the folder detail',
      (tester) async {
        await pumpTestApp(tester);

        final folder = FolderRobot(tester);
        await folder.createRootFolder('E2E Deck Read Folder');
        await folder.openFolder('E2E Deck Read Folder');

        final deck = DeckRobot(tester);
        await deck.createDeck('E2E Read Deck');
        await deck.openDeck('E2E Read Deck');

        expect(find.text('E2E Read Deck'), findsWidgets);
        expect(find.text('No flashcards yet'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('DT3 onUpdate: renames the opened deck from actions', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E Deck Update Folder');
      await folder.openFolder('E2E Deck Update Folder');

      final deck = DeckRobot(tester);
      await deck.createDeck('E2E Deck Before');
      await deck.openDeck('E2E Deck Before');
      await deck.renameCurrentDeck(
        from: 'E2E Deck Before',
        to: 'E2E Deck After',
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('DT4 onUpdate: duplicates deck content into current folder', (
      tester,
    ) async {
      const deckId = 'e2e-duplicate-source-deck';
      await pumpTestApp(
        tester,
        initialLocation: '${RoutePaths.library}/deck/$deckId/flashcards',
        seedData: (app) => app.seedDeckWithFlashcard(
          folderId: 'e2e-duplicate-folder',
          deckId: deckId,
          flashcardId: 'e2e-duplicate-card',
          folderName: 'E2E Duplicate Folder',
          deckName: 'E2E Source Deck',
          front: 'E2E Duplicate Front',
          back: 'E2E Duplicate Back',
        ),
      );

      final deck = DeckRobot(tester);
      await deck.duplicateCurrentDeckToCurrentFolder(
        sourceName: 'E2E Source Deck',
        duplicatedName: 'E2E Source Deck Copy',
      );

      expect(find.text('E2E Duplicate Front'), findsOneWidget);
      expect(find.text('E2E Duplicate Back'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT5 onUpdate: cancels deck rename without changing title', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E Deck Stable Folder');
      await folder.openFolder('E2E Deck Stable Folder');

      final deck = DeckRobot(tester);
      await deck.createDeck('E2E Stable Deck');
      await deck.openDeck('E2E Stable Deck');
      await deck.cancelRenameCurrentDeck(
        from: 'E2E Stable Deck',
        attemptedName: 'E2E Ignored Deck',
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('DT3 onDelete: deletes the opened deck after confirmation', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E Deck Delete Folder');
      await folder.openFolder('E2E Deck Delete Folder');

      final deck = DeckRobot(tester);
      await deck.createDeck('E2E Delete Deck');
      await deck.openDeck('E2E Delete Deck');
      await deck.deleteCurrentDeck('E2E Delete Deck');
      await deck.waitUntilVisible(find.text('This folder is empty'));

      expect(tester.takeException(), isNull);
    });

    testWidgets('DT4 onDelete: cancels deck deletion and keeps flashcards', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E Keep Deck Folder');
      await folder.openFolder('E2E Keep Deck Folder');

      final deck = DeckRobot(tester);
      await deck.createDeck('E2E Keep Deck');
      await deck.openDeck('E2E Keep Deck');
      await FlashcardRobot(
        tester,
      ).createFlashcard(front: 'E2E Keep Front', back: 'E2E Keep Back');
      await deck.cancelDeleteCurrentDeck('E2E Keep Deck');

      expect(find.text('E2E Keep Front'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT3 onSearchFilterSort: filters decks by name in a folder', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E Deck Search Folder');
      await folder.openFolder('E2E Deck Search Folder');

      final deck = DeckRobot(tester);
      await deck.createDeck('E2E Alpha Deck');
      await deck.createDeck('E2E Beta Deck');
      await deck.searchFor('Beta');

      await deck.waitUntilVisible(find.text('E2E Beta Deck'));
      await deck.waitUntilAbsent(find.text('E2E Alpha Deck'));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'DT6 onSearchFilterSort: clears deck search and restores rows',
      (tester) async {
        await pumpTestApp(tester);

        final folder = FolderRobot(tester);
        await folder.createRootFolder('E2E Deck Restore Folder');
        await folder.openFolder('E2E Deck Restore Folder');

        final deck = DeckRobot(tester);
        await deck.createDeck('E2E Restore Deck');
        await deck.searchFor('No matching deck');
        await deck.waitUntilAbsent(find.text('E2E Restore Deck'));
        await deck.clearSearch();
        await deck.waitUntilVisible(find.text('E2E Restore Deck'));

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DT9 onSearchFilterSort: matches deck search case-insensitively',
      (tester) async {
        await pumpTestApp(tester);

        final folder = FolderRobot(tester);
        await folder.createRootFolder('E2E Deck Case Folder');
        await folder.openFolder('E2E Deck Case Folder');

        final deck = DeckRobot(tester);
        await deck.createDeck('E2E Mixed Case Deck');
        await deck.createDeck('E2E Other Deck');
        await deck.searchFor('mixed case');

        await deck.waitUntilVisible(find.text('E2E Mixed Case Deck'));
        await deck.waitUntilAbsent(find.text('E2E Other Deck'));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DT10 onSearchFilterSort: shows empty state for unmatched deck search',
      (tester) async {
        await pumpTestApp(tester);

        final folder = FolderRobot(tester);
        await folder.createRootFolder('E2E Deck Empty Search Folder');
        await folder.openFolder('E2E Deck Empty Search Folder');

        final deck = DeckRobot(tester);
        await deck.createDeck('E2E Searchable Deck');
        await deck.searchFor('No matching deck');

        await deck.waitUntilVisible(find.text('No matching items'));
        await deck.waitUntilAbsent(find.text('E2E Searchable Deck'));
        expect(tester.takeException(), isNull);
      },
    );
  });
}
