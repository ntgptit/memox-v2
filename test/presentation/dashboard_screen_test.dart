import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/theme/responsive/app_layout.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_overview_viewmodel.dart';
import 'package:memox/presentation/features/dashboard/widgets/dashboard_skeleton.dart';
import 'package:memox/presentation/shared/widgets/mx_card.dart';
import 'package:memox/presentation/shared/widgets/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/mx_progress_ring.dart';

const _maximumCompactDashboardActionButtonWidth = 160.0;

void main() {
  testWidgets('DT1 onOpen: shows skeleton while dashboard overview loads', (
    tester,
  ) async {
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

    expect(find.byType(DashboardSkeleton), findsOneWidget);
  });

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

    expect(find.text('Hello 👋'), findsOneWidget);
    expect(find.text('Ready to study today?'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Today\'s study focus'), findsOneWidget);
    expect(find.byType(MxProgressRing), findsOneWidget);
    expect(find.text('Library progress'), findsOneWidget);
    expect(find.text('30% mastery'), findsOneWidget);
    expect(find.text('30% mastery · 2 folders · 20 cards'), findsNothing);
    expect(find.text('2 folders · 3 decks · 20 cards'), findsOneWidget);
    expect(find.text('View library'), findsOneWidget);
    expect(find.text('Mastery'), findsOneWidget);
    expect(find.text('30%'), findsOneWidget);
    expect(find.text('Today Review'), findsOneWidget);
    expect(find.text('Overdue: 3'), findsOneWidget);
    expect(find.text('Due today: 2'), findsOneWidget);
    expect(find.text('New Study'), findsOneWidget);
    expect(find.text('7 new cards are ready.'), findsOneWidget);
    expect(
      find.text('7 new cards are ready for a deck or folder session.'),
      findsNothing,
    );
    expect(find.text('New cards available: 7'), findsOneWidget);
    expect(find.text('Resume'), findsWidgets);
    expect(find.text('Active sessions: 1'), findsOneWidget);
  });

  testWidgets(
    'DT2 onDisplay: disables study actions when no dashboard work exists',
    (tester) async {
      await _pumpDashboard(tester, _idleDashboardState);

      _expectSecondaryButtonEnabled(
        tester,
        key: const ValueKey('dashboard_review_now_action'),
        isEnabled: false,
      );
      _expectPrimaryButtonEnabled(
        tester,
        key: const ValueKey('dashboard_start_new_study_action'),
        isEnabled: false,
      );
      _expectSecondaryButtonEnabled(
        tester,
        key: const ValueKey('dashboard_continue_session_action'),
        isEnabled: false,
      );
      expect(find.byType(MxProgressRing), findsOneWidget);
      expect(find.text('Library progress'), findsOneWidget);
      expect(
        find.text('No active session. Start studying to resume later.'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('dashboard_action_list_card')),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
      final actionListCard = tester.widget<MxCard>(
        find.byKey(const ValueKey('dashboard_action_list_card')),
      );
      expect(actionListCard.variant, MxCardVariant.outlined);
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
      _expectSecondaryButtonSurface(reviewKey);
      _expectPrimaryButtonSurface(startKey);
      _expectSecondaryButtonSurface(resumeKey);

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
    'renders dashboard action buttons full-width in compact viewport',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      const reviewKey = ValueKey('dashboard_review_now_action');
      const startKey = ValueKey('dashboard_start_new_study_action');
      const resumeKey = ValueKey('dashboard_continue_session_action');

      await _pumpDashboard(tester, _newCardsOnlyDashboardState);

      _expectDashboardActionLabel(reviewKey, 'Review');
      _expectDashboardActionLabel(startKey, 'Start');
      _expectDashboardActionLabel(resumeKey, 'Resume');

      final buttonWidths = [
        _dashboardActionButtonSize(tester, reviewKey).width,
        _dashboardActionButtonSize(tester, startKey).width,
        _dashboardActionButtonSize(tester, resumeKey).width,
      ];

      expect(buttonWidths.toSet(), hasLength(1));
      expect(
        buttonWidths.first,
        greaterThan(_maximumCompactDashboardActionButtonWidth),
      );
    },
  );

  testWidgets(
    'DT4 onDisplay: renders singular library health without duplicated metadata',
    (tester) async {
      await _pumpDashboard(tester, _singleItemDashboardState);

      expect(find.text('1% mastery'), findsOneWidget);
      expect(find.text('1 folder · 1 deck · 1 card'), findsOneWidget);
      expect(find.text('1% mastery · 1 folders · 1 cards'), findsNothing);
      expect(find.textContaining('1 folders'), findsNothing);
    },
  );

  testWidgets(
    'DT5 onDisplay: renders recent deck highlights with content-only metadata',
    (tester) async {
      await _pumpDashboard(tester, _recentDecksDashboardState);
      await _scrollDashboardToDeckHighlights(tester);

      expect(find.text('Recent decks'), findsOneWidget);
      expect(find.text('Start a deck'), findsNothing);
      expect(find.text('Grammar'), findsOneWidget);
      expect(find.text('Vocabulary'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('Writing'), findsNothing);
      expect(find.text('12 cards'), findsOneWidget);
      expect(find.text('12 cards · 4 due today'), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('dashboard_deck_study_deck-grammar')),
          matching: find.text('4'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'DT6 onDisplay: renders start deck title for fallback deck highlights',
    (tester) async {
      await _pumpDashboard(tester, _fallbackDecksDashboardState);
      await _scrollDashboardToDeckHighlights(tester);

      expect(find.text('Start a deck'), findsOneWidget);
      expect(find.text('Recent decks'), findsNothing);
      expect(find.text('Starter'), findsOneWidget);
      expect(find.text('1 card'), findsOneWidget);
    },
  );

  testWidgets(
    'DT7 onDisplay: shows deck empty state CTA when no suggested decks exist',
    (tester) async {
      await _pumpDashboard(tester, _idleDashboardState);
      await _scrollDashboardToDeckHighlights(tester);

      expect(find.text('Recent decks'), findsNothing);
      expect(find.text('Start a deck'), findsOneWidget);
      expect(
        find.text('Add or import cards before starting a new study session.'),
        findsNWidgets(2),
      );
    },
  );

  testWidgets('shows skeleton layout while dashboard data is loading', (
    tester,
  ) async {
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

    expect(find.byType(DashboardSkeleton), findsOneWidget);
    expect(find.byKey(const ValueKey('dashboard_skeleton')), findsOneWidget);
  });

  testWidgets(
    'DT1 onResponsive: keeps dashboard dense on Samsung 412x915 viewport',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(412, 915);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await _pumpDashboard(tester, _studyReadyDashboardState);

      expect(find.text('Hello 👋'), findsNothing);
      expect(find.text('Ready to study today?'), findsNothing);
      expect(find.text('Today Review'), findsOneWidget);
      expect(find.text('New Study'), findsOneWidget);
      expect(find.text('Resume'), findsWidgets);
      expect(find.text('5 due'), findsOneWidget);
      expect(find.text('7 new'), findsOneWidget);
      expect(find.text('1 active'), findsOneWidget);
      expect(find.text('7 new cards are ready.'), findsNothing);
      expect(find.text('New cards available: 7'), findsNothing);
      expect(find.text('30% mastery'), findsNothing);
      expect(find.text('2 folders · 3 decks · 20 cards'), findsOneWidget);

      final progressRing = find.byType(MxProgressRing);
      expect(progressRing, findsOneWidget);
      final progressContext = tester.element(progressRing);
      expect(
        tester.getSize(progressRing),
        Size.square(AppLayout.dashboardChartSize(progressContext)),
      );

      final actionListCard = find.byKey(
        const ValueKey('dashboard_action_list_card'),
      );
      expect(actionListCard, findsOneWidget);
      final cardSize = tester.getSize(actionListCard);
      expect(cardSize.width, lessThanOrEqualTo(412));
    },
  );

  testWidgets('renders dashboard without overflow at text scale 1.5', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(() {
      tester.platformDispatcher.textScaleFactorTestValue = 1.0;
    });

    await _pumpDashboard(tester, _studyReadyDashboardState);

    expect(find.text('Today Review'), findsOneWidget);
    expect(find.text('New Study'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('dashboard_content')),
      const Offset(0, -320),
    );
    await tester.pumpAndSettle();
    expect(find.text('Library progress'), findsOneWidget);
  });

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

  testWidgets(
    'DT5 onNavigate: tapping a recent deck row opens flashcards and preserves back stack',
    (tester) async {
      final router = _dashboardRouter();
      addTearDown(router.dispose);
      await _pumpDashboardRouter(tester, router, _recentDecksDashboardState);
      await _scrollDashboardToDeckHighlights(tester);

      await tester.ensureVisible(
        find.byKey(const ValueKey('dashboard_deck_deck-grammar')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Grammar'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('flashcard_list_destination')),
        findsOneWidget,
      );
      expect(router.canPop(), isTrue);

      router.pop();
      await tester.pumpAndSettle();

      expect(find.text('Recent decks'), findsOneWidget);
      expect(find.text('Grammar'), findsOneWidget);
    },
  );

  testWidgets(
    'DT6 onNavigate: tapping a recent deck study action opens study',
    (tester) async {
      final router = _dashboardRouter();
      addTearDown(router.dispose);
      await _pumpDashboardRouter(tester, router, _recentDecksDashboardState);
      await _scrollDashboardToDeckHighlights(tester);

      await _tapDashboardButton(
        tester,
        const ValueKey('dashboard_deck_study_deck-grammar'),
      );

      expect(
        router.routeInformationProvider.value.uri.path,
        '/library/study/deck/deck-grammar',
      );
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
        locale: const Locale('en'),
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

Future<void> _scrollDashboardToDeckHighlights(WidgetTester tester) async {
  await tester.drag(
    find.byKey(const ValueKey('dashboard_content')),
    const Offset(0, -900),
  );
  await tester.pumpAndSettle();
}

void _expectPrimaryButtonEnabled(
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

void _expectSecondaryButtonEnabled(
  WidgetTester tester, {
  required Key key,
  required bool isEnabled,
}) {
  final finder = find.descendant(
    of: find.byKey(key),
    matching: find.byType(OutlinedButton),
  );
  final button = tester.widget<OutlinedButton>(finder);
  expect(button.onPressed, isEnabled ? isNotNull : isNull);
}

void _expectPrimaryButtonSurface(Key key) {
  expect(
    find.descendant(of: find.byKey(key), matching: find.byType(ElevatedButton)),
    findsOneWidget,
  );
  expect(
    find.descendant(of: find.byKey(key), matching: find.byType(OutlinedButton)),
    findsNothing,
  );
}

void _expectSecondaryButtonSurface(Key key) {
  expect(
    find.descendant(of: find.byKey(key), matching: find.byType(OutlinedButton)),
    findsOneWidget,
  );
  expect(
    find.descendant(of: find.byKey(key), matching: find.byType(ElevatedButton)),
    findsNothing,
  );
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
            path: RoutePaths.flashcardListSegment,
            name: RouteNames.flashcardList,
            builder: (context, state) =>
                const SizedBox(key: ValueKey('flashcard_list_destination')),
          ),
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
          GoRoute(
            path: RoutePaths.studyEntrySegment,
            name: RouteNames.studyEntry,
            builder: (context, state) =>
                const SizedBox(key: ValueKey('study_entry_destination')),
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
      locale: const Locale('en'),
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
  deckHighlights: <DashboardDeckHighlightItem>[],
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
  deckHighlights: <DashboardDeckHighlightItem>[],
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
  deckHighlights: <DashboardDeckHighlightItem>[],
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
  deckHighlights: <DashboardDeckHighlightItem>[],
);

const _singleItemDashboardState = DashboardOverviewState(
  overdueCount: 0,
  dueTodayCount: 0,
  newCardCount: 0,
  activeSessionCount: 0,
  folderCount: 1,
  deckCount: 1,
  cardCount: 1,
  masteryPercent: 1,
  resumeSessionId: null,
  deckHighlights: <DashboardDeckHighlightItem>[],
);

const _recentDecksDashboardState = DashboardOverviewState(
  overdueCount: 0,
  dueTodayCount: 0,
  newCardCount: 0,
  activeSessionCount: 0,
  folderCount: 1,
  deckCount: 4,
  cardCount: 32,
  masteryPercent: 25,
  resumeSessionId: null,
  deckHighlights: <DashboardDeckHighlightItem>[
    DashboardDeckHighlightItem(
      id: 'deck-grammar',
      name: 'Grammar',
      cardCount: 12,
      dueTodayCount: 4,
      masteryPercent: 43,
      lastStudiedAt: 5000,
    ),
    DashboardDeckHighlightItem(
      id: 'deck-vocabulary',
      name: 'Vocabulary',
      cardCount: 9,
      dueTodayCount: 0,
      masteryPercent: 29,
      lastStudiedAt: 3000,
    ),
    DashboardDeckHighlightItem(
      id: 'deck-reading',
      name: 'Reading',
      cardCount: 7,
      dueTodayCount: 1,
      masteryPercent: 14,
      lastStudiedAt: null,
    ),
    DashboardDeckHighlightItem(
      id: 'deck-writing',
      name: 'Writing',
      cardCount: 4,
      dueTodayCount: 0,
      masteryPercent: 0,
      lastStudiedAt: null,
    ),
  ],
);

const _fallbackDecksDashboardState = DashboardOverviewState(
  overdueCount: 0,
  dueTodayCount: 0,
  newCardCount: 0,
  activeSessionCount: 0,
  folderCount: 1,
  deckCount: 1,
  cardCount: 1,
  masteryPercent: 0,
  resumeSessionId: null,
  deckHighlights: <DashboardDeckHighlightItem>[
    DashboardDeckHighlightItem(
      id: 'deck-starter',
      name: 'Starter',
      cardCount: 1,
      dueTodayCount: 0,
      masteryPercent: 0,
      lastStudiedAt: null,
    ),
  ],
);
