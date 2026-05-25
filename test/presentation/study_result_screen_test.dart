import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/providers/study_session_notifier.dart';
import 'package:memox/presentation/features/study/screens/study_result_screen.dart';
import 'package:memox/presentation/shared/widgets/mx_loading_state.dart';

void main() {
  testWidgets('DT1 onOpen: shows loading state while result loads', (
    tester,
  ) async {
    final completer = Completer<StudySessionSnapshot>();
    addTearDown(() {
      if (!completer.isCompleted) {
        completer.complete(_snapshot(SessionStatus.completed));
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => completer.future),
        ],
        child: const _TestApp(
          child: StudyResultScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(MxLoadingState), findsOneWidget);
  });

  testWidgets(
    'DT1 onDisplay: completed result separates card outcome and attempt accuracy',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionStateProvider('session-001').overrideWith(
              (ref) => Future.value(_snapshot(SessionStatus.completed)),
            ),
          ],
          child: const _TestApp(
            child: StudyResultScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Session summary'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cards mastered: 4/4'), findsOneWidget);
      expect(find.text('Attempt accuracy'), findsOneWidget);
      expect(find.text('83%'), findsWidgets);
      expect(find.text('Retry cards'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Accuracy'), findsNothing);

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Review'), findsOneWidget);
      expect(find.text('Study'), findsOneWidget);
    },
  );

  testWidgets('DT2 onDisplay: cancelled result keeps a distinct status label', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider('session-001').overrideWith(
            (ref) => Future.value(_snapshot(SessionStatus.cancelled)),
          ),
        ],
        child: const _TestApp(
          child: StudyResultScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Completed'), findsNothing);
  });

  testWidgets('DT1 onNavigate: Back returns to the previous route', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider('session-001').overrideWith(
            (ref) => Future.value(_snapshot(SessionStatus.completed)),
          ),
        ],
        child: const _TestRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open result'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Previous route'), findsOneWidget);
    expect(find.text('Library'), findsNothing);
  });

  testWidgets('DT2 onNavigate: Review preserves the result route underneath', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider('session-001').overrideWith(
            (ref) => Future.value(_snapshot(SessionStatus.completed)),
          ),
        ],
        child: const _TestRouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open result'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Today back'));
    await tester.pumpAndSettle();

    expect(find.text('Study'), findsOneWidget);
    expect(find.text('Library'), findsNothing);
  });
}

StudySessionSnapshot _snapshot(SessionStatus status) => StudySessionSnapshot(
  session: StudySession(
    id: 'session-001',
    entryType: StudyEntryType.deck,
    entryRefId: 'deck-001',
    studyType: StudyType.srsReview,
    studyFlow: StudyFlow.srsFillReview,
    settings: const StudySettingsSnapshot(
      batchSize: 4,
      shuffleFlashcards: false,
      shuffleAnswers: false,
      prioritizeOverdue: true,
    ),
    status: status,
    startedAt: 0,
    endedAt: 1,
    restartedFromSessionId: null,
  ),
  currentItem: null,
  sessionFlashcards: const <StudyFlashcardRef>[],
  summary: const StudySummary(
    totalCards: 4,
    masteredCardCount: 4,
    retryCardCount: 2,
    completedAttempts: 6,
    correctAttempts: 5,
    incorrectAttempts: 1,
    increasedBoxCount: 1,
    decreasedBoxCount: 0,
    remainingCount: 0,
  ),
  canFinalize: false,
);

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
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
                    onPressed: () =>
                        context.push('/study/session/session-001/result'),
                    child: const Text('Open result'),
                  ),
                ],
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/${RoutePaths.studyResultSegment}',
          name: RouteNames.studyResult,
          builder: (context, state) =>
              const StudyResultScreen(sessionId: 'session-001'),
        ),
        GoRoute(
          path: '/${RoutePaths.studyTodaySegment}',
          name: RouteNames.studyToday,
          builder: (context, state) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () =>
                    context.popRoute(fallback: () => context.go('/library')),
                child: const Text('Today back'),
              ),
            ),
          ),
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
