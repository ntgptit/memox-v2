import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/router/route_names.dart';

import '../robots/memox_robot.dart';
import '../robots/study_robot.dart';
import '../test_app.dart';

void studyFlowTests() {
  group('Study flow', () {
    testWidgets('DT7 onOpen: renders error for missing study session route', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        initialLocation:
            '${RoutePaths.library}/study/session/e2e-missing-session',
      );

      await MemoxRobot(tester).expectErrorState(
        title: 'Something went wrong',
        message: 'Study action failed.',
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('DT7 onDisplay: shows study action for seeded flashcard list', (
      tester,
    ) async {
      const deckId = 'e2e-study-action-deck';
      const front = 'E2E Action Prompt';
      const back = 'E2E Action Answer';

      await pumpTestApp(
        tester,
        initialLocation: '${RoutePaths.library}/deck/$deckId/flashcards',
        seedData: (app) => app.seedDeckWithFlashcard(
          folderId: 'e2e-study-action-folder',
          deckId: deckId,
          flashcardId: 'e2e-study-action-card',
          folderName: 'E2E Study Action Folder',
          deckName: 'E2E Study Action Deck',
          front: front,
          back: back,
        ),
      );

      await StudyRobot(tester).expectFlashcardListVisible(front);

      expect(tester.takeException(), isNull);
    });

    testWidgets('DT4 onDisplay: renders study entry defaults before start', (
      tester,
    ) async {
      const deckId = 'e2e-study-entry-deck';
      const front = 'E2E Entry Prompt';
      const back = 'E2E Entry Answer';

      await pumpTestApp(
        tester,
        initialLocation: '${RoutePaths.library}/deck/$deckId/flashcards',
        seedData: (app) => app.seedDeckWithFlashcard(
          folderId: 'e2e-study-entry-folder',
          deckId: deckId,
          flashcardId: 'e2e-study-entry-card',
          folderName: 'E2E Study Entry Folder',
          deckName: 'E2E Study Entry Deck',
          front: front,
          back: back,
        ),
      );

      final study = StudyRobot(tester);
      await study.expectFlashcardListVisible(front);
      await study.openStudyEntryFromFlashcardList();
      await study.expectDefaultStudyEntrySettings();

      expect(tester.takeException(), isNull);
    });

    testWidgets('DT7 onUpdate: changes study entry batch size locally', (
      tester,
    ) async {
      const deckId = 'e2e-study-settings-deck';
      const front = 'E2E Settings Prompt';
      const back = 'E2E Settings Answer';

      await pumpTestApp(
        tester,
        initialLocation: '${RoutePaths.library}/deck/$deckId/flashcards',
        seedData: (app) => app.seedDeckWithFlashcard(
          folderId: 'e2e-study-settings-folder',
          deckId: deckId,
          flashcardId: 'e2e-study-settings-card',
          folderName: 'E2E Study Settings Folder',
          deckName: 'E2E Study Settings Deck',
          front: front,
          back: back,
        ),
      );

      final study = StudyRobot(tester);
      await study.expectFlashcardListVisible(front);
      await study.openStudyEntryFromFlashcardList();
      await study.decreaseAndRestoreBatchSize();

      expect(tester.takeException(), isNull);
    });

    testWidgets('DT8 onUpdate: selects SRS review flow before start', (
      tester,
    ) async {
      const deckId = 'e2e-study-review-flow-deck';
      const front = 'E2E Review Flow Prompt';
      const back = 'E2E Review Flow Answer';

      await pumpTestApp(
        tester,
        initialLocation: '${RoutePaths.library}/deck/$deckId/flashcards',
        seedData: (app) => app.seedDeckWithFlashcard(
          folderId: 'e2e-study-review-flow-folder',
          deckId: deckId,
          flashcardId: 'e2e-study-review-flow-card',
          folderName: 'E2E Study Review Flow Folder',
          deckName: 'E2E Study Review Flow Deck',
          front: front,
          back: back,
        ),
      );

      final study = StudyRobot(tester);
      await study.expectFlashcardListVisible(front);
      await study.openStudyEntryFromFlashcardList();
      await study.selectSrsReviewFlow();

      expect(tester.takeException(), isNull);
    });

    testWidgets('DT9 onUpdate: toggles study entry session settings locally', (
      tester,
    ) async {
      const deckId = 'e2e-study-toggle-deck';
      const front = 'E2E Toggle Prompt';
      const back = 'E2E Toggle Answer';

      await pumpTestApp(
        tester,
        initialLocation: '${RoutePaths.library}/deck/$deckId/flashcards',
        seedData: (app) => app.seedDeckWithFlashcard(
          folderId: 'e2e-study-toggle-folder',
          deckId: deckId,
          flashcardId: 'e2e-study-toggle-card',
          folderName: 'E2E Study Toggle Folder',
          deckName: 'E2E Study Toggle Deck',
          front: front,
          back: back,
        ),
      );

      final study = StudyRobot(tester);
      await study.expectFlashcardListVisible(front);
      await study.openStudyEntryFromFlashcardList();
      await study.toggleSessionSettings();

      expect(tester.takeException(), isNull);
    });

    testWidgets('DT1 onNavigate: starts a study session from a seeded deck', (
      tester,
    ) async {
      const deckId = 'e2e-study-deck';
      const front = 'E2E Prompt';
      const back = 'E2E Answer';

      await pumpTestApp(
        tester,
        initialLocation: '${RoutePaths.library}/deck/$deckId/flashcards',
        seedData: (app) => app.seedDeckWithFlashcard(
          folderId: 'e2e-study-folder',
          deckId: deckId,
          flashcardId: 'e2e-study-card',
          folderName: 'E2E Study Folder',
          deckName: 'E2E Study Deck',
          front: front,
          back: back,
        ),
      );

      final study = StudyRobot(tester);
      await study.expectFlashcardListVisible(front);
      await study.startStudyFromFlashcardList();
      await study.expectStudySessionVisible(front: front, back: back);

      expect(tester.takeException(), isNull);
    });
  });
}
