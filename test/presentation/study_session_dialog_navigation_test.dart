import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/study/study_data_providers.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/providers/study_session_notifier.dart';
import 'package:memox/presentation/features/study/screens/study_session_screen.dart';

void main() {
  testWidgets(
    'DT1 onNavigate: confirmed cancel dialog preserves route below result',
    (tester) async {
      final repo = _CancelDialogStudyRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_activeFillSnapshot)),
          ],
          child: const _TestRouterApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open session'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel this session?'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(repo.cancelCount, 1);
      expect(find.text('Result back'), findsOneWidget);
      expect(find.text('Study session'), findsNothing);

      await tester.tap(find.text('Result back'));
      await tester.pumpAndSettle();

      expect(find.text('Previous route'), findsOneWidget);
      expect(find.text('Library'), findsNothing);
    },
  );
}

class _TestRouterApp extends StatelessWidget {
  const _TestRouterApp();

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/previous',
      routes: [
        GoRoute(
          path: '/previous',
          builder: (context, state) => Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Previous route'),
                  TextButton(
                    onPressed: () => context.goStudySession('session-001'),
                    child: const Text('Open session'),
                  ),
                ],
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/${RoutePaths.studyResultSegment}',
          name: RouteNames.studyResult,
          builder: (context, state) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () =>
                    context.popRoute(fallback: () => context.go('/library')),
                child: const Text('Result back'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/${RoutePaths.studySessionSegment}',
          name: RouteNames.studySession,
          builder: (context, state) =>
              const StudySessionScreen(sessionId: 'session-001'),
        ),
        GoRoute(
          path: '/library',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Library'))),
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

final class _CancelDialogStudyRepo implements StudyRepo {
  int cancelCount = 0;

  @override
  Future<int> countFlashcardsInDeck(String deckId) async => 1;

  @override
  Future<List<StudyFlashcardRef>> loadNewCards(StudyContext context) {
    throw UnimplementedError();
  }

  @override
  Future<List<StudyFlashcardRef>> loadDueCards(StudyContext context) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot?> findResumeCandidate(StudyContext context) {
    throw UnimplementedError();
  }

  @override
  Future<List<StudySessionSnapshot>> listActiveSessions() {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> startSession({
    required StudyContext context,
    required StudyFlow flow,
    required List<StudyMode> modes,
    required List<StudyFlashcardRef> batch,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> loadSession(String sessionId) =>
      Future.value(_activeFillSnapshot);

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
    cancelCount += 1;
    return Future.value(_cancelledSnapshot);
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

const _fillCard = StudyFlashcardRef(
  id: 'card-001',
  deckId: 'deck-001',
  front: 'front 1',
  back: 'back 1',
  sourcePool: SessionItemSourcePool.newCards,
);

const _fillItem = StudySessionItem(
  id: 'item-001',
  sessionId: 'session-001',
  flashcard: _fillCard,
  studyMode: StudyMode.fill,
  modeOrder: 4,
  roundIndex: 1,
  queuePosition: 1,
  sourcePool: SessionItemSourcePool.newCards,
  status: SessionItemStatus.pending,
  completedAt: null,
);

const _studySettings = StudySettingsSnapshot(
  batchSize: 5,
  shuffleFlashcards: false,
  shuffleAnswers: false,
  prioritizeOverdue: true,
);

const _summary = StudySummary(
  totalCards: 1,
  masteredCardCount: 0,
  retryCardCount: 0,
  completedAttempts: 0,
  correctAttempts: 0,
  incorrectAttempts: 0,
  increasedBoxCount: 0,
  decreasedBoxCount: 0,
  remainingCount: 1,
);

const _activeFillSnapshot = StudySessionSnapshot(
  session: StudySession(
    id: 'session-001',
    entryType: StudyEntryType.deck,
    entryRefId: 'deck-001',
    studyType: StudyType.newStudy,
    studyFlow: StudyFlow.newFullCycle,
    settings: _studySettings,
    status: SessionStatus.inProgress,
    startedAt: 0,
    endedAt: null,
    restartedFromSessionId: null,
  ),
  currentItem: _fillItem,
  sessionFlashcards: [_fillCard],
  summary: _summary,
  canFinalize: false,
);

const _cancelledSnapshot = StudySessionSnapshot(
  session: StudySession(
    id: 'session-001',
    entryType: StudyEntryType.deck,
    entryRefId: 'deck-001',
    studyType: StudyType.newStudy,
    studyFlow: StudyFlow.newFullCycle,
    settings: _studySettings,
    status: SessionStatus.cancelled,
    startedAt: 0,
    endedAt: 1,
    restartedFromSessionId: null,
  ),
  currentItem: null,
  sessionFlashcards: [_fillCard],
  summary: _summary,
  canFinalize: false,
);
