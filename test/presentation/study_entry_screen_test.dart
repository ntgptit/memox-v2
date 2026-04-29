import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/providers/study_entry_notifier.dart';
import 'package:memox/presentation/features/study/screens/study_entry_screen.dart';
import 'package:memox/presentation/shared/states/mx_loading_state.dart';

void main() {
  testWidgets('DT1 onOpen: shows loading state while study entry loads', (
    tester,
  ) async {
    final completer = Completer<StudyEntryState>();
    addTearDown(() {
      if (!completer.isCompleted) {
        completer.complete(_deckEntryState);
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyEntryStateProvider(
            'deck',
            'deck-001',
          ).overrideWith((ref) => completer.future),
        ],
        child: const _TestApp(
          child: StudyEntryScreen(entryType: 'deck', entryRefId: 'deck-001'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(MxLoadingState), findsOneWidget);
  });

  testWidgets('DT1 onDisplay: deck entry shows new and review study flows', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyEntryStateProvider(
            'deck',
            'deck-001',
          ).overrideWith((ref) => Future.value(_deckEntryState)),
        ],
        child: const _TestApp(
          child: StudyEntryScreen(entryType: 'deck', entryRefId: 'deck-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start a study session'), findsOneWidget);
    expect(find.text('New Study'), findsOneWidget);
    expect(find.text('SRS Review'), findsOneWidget);
    expect(find.text('Session settings'), findsOneWidget);
  });

  testWidgets('DT2 onDisplay: today entry locks the flow to SRS Review', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyEntryStateProvider(
            'today',
            null,
          ).overrideWith((ref) => Future.value(_todayEntryState)),
        ],
        child: const _TestApp(
          child: StudyEntryScreen(entryType: 'today', entryRefId: null),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SRS Review'), findsOneWidget);
    expect(find.text('New Study'), findsNothing);
    expect(
      find.text('Today supports SRS Review due and overdue cards in v1.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'DT3 onDisplay: shows separate continue and start-new actions for resume candidate',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyEntryStateProvider(
              'deck',
              'deck-001',
            ).overrideWith((ref) => Future.value(_resumeEntryState)),
          ],
          child: const _TestApp(
            child: StudyEntryScreen(entryType: 'deck', entryRefId: 'deck-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Session in progress'), findsOneWidget);
      expect(find.text('Continue session'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Start new session'),
        300,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Start new session'), findsOneWidget);
      expect(find.text('Restart'), findsNothing);
    },
  );

  testWidgets('DT4 onDisplay: keeps New Study batch size within 5-20', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyEntryStateProvider(
            'deck',
            'deck-001',
          ).overrideWith((ref) => Future.value(_deckEntryState)),
        ],
        child: const _TestApp(
          child: StudyEntryScreen(entryType: 'deck', entryRefId: 'deck-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Batch size: 20'), findsOneWidget);
    expect(find.text('5-20 cards'), findsOneWidget);

    await tester.tap(
      find.byTooltip('Increase batch size'),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(find.text('Batch size: 20'), findsOneWidget);
    expect(find.text('Batch size: 21'), findsNothing);
  });

  testWidgets('DT5 onDisplay: keeps SRS Review batch size within 5-50', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyEntryStateProvider(
            'today',
            null,
          ).overrideWith((ref) => Future.value(_todayMaxReviewEntryState)),
        ],
        child: const _TestApp(
          child: StudyEntryScreen(entryType: 'today', entryRefId: null),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Batch size: 50'), findsOneWidget);
    expect(find.text('5-50 cards'), findsOneWidget);

    await tester.tap(
      find.byTooltip('Increase batch size'),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(find.text('Batch size: 50'), findsOneWidget);
    expect(find.text('Batch size: 51'), findsNothing);
  });

  testWidgets(
    'DT1 onSelect: confirms before starting new session over a resume candidate',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyEntryStateProvider(
              'deck',
              'deck-001',
            ).overrideWith((ref) => Future.value(_resumeEntryState)),
          ],
          child: const _TestApp(
            child: StudyEntryScreen(entryType: 'deck', entryRefId: 'deck-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Start new session'),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text('Start new session'));
      await tester.pumpAndSettle();

      expect(find.text('Start a new session?'), findsOneWidget);
      expect(
        find.text(
          'Starting a new session will cancel the current unfinished session.',
        ),
        findsOneWidget,
      );
    },
  );
}

const _newDefaults = StudySettingsSnapshot(
  batchSize: 20,
  shuffleFlashcards: true,
  shuffleAnswers: true,
  prioritizeOverdue: false,
);

const _reviewDefaults = StudySettingsSnapshot(
  batchSize: 12,
  shuffleFlashcards: false,
  shuffleAnswers: false,
  prioritizeOverdue: true,
);

const _deckEntryState = StudyEntryState(
  entryType: StudyEntryType.deck,
  entryRefId: 'deck-001',
  newStudyDefaults: _newDefaults,
  reviewDefaults: _reviewDefaults,
  resumeCandidate: null,
);

const _todayEntryState = StudyEntryState(
  entryType: StudyEntryType.today,
  entryRefId: null,
  newStudyDefaults: _newDefaults,
  reviewDefaults: _reviewDefaults,
  resumeCandidate: null,
);

const _reviewMaxDefaults = StudySettingsSnapshot(
  batchSize: 50,
  shuffleFlashcards: false,
  shuffleAnswers: false,
  prioritizeOverdue: true,
);

const _todayMaxReviewEntryState = StudyEntryState(
  entryType: StudyEntryType.today,
  entryRefId: null,
  newStudyDefaults: _newDefaults,
  reviewDefaults: _reviewMaxDefaults,
  resumeCandidate: null,
);

const _resumeEntryState = StudyEntryState(
  entryType: StudyEntryType.deck,
  entryRefId: 'deck-001',
  newStudyDefaults: _newDefaults,
  reviewDefaults: _reviewDefaults,
  resumeCandidate: _resumeSnapshot,
);

const _resumeSnapshot = StudySessionSnapshot(
  session: StudySession(
    id: 'session-001',
    entryType: StudyEntryType.deck,
    entryRefId: 'deck-001',
    studyType: StudyType.newStudy,
    studyFlow: StudyFlow.newFullCycle,
    settings: _newDefaults,
    status: SessionStatus.inProgress,
    startedAt: 0,
    endedAt: null,
    restartedFromSessionId: null,
  ),
  currentItem: StudySessionItem(
    id: 'item-001',
    sessionId: 'session-001',
    flashcard: _resumeFlashcard,
    studyMode: StudyMode.review,
    modeOrder: 1,
    roundIndex: 1,
    queuePosition: 1,
    sourcePool: SessionItemSourcePool.newCards,
    status: SessionItemStatus.pending,
    completedAt: null,
  ),
  sessionFlashcards: [_resumeFlashcard],
  summary: StudySummary(
    totalCards: 1,
    completedAttempts: 0,
    correctAttempts: 0,
    incorrectAttempts: 0,
    increasedBoxCount: 0,
    decreasedBoxCount: 0,
    remainingCount: 1,
  ),
  canFinalize: false,
);

const _resumeFlashcard = StudyFlashcardRef(
  id: 'card-001',
  deckId: 'deck-001',
  front: 'Front',
  back: 'Back',
  sourcePool: SessionItemSourcePool.newCards,
);

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}
