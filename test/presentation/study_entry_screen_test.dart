import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/study/study_data_providers.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/errors/app_exception.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/providers/study_entry_notifier.dart';
import 'package:memox/presentation/features/study/screens/study_entry_screen.dart';
import 'package:memox/presentation/shared/widgets/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/mx_loading_state.dart';

void main() {
  testWidgets('DT1 onOpen: shows loading state while direct start loads', (
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
        child: _TestRouterApp(initialLocation: _deckEntryLocation()),
      ),
    );
    await tester.pump();

    expect(find.byType(MxLoadingState), findsOneWidget);
  });

  testWidgets('DT1 onNavigate: mix starts full-cycle study session directly', (
    tester,
  ) async {
    final repo = _CapturingStudyRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          studyEntryStateProvider(
            'deck',
            'deck-001',
          ).overrideWith((ref) => Future.value(_deckEntryState)),
        ],
        child: _TestRouterApp(initialLocation: _deckEntryLocation()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Session session-001'), findsOneWidget);
    expect(repo.startedFlow, StudyFlow.newFullCycle);
    expect(repo.startedModes, <StudyMode>[
      StudyMode.review,
      StudyMode.match,
      StudyMode.guess,
      StudyMode.recall,
      StudyMode.fill,
    ]);
  });

  for (final entry in _singleModeFlowCases.entries) {
    testWidgets(
      'DT2 onNavigate: ${entry.key.name} starts ${entry.value.name} directly',
      (tester) async {
        final repo = _CapturingStudyRepo();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              studyRepoProvider.overrideWithValue(repo),
              studyEntryStateProvider(
                'deck',
                'deck-001',
              ).overrideWith((ref) => Future.value(_deckEntryState)),
            ],
            child: _TestRouterApp(
              initialLocation: _deckEntryLocation(studyMode: entry.key),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Session session-001'), findsOneWidget);
        expect(find.text('Study action failed.'), findsNothing);
        expect(repo.startedFlow, entry.value);
        expect(repo.startedModes, <StudyMode>[entry.key]);
      },
    );
  }

  testWidgets(
    'DT7 onNavigate: start failure shows original storage error message',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(
              _FailingStartStudyRepo(
                const StorageException(message: 'Database unavailable.'),
              ),
            ),
            studyEntryStateProvider(
              'deck',
              'deck-001',
            ).overrideWith((ref) => Future.value(_deckEntryState)),
          ],
          child: _TestRouterApp(initialLocation: _deckEntryLocation()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MxErrorState), findsOneWidget);
      expect(find.text('Database unavailable.'), findsOneWidget);
      expect(find.text('Study action failed.'), findsNothing);
    },
  );

  testWidgets('DT3 onNavigate: matching resume candidate shows choice dialog', (
    tester,
  ) async {
    final repo = _CapturingStudyRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          studyEntryStateProvider(
            'deck',
            'deck-001',
          ).overrideWith((ref) => Future.value(_resumeEntryState)),
        ],
        child: _TestRouterApp(initialLocation: _deckEntryLocation()),
      ),
    );
    await _pumpDialogs(tester);

    expect(find.text('Resume previous session?'), findsOneWidget);
    expect(repo.startCount, 0);
  });

  testWidgets('DT3 onResume: Resume opens existing session, no new session', (
    tester,
  ) async {
    final repo = _CapturingStudyRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          studyEntryStateProvider(
            'deck',
            'deck-001',
          ).overrideWith((ref) => Future.value(_resumeEntryState)),
        ],
        child: _TestRouterApp(initialLocation: _deckEntryLocation()),
      ),
    );
    await _pumpDialogs(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Resume'));
    await tester.pumpAndSettle();

    expect(find.text('Session resume-session-001'), findsOneWidget);
    expect(repo.startCount, 0);
    expect(repo.cancelledSessionId, isNull);
  });

  testWidgets('DT3 onStartOver: discard confirm restarts into a new session', (
    tester,
  ) async {
    final repo = _CapturingStudyRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          studyEntryStateProvider(
            'deck',
            'deck-001',
          ).overrideWith((ref) => Future.value(_resumeEntryState)),
        ],
        child: _TestRouterApp(initialLocation: _deckEntryLocation()),
      ),
    );
    await _pumpDialogs(tester);

    await tester.tap(find.text('Start over'));
    await _pumpDialogs(tester);

    // Second-tier discard confirmation.
    expect(find.text('Start a new session?'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Start over'));
    await _pumpDialogs(tester);

    expect(find.text('Session session-001'), findsOneWidget);
    expect(repo.cancelledSessionId, isNull);
    expect(repo.restartedFromSessionId, 'resume-session-001');
    expect(repo.startCount, 1);
    expect(repo.startedFlow, StudyFlow.newFullCycle);
  });

  testWidgets('DT3 onStartOver: Start over opens second confirmation', (
    tester,
  ) async {
    final repo = _CapturingStudyRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          studyEntryStateProvider(
            'deck',
            'deck-001',
          ).overrideWith((ref) => Future.value(_resumeEntryState)),
        ],
        child: _TestRouterApp(initialLocation: _deckEntryLocation()),
      ),
    );
    await _pumpDialogs(tester);

    await tester.tap(find.text('Start over'));
    await _pumpDialogs(tester);

    expect(find.text('Start a new session?'), findsOneWidget);
    expect(repo.startCount, 0);
    expect(repo.cancelledSessionId, isNull);
    expect(repo.restartedFromSessionId, isNull);
  });

  testWidgets('DT3 onCancel: dismissing the choice creates no session', (
    tester,
  ) async {
    final repo = _CapturingStudyRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          studyEntryStateProvider(
            'deck',
            'deck-001',
          ).overrideWith((ref) => Future.value(_resumeEntryState)),
        ],
        child: _TestRouterApp(initialLocation: _deckEntryLocation()),
      ),
    );
    await _pumpDialogs(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await _pumpDialogs(tester);

    // Choice dismissed: no session is created and we never land on a session.
    expect(find.text('Resume previous session?'), findsNothing);
    expect(find.textContaining('Session '), findsNothing);
    expect(repo.startCount, 0);
    expect(repo.cancelledSessionId, isNull);
  });

  testWidgets(
    'DT5 onModeMismatch: different mode flow still shows choice dialog',
    (tester) async {
      final repo = _CapturingStudyRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studyEntryStateProvider(
              'deck',
              'deck-001',
            ).overrideWith((ref) => Future.value(_resumeEntryState)),
          ],
          child: _TestRouterApp(
            initialLocation: _deckEntryLocation(studyMode: StudyMode.match),
          ),
        ),
      );
      await _pumpDialogs(tester);

      expect(find.text('Resume previous session?'), findsOneWidget);
      expect(repo.startCount, 0);
    },
  );

  testWidgets(
    'DT5 onModeMismatch: Resume opens existing different-flow session',
    (tester) async {
      final repo = _CapturingStudyRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studyEntryStateProvider(
              'deck',
              'deck-001',
            ).overrideWith((ref) => Future.value(_resumeEntryState)),
          ],
          child: _TestRouterApp(
            initialLocation: _deckEntryLocation(studyMode: StudyMode.match),
          ),
        ),
      );
      await _pumpDialogs(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Resume'));
      await tester.pumpAndSettle();

      expect(find.text('Session resume-session-001'), findsOneWidget);
      expect(repo.startCount, 0);
      expect(repo.cancelledSessionId, isNull);
    },
  );

  testWidgets(
    'DT5 onModeMismatch: Start over confirm creates requested mode flow',
    (tester) async {
      final repo = _CapturingStudyRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studyEntryStateProvider(
              'deck',
              'deck-001',
            ).overrideWith((ref) => Future.value(_resumeEntryState)),
          ],
          child: _TestRouterApp(
            initialLocation: _deckEntryLocation(studyMode: StudyMode.match),
          ),
        ),
      );
      await _pumpDialogs(tester);

      await tester.tap(find.text('Start over'));
      await _pumpDialogs(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Start over'));
      await _pumpDialogs(tester);

      expect(find.text('Session session-001'), findsOneWidget);
      expect(repo.startCount, 1);
      expect(repo.cancelledSessionId, isNull);
      expect(repo.restartedFromSessionId, 'resume-session-001');
      expect(repo.startedFlow, StudyFlow.newMatchOnly);
      expect(repo.startedModes, const <StudyMode>[StudyMode.match]);
    },
  );

  testWidgets(
    'DT6 onNavigate: non-matching scope starts normally without dialog',
    (tester) async {
      final repo = _CapturingStudyRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studyEntryStateProvider(
              'deck',
              'deck-001',
            ).overrideWith((ref) => Future.value(_deckEntryState)),
          ],
          child: _TestRouterApp(initialLocation: _deckEntryLocation()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Resume previous session?'), findsNothing);
      expect(find.text('Session session-001'), findsOneWidget);
      expect(repo.startCount, 1);
    },
  );

  testWidgets('DT4 onNavigate: empty eligible batch shows recovery error', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(_EmptyStudyRepo()),
          studyEntryStateProvider(
            'deck',
            'deck-001',
          ).overrideWith((ref) => Future.value(_deckEntryState)),
        ],
        child: _TestRouterApp(initialLocation: _deckEntryLocation()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MxErrorState), findsOneWidget);
    expect(find.textContaining('No eligible flashcards'), findsOneWidget);
  });

  testWidgets(
    'S4 onTap: deck_noCards empty state CTA pushes flashcardCreate route',
    (tester) async {
      final repo = _CapturingStudyRepo()..deckFlashcardCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studyEntryStateProvider(
              'deck',
              'deck-001',
            ).overrideWith((ref) => Future.value(_deckEntryState)),
          ],
          child: _TestRouterApp(initialLocation: _deckEntryLocation()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No flashcards in this deck'), findsOneWidget);
      expect(repo.startCount, 0);

      await tester.tap(find.text('Add flashcards'));
      await tester.pumpAndSettle();

      expect(find.text('FlashcardCreate deck-001'), findsOneWidget);
    },
  );
}

/// Advances the dialog transition without waiting for `pumpAndSettle`: the
/// study entry gate renders an indeterminate progress spinner behind the
/// dialog, so the tree never fully settles while the gate is on screen.
Future<void> _pumpDialogs(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

String _deckEntryLocation({StudyMode? studyMode}) {
  final mode = studyMode?.storageValue;
  return mode == null
      ? '/study/deck/deck-001'
      : '/study/deck/deck-001?mode=$mode';
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

const _singleModeFlowCases = <StudyMode, StudyFlow>{
  StudyMode.review: StudyFlow.newReviewOnly,
  StudyMode.match: StudyFlow.newMatchOnly,
  StudyMode.guess: StudyFlow.newGuessOnly,
  StudyMode.recall: StudyFlow.newRecallOnly,
  StudyMode.fill: StudyFlow.newFillOnly,
};

const _deckEntryState = StudyEntryState(
  entryType: StudyEntryType.deck,
  entryRefId: 'deck-001',
  newStudyDefaults: _newDefaults,
  reviewDefaults: _reviewDefaults,
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
    id: 'resume-session-001',
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
  currentItem: null,
  sessionFlashcards: <StudyFlashcardRef>[],
  summary: StudySummary(
    totalCards: 0,
    completedAttempts: 0,
    correctAttempts: 0,
    incorrectAttempts: 0,
    increasedBoxCount: 0,
    decreasedBoxCount: 0,
    remainingCount: 0,
  ),
  canFinalize: false,
);

class _TestRouterApp extends StatelessWidget {
  const _TestRouterApp({required this.initialLocation});

  final String initialLocation;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/home',
          name: RouteNames.home,
          builder: (_, _) => const Text('Home'),
        ),
        GoRoute(
          path: '/study/:entryType/:entryRefId',
          name: RouteNames.studyEntry,
          builder: (_, state) => StudyEntryScreen(
            entryType: state.pathParameters['entryType']!,
            entryRefId: state.pathParameters['entryRefId'],
            studyMode: state.uri.queryParameters['mode'],
          ),
        ),
        GoRoute(
          path: '/session/:sessionId',
          name: RouteNames.studySession,
          builder: (_, state) =>
              Text('Session ${state.pathParameters['sessionId']}'),
        ),
        GoRoute(
          path: '/deck/:deckId/flashcards/new',
          name: RouteNames.flashcardCreate,
          builder: (_, state) =>
              Text('FlashcardCreate ${state.pathParameters['deckId']}'),
        ),
      ],
    );
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}

class _CapturingStudyRepo implements StudyRepo {
  int startCount = 0;
  StudyFlow? startedFlow;
  List<StudyMode>? startedModes;
  int deckFlashcardCount = 1;
  String? cancelledSessionId;
  String? restartedFromSessionId;

  @override
  Future<int> countFlashcardsInDeck(String deckId) async => deckFlashcardCount;

  @override
  Future<int> countFlashcardsInScope(StudyContext context) async => 1;

  @override
  Future<int> countDueCardsInScope(StudyContext context) async => 1;

  @override
  Future<DateTime?> nextDueAt(StudyContext context) async => null;

  @override
  Future<void> setBuried({
    required String flashcardId,
    required bool buried,
  }) async {}

  @override
  Future<void> setSuspended({
    required String flashcardId,
    required bool suspended,
  }) async {}

  @override
  Future<int> countSuspendedInScope(StudyContext context) async => 0;

  @override
  Future<int> countActiveBuriedInScope(StudyContext context) async => 0;

  @override
  Future<StudySessionSnapshot> dropCurrentItemFromSession({
    required String sessionId,
    required List<StudyMode> modes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<StudyFlashcardRef>> loadNewCards(StudyContext context) async => [
    _card(),
  ];

  @override
  Future<List<StudyFlashcardRef>> loadDueCards(StudyContext context) async => [
    _card(sourcePool: SessionItemSourcePool.due),
  ];

  @override
  Future<StudySessionSnapshot> startSession({
    required StudyContext context,
    required StudyFlow flow,
    required List<StudyMode> modes,
    required List<StudyFlashcardRef> batch,
  }) async {
    startCount += 1;
    startedFlow = flow;
    startedModes = modes;
    restartedFromSessionId = context.restartedFromSessionId;
    return _snapshot(
      studyType: context.studyType,
      studyFlow: flow,
      settings: context.settings,
      mode: modes.first,
      flashcard: batch.first,
    );
  }

  @override
  Future<StudySessionSnapshot?> findResumeCandidate(
    StudyContext context,
  ) async => null;

  @override
  Future<List<StudySessionSnapshot>> listActiveSessions() async =>
      const <StudySessionSnapshot>[];

  @override
  Future<StudySessionSnapshot> loadSession(String sessionId) async =>
      _resumeSnapshot;

  @override
  Future<StudySessionSnapshot> answerCurrentItem({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> answerCurrentModeItemGradesBatch({
    required String sessionId,
    required Map<String, AttemptGrade> itemGrades,
    required List<StudyMode> modes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> skipCurrentItem(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> cancelSession(String sessionId) async {
    cancelledSessionId = sessionId;
    return _resumeSnapshot;
  }

  @override
  Future<StudySessionSnapshot> finalizeSession({
    required String sessionId,
    required StudyType studyType,
    required StudyFinalizePolicy finalizePolicy,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> retryFinalize({
    required String sessionId,
    required StudyType studyType,
    required StudyFinalizePolicy finalizePolicy,
  }) {
    throw UnimplementedError();
  }
}

final class _EmptyStudyRepo extends _CapturingStudyRepo {
  @override
  Future<List<StudyFlashcardRef>> loadNewCards(StudyContext context) async =>
      const <StudyFlashcardRef>[];

  @override
  Future<List<StudyFlashcardRef>> loadDueCards(StudyContext context) async =>
      const <StudyFlashcardRef>[];
}

final class _FailingStartStudyRepo extends _CapturingStudyRepo {
  _FailingStartStudyRepo(this.error);

  final Object error;

  @override
  Future<StudySessionSnapshot> startSession({
    required StudyContext context,
    required StudyFlow flow,
    required List<StudyMode> modes,
    required List<StudyFlashcardRef> batch,
  }) async {
    throw error;
  }
}

StudySessionSnapshot _snapshot({
  required StudyType studyType,
  required StudyFlow studyFlow,
  required StudySettingsSnapshot settings,
  required StudyMode mode,
  required StudyFlashcardRef flashcard,
}) => StudySessionSnapshot(
  session: StudySession(
    id: 'session-001',
    entryType: StudyEntryType.deck,
    entryRefId: 'deck-001',
    studyType: studyType,
    studyFlow: studyFlow,
    settings: settings,
    status: SessionStatus.inProgress,
    startedAt: 0,
    endedAt: null,
    restartedFromSessionId: null,
  ),
  currentItem: StudySessionItem(
    id: 'item-001',
    sessionId: 'session-001',
    flashcard: flashcard,
    studyMode: mode,
    modeOrder: 1,
    roundIndex: 1,
    queuePosition: 1,
    sourcePool: flashcard.sourcePool,
    status: SessionItemStatus.pending,
    completedAt: null,
  ),
  sessionFlashcards: [flashcard],
  summary: const StudySummary(
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

StudyFlashcardRef _card({
  SessionItemSourcePool sourcePool = SessionItemSourcePool.newCards,
}) => StudyFlashcardRef(
  id: 'card-${sourcePool.storageValue}',
  deckId: 'deck-001',
  front: 'Front',
  back: 'Back',
  sourcePool: sourcePool,
);
