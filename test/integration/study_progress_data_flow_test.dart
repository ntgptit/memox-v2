import 'dart:math';

import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/config/app_config.dart';
import 'package:memox/app/config/env.dart';
import 'package:memox/app/di/content_providers.dart';
import 'package:memox/app/di/providers.dart';
import 'package:memox/app/router/app_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/datasources/local/daos/study_attempt_dao.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/datasources/local/daos/study_session_item_dao.dart';
import 'package:memox/data/datasources/local/local_transaction_runner.dart';
import 'package:memox/data/repositories/study_repo_impl.dart';
import 'package:memox/domain/enums/folder_content_mode.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/strategy/study_strategy.dart';
import 'package:memox/domain/study/strategy/study_strategy_factory.dart';
import 'package:memox/domain/study/usecases/study_usecases.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_secondary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/content_repository_harness.dart';

void main() {
  testWidgets(
    'DT1 onOpen: progress direct route loads active in-progress session data',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      await harness.driver.startNewStudy();

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('Active sessions'));

      expect(find.text('In progress'), findsOneWidget);
      expect(find.text('Current card: $_alphaFront'), findsOneWidget);
      expect(find.text('Review · round 1'), findsOneWidget);
    },
  );

  testWidgets(
    'DT2 onOpen: study result direct route loads completed session summary',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck(dueProgress: true);
      final ready = await harness.driver.startReadySrsReview();
      await harness.driver.finalize(ready);

      await harness.pumpApp(tester, _studyResultLocation(ready.session.id));
      await _pumpUntilFound(tester, find.text('Session summary'));

      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Attempts'), findsOneWidget);
      expect(find.text('Correct'), findsOneWidget);
    },
  );

  testWidgets(
    'DT3 onOpen: study entry direct route loads start state without resume',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();

      await harness.pumpApp(tester, _studyEntryLocation(StudyEntryType.deck));
      await _pumpUntilFound(tester, find.text('Start a study session'));

      expect(find.widgetWithText(MxPrimaryButton, 'Study'), findsOneWidget);
      expect(find.text('Session in progress'), findsNothing);
      expect(find.text('Restart'), findsNothing);
    },
  );

  testWidgets(
    'DT1 onNavigate: deck study data flows from flashcard list to session and progress',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      await harness.pumpApp(tester, _flashcardListLocation(_deckId));
      await _pumpUntilFound(tester, find.text(_alphaFront));

      expect(find.text(_alphaFront), findsOneWidget);
      expect(find.text(_alphaBack), findsOneWidget);

      await _tapText(tester, 'Study');
      await _pumpUntilFound(tester, find.text('Start a study session'));

      await _tapText(tester, 'Study');
      await _pumpUntilFound(tester, find.text('Review'));

      expect(find.text(_alphaFront), findsOneWidget);
      expect(find.text(_alphaBack), findsOneWidget);

      await tester.tap(find.text('Progress').last);
      await _pumpUntilFound(tester, find.text('Active sessions'));

      expect(find.text('New Study · Deck'), findsOneWidget);
      expect(find.text('Current card: $_alphaFront'), findsOneWidget);
      expect(find.text('0 of 10 study steps · 2 remaining'), findsOneWidget);

      await _tapText(tester, 'Continue');
      await _pumpUntilFound(tester, find.text('Review'));

      expect(find.text(_alphaFront), findsOneWidget);
      expect(find.text(_alphaBack), findsOneWidget);
    },
  );

  testWidgets(
    'DT2 onNavigate: study entry resume card opens the active session data',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      await harness.driver.startNewStudy();

      await harness.pumpApp(tester, _studyEntryLocation(StudyEntryType.deck));
      await _pumpUntilFound(tester, find.text('Session in progress'));

      expect(find.text('Review · round 1'), findsOneWidget);

      await _tapText(tester, 'Continue');
      await _pumpUntilFound(tester, find.text('Review'));

      expect(find.text(_alphaFront), findsOneWidget);
      expect(find.text(_alphaBack), findsOneWidget);
    },
  );

  testWidgets(
    'DT3 onNavigate: folder study data flows into progress with folder entry label',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();

      await harness.pumpApp(tester, _studyEntryLocation(StudyEntryType.folder));
      await _pumpUntilFound(tester, find.text('Start a study session'));

      await _tapText(tester, 'Study');
      await _pumpUntilFound(tester, find.text('Review'));

      expect(find.text(_alphaFront), findsOneWidget);

      await tester.tap(find.text('Progress').last);
      await _pumpUntilFound(tester, find.text('Active sessions'));

      expect(find.text('New Study · Folder'), findsOneWidget);
      expect(find.text('Current card: $_alphaFront'), findsOneWidget);
    },
  );

  testWidgets(
    'DT4 onNavigate: progress continue opens in-progress review session',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      await harness.driver.startNewStudy();

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('Active sessions'));

      await _tapText(tester, 'Continue');
      await _pumpUntilFound(tester, find.text('Review'));

      expect(find.text(_alphaFront), findsOneWidget);
      expect(find.text(_alphaBack), findsOneWidget);
    },
  );

  testWidgets(
    'DT5 onNavigate: progress continue opens ready-to-finalize session panel',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck(dueProgress: true);
      await harness.driver.startReadySrsReview();

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('Ready to finalize'));

      await _tapText(tester, 'Continue');
      await _pumpUntilFound(
        tester,
        find.text(
          'All required items are passed. Finalize to commit SRS progress.',
        ),
      );

      expect(find.text('Ready to finalize'), findsWidgets);
      expect(find.text('Finalize'), findsOneWidget);
    },
  );

  testWidgets(
    'DT6 onNavigate: review back fallback returns to library overview',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final session = await harness.driver.startNewStudy();

      await harness.pumpApp(tester, _studySessionLocation(session.session.id));
      await _pumpUntilFound(tester, find.text('Review'));

      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await _pumpUntilFound(tester, find.text('Folders'));

      expect(find.text('Integration Folder'), findsOneWidget);
    },
  );

  testWidgets(
    'DT7 onNavigate: result study again opens same deck study entry',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck(dueProgress: true);
      final ready = await harness.driver.startReadySrsReview();
      await harness.driver.finalize(ready);

      await harness.pumpApp(tester, _studyResultLocation(ready.session.id));
      await _pumpUntilFound(tester, find.text('Study'));

      await _tapText(tester, 'Study');
      await _pumpUntilFound(tester, find.text('Start a study session'));

      expect(find.text('Session in progress'), findsNothing);
      expect(find.widgetWithText(MxPrimaryButton, 'Study'), findsOneWidget);
    },
  );

  testWidgets('DT8 onNavigate: progress empty action opens library overview', (
    tester,
  ) async {
    final harness = await _IntegrationHarness.create(tester);
    await harness.seedDeck();

    await harness.pumpApp(tester, RoutePaths.progress);
    await _pumpUntilFound(tester, find.text('No active study sessions'));

    await _tapText(tester, 'View library');
    await _pumpUntilFound(tester, find.text('Folders'));

    expect(find.text('Integration Folder'), findsOneWidget);
  });

  testWidgets(
    'DT9 onNavigate: continuing after stopping with two mode queues resumes Match',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final sessionId = await _startStudyAndStopAtMode(
        tester,
        harness,
        StudyMode.match,
      );

      await _openStudyEntryAndContinue(tester, harness);
      await _pumpUntilFound(tester, find.text('Match'));

      expect(await harness.distinctModeCount(sessionId), 2);
      expect(await harness.currentStudyMode(sessionId), StudyMode.match);
      expect(find.text('Match'), findsOneWidget);
      expect(find.text(_alphaFront), findsOneWidget);
    },
  );

  testWidgets(
    'DT10 onNavigate: continuing after stopping with three mode queues resumes Guess',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final sessionId = await _startStudyAndStopAtMode(
        tester,
        harness,
        StudyMode.guess,
      );

      await _openStudyEntryAndContinue(tester, harness);
      await _pumpUntilFound(tester, find.text('Guess'));

      expect(await harness.distinctModeCount(sessionId), 3);
      expect(await harness.currentStudyMode(sessionId), StudyMode.guess);
      expect(find.text('Guess'), findsOneWidget);
      expect(find.text(_alphaFront), findsOneWidget);
    },
  );

  testWidgets(
    'DT11 onNavigate: continuing after stopping with four mode queues resumes Recall',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final sessionId = await _startStudyAndStopAtMode(
        tester,
        harness,
        StudyMode.recall,
      );

      await _openStudyEntryAndContinue(tester, harness);
      await _pumpUntilFound(tester, find.text('Recall'));

      expect(await harness.distinctModeCount(sessionId), 4);
      expect(await harness.currentStudyMode(sessionId), StudyMode.recall);
      expect(find.text('Recall'), findsOneWidget);
      expect(find.text(_alphaFront), findsOneWidget);
    },
  );

  testWidgets(
    'DT12 onNavigate: continuing after stopping with five mode queues resumes Fill',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final sessionId = await _startStudyAndStopAtMode(
        tester,
        harness,
        StudyMode.fill,
      );

      await _openStudyEntryAndContinue(tester, harness);
      await _pumpUntilFound(tester, find.text('Fill'));

      expect(await harness.distinctModeCount(sessionId), 5);
      expect(await harness.currentStudyMode(sessionId), StudyMode.fill);
      expect(find.text('Fill'), findsOneWidget);
      expect(find.text(_alphaBack), findsOneWidget);
    },
  );

  testWidgets(
    'DT13 onNavigate: progress continue after cached two mode queues resumes Match',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final sessionId = await _startStudyWithCachedProgressAndStopAtMode(
        tester,
        harness,
        StudyMode.match,
      );

      await _openProgressAndContinueAtMode(
        tester,
        modeRoundLabel: 'Match · round 1',
        modeTitle: 'Match',
      );

      expect(await harness.distinctModeCount(sessionId), 2);
      expect(await harness.currentStudyMode(sessionId), StudyMode.match);
      expect(find.text(_alphaFront), findsOneWidget);
    },
  );

  testWidgets(
    'DT14 onNavigate: progress continue after cached three mode queues resumes Guess',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final sessionId = await _startStudyWithCachedProgressAndStopAtMode(
        tester,
        harness,
        StudyMode.guess,
      );

      await _openProgressAndContinueAtMode(
        tester,
        modeRoundLabel: 'Guess · round 1',
        modeTitle: 'Guess',
      );

      expect(await harness.distinctModeCount(sessionId), 3);
      expect(await harness.currentStudyMode(sessionId), StudyMode.guess);
      expect(find.text(_alphaFront), findsOneWidget);
    },
  );

  testWidgets(
    'DT15 onNavigate: progress continue after cached four mode queues resumes Recall',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final sessionId = await _startStudyWithCachedProgressAndStopAtMode(
        tester,
        harness,
        StudyMode.recall,
      );

      await _openProgressAndContinueAtMode(
        tester,
        modeRoundLabel: 'Recall · round 1',
        modeTitle: 'Recall',
      );

      expect(await harness.distinctModeCount(sessionId), 4);
      expect(await harness.currentStudyMode(sessionId), StudyMode.recall);
      expect(find.text(_alphaFront), findsOneWidget);
    },
  );

  testWidgets(
    'DT16 onNavigate: progress continue after cached five mode queues resumes Fill',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final sessionId = await _startStudyWithCachedProgressAndStopAtMode(
        tester,
        harness,
        StudyMode.fill,
      );

      await _openProgressAndContinueAtMode(
        tester,
        modeRoundLabel: 'Fill · round 1',
        modeTitle: 'Fill',
      );

      expect(await harness.distinctModeCount(sessionId), 5);
      expect(await harness.currentStudyMode(sessionId), StudyMode.fill);
      expect(find.text(_alphaBack), findsOneWidget);
    },
  );

  testWidgets(
    'DT17 onNavigate: Review auto-submit enters Match board before DB writes',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();

      await harness.pumpApp(tester, _studyEntryLocation(StudyEntryType.deck));
      await _pumpUntilFound(tester, find.text('Start a study session'));
      await _tapText(tester, 'Study');
      await _pumpUntilFound(tester, find.text('Review'));
      final sessionId = await harness.singleActiveSessionId();

      await _advanceReviewToMatch(tester);

      expect(find.text('Match'), findsOneWidget);
      expect(find.text(_alphaBack), findsOneWidget);
      expect(find.text(_betaBack), findsOneWidget);
      expect(find.text(_alphaFront), findsOneWidget);
      expect(find.text(_betaFront), findsOneWidget);
      expect(await harness.attemptCountForMode(sessionId, StudyMode.match), 0);
    },
  );

  testWidgets(
    'DT1 onUpdate: cancelling progress session removes resume candidate across screens',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final session = await harness.driver.startNewStudy();

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('Active sessions'));

      await _tapText(tester, 'Cancel');
      await _pumpUntilFound(tester, find.text('Cancel this study session?'));
      await tester.tap(find.text('Cancel').last);
      await _pumpUntilFound(tester, find.text('No active study sessions'));

      expect(await harness.sessionStatus(session.session.id), 'cancelled');

      await harness.pumpApp(tester, _studyEntryLocation(StudyEntryType.deck));
      await _pumpUntilFound(tester, find.text('Start a study session'));

      expect(find.text('Session in progress'), findsNothing);
      expect(find.text('Restart'), findsNothing);
      expect(find.widgetWithText(MxPrimaryButton, 'Study'), findsOneWidget);
    },
  );

  testWidgets(
    'DT2 onUpdate: finalizing ready progress session updates result data',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck(dueProgress: true);
      final session = await harness.driver.startReadySrsReview();

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('Ready to finalize'));

      await _tapText(tester, 'Finalize');
      await _pumpUntilFound(tester, find.text('No active study sessions'));

      expect(await harness.sessionStatus(session.session.id), 'completed');
      expect(await harness.currentBox('integration-card-alpha'), 2);

      await harness.pumpApp(tester, _studyResultLocation(session.session.id));
      await _pumpUntilFound(tester, find.text('Session summary'));

      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('100%'), findsWidgets);
    },
  );

  testWidgets(
    'DT3 onUpdate: retrying failed finalize session clears retry state',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck(dueProgress: true);
      final session = await harness.driver.startReadySrsReview();
      await harness.setSessionStatus(
        session.session.id,
        SessionStatus.failedToFinalize,
      );

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('Finalize failed'));

      expect(find.text('Retry'), findsOneWidget);

      await _tapText(tester, 'Retry');
      await _pumpUntilFound(tester, find.text('No active study sessions'));

      expect(await harness.sessionStatus(session.session.id), 'completed');

      await harness.pumpApp(tester, _studyResultLocation(session.session.id));
      await _pumpUntilFound(tester, find.text('Session summary'));

      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Finalize failed. Retry when ready.'), findsNothing);
    },
  );

  testWidgets(
    'DT4 onUpdate: dismissing progress cancel leaves active session unchanged',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final session = await harness.driver.startNewStudy();

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('Active sessions'));

      await _tapText(tester, 'Cancel');
      await _pumpUntilFound(tester, find.text('Cancel this study session?'));
      await tester.tap(find.widgetWithText(MxSecondaryButton, 'Cancel').last);
      await tester.pump(const Duration(milliseconds: 200));

      expect(await harness.sessionStatus(session.session.id), 'in_progress');
      expect(find.text('In progress'), findsOneWidget);
    },
  );

  testWidgets(
    'DT5 onUpdate: cancelling ready session from study screen writes cancelled result',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck(dueProgress: true);
      final ready = await harness.driver.startReadySrsReview();

      await harness.pumpApp(tester, _studySessionLocation(ready.session.id));
      await _pumpUntilFound(tester, find.text('Ready to finalize'));

      await tester.tap(find.byIcon(Icons.close_rounded).first);
      await _pumpUntilFound(tester, find.text('Cancel this session?'));
      await tester.tap(find.text('Cancel').last);
      await _pumpUntilFound(tester, find.text('Session summary'));

      expect(await harness.sessionStatus(ready.session.id), 'cancelled');
      expect(find.text('Cancelled'), findsOneWidget);
    },
  );

  testWidgets(
    'DT6 onUpdate: finalizing ready session from study screen writes completed result',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck(dueProgress: true);
      final ready = await harness.driver.startReadySrsReview();

      await harness.pumpApp(tester, _studySessionLocation(ready.session.id));
      await _pumpUntilFound(tester, find.text('Ready to finalize'));

      await _tapText(tester, 'Finalize');
      await _pumpUntilFound(tester, find.text('Session summary'));

      expect(await harness.sessionStatus(ready.session.id), 'completed');
      expect(find.text('Completed'), findsOneWidget);
    },
  );

  testWidgets(
    'DT7 onUpdate: review auto-submit advances session data visible in progress',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck(includeSecondCard: false);
      final session = await harness.driver.startNewStudy(batchSize: 1);

      await harness.pumpApp(tester, _studySessionLocation(session.session.id));
      await _pumpUntilFound(tester, find.text('Review'));
      await tester.pump(const Duration(milliseconds: 2500));
      await _pumpUntilFound(tester, find.text('Match'));

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('Active sessions'));

      expect(find.text('Match · round 1'), findsOneWidget);
      expect(find.text('Current card: $_alphaFront'), findsOneWidget);
    },
  );

  testWidgets(
    'DT8 onUpdate: restarting from study entry cancels old session and opens new data',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final oldSession = await harness.driver.startNewStudy();

      await harness.pumpApp(tester, _studyEntryLocation(StudyEntryType.deck));
      await _pumpUntilFound(tester, find.text('Session in progress'));

      await tester.scrollUntilVisible(
        find.text('Start'),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text('Start'));
      await _pumpUntilFound(
        tester,
        find.text(
          'Starting a new session will cancel the current unfinished session.',
        ),
      );
      await tester.tap(find.text('Start').last);
      await _pumpUntilFound(tester, find.text('Review'));

      expect(await harness.sessionStatus(oldSession.session.id), 'cancelled');
      expect(await harness.activeSessionCount(), 1);
      expect(find.text(_alphaFront), findsOneWidget);
    },
  );

  testWidgets(
    'DT9 onUpdate: restarting after stopping with two mode queues starts fresh Review',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final previousSessionId = await _startStudyAndStopAtMode(
        tester,
        harness,
        StudyMode.match,
      );

      final restartedSessionId = await _openStudyEntryAndRestart(
        tester,
        harness,
      );

      expect(await harness.distinctModeCount(previousSessionId), 2);
      expect(
        await harness.sessionStatus(previousSessionId),
        SessionStatus.cancelled.storageValue,
      );
      expect(
        await harness.restartedFromSessionId(restartedSessionId),
        previousSessionId,
      );
      expect(await harness.activeSessionCount(), 1);
      expect(
        await harness.currentStudyMode(restartedSessionId),
        StudyMode.review,
      );
      expect(find.text('Review'), findsOneWidget);
      expect(find.text(_alphaFront), findsOneWidget);
    },
  );

  testWidgets(
    'DT10 onUpdate: restarting after stopping with three mode queues starts fresh Review',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final previousSessionId = await _startStudyAndStopAtMode(
        tester,
        harness,
        StudyMode.guess,
      );

      final restartedSessionId = await _openStudyEntryAndRestart(
        tester,
        harness,
      );

      expect(await harness.distinctModeCount(previousSessionId), 3);
      expect(
        await harness.sessionStatus(previousSessionId),
        SessionStatus.cancelled.storageValue,
      );
      expect(
        await harness.restartedFromSessionId(restartedSessionId),
        previousSessionId,
      );
      expect(await harness.activeSessionCount(), 1);
      expect(
        await harness.currentStudyMode(restartedSessionId),
        StudyMode.review,
      );
      expect(find.text('Review'), findsOneWidget);
      expect(find.text(_alphaFront), findsOneWidget);
    },
  );

  testWidgets(
    'DT11 onUpdate: restarting after stopping with four mode queues starts fresh Review',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final previousSessionId = await _startStudyAndStopAtMode(
        tester,
        harness,
        StudyMode.recall,
      );

      final restartedSessionId = await _openStudyEntryAndRestart(
        tester,
        harness,
      );

      expect(await harness.distinctModeCount(previousSessionId), 4);
      expect(
        await harness.sessionStatus(previousSessionId),
        SessionStatus.cancelled.storageValue,
      );
      expect(
        await harness.restartedFromSessionId(restartedSessionId),
        previousSessionId,
      );
      expect(await harness.activeSessionCount(), 1);
      expect(
        await harness.currentStudyMode(restartedSessionId),
        StudyMode.review,
      );
      expect(find.text('Review'), findsOneWidget);
      expect(find.text(_alphaFront), findsOneWidget);
    },
  );

  testWidgets(
    'DT12 onUpdate: restarting after stopping with five mode queues starts fresh Review',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final previousSessionId = await _startStudyAndStopAtMode(
        tester,
        harness,
        StudyMode.fill,
      );

      final restartedSessionId = await _openStudyEntryAndRestart(
        tester,
        harness,
      );

      expect(await harness.distinctModeCount(previousSessionId), 5);
      expect(
        await harness.sessionStatus(previousSessionId),
        SessionStatus.cancelled.storageValue,
      );
      expect(
        await harness.restartedFromSessionId(restartedSessionId),
        previousSessionId,
      );
      expect(await harness.activeSessionCount(), 1);
      expect(
        await harness.currentStudyMode(restartedSessionId),
        StudyMode.review,
      );
      expect(find.text('Review'), findsOneWidget);
      expect(find.text(_alphaFront), findsOneWidget);
    },
  );

  testWidgets(
    'DT13 onUpdate: Match mismatch writes retry only after board completion',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final sessionId = await _startStudyAndLeaveMatchRetry(tester, harness);

      final attempts = await harness.attemptResultsForMode(
        sessionId,
        StudyMode.match,
      );
      expect(attempts, <String, String>{
        'integration-card-alpha': AttemptGrade.incorrect.storageValue,
        'integration-card-beta': AttemptGrade.correct.storageValue,
      });
      expect(await harness.currentStudyMode(sessionId), StudyMode.match);
      expect(await harness.currentRoundIndex(sessionId), 2);
      expect(await harness.pendingFlashcardIds(sessionId), <String>[
        'integration-card-alpha',
      ]);
    },
  );

  testWidgets('DT14 onUpdate: completing Match retry advances to Guess', (
    tester,
  ) async {
    final harness = await _IntegrationHarness.create(tester);
    await harness.seedDeck();
    final sessionId = await _startStudyAndLeaveMatchRetry(tester, harness);

    await _matchPair(tester, back: _alphaBack, front: _alphaFront);
    await _pumpUntilFound(tester, find.text('Guess'));

    final attempts = await harness.attemptResultsForMode(
      sessionId,
      StudyMode.match,
    );
    expect(
      attempts['integration-card-alpha'],
      AttemptGrade.correct.storageValue,
    );
    expect(await harness.currentStudyMode(sessionId), StudyMode.guess);
  });

  testWidgets(
    'DT15 onUpdate: Progress Continue opens persisted Match retry round',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final sessionId = await _startStudyAndLeaveMatchRetry(tester, harness);

      await tester.tap(find.text('Progress').last);
      await _pumpUntilFound(tester, find.text('Match · round 2'));
      await _tapText(tester, 'Continue');
      await _pumpUntilFound(tester, find.text('Match'));

      expect(await harness.currentRoundIndex(sessionId), 2);
      expect(find.text(_alphaBack), findsOneWidget);
      expect(find.text(_alphaFront), findsOneWidget);
      expect(find.text(_betaBack), findsNothing);
      expect(find.text(_betaFront), findsNothing);
    },
  );

  testWidgets(
    'DT1 onExternalChange: completing session refreshes cached Study Entry resume candidate',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck(dueProgress: true);
      final ready = await harness.driver.startReadySrsReview();

      await harness.pumpApp(tester, _studyEntryLocation(StudyEntryType.deck));
      await _pumpUntilFound(tester, find.text('Session in progress'));
      expect(find.text('Ready to finalize'), findsOneWidget);

      _goToLocation(tester, _studySessionLocation(ready.session.id));
      await tester.pump(const Duration(milliseconds: 100));
      await _pumpUntilFound(tester, find.text('Finalize'));
      await _tapText(tester, 'Finalize');
      await _pumpUntilFound(tester, find.text('Session summary'));
      expect(await harness.sessionStatus(ready.session.id), 'completed');

      _goToLocation(tester, _studyEntryLocation(StudyEntryType.deck));
      await tester.pump(const Duration(milliseconds: 100));
      await _pumpUntilFound(tester, find.text('Start a study session'));

      expect(find.text('Session in progress'), findsNothing);
      expect(find.widgetWithText(MxPrimaryButton, 'Study'), findsOneWidget);
    },
  );

  testWidgets(
    'DT1 onDisplay: terminal sessions are excluded from progress active data',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final completed = await harness.driver.startNewStudy();
      final cancelled = await harness.driver.startNewStudy();
      await harness.setSessionStatus(
        completed.session.id,
        SessionStatus.completed,
      );
      await harness.setSessionStatus(
        cancelled.session.id,
        SessionStatus.cancelled,
      );

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('No active study sessions'));

      expect(find.text('Completed'), findsNothing);
      expect(find.text('Cancelled'), findsNothing);
      expect(find.text('New Study · Deck'), findsNothing);
    },
  );

  testWidgets('DT2 onDisplay: progress with no sessions shows empty state', (
    tester,
  ) async {
    final harness = await _IntegrationHarness.create(tester);

    await harness.pumpApp(tester, RoutePaths.progress);
    await _pumpUntilFound(tester, find.text('No active study sessions'));

    expect(find.text('View library'), findsOneWidget);
    expect(find.text('Active sessions'), findsOneWidget);
  });

  testWidgets(
    'DT3 onDisplay: progress mixed statuses show counters and labels',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      await harness.driver.startNewStudy();
      await harness.makeCardsDue();
      await harness.driver.startReadySrsReview();
      final failed = await harness.driver.startReadySrsReview();
      await harness.setSessionStatus(
        failed.session.id,
        SessionStatus.failedToFinalize,
      );

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('Active sessions'));

      expect(find.text('Active'), findsWidgets);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Needs retry'), findsOneWidget);
      expect(find.text('Finalize failed'), findsWidgets);
      await _scrollUntilAnyFound(tester, find.text('Ready to finalize'));
      expect(find.text('Ready to finalize'), findsWidgets);
      await _scrollUntilAnyFound(tester, find.text('In progress'));
      expect(find.text('In progress'), findsOneWidget);
    },
  );

  testWidgets(
    'DT4 onDisplay: in-progress progress card shows mode current card and started time',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      await harness.driver.startNewStudy();

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('Active sessions'));

      expect(find.text('Review · round 1'), findsOneWidget);
      expect(find.text('Current card: $_alphaFront'), findsOneWidget);
      expect(find.textContaining('Started'), findsOneWidget);
    },
  );

  testWidgets(
    'DT5 onDisplay: ready progress card shows finalize actions and completed progress',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck(dueProgress: true);
      await harness.driver.startReadySrsReview();

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('Ready to finalize'));

      expect(find.text('Finalize'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('1 of 1 study steps · 0 remaining'), findsOneWidget);
    },
  );

  testWidgets(
    'DT6 onDisplay: failed progress card shows retry and cancel actions',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck(dueProgress: true);
      final failed = await harness.driver.startReadySrsReview();
      await harness.setSessionStatus(
        failed.session.id,
        SessionStatus.failedToFinalize,
      );

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('Finalize failed'));

      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Finalize'), findsNothing);
    },
  );

  testWidgets('DT7 onDisplay: progress orders active sessions newest first', (
    tester,
  ) async {
    final harness = await _IntegrationHarness.create(tester);
    await harness.seedDeck();
    await harness.driver.startNewStudy();
    harness.clock.advance(const Duration(minutes: 1));
    await harness.makeCardsDue();
    final failed = await harness.driver.startReadySrsReview();
    await harness.setSessionStatus(
      failed.session.id,
      SessionStatus.failedToFinalize,
    );

    await harness.pumpApp(tester, RoutePaths.progress);
    await _pumpUntilFound(tester, find.text('Finalize failed'));

    final failedTop = tester.getTopLeft(find.text('Finalize failed').first).dy;
    final inProgressTop = tester.getTopLeft(find.text('In progress').first).dy;
    expect(failedTop, lessThan(inProgressTop));
  });

  testWidgets(
    'DT8 onDisplay: ready result screen shows unfinalized state from session data',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck(dueProgress: true);
      final ready = await harness.driver.startReadySrsReview();

      await harness.pumpApp(tester, _studyResultLocation(ready.session.id));
      await _pumpUntilFound(tester, find.text('Session summary'));

      expect(find.text('Ready to finalize'), findsOneWidget);
      expect(find.text('Remaining'), findsOneWidget);
    },
  );

  testWidgets(
    'DT1 onSelect: progress cancel action opens confirmation before mutation',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck();
      final session = await harness.driver.startNewStudy();

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('Active sessions'));

      await _tapText(tester, 'Cancel');
      await _pumpUntilFound(tester, find.text('Cancel this study session?'));

      expect(await harness.sessionStatus(session.session.id), 'in_progress');
      expect(
        find.text(
          'The current session will stop. Completed attempts remain in its history, but pending cards are abandoned.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'DT2 onSelect: ready progress card exposes finalize and continue choices',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck(dueProgress: true);
      await harness.driver.startReadySrsReview();

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('Ready to finalize'));

      expect(find.text('Finalize'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    },
  );

  testWidgets(
    'DT3 onSelect: failed progress card exposes retry and cancel choices',
    (tester) async {
      final harness = await _IntegrationHarness.create(tester);
      await harness.seedDeck(dueProgress: true);
      final failed = await harness.driver.startReadySrsReview();
      await harness.setSessionStatus(
        failed.session.id,
        SessionStatus.failedToFinalize,
      );

      await harness.pumpApp(tester, RoutePaths.progress);
      await _pumpUntilFound(tester, find.text('Finalize failed'));

      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Finalize'), findsNothing);
    },
  );
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Timed out waiting for $finder');
}

Future<void> _tapText(
  WidgetTester tester,
  String text, {
  bool last = false,
}) async {
  final finder = _buttonTextFinder(text, last: last);
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(finder);
}

Finder _buttonTextFinder(String text, {required bool last}) {
  final buttonFinders = [
    find.widgetWithText(MxPrimaryButton, text),
    find.widgetWithText(MxSecondaryButton, text),
  ];

  for (final finder in buttonFinders) {
    if (finder.evaluate().isNotEmpty) {
      return last ? finder.last : finder.first;
    }
  }

  return last ? find.text(text).last : find.text(text);
}

Future<void> _scrollUntilAnyFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 12; attempt++) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -320));
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Timed out scrolling for $finder');
}

Future<String> _startStudyAndStopAtMode(
  WidgetTester tester,
  _IntegrationHarness harness,
  StudyMode targetMode,
) async {
  await harness.pumpApp(tester, _studyEntryLocation(StudyEntryType.deck));
  await _pumpUntilFound(tester, find.text('Start a study session'));

  await _tapText(tester, 'Study');
  await _pumpUntilFound(tester, find.text('Review'));
  final sessionId = await harness.singleActiveSessionId();

  await _advanceReviewToMatch(tester);
  if (targetMode == StudyMode.match) {
    return sessionId;
  }

  await _completeMatchMode(tester);
  if (targetMode == StudyMode.guess) {
    return sessionId;
  }

  await _completeGuessMode(tester);
  if (targetMode == StudyMode.recall) {
    return sessionId;
  }

  await _completeRecallMode(tester);
  if (targetMode == StudyMode.fill) {
    return sessionId;
  }

  fail('Unsupported target mode for stop checkpoint: $targetMode');
}

Future<String> _startStudyWithCachedProgressAndStopAtMode(
  WidgetTester tester,
  _IntegrationHarness harness,
  StudyMode targetMode,
) async {
  await harness.pumpApp(tester, _studyEntryLocation(StudyEntryType.deck));
  await _pumpUntilFound(tester, find.text('Start a study session'));

  await _tapText(tester, 'Study');
  await _pumpUntilFound(tester, find.text('Review'));
  final sessionId = await harness.singleActiveSessionId();

  await tester.tap(find.text('Progress').last);
  await _pumpUntilFound(tester, find.text('Review · round 1'));
  await _tapText(tester, 'Continue');
  await _pumpUntilFound(tester, find.text('Review'));

  await _advanceReviewToMatch(tester);
  if (targetMode == StudyMode.match) {
    return sessionId;
  }

  await _completeMatchMode(tester);
  if (targetMode == StudyMode.guess) {
    return sessionId;
  }

  await _completeGuessMode(tester);
  if (targetMode == StudyMode.recall) {
    return sessionId;
  }

  await _completeRecallMode(tester);
  if (targetMode == StudyMode.fill) {
    return sessionId;
  }

  fail('Unsupported target mode for cached Progress checkpoint: $targetMode');
}

Future<void> _advanceReviewToMatch(WidgetTester tester) async {
  await tester.drag(find.byType(PageView), const Offset(-700, 0));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 2500));
  await _pumpUntilFound(tester, find.text('Match'));
}

Future<void> _completeMatchMode(WidgetTester tester) async {
  await _matchPair(tester, back: _alphaBack, front: _alphaFront);
  await _matchPair(tester, back: _betaBack, front: _betaFront);
  await _pumpUntilFound(tester, find.text('Guess'));
}

Future<String> _startStudyAndLeaveMatchRetry(
  WidgetTester tester,
  _IntegrationHarness harness,
) async {
  await harness.pumpApp(tester, _studyEntryLocation(StudyEntryType.deck));
  await _pumpUntilFound(tester, find.text('Start a study session'));

  await _tapText(tester, 'Study');
  await _pumpUntilFound(tester, find.text('Review'));
  final sessionId = await harness.singleActiveSessionId();

  await _advanceReviewToMatch(tester);
  await _mismatchPair(tester, front: _alphaFront, wrongBack: _betaBack);
  expect(await harness.attemptCountForMode(sessionId, StudyMode.match), 0);
  await _matchPair(tester, back: _alphaBack, front: _alphaFront);
  await _matchPair(tester, back: _betaBack, front: _betaFront);
  await tester.pump(const Duration(milliseconds: 700));

  expect(await harness.currentStudyMode(sessionId), StudyMode.match);
  expect(await harness.currentRoundIndex(sessionId), 2);
  return sessionId;
}

Future<void> _matchPair(
  WidgetTester tester, {
  required String back,
  required String front,
}) async {
  await _pumpUntilFound(tester, find.text(front));
  await tester.tap(find.text(front));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(find.text(back));
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _mismatchPair(
  WidgetTester tester, {
  required String front,
  required String wrongBack,
}) async {
  await _pumpUntilFound(tester, find.text(front));
  await tester.tap(find.text(front));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(find.text(wrongBack));
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _completeGuessMode(WidgetTester tester) async {
  await _answerGuessPrompt(tester, front: _alphaFront, back: _alphaBack);
  await _answerGuessPrompt(tester, front: _betaFront, back: _betaBack);
  await _pumpUntilFound(tester, find.text('Recall'));
}

Future<void> _completeRecallMode(WidgetTester tester) async {
  await _answerRecallPrompt(tester, front: _alphaFront, action: 'Remembered');
  await _answerRecallPrompt(tester, front: _betaFront, action: 'Remembered');
  await _pumpUntilFound(tester, find.text('Fill'));
}

Future<void> _answerGuessPrompt(
  WidgetTester tester, {
  required String front,
  required String back,
}) async {
  await _pumpUntilFound(tester, find.text(front));
  await _tapText(tester, back);
  await tester.pump(const Duration(milliseconds: 700));
}

Future<void> _answerRecallPrompt(
  WidgetTester tester, {
  required String front,
  required String action,
}) async {
  await _pumpUntilFound(tester, find.text(front));
  await _tapText(tester, 'Show (20s)');
  await tester.pump(const Duration(milliseconds: 300));
  await _tapText(tester, action);
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _openStudyEntryAndContinue(
  WidgetTester tester,
  _IntegrationHarness harness,
) async {
  _goToLocation(tester, _studyEntryLocation(StudyEntryType.deck));
  await tester.pump(const Duration(milliseconds: 100));
  await _pumpUntilFound(tester, find.text('Session in progress'));
  await _tapText(tester, 'Continue');
}

Future<void> _openProgressAndContinueAtMode(
  WidgetTester tester, {
  required String modeRoundLabel,
  required String modeTitle,
}) async {
  await tester.tap(find.text('Progress').last);
  await _pumpUntilFound(tester, find.text('Active sessions'));
  await _pumpUntilFound(tester, find.text(modeRoundLabel));
  await _tapText(tester, 'Continue');
  await _pumpUntilFound(tester, find.text(modeTitle));
}

Future<String> _openStudyEntryAndRestart(
  WidgetTester tester,
  _IntegrationHarness harness,
) async {
  _goToLocation(tester, _studyEntryLocation(StudyEntryType.deck));
  await tester.pump(const Duration(milliseconds: 100));
  await _pumpUntilFound(tester, find.text('Session in progress'));
  await tester.scrollUntilVisible(
    find.text('Start'),
    300,
    scrollable: find.byType(Scrollable),
  );
  await tester.tap(find.text('Start'));
  await _pumpUntilFound(
    tester,
    find.text(
      'Starting a new session will cancel the current unfinished session.',
    ),
  );
  await tester.tap(find.text('Start').last);
  await _pumpUntilFound(tester, find.text('Review'));
  return harness.singleActiveSessionId();
}

void _goToLocation(WidgetTester tester, String location) {
  final context = tester.element(find.byType(Scaffold).first);
  GoRouter.of(context).go(location);
}

class _IntegrationHarness {
  _IntegrationHarness._({
    required this.database,
    required this.clock,
    required this.ids,
  });

  static Future<_IntegrationHarness> create(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(_surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues(const <String, Object>{
      AppConstants.sharedPrefsShuffleFlashcardsKey: false,
      AppConstants.sharedPrefsShuffleAnswersKey: false,
    });

    final harness = _IntegrationHarness._(
      database: AppDatabase(executor: NativeDatabase.memory()),
      clock: TestClock(DateTime.utc(2026, 4, 24, 9)),
      ids: SequenceIdGenerator(),
    );
    addTearDown(harness.dispose);
    return harness;
  }

  final AppDatabase database;
  final TestClock clock;
  final SequenceIdGenerator ids;

  _StudyDriver get driver =>
      _StudyDriver(database: database, clock: clock, ids: ids);

  Future<void> pumpApp(WidgetTester tester, String initialLocation) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            _testConfig(initialLocation: initialLocation),
          ),
          appDatabaseProvider.overrideWithValue(database),
          clockProvider.overrideWithValue(clock),
          idGeneratorProvider.overrideWithValue(ids),
          contentDataRevisionProvider.overrideWith(
            (ref) => Stream<int>.value(0),
          ),
        ],
        child: const _IntegrationApp(),
      ),
    );
  }

  Future<void> seedDeck({
    bool dueProgress = false,
    bool includeSecondCard = true,
  }) async {
    final now = clock.nowEpochMillis();
    await database
        .into(database.folders)
        .insert(
          FoldersCompanion.insert(
            id: _folderId,
            name: 'Integration Folder',
            contentMode: FolderContentMode.decks.storageValue,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.decks)
        .insert(
          DecksCompanion.insert(
            id: _deckId,
            folderId: _folderId,
            name: 'Integration Deck',
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await _insertFlashcard(
      id: 'integration-card-alpha',
      front: _alphaFront,
      back: _alphaBack,
      sortOrder: 0,
    );
    if (includeSecondCard) {
      await _insertFlashcard(
        id: 'integration-card-beta',
        front: _betaFront,
        back: _betaBack,
        sortOrder: 1,
      );
    }
    if (!dueProgress) {
      return;
    }
    await _insertDueProgress('integration-card-alpha');
    if (includeSecondCard) {
      await _insertDueProgress('integration-card-beta');
    }
  }

  Future<void> makeCardsDue() async {
    await _insertDueProgress('integration-card-alpha');
    final beta =
        await (database.select(database.flashcards)
              ..where((table) => table.id.equals('integration-card-beta')))
            .getSingleOrNull();
    if (beta == null) {
      return;
    }
    await _insertDueProgress('integration-card-beta');
  }

  Future<void> _insertFlashcard({
    required String id,
    required String front,
    required String back,
    required int sortOrder,
  }) async {
    final now = clock.nowEpochMillis();
    await database
        .into(database.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: _deckId,
            front: front,
            back: back,
            sortOrder: sortOrder,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.flashcardProgress)
        .insert(
          FlashcardProgressCompanion.insert(
            flashcardId: id,
            currentBox: 1,
            reviewCount: 0,
            lapseCount: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> _insertDueProgress(String flashcardId) {
    final now = clock.nowEpochMillis();
    return database
        .into(database.flashcardProgress)
        .insertOnConflictUpdate(
          FlashcardProgressCompanion.insert(
            flashcardId: flashcardId,
            currentBox: 1,
            reviewCount: 0,
            lapseCount: 0,
            dueAt: Value(now - Duration.millisecondsPerDay),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> setSessionStatus(String sessionId, SessionStatus status) {
    return (database.update(
      database.studySessions,
    )..where((table) => table.id.equals(sessionId))).write(
      StudySessionsCompanion(
        status: Value(status.storageValue),
        endedAt: Value(clock.nowEpochMillis()),
      ),
    );
  }

  Future<String> sessionStatus(String sessionId) async {
    final session = await (database.select(
      database.studySessions,
    )..where((table) => table.id.equals(sessionId))).getSingle();
    return session.status;
  }

  Future<int> currentBox(String flashcardId) async {
    final progress = await (database.select(
      database.flashcardProgress,
    )..where((table) => table.flashcardId.equals(flashcardId))).getSingle();
    return progress.currentBox;
  }

  Future<int> activeSessionCount() {
    return (database.select(database.studySessions)..where(
          (table) => table.status.isIn(const <String>[
            'in_progress',
            'ready_to_finalize',
            'failed_to_finalize',
          ]),
        ))
        .get()
        .then((sessions) => sessions.length);
  }

  Future<String> singleActiveSessionId() async {
    final sessions =
        await (database.select(database.studySessions)
              ..where(
                (table) => table.status.isIn(const <String>[
                  'in_progress',
                  'ready_to_finalize',
                  'failed_to_finalize',
                ]),
              )
              ..orderBy([(table) => OrderingTerm.desc(table.startedAt)]))
            .get();
    expect(sessions, hasLength(1));
    return sessions.single.id;
  }

  Future<String?> restartedFromSessionId(String sessionId) async {
    final session = await (database.select(
      database.studySessions,
    )..where((table) => table.id.equals(sessionId))).getSingle();
    return session.restartedFromSessionId;
  }

  Future<StudyMode?> currentStudyMode(String sessionId) async {
    final item =
        await (database.select(database.studySessionItems)
              ..where((table) => table.sessionId.equals(sessionId))
              ..where(
                (table) =>
                    table.status.equals(SessionItemStatus.pending.storageValue),
              )
              ..orderBy([
                (table) => OrderingTerm.asc(table.modeOrder),
                (table) => OrderingTerm.asc(table.roundIndex),
                (table) => OrderingTerm.asc(table.queuePosition),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (item == null) {
      return null;
    }
    return StudyMode.values.firstWhere(
      (mode) => mode.storageValue == item.studyMode,
    );
  }

  Future<int?> currentRoundIndex(String sessionId) async {
    final item =
        await (database.select(database.studySessionItems)
              ..where((table) => table.sessionId.equals(sessionId))
              ..where(
                (table) =>
                    table.status.equals(SessionItemStatus.pending.storageValue),
              )
              ..orderBy([
                (table) => OrderingTerm.asc(table.modeOrder),
                (table) => OrderingTerm.asc(table.roundIndex),
                (table) => OrderingTerm.asc(table.queuePosition),
              ])
              ..limit(1))
            .getSingleOrNull();
    return item?.roundIndex;
  }

  Future<List<String>> pendingFlashcardIds(String sessionId) async {
    final items =
        await (database.select(database.studySessionItems)
              ..where((table) => table.sessionId.equals(sessionId))
              ..where(
                (table) =>
                    table.status.equals(SessionItemStatus.pending.storageValue),
              )
              ..orderBy([
                (table) => OrderingTerm.asc(table.modeOrder),
                (table) => OrderingTerm.asc(table.roundIndex),
                (table) => OrderingTerm.asc(table.queuePosition),
              ]))
            .get();
    return items.map((item) => item.flashcardId).toList(growable: false);
  }

  Future<int> attemptCountForMode(String sessionId, StudyMode mode) async {
    final attempts = await attemptResultsForMode(sessionId, mode);
    return attempts.length;
  }

  Future<Map<String, String>> attemptResultsForMode(
    String sessionId,
    StudyMode mode,
  ) async {
    final items =
        await (database.select(database.studySessionItems)
              ..where((table) => table.sessionId.equals(sessionId))
              ..where((table) => table.studyMode.equals(mode.storageValue)))
            .get();
    final itemIds = items.map((item) => item.id).toSet();
    final attempts =
        await (database.select(database.studyAttempts)
              ..where((table) => table.sessionId.equals(sessionId))
              ..orderBy([
                (table) => OrderingTerm.asc(table.answeredAt),
                (table) => OrderingTerm.asc(table.attemptNumber),
              ]))
            .get();
    return <String, String>{
      for (final attempt in attempts)
        if (itemIds.contains(attempt.sessionItemId))
          attempt.flashcardId: attempt.result,
    };
  }

  Future<int> distinctModeCount(String sessionId) async {
    final items = await (database.select(
      database.studySessionItems,
    )..where((table) => table.sessionId.equals(sessionId))).get();
    return items.map((item) => item.modeOrder).toSet().length;
  }

  Future<void> dispose() => database.close();
}

class _StudyDriver {
  _StudyDriver({
    required this.database,
    required this.clock,
    required this.ids,
  });

  final AppDatabase database;
  final TestClock clock;
  final SequenceIdGenerator ids;

  Future<StudySessionSnapshot> startNewStudy({
    StudyEntryType entryType = StudyEntryType.deck,
    int batchSize = 2,
  }) {
    return _start.execute(
      StudyContext(
        entryType: entryType,
        entryRefId: _entryRefId(entryType),
        studyType: StudyType.newStudy,
        settings: StudySettingsSnapshot(
          batchSize: batchSize,
          shuffleFlashcards: false,
          shuffleAnswers: false,
          prioritizeOverdue: true,
        ),
      ),
    );
  }

  Future<StudySessionSnapshot> startReadySrsReview() async {
    final session = await _start.execute(
      const StudyContext(
        entryType: StudyEntryType.deck,
        entryRefId: _deckId,
        studyType: StudyType.srsReview,
        settings: StudySettingsSnapshot(
          batchSize: 1,
          shuffleFlashcards: false,
          shuffleAnswers: false,
          prioritizeOverdue: true,
        ),
      ),
    );
    return _answer.execute(
      sessionId: session.session.id,
      studyType: StudyType.srsReview,
      grade: AttemptGrade.correct,
    );
  }

  Future<StudySessionSnapshot> finalize(StudySessionSnapshot snapshot) {
    return _finalize.execute(
      sessionId: snapshot.session.id,
      studyType: snapshot.session.studyType,
    );
  }

  StartStudySessionUseCase get _start => StartStudySessionUseCase(
    repository: _repo,
    strategyFactory: _strategyFactory,
  );

  AnswerFlashcardUseCase get _answer => AnswerFlashcardUseCase(
    repository: _repo,
    strategyFactory: _strategyFactory,
  );

  FinalizeStudySessionUseCase get _finalize => FinalizeStudySessionUseCase(
    repository: _repo,
    strategyFactory: _strategyFactory,
  );

  StudyRepoImpl get _repo {
    final transactionRunner = LocalTransactionRunner(database);
    return StudyRepoImpl(
      database: database,
      studySessionDao: StudySessionDao(database),
      studySessionItemDao: StudySessionItemDao(database),
      studyAttemptDao: StudyAttemptDao(database),
      folderDao: FolderDao(database),
      transactionRunner: transactionRunner,
      clock: clock,
      idGenerator: ids,
      shuffleRandom: Random(7),
      logger: const NoopAppLogger(),
    );
  }

  StudyStrategyFactory get _strategyFactory => StudyStrategyFactory(
    const <StudyStrategy>[NewStudyStrategy(), SrsReviewStrategy()],
  );
}

class _IntegrationApp extends ConsumerWidget {
  const _IntegrationApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}

const _surfaceSize = Size(900, 1200);
const _folderId = 'integration-folder';
const _deckId = 'integration-deck';
const _alphaFront = 'Alpha prompt';
const _alphaBack = 'Alpha answer';
const _betaFront = 'Beta prompt';
const _betaBack = 'Beta answer';

String _flashcardListLocation(String deckId) {
  return '${RoutePaths.library}/deck/$deckId/flashcards';
}

String _studyEntryLocation(StudyEntryType entryType) {
  final entryRefId = _entryRefId(entryType);
  return '${RoutePaths.library}/study/${entryType.storageValue}/$entryRefId';
}

String _studyResultLocation(String sessionId) {
  return '${RoutePaths.library}/study/session/$sessionId/result';
}

String _studySessionLocation(String sessionId) {
  return '${RoutePaths.library}/study/session/$sessionId';
}

String _entryRefId(StudyEntryType entryType) {
  if (entryType == StudyEntryType.folder) {
    return _folderId;
  }
  return _deckId;
}

AppConfig _testConfig({required String initialLocation}) {
  return AppConfig(
    env: AppEnv.local,
    initialLocation: initialLocation,
    showDebugBanner: false,
    enableRouterDiagnostics: false,
    enableTalkerConsoleLogs: false,
    enableTalkerRouteLogging: false,
    enableRiverpodDiagnostics: false,
    exposeInternalErrorDetails: true,
  );
}
