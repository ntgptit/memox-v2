import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_overview_viewmodel.dart';
import 'package:memox/presentation/shared/states/mx_error_state.dart';
import 'package:memox/presentation/shared/states/mx_loading_state.dart';

const _maximumCompactDashboardActionButtonWidth = 160.0;

void main() {
  testWidgets(
    'DT1 onOpen: shows loading state while dashboard overview loads',
    (tester) async {
      final completer = Completer<DashboardOverviewState>();
      addTearDown(() {
        if (!completer.isCompleted) {
          completer.complete(_studyReadyDashboardState);
        }
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardOverviewProvider.overrideWith((ref) => completer.future),
          ],
          child: const _TestApp(child: DashboardScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(MxLoadingState), findsOneWidget);
    },
  );

  testWidgets(
    'DT1 onSearchFilterSort: shows retryable error state when dashboard overview fails',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardOverviewProvider.overrideWith(
              (ref) => Future<DashboardOverviewState>.error(
                Exception('dashboard failed'),
                StackTrace.current,
              ),
            ),
          ],
          child: const _TestApp(child: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MxErrorState), findsOneWidget);
    },
  );

  testWidgets('DT1 onDisplay: renders compact dashboard with progress chart', (
    tester,
  ) async {
    await _pumpDashboard(tester, _studyReadyDashboardState);

    expect(find.text('Today\'s study focus'), findsOneWidget);
    expect(find.byType(PieChart), findsOneWidget);
    expect(find.text('Library progress'), findsOneWidget);
    expect(find.text('30% mastery · 2 folders · 20 cards'), findsOneWidget);
    expect(find.text('2 folders · 3 decks · 20 cards'), findsOneWidget);
    expect(find.text('Mastery'), findsOneWidget);
    expect(find.text('30%'), findsOneWidget);
    expect(find.text('Today Review'), findsOneWidget);
    expect(find.text('Overdue: 3'), findsOneWidget);
    expect(find.text('Due today: 2'), findsOneWidget);
    expect(find.text('New Study'), findsOneWidget);
    expect(find.text('New cards available: 7'), findsOneWidget);
    expect(find.text('Resume'), findsWidgets);
    expect(find.text('Active sessions: 1'), findsOneWidget);
  });

  testWidgets(
    'DT2 onDisplay: disables study actions when no dashboard work exists',
    (tester) async {
      await _pumpDashboard(tester, _idleDashboardState);

      _expectElevatedButtonEnabled(
        tester,
        key: const ValueKey('dashboard_review_now_action'),
        isEnabled: false,
      );
      _expectElevatedButtonEnabled(
        tester,
        key: const ValueKey('dashboard_start_new_study_action'),
        isEnabled: false,
      );
      _expectElevatedButtonEnabled(
        tester,
        key: const ValueKey('dashboard_continue_session_action'),
        isEnabled: false,
      );
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('Library progress'), findsOneWidget);
    },
  );

  testWidgets(
    'DT3 onDisplay: keeps dashboard action buttons concise and equal width',
    (tester) async {
      const reviewKey = ValueKey('dashboard_review_now_action');
      const startKey = ValueKey('dashboard_start_new_study_action');
      const resumeKey = ValueKey('dashboard_continue_session_action');

      await _pumpDashboard(tester, _newCardsOnlyDashboardState);

      _expectDashboardActionLabel(reviewKey, 'Review');
      _expectDashboardActionLabel(startKey, 'Start');
      _expectDashboardActionLabel(resumeKey, 'Resume');
      expect(find.text('Review now'), findsNothing);
      expect(find.text('Start new study'), findsNothing);
      expect(find.text('Continue session'), findsNothing);

      final buttonWidths = [
        _dashboardActionButtonSize(tester, reviewKey).width,
        _dashboardActionButtonSize(tester, startKey).width,
        _dashboardActionButtonSize(tester, resumeKey).width,
      ];

      expect(buttonWidths.toSet(), hasLength(1));
      expect(
        buttonWidths.first,
        lessThanOrEqualTo(_maximumCompactDashboardActionButtonWidth),
      );
    },
  );

  testWidgets(
    'DT1 onNavigate: Review opens Today study entry when review cards exist',
    (tester) async {
      final router = _dashboardRouter();
      addTearDown(router.dispose);
      await _pumpDashboardRouter(tester, router, _studyReadyDashboardState);

      await _tapDashboardButton(
        tester,
        const ValueKey('dashboard_review_now_action'),
      );

      expect(
        router.routeInformationProvider.value.uri.path,
        '/library/study/today',
      );
    },
  );

  testWidgets('DT2 onNavigate: Start opens Library selection', (tester) async {
    final router = _dashboardRouter();
    addTearDown(router.dispose);
    await _pumpDashboardRouter(tester, router, _studyReadyDashboardState);

    await _tapDashboardButton(
      tester,
      const ValueKey('dashboard_start_new_study_action'),
    );

    expect(router.routeInformationProvider.value.uri.path, '/library');
  });

  testWidgets('DT3 onNavigate: Resume opens single resumable session', (
    tester,
  ) async {
    final router = _dashboardRouter();
    addTearDown(router.dispose);
    await _pumpDashboardRouter(tester, router, _studyReadyDashboardState);

    await _tapDashboardButton(
      tester,
      const ValueKey('dashboard_continue_session_action'),
    );

    expect(
      router.routeInformationProvider.value.uri.path,
      '/library/study/session/session-001',
    );
  });

  testWidgets(
    'DT4 onNavigate: Resume opens Progress when multiple sessions exist',
    (tester) async {
      final router = _dashboardRouter();
      addTearDown(router.dispose);
      await _pumpDashboardRouter(
        tester,
        router,
        _multipleSessionsDashboardState,
      );

      await _tapDashboardButton(
        tester,
        const ValueKey('dashboard_continue_session_action'),
      );

      expect(router.routeInformationProvider.value.uri.path, '/progress');
    },
  );
}

Future<void> _pumpDashboard(
  WidgetTester tester,
  DashboardOverviewState state,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardOverviewProvider.overrideWith(
          (ref) => Future<DashboardOverviewState>.value(state),
        ),
      ],
      child: const _TestApp(child: DashboardScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpDashboardRouter(
  WidgetTester tester,
  GoRouter router,
  DashboardOverviewState state,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardOverviewProvider.overrideWith(
          (ref) => Future<DashboardOverviewState>.value(state),
        ),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapDashboardButton(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

void _expectElevatedButtonEnabled(
  WidgetTester tester, {
  required Key key,
  required bool isEnabled,
}) {
  final finder = find.descendant(
    of: find.byKey(key),
    matching: find.byType(ElevatedButton),
  );
  final button = tester.widget<ElevatedButton>(finder);
  expect(button.onPressed, isEnabled ? isNotNull : isNull);
}

Size _dashboardActionButtonSize(WidgetTester tester, Key key) {
  return tester.getSize(find.byKey(key));
}

void _expectDashboardActionLabel(Key key, String label) {
  expect(
    find.descendant(of: find.byKey(key), matching: find.text(label)),
    findsOneWidget,
  );
}

GoRouter _dashboardRouter() {
  return GoRouter(
    initialLocation: RoutePaths.home,
    routes: [
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.library,
        name: RouteNames.library,
        builder: (context, state) => const SizedBox.shrink(),
        routes: [
          GoRoute(
            path: RoutePaths.studyTodaySegment,
            name: RouteNames.studyToday,
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: RoutePaths.studySessionSegment,
            name: RouteNames.studySession,
            builder: (context, state) => const SizedBox.shrink(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.progress,
        name: RouteNames.progress,
        builder: (context, state) => const SizedBox.shrink(),
      ),
    ],
  );
}

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

const _studyReadyDashboardState = DashboardOverviewState(
  overdueCount: 3,
  dueTodayCount: 2,
  newCardCount: 7,
  activeSessionCount: 1,
  folderCount: 2,
  deckCount: 3,
  cardCount: 20,
  masteryPercent: 30,
  resumeSessionId: 'session-001',
);

const _multipleSessionsDashboardState = DashboardOverviewState(
  overdueCount: 3,
  dueTodayCount: 2,
  newCardCount: 7,
  activeSessionCount: 2,
  folderCount: 2,
  deckCount: 3,
  cardCount: 20,
  masteryPercent: 30,
  resumeSessionId: null,
);

const _newCardsOnlyDashboardState = DashboardOverviewState(
  overdueCount: 0,
  dueTodayCount: 0,
  newCardCount: 7,
  activeSessionCount: 0,
  folderCount: 2,
  deckCount: 3,
  cardCount: 20,
  masteryPercent: 30,
  resumeSessionId: null,
);

const _idleDashboardState = DashboardOverviewState(
  overdueCount: 0,
  dueTodayCount: 0,
  newCardCount: 0,
  activeSessionCount: 0,
  folderCount: 0,
  deckCount: 0,
  cardCount: 0,
  masteryPercent: 0,
  resumeSessionId: null,
);
