import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/router/route_names.dart';

import '../robots/deck_robot.dart';
import '../robots/flashcard_robot.dart';
import '../robots/folder_robot.dart';
import '../robots/memox_robot.dart';
import '../test_app.dart';

void flashcardFlowTests() {
  group('Flashcard flow', () {
    testWidgets(
      'DT5 onOpen: renders not-found error for missing flashcard-list deck',
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

    testWidgets(
      'DT6 onOpen: renders not-found error for missing flashcard edit target',
      (tester) async {
        const deckId = 'e2e-editor-error-deck';

        await pumpTestApp(
          tester,
          initialLocation:
              '${RoutePaths.library}/deck/$deckId/flashcards/e2e-missing-card/edit',
          seedData: (app) => app.seedDeckWithoutFlashcards(
            folderId: 'e2e-editor-error-folder',
            deckId: deckId,
            folderName: 'E2E Editor Error Folder',
            deckName: 'E2E Editor Error Deck',
          ),
        );

        await MemoxRobot(tester).expectErrorState(
          title: 'Something went wrong',
          message: 'Flashcard not found.',
        );

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('DT7 onInsert: creates a flashcard inside an opened deck', (
      tester,
    ) async {
      await _openEmptyDeck(tester, folderName: 'E2E Card Create Folder');

      final flashcard = FlashcardRobot(tester);
      await flashcard.expectEmptyDeck();
      await flashcard.createFlashcard(
        front: 'E2E Card Front',
        back: 'E2E Card Back',
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('DT8 onInsert: saves one flashcard and keeps creating next', (
      tester,
    ) async {
      await _openEmptyDeck(tester, folderName: 'E2E Card Next Folder');

      final flashcard = FlashcardRobot(tester);
      await flashcard.saveAndAddNext(
        front: 'E2E First Next Front',
        back: 'E2E First Next Back',
      );
      await flashcard.saveCurrentNewFlashcard(
        front: 'E2E Second Next Front',
        back: 'E2E Second Next Back',
      );

      expect(find.text('E2E First Next Front'), findsOneWidget);
      expect(find.text('E2E Second Next Front'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT9 onInsert: rejects blank flashcard front and back', (
      tester,
    ) async {
      await _openEmptyDeck(tester, folderName: 'E2E Card Validation Folder');

      final flashcard = FlashcardRobot(tester);
      await flashcard.attemptBlankCreate();

      expect(find.text('No flashcards yet'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT3 onDisplay: opens an existing flashcard in edit mode', (
      tester,
    ) async {
      await _openEmptyDeck(tester, folderName: 'E2E Card Read Folder');

      final flashcard = FlashcardRobot(tester);
      await flashcard.createFlashcard(
        front: 'E2E Read Front',
        back: 'E2E Read Back',
      );
      await flashcard.openFlashcardForEdit('E2E Read Front');

      expect(find.text('E2E Read Front'), findsOneWidget);
      expect(find.text('E2E Read Back'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT6 onDisplay: renders created flashcard row text in list', (
      tester,
    ) async {
      await _openEmptyDeck(tester, folderName: 'E2E Card Row Folder');

      final flashcard = FlashcardRobot(tester);
      await flashcard.createFlashcard(
        front: 'E2E Row Front',
        back: 'E2E Row Back',
      );

      expect(find.text('E2E Row Front'), findsOneWidget);
      expect(find.text('E2E Row Back'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT6 onUpdate: saves edited flashcard front and back text', (
      tester,
    ) async {
      await _openEmptyDeck(tester, folderName: 'E2E Card Update Folder');

      final flashcard = FlashcardRobot(tester);
      await flashcard.createFlashcard(
        front: 'E2E Before Front',
        back: 'E2E Before Back',
      );
      await flashcard.openFlashcardForEdit('E2E Before Front');
      await flashcard.updateCurrentFlashcard(
        fromFront: 'E2E Before Front',
        toFront: 'E2E After Front',
        toBack: 'E2E After Back',
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'DT5 onDelete: deletes an existing flashcard after confirmation',
      (tester) async {
        await _openEmptyDeck(tester, folderName: 'E2E Card Delete Folder');

        final flashcard = FlashcardRobot(tester);
        await flashcard.createFlashcard(
          front: 'E2E Delete Front',
          back: 'E2E Delete Back',
        );
        await flashcard.deleteFlashcard('E2E Delete Front');

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('DT6 onDelete: cancels flashcard deletion and keeps row', (
      tester,
    ) async {
      await _openEmptyDeck(tester, folderName: 'E2E Card Keep Folder');

      final flashcard = FlashcardRobot(tester);
      await flashcard.createFlashcard(
        front: 'E2E Keep Card Front',
        back: 'E2E Keep Card Back',
      );
      await flashcard.cancelDeleteFlashcard('E2E Keep Card Front');

      expect(find.text('E2E Keep Card Front'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT7 onDelete: bulk deletes selected flashcards', (
      tester,
    ) async {
      await _openEmptyDeck(tester, folderName: 'E2E Card Bulk Delete Folder');

      final flashcard = FlashcardRobot(tester);
      await flashcard.createFlashcard(
        front: 'E2E Bulk First',
        back: 'E2E Bulk First Back',
      );
      await flashcard.createFlashcard(
        front: 'E2E Bulk Second',
        back: 'E2E Bulk Second Back',
      );
      await flashcard.selectFlashcard('E2E Bulk First');
      await flashcard.tapVisible(find.text('E2E Bulk Second'));
      await flashcard.waitUntilVisible(find.text('2 selected'));
      await flashcard.bulkDeleteSelected();

      await flashcard.waitUntilVisible(find.text('No flashcards yet'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT1 onMove: moves selected flashcard to another deck', (
      tester,
    ) async {
      await _openTwoDecksAndOpenSource(tester);

      final flashcard = FlashcardRobot(tester);
      await flashcard.createFlashcard(
        front: 'E2E Move Front',
        back: 'E2E Move Back',
      );
      await flashcard.selectFlashcard('E2E Move Front');
      await flashcard.moveSelectedToDeck('E2E Target Deck');
      await flashcard.waitUntilVisible(find.text('No flashcards yet'));
      await flashcard.tapVisible(find.byTooltip('Back'));

      final deck = DeckRobot(tester);
      await deck.openDeck('E2E Target Deck');
      await flashcard.waitUntilVisible(find.text('E2E Move Front'));

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'DT1 onSelect: selects one flashcard without mutating content',
      (tester) async {
        await _openEmptyDeck(tester, folderName: 'E2E Card Select Folder');

        final flashcard = FlashcardRobot(tester);
        await flashcard.createFlashcard(
          front: 'E2E Select Front',
          back: 'E2E Select Back',
        );
        await flashcard.selectFlashcard('E2E Select Front');

        expect(find.text('1 selected'), findsOneWidget);
        expect(find.text('E2E Select Front'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('DT4 onSearchFilterSort: searches flashcards by back text', (
      tester,
    ) async {
      await _openEmptyDeck(tester, folderName: 'E2E Card Search Folder');

      final flashcard = FlashcardRobot(tester);
      await flashcard.createFlashcard(
        front: 'E2E Search Alpha',
        back: 'Shared Back',
      );
      await flashcard.createFlashcard(
        front: 'E2E Search Beta',
        back: 'Unique Back Needle',
      );
      await flashcard.searchFor('Needle');

      await flashcard.waitUntilVisible(find.text('E2E Search Beta'));
      await flashcard.waitUntilAbsent(find.text('E2E Search Alpha'));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'DT7 onSearchFilterSort: clears flashcard search and restores rows',
      (tester) async {
        await _openEmptyDeck(tester, folderName: 'E2E Card Restore Folder');

        final flashcard = FlashcardRobot(tester);
        await flashcard.createFlashcard(
          front: 'E2E Restore Front',
          back: 'E2E Restore Back',
        );
        await flashcard.searchFor('No matching card');
        await flashcard.waitUntilAbsent(find.text('E2E Restore Front'));
        await flashcard.clearSearch();
        await flashcard.waitUntilVisible(find.text('E2E Restore Front'));

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('DT11 onSearchFilterSort: searches flashcards by front text', (
      tester,
    ) async {
      await _openEmptyDeck(tester, folderName: 'E2E Card Front Search Folder');

      final flashcard = FlashcardRobot(tester);
      await flashcard.createFlashcard(
        front: 'E2E Front Needle',
        back: 'Shared Back One',
      );
      await flashcard.createFlashcard(
        front: 'E2E Front Haystack',
        back: 'Shared Back Two',
      );
      await flashcard.searchFor('Needle');

      await flashcard.waitUntilVisible(find.text('E2E Front Needle'));
      await flashcard.waitUntilAbsent(find.text('E2E Front Haystack'));
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _openEmptyDeck(
  WidgetTester tester, {
  required String folderName,
}) async {
  await pumpTestApp(tester);

  final folder = FolderRobot(tester);
  await folder.createRootFolder(folderName);
  await folder.openFolder(folderName);

  final deck = DeckRobot(tester);
  await deck.createDeck('E2E Card Deck');
  await deck.openDeck('E2E Card Deck');
}

Future<void> _openTwoDecksAndOpenSource(WidgetTester tester) async {
  await pumpTestApp(tester);

  final folder = FolderRobot(tester);
  await folder.createRootFolder('E2E Card Move Folder');
  await folder.openFolder('E2E Card Move Folder');

  final deck = DeckRobot(tester);
  await deck.createDeck('E2E Source Deck');
  await deck.createDeck('E2E Target Deck');
  await deck.openDeck('E2E Source Deck');
}
