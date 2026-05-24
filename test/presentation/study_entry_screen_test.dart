import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/study/study_data_providers.dart';
import 'package:memox/app/router/route_names.dart';
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

  testWidgets('DT2 onNavigate: selected mode starts that mode directly', (
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
        child: _TestRouterApp(
          initialLocation: _deckEntryLocation(studyMode: StudyMode.match),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Session session-001'), findsOneWidget);
    expect(repo.startedFlow, StudyFlow.newMatchOnly);
    expect(repo.startedModes, <StudyMode>[StudyMode.match]);
  });

  testWidgets('DT3 onNavigate: resume candidate opens existing session', (
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
    await tester.pumpAndSettle();

    expect(find.text('Session resume-session-001'), findsOneWidget);
    expect(repo.startCount, 0);
  });

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

  @override
  Future<List<StudyFlashcardRef>> loadNewCards(StudyContext context) async => [_card()];

  @override
  Future<List<StudyFlashcardRef>> loadDueCards(StudyContext context) async => [_card(sourcePool: SessionItemSourcePool.due)];

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
  Future<List<StudySessionSnapshot>> listActiveSessions() async => const <StudySessionSnapshot>[];

  @override
  Future<StudySessionSnapshot> loadSession(String sessionId) {
    throw UnimplementedError();
  }

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
  Future<StudySessionSnapshot> cancelSession(String sessionId) {
    throw UnimplementedError();
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
  Future<List<StudyFlashcardRef>> loadNewCards(StudyContext context) async => const <StudyFlashcardRef>[];

  @override
  Future<List<StudyFlashcardRef>> loadDueCards(StudyContext context) async => const <StudyFlashcardRef>[];
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
