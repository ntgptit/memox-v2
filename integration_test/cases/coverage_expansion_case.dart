import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/constants/app_constants.dart';

import '../robots/deck_robot.dart';
import '../robots/flashcard_robot.dart';
import '../robots/folder_robot.dart';
import '../robots/memox_robot.dart';
import '../robots/study_robot.dart';
import '../test_app.dart';

void coverageExpansionTests() {
  group('Coverage expansion flow', () {
    testWidgets('DT9 onOpen: opens Home branch directly from config', (
      tester,
    ) async {
      await _expectInitialTexts(
        tester,
        initialLocation: RoutePaths.home,
        texts: ["Today's study focus"],
      );
    });

    testWidgets('DT10 onOpen: opens Progress branch directly from config', (
      tester,
    ) async {
      await _expectInitialTexts(
        tester,
        initialLocation: RoutePaths.progress,
        texts: ['No active study sessions'],
      );
    });

    testWidgets('DT11 onOpen: opens Settings branch directly from config', (
      tester,
    ) async {
      await _expectInitialTexts(
        tester,
        initialLocation: RoutePaths.settings,
        texts: ['Appearance'],
      );
    });

    testWidgets('DT12 onOpen: opens Library branch on compact viewport', (
      tester,
    ) async {
      await _expectInitialTexts(
        tester,
        initialLocation: RoutePaths.library,
        surfaceSize: integrationTestCompactSurfaceSize,
        texts: ['No folders yet'],
      );
    });

    testWidgets('DT13 onOpen: renders error for invalid study entry type', (
      tester,
    ) async {
      await _expectInitialError(
        tester,
        initialLocation: '${RoutePaths.library}/study/invalid/e2e-entry',
        title: 'Something went wrong',
        message: 'Study action failed.',
      );
    });

    testWidgets('DT14 onOpen: renders error for missing study result route', (
      tester,
    ) async {
      await _expectInitialError(
        tester,
        initialLocation:
            '${RoutePaths.library}/study/session/e2e-missing-result/result',
        title: 'Something went wrong',
        message: 'Study action failed.',
      );
    });

    testWidgets('DT15 onOpen: renders error for missing flashcard edit deck', (
      tester,
    ) async {
      await _expectInitialError(
        tester,
        initialLocation:
            '${RoutePaths.library}/deck/e2e-missing-deck/flashcards/e2e-missing-card/edit',
        title: 'Something went wrong',
        message: 'Flashcard not found.',
      );
    });

    testWidgets(
      'DT16 onOpen: renders missing folder error on compact viewport',
      (tester) async {
        await _expectInitialError(
          tester,
          initialLocation: '${RoutePaths.library}/folder/e2e-compact-missing',
          surfaceSize: integrationTestCompactSurfaceSize,
          title: 'Something went wrong',
          message: 'Folder not found.',
        );
      },
    );

    testWidgets('DT17 onOpen: renders missing deck error on compact viewport', (
      tester,
    ) async {
      await _expectInitialError(
        tester,
        initialLocation:
            '${RoutePaths.library}/deck/e2e-compact-missing/flashcards',
        surfaceSize: integrationTestCompactSurfaceSize,
        title: 'Something went wrong',
        message: 'Deck not found.',
      );
    });

    testWidgets(
      'DT18 onOpen: renders unknown route error on compact viewport',
      (tester) async {
        await _expectInitialError(
          tester,
          initialLocation: '/unknown-compact-route',
          surfaceSize: integrationTestCompactSurfaceSize,
          title: 'Navigation error',
          message: 'Something went wrong.',
        );
      },
    );

    testWidgets('DT19 onOpen: opens today study entry from direct route', (
      tester,
    ) async {
      await _expectInitialTexts(
        tester,
        initialLocation: '${RoutePaths.library}/study/today',
        texts: ['Start a study session', 'SRS Review'],
      );
    });

    testWidgets('DT20 onOpen: opens create flashcard route for existing deck', (
      tester,
    ) async {
      const deckId = 'e2e-create-route-deck';
      await _expectInitialTexts(
        tester,
        initialLocation: '${RoutePaths.library}/deck/$deckId/flashcards/new',
        seedData: (app) => app.seedDeckWithoutFlashcards(
          folderId: 'e2e-create-route-folder',
          deckId: deckId,
          folderName: 'E2E Create Route Folder',
          deckName: 'E2E Create Route Deck',
        ),
        texts: ['New flashcard', 'Save flashcard'],
      );
    });

    testWidgets('DT8 onDisplay: dashboard shows zero due-card metric', (
      tester,
    ) async {
      await _expectInitialTexts(
        tester,
        initialLocation: RoutePaths.home,
        texts: ['Due today', '0'],
      );
    });

    testWidgets('DT9 onDisplay: dashboard shows empty library health', (
      tester,
    ) async {
      await _expectInitialTexts(
        tester,
        initialLocation: RoutePaths.home,
        texts: ['Library health', '0 folders · 0 decks · 0 cards'],
      );
    });

    testWidgets('DT10 onDisplay: dashboard shows empty mastery metric', (
      tester,
    ) async {
      await _expectInitialTexts(
        tester,
        initialLocation: RoutePaths.home,
        texts: ['Mastery', '0%'],
      );
    });

    testWidgets('DT11 onDisplay: progress empty state shows title', (
      tester,
    ) async {
      await _expectInitialTexts(
        tester,
        initialLocation: RoutePaths.progress,
        texts: ['No active study sessions'],
      );
    });

    testWidgets('DT12 onDisplay: progress empty state explains source route', (
      tester,
    ) async {
      await _expectInitialTexts(
        tester,
        initialLocation: RoutePaths.progress,
        texts: [
          'Start studying from Library. Sessions that are in progress or waiting to finalize will appear here.',
        ],
      );
    });

    testWidgets('DT13 onDisplay: settings appearance options render', (
      tester,
    ) async {
      await _expectInitialTexts(
        tester,
        initialLocation: RoutePaths.settings,
        texts: ['Appearance', 'System', 'Light', 'Dark'],
      );
    });

    testWidgets('DT14 onDisplay: settings language options render', (
      tester,
    ) async {
      await _expectInitialTexts(
        tester,
        initialLocation: RoutePaths.settings,
        texts: ['Language', 'English', 'Vietnamese'],
      );
    });

    testWidgets('DT15 onDisplay: settings speech options render', (
      tester,
    ) async {
      await _expectInitialTexts(
        tester,
        initialLocation: RoutePaths.settings,
        texts: ['Speech', 'Auto-play in study'],
      );
    });

    testWidgets('DT16 onDisplay: library empty state shows onboarding copy', (
      tester,
    ) async {
      await _expectInitialTexts(
        tester,
        initialLocation: RoutePaths.library,
        texts: [
          'No folders yet',
          'Create your first folder to start building your library.',
        ],
      );
    });

    testWidgets('DT17 onDisplay: unlocked folder shows both creation actions', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E Unlocked Display Folder');
      await folder.openFolder('E2E Unlocked Display Folder');

      await folder.waitUntilVisible(find.text('New subfolder'));
      await folder.waitUntilVisible(find.text('New deck'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT18 onDisplay: subfolder-mode folder shows child count', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E Subfolder Count Parent');
      await folder.openFolder('E2E Subfolder Count Parent');
      await folder.createSubfolder('E2E Subfolder Count Child');

      await folder.waitUntilVisible(find.text('Contains 1 subfolders'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT19 onDisplay: flashcard list shows empty deck state', (
      tester,
    ) async {
      const deckId = 'e2e-empty-overview-deck';
      await _expectInitialTexts(
        tester,
        initialLocation: '${RoutePaths.library}/deck/$deckId/flashcards',
        seedData: (app) => app.seedDeckWithoutFlashcards(
          folderId: 'e2e-empty-overview-folder',
          deckId: deckId,
          folderName: 'E2E Empty Overview Folder',
          deckName: 'E2E Empty Overview Deck',
        ),
        texts: ['E2E Empty Overview Deck', 'No flashcards yet'],
      );
    });

    testWidgets(
      'DT20 onDisplay: flashcard list keeps empty deck entry points',
      (tester) async {
        const deckId = 'e2e-never-studied-deck';
        await _expectInitialTexts(
          tester,
          initialLocation: '${RoutePaths.library}/deck/$deckId/flashcards',
          seedData: (app) => app.seedDeckWithoutFlashcards(
            folderId: 'e2e-never-studied-folder',
            deckId: deckId,
            folderName: 'E2E Never Studied Folder',
            deckName: 'E2E Never Studied Deck',
          ),
          texts: ['E2E Never Studied Deck', 'Add flashcard', 'Import'],
        );
      },
    );

    testWidgets('DT21 onDisplay: flashcard list shows seeded front and back', (
      tester,
    ) async {
      const deckId = 'e2e-seeded-list-deck';
      await _expectInitialTexts(
        tester,
        initialLocation: '${RoutePaths.library}/deck/$deckId/flashcards',
        seedData: (app) => app.seedDeckWithFlashcard(
          folderId: 'e2e-seeded-list-folder',
          deckId: deckId,
          flashcardId: 'e2e-seeded-list-card',
          folderName: 'E2E Seeded List Folder',
          deckName: 'E2E Seeded List Deck',
          front: 'E2E Seeded List Front',
          back: 'E2E Seeded List Back',
        ),
        texts: ['E2E Seeded List Front', 'E2E Seeded List Back'],
      );
    });

    testWidgets('DT22 onDisplay: study entry shows explanatory subtitle', (
      tester,
    ) async {
      const deckId = 'e2e-study-subtitle-deck';
      await _expectInitialTexts(
        tester,
        initialLocation: '${RoutePaths.library}/deck/$deckId/flashcards',
        seedData: (app) => app.seedDeckWithFlashcard(
          folderId: 'e2e-study-subtitle-folder',
          deckId: deckId,
          flashcardId: 'e2e-study-subtitle-card',
          folderName: 'E2E Study Subtitle Folder',
          deckName: 'E2E Study Subtitle Deck',
          front: 'E2E Study Subtitle Front',
          back: 'E2E Study Subtitle Back',
        ),
        texts: ['E2E Study Subtitle Front'],
      );

      final study = StudyRobot(tester);
      await study.openStudyEntryFromFlashcardList();
      await study.waitUntilVisible(
        find.text('Choose a flow and snapshot settings for this session.'),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT23 onDisplay: today study entry explains review-only mode', (
      tester,
    ) async {
      await _expectInitialTexts(
        tester,
        initialLocation: '${RoutePaths.library}/study/today',
        texts: ['Today supports SRS Review due and overdue cards in v1.'],
      );
    });

    testWidgets('DT3 onNavigate: dashboard Open library action opens Library', (
      tester,
    ) async {
      await pumpTestApp(tester, initialLocation: RoutePaths.home);

      final robot = MemoxRobot(tester);
      await robot.tapVisible(find.text('Open library').first);
      await robot.waitUntilVisible(find.text('No folders yet'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT4 onNavigate: progress empty action opens Library', (
      tester,
    ) async {
      await pumpTestApp(tester, initialLocation: RoutePaths.progress);

      final robot = MemoxRobot(tester);
      await robot.tapVisible(find.text('Open library').first);
      await robot.waitUntilVisible(find.text('No folders yet'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT5 onNavigate: Settings shell destination returns Library', (
      tester,
    ) async {
      await pumpTestApp(tester, initialLocation: RoutePaths.settings);

      final robot = MemoxRobot(tester);
      await robot.tapVisible(find.text('Library'));
      await robot.waitUntilVisible(find.text('No folders yet'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT6 onNavigate: Library shell destination opens Home', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final robot = MemoxRobot(tester);
      await robot.tapVisible(find.text('Home'));
      await robot.waitUntilVisible(find.text("Today's study focus"));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT7 onNavigate: Library shell destination opens Settings', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final robot = MemoxRobot(tester);
      await robot.tapVisible(find.text('Settings'));
      await robot.waitUntilVisible(find.text('Appearance'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT8 onNavigate: Home shell destination opens Progress', (
      tester,
    ) async {
      await pumpTestApp(tester, initialLocation: RoutePaths.home);

      final robot = MemoxRobot(tester);
      await robot.tapVisible(find.text('Progress'));
      await robot.waitUntilVisible(find.text('No active study sessions'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT12 onSearchFilterSort: folder search trims whitespace', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E Trim Alpha Folder');
      await folder.createRootFolder('E2E Trim Beta Folder');
      await folder.searchFor('  Beta  ');

      await folder.waitUntilVisible(find.text('E2E Trim Beta Folder'));
      await folder.waitUntilAbsent(find.text('E2E Trim Alpha Folder'));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'DT13 onSearchFilterSort: folder no-result clear action restores rows',
      (tester) async {
        await pumpTestApp(tester);

        final folder = FolderRobot(tester);
        await folder.createRootFolder('E2E Clear Button Folder');
        await folder.searchFor('missing folder term');
        await folder.tapVisible(find.text('Clear search'));
        await folder.waitUntilVisible(find.text('E2E Clear Button Folder'));

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('DT14 onSearchFilterSort: deck search trims whitespace', (
      tester,
    ) async {
      await _openFolderWithTwoDecks(tester);

      final deck = DeckRobot(tester);
      await deck.searchFor('  Beta  ');
      await deck.waitUntilVisible(find.text('E2E Search Beta Deck'));
      await deck.waitUntilAbsent(find.text('E2E Search Alpha Deck'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT15 onSearchFilterSort: flashcard back search trims spaces', (
      tester,
    ) async {
      await _openDeckWithTwoFlashcards(tester);

      final flashcard = FlashcardRobot(tester);
      await flashcard.searchFor('  Needle  ');
      await flashcard.waitUntilVisible(find.text('E2E Search Beta'));
      await flashcard.waitUntilAbsent(find.text('E2E Search Alpha'));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'DT16 onSearchFilterSort: unmatched flashcard search shows empty state',
      (tester) async {
        await _openDeckWithTwoFlashcards(tester);

        final flashcard = FlashcardRobot(tester);
        await flashcard.searchFor('missing flashcard term');
        await flashcard.waitUntilVisible(find.text('No flashcards yet'));
        await flashcard.waitUntilAbsent(find.text('E2E Search Alpha'));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DT17 onSearchFilterSort: flashcard clear after no-result restores rows',
      (tester) async {
        await _openDeckWithTwoFlashcards(tester);

        final flashcard = FlashcardRobot(tester);
        await flashcard.searchFor('missing flashcard term');
        await flashcard.clearSearch();
        await flashcard.waitUntilVisible(find.text('E2E Search Alpha'));
        await flashcard.waitUntilVisible(find.text('E2E Search Beta'));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('DT2 onSelect: selecting two flashcards updates count', (
      tester,
    ) async {
      await _openDeckWithTwoFlashcards(tester);

      final flashcard = FlashcardRobot(tester);
      await flashcard.selectFlashcard('E2E Search Alpha');
      await flashcard.tapVisible(find.text('E2E Search Beta'));
      await flashcard.waitUntilVisible(find.text('2 selected'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT3 onSelect: Select all expands partial selection', (
      tester,
    ) async {
      await _openDeckWithTwoFlashcards(tester);

      final flashcard = FlashcardRobot(tester);
      await flashcard.selectFlashcard('E2E Search Alpha');
      await flashcard.tapVisible(find.text('Select all'));
      await flashcard.waitUntilVisible(find.text('2 selected'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT4 onSelect: Clear removes complete selection', (
      tester,
    ) async {
      await _openDeckWithTwoFlashcards(tester);

      final flashcard = FlashcardRobot(tester);
      await flashcard.selectFlashcard('E2E Search Alpha');
      await flashcard.tapVisible(find.text('Select all'));
      await flashcard.tapVisible(find.text('Clear'));
      await flashcard.waitUntilAbsent(find.text('2 selected'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT5 onSelect: tapping selected row clears single selection', (
      tester,
    ) async {
      await _openDeckWithTwoFlashcards(tester);

      final flashcard = FlashcardRobot(tester);
      await flashcard.selectFlashcard('E2E Search Alpha');
      await flashcard.tapVisible(find.text('E2E Search Alpha'));
      await flashcard.waitUntilAbsent(find.text('1 selected'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT10 onUpdate: settings accepts Dark theme selection', (
      tester,
    ) async {
      await pumpTestApp(tester, initialLocation: RoutePaths.settings);

      final robot = MemoxRobot(tester);
      await robot.tapVisible(find.text('Dark'));
      await robot.waitUntilVisible(find.text('Settings updated.'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT11 onUpdate: settings accepts System theme selection', (
      tester,
    ) async {
      await pumpTestApp(tester, initialLocation: RoutePaths.settings);

      final robot = MemoxRobot(tester);
      await robot.tapVisible(find.text('System'));
      await robot.waitUntilVisible(find.text('Settings updated.'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT12 onUpdate: settings accepts Vietnamese locale selection', (
      tester,
    ) async {
      await pumpTestApp(tester, initialLocation: RoutePaths.settings);

      final robot = MemoxRobot(tester);
      await robot.tapVisible(find.text('Vietnamese'));
      await robot.waitUntilVisible(find.text('Settings updated.'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT13 onUpdate: study entry keeps new-study batch at max', (
      tester,
    ) async {
      const deckId = 'e2e-batch-increase-deck';
      await _expectInitialTexts(
        tester,
        initialLocation: '${RoutePaths.library}/deck/$deckId/flashcards',
        seedData: (app) => app.seedDeckWithFlashcard(
          folderId: 'e2e-batch-increase-folder',
          deckId: deckId,
          flashcardId: 'e2e-batch-increase-card',
          folderName: 'E2E Batch Increase Folder',
          deckName: 'E2E Batch Increase Deck',
          front: 'E2E Batch Increase Front',
          back: 'E2E Batch Increase Back',
        ),
        sharedPreferencesOverrides: const {
          AppConstants.sharedPrefsDefaultNewBatchSizeKey: 20,
        },
        texts: ['E2E Batch Increase Front'],
      );

      final study = StudyRobot(tester);
      await study.openStudyEntryFromFlashcardList();
      await study.tapVisible(find.byTooltip('Increase batch size'));
      await study.waitUntilVisible(find.text('Batch size: 20'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT10 onInsert: creates a second root folder in library', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E First Root Folder');
      await folder.createRootFolder('E2E Second Root Folder');

      expect(find.text('E2E First Root Folder'), findsOneWidget);
      expect(find.text('E2E Second Root Folder'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DT11 onInsert: creates flashcard with multiline content', (
      tester,
    ) async {
      await _openEmptyFlashcardDeck(tester);

      final flashcard = FlashcardRobot(tester);
      await flashcard.createFlashcard(
        front: 'E2E Multiline Front\nLine Two',
        back: 'E2E Multiline Back\nLine Two',
      );

      expect(find.text('E2E Multiline Front\nLine Two'), findsOneWidget);
      expect(find.text('E2E Multiline Back\nLine Two'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _expectInitialTexts(
  WidgetTester tester, {
  required String initialLocation,
  required List<String> texts,
  Size? surfaceSize,
  Map<String, Object> sharedPreferencesOverrides = const <String, Object>{},
  Future<void> Function(IntegrationTestAppHandle app)? seedData,
}) async {
  await pumpTestApp(
    tester,
    initialLocation: initialLocation,
    surfaceSize: surfaceSize,
    sharedPreferencesOverrides: sharedPreferencesOverrides,
    seedData: seedData,
  );

  final robot = MemoxRobot(tester);
  for (final text in texts) {
    await robot.waitUntilVisible(find.text(text));
  }
  expect(tester.takeException(), isNull);
}

Future<void> _expectInitialError(
  WidgetTester tester, {
  required String initialLocation,
  required String title,
  required String message,
  Size? surfaceSize,
}) async {
  await pumpTestApp(
    tester,
    initialLocation: initialLocation,
    surfaceSize: surfaceSize,
  );

  await MemoxRobot(tester).expectErrorState(title: title, message: message);
  expect(tester.takeException(), isNull);
}

Future<void> _openFolderWithTwoDecks(WidgetTester tester) async {
  await pumpTestApp(tester);

  final folder = FolderRobot(tester);
  await folder.createRootFolder('E2E Deck Search Trim Folder');
  await folder.openFolder('E2E Deck Search Trim Folder');

  final deck = DeckRobot(tester);
  await deck.createDeck('E2E Search Alpha Deck');
  await deck.createDeck('E2E Search Beta Deck');
}

Future<void> _openDeckWithTwoFlashcards(WidgetTester tester) async {
  await _openEmptyFlashcardDeck(tester);

  final flashcard = FlashcardRobot(tester);
  await flashcard.createFlashcard(
    front: 'E2E Search Alpha',
    back: 'Shared Back',
  );
  await flashcard.createFlashcard(
    front: 'E2E Search Beta',
    back: 'Unique Back Needle',
  );
}

Future<void> _openEmptyFlashcardDeck(WidgetTester tester) async {
  await pumpTestApp(tester);

  final folder = FolderRobot(tester);
  await folder.createRootFolder('E2E Expansion Card Folder');
  await folder.openFolder('E2E Expansion Card Folder');

  final deck = DeckRobot(tester);
  await deck.createDeck('E2E Expansion Card Deck');
  await deck.openDeck('E2E Expansion Card Deck');
}
