import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/theme/tokens/app_spacing.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/value_objects/content_actions.dart';
import 'package:memox/domain/value_objects/content_read_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_overview_viewmodel.dart';
import 'package:memox/presentation/features/dashboard/widgets/dashboard_skeleton.dart';
import 'package:memox/presentation/features/progress/providers/progress_session_notifier.dart';
import 'package:memox/presentation/shared/widgets/mx_error_state.dart';

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

  testWidgets('DT1 onDisplay: renders Home kit dashboard hero and stats', (
    tester,
  ) async {
    await _pumpDashboard(tester, _studyReadyDashboardState);

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Good evening, learner'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Due now'), findsOneWidget);
    expect(find.text('5 cards across 3 decks'), findsOneWidget);
    expect(find.text('About 2 minutes'), findsOneWidget);
    expect(find.text('Start review'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('0 days'), findsOneWidget);
    expect(find.text('Mastery'), findsOneWidget);
    expect(find.text('6 cards'), findsOneWidget);
    expect(find.text('Pick up where you left off'), findsOneWidget);
    expect(find.text('Start a deck'), findsOneWidget);
  });

  testWidgets(
    'DT2 onDisplay: renders caught-up Home state when no review cards exist',
    (tester) async {
      await _pumpDashboard(tester, _idleDashboardState);

      expect(find.text('All caught up'), findsOneWidget);
      expect(find.text('No cards due now'), findsOneWidget);
      expect(find.text('View library'), findsWidgets);
      expect(
        find.byKey(const ValueKey('dashboard_review_now_action')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('dashboard_start_new_study_action')),
        findsWidgets,
      );
    },
  );

  testWidgets(
    'DT3 onDisplay: keeps the due CTA primary and compact (not full-width)',
    (tester) async {
      await _pumpDashboard(tester, _studyReadyDashboardState);

      const reviewKey = ValueKey('dashboard_review_now_action');
      _expectDashboardActionLabel(reviewKey, 'Start review');
      _expectPrimaryButtonSurface(reviewKey);
      // UI-0: card actions must not be full-width hero blocks.
      expect(_dashboardActionButtonSize(tester, reviewKey).width, lessThan(300));
    },
  );

  testWidgets('DT3 onDisplay: secondary action is lighter than primary', (
    tester,
  ) async {
    await _pumpDashboard(tester, _studyReadyDashboardState);

    // "Start new learning" companion is secondary (tonal), not an ElevatedButton.
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('dashboard_start_new_study_action')),
        matching: find.byType(ElevatedButton),
      ),
      findsNothing,
    );
  });

  testWidgets(
    'renders dashboard action buttons compact (not full-width) in compact viewport',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await _pumpDashboard(tester, _studyReadyDashboardState);

      const reviewKey = ValueKey('dashboard_review_now_action');
      _expectDashboardActionLabel(reviewKey, 'Start review');
      expect(_dashboardActionButtonSize(tester, reviewKey).width, lessThan(300));
    },
  );

  testWidgets(
    'DT4 onDisplay: renders singular library health without duplicated metadata',
    (tester) async {
      await _pumpDashboard(tester, _singleItemDashboardState);

      expect(find.text('Mastery'), findsOneWidget);
      expect(find.text('0 cards'), findsOneWidget);
      expect(find.text('1% mastery · 1 folders · 1 cards'), findsNothing);
      expect(find.textContaining('1 folders'), findsNothing);
    },
  );

  testWidgets(
    'DT5 onDisplay: renders recent deck highlights with content-only metadata',
    (tester) async {
      await _pumpDashboard(tester, _recentDecksDashboardState);
      await _scrollDashboardToDeckHighlights(tester);

      expect(find.text('Pick up where you left off'), findsOneWidget);
      expect(find.text('Start a deck'), findsNothing);
      expect(find.text('Grammar'), findsOneWidget);
      expect(find.text('Vocabulary'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('Writing'), findsNothing);
      expect(find.text('4 due · 12 cards'), findsOneWidget);
      expect(find.text('12 cards · 4 due today'), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('dashboard_deck_study_deck-grammar')),
          matching: find.text('4'),
        ),
        findsOneWidget,
      );

      final deckTileSize = tester.getSize(
        find.byKey(const ValueKey('dashboard_deck_deck-grammar')),
      );
      expect(
        deckTileSize.height,
        greaterThanOrEqualTo(kMinInteractiveDimension + AppSpacing.lg * 2),
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
      expect(find.text('All caught up · 1 card'), findsOneWidget);
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
        findsOneWidget,
      );
    },
  );

  // --- Resume flow ----------------------------------------------------------

  testWidgets('Resume: resume card appears when a resumable session exists', (
    tester,
  ) async {
    await _pumpDashboard(tester, _resumableDashboardState);

    expect(
      find.byKey(const ValueKey('dashboard_resume_section')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('dashboard_resume_card')), findsOneWidget);
    expect(find.text('Continue studying'), findsOneWidget);
  });

  testWidgets('Resume: resume card hidden when no resumable session exists', (
    tester,
  ) async {
    await _pumpDashboard(tester, _studyReadyDashboardState);

    expect(find.byKey(const ValueKey('dashboard_resume_section')), findsNothing);
    expect(find.byKey(const ValueKey('dashboard_resume_card')), findsNothing);
  });

  testWidgets('Resume: appears above the due-now action card', (tester) async {
    await _pumpDashboard(tester, _resumableDashboardState);

    final resumeY = tester
        .getTopLeft(find.byKey(const ValueKey('dashboard_resume_section')))
        .dy;
    final dueY = tester
        .getTopLeft(find.byKey(const ValueKey('dashboard_due_now_card')))
        .dy;
    expect(resumeY, lessThan(dueY));
  });

  testWidgets('Resume: Continue navigates to the existing session', (
    tester,
  ) async {
    final router = _dashboardRouter();
    addTearDown(router.dispose);
    await _pumpDashboardRouter(tester, router, _resumableDashboardState);

    await _tapDashboardButton(
      tester,
      const ValueKey('dashboard_resume_continue_action'),
    );

    expect(
      router.routeInformationProvider.value.uri.path,
      '/library/study/session/session-001',
    );
  });

  testWidgets(
    'Resume: multiple paused sessions open the paused-sessions sheet',
    (tester) async {
      await _pumpDashboard(tester, _multiResumableDashboardState);

      await _tapDashboardButton(
        tester,
        const ValueKey('dashboard_more_paused_sessions'),
      );

      expect(
        find.byKey(const ValueKey('dashboard_paused_sessions_sheet')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('dashboard_paused_session_session-001')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('dashboard_paused_session_session-002')),
        findsOneWidget,
      );
    },
  );

  testWidgets('Resume: Discard shows a confirmation dialog', (tester) async {
    await _pumpDashboard(tester, _resumableDashboardState);

    await _tapDashboardButton(
      tester,
      const ValueKey('dashboard_resume_discard_action'),
    );

    expect(find.text('Discard this session?'), findsOneWidget);
  });

  testWidgets(
    'Resume: confirming discard cancels the session through the use-case path',
    (tester) async {
      final stub = _StubProgressSessionActionController();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardOverviewProvider.overrideWith(
              (ref) =>
                  Future<DashboardOverviewState>.value(_resumableDashboardState),
            ),
            progressSessionActionControllerProvider.overrideWith(
              () => stub,
            ),
          ],
          child: const _TestApp(child: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await _tapDashboardButton(
        tester,
        const ValueKey('dashboard_resume_discard_action'),
      );
      // The dialog's confirm is the primary (ElevatedButton); the card's
      // discard action is a lighter secondary, so target the primary.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Discard'));
      await tester.pumpAndSettle();

      expect(stub.cancelledSessionId, 'session-001');
      expect(find.text('Discard this session?'), findsNothing);
      expect(find.text('Session discarded.'), findsOneWidget);
    },
  );

  // --- Start new learning / scope picker ------------------------------------

  testWidgets('Scope: Start new learning opens the scope picker', (
    tester,
  ) async {
    await _pumpDashboard(tester, _studyReadyDashboardState);

    await _tapDashboardButton(
      tester,
      const ValueKey('dashboard_start_new_study_action'),
    );

    expect(find.text('What do you want to study?'), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Deck'), findsWidgets);
    expect(find.text('Folder'), findsWidgets);
  });

  testWidgets('Scope: Tag scope is not offered in V1', (tester) async {
    await _pumpDashboard(tester, _studyReadyDashboardState);

    await _tapDashboardButton(
      tester,
      const ValueKey('dashboard_start_new_study_action'),
    );

    expect(find.text('Tag'), findsNothing);
  });

  testWidgets(
    'Scope: selecting deck scope navigates to the Study Entry Gate',
    (tester) async {
      final router = _dashboardRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardOverviewProvider.overrideWith(
              (ref) =>
                  Future<DashboardOverviewState>.value(_studyReadyDashboardState),
            ),
            dashboardDeckScopeOptionsProvider.overrideWith(
              (ref) => Future<List<DeckMoveTarget>>.value(const [
                DeckMoveTarget(
                  id: 'deck-1',
                  name: 'Korean N5',
                  breadcrumb: <String>[],
                ),
              ]),
            ),
          ],
          child: _TestRouterApp(router: router),
        ),
      );
      await tester.pumpAndSettle();

      await _tapDashboardButton(
        tester,
        const ValueKey('dashboard_start_new_study_action'),
      );
      await tester.tap(find.text('Deck'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Korean N5'));
      await tester.pumpAndSettle();

      expect(
        router.routeInformationProvider.value.uri.path,
        '/library/study/deck/deck-1',
      );
    },
  );

  testWidgets(
    'Scope: selecting folder scope navigates to the Study Entry Gate',
    (tester) async {
      final router = _dashboardRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardOverviewProvider.overrideWith(
              (ref) =>
                  Future<DashboardOverviewState>.value(_studyReadyDashboardState),
            ),
            dashboardFolderScopeOptionsProvider.overrideWith(
              (ref) => Future<List<FolderScopeOption>>.value(const [
                FolderScopeOption(
                  id: 'folder-1',
                  name: 'Grammar',
                  breadcrumb: <String>['Grammar'],
                ),
              ]),
            ),
          ],
          child: _TestRouterApp(router: router),
        ),
      );
      await tester.pumpAndSettle();

      await _tapDashboardButton(
        tester,
        const ValueKey('dashboard_start_new_study_action'),
      );
      await tester.tap(find.text('Folder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Grammar'));
      await tester.pumpAndSettle();

      expect(
        router.routeInformationProvider.value.uri.path,
        '/library/study/folder/folder-1',
      );
    },
  );

  testWidgets(
    'Scope: selecting today scope navigates to today study entry',
    (tester) async {
      final router = _dashboardRouter();
      addTearDown(router.dispose);
      await _pumpDashboardRouter(tester, router, _studyReadyDashboardState);

      await _tapDashboardButton(
        tester,
        const ValueKey('dashboard_start_new_study_action'),
      );
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      expect(
        router.routeInformationProvider.value.uri.path,
        '/library/study/today',
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

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Good evening, learner'), findsOneWidget);
      expect(find.text('Due now'), findsOneWidget);
      expect(find.text('5 cards across 3 decks'), findsOneWidget);
      expect(find.text('Start review'), findsOneWidget);
      expect(find.text('Pick up where you left off'), findsOneWidget);

      final actionListCard = find.byKey(
        const ValueKey('dashboard_due_now_card'),
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

    expect(find.text('Due now'), findsOneWidget);
    expect(find.text('Start review'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('dashboard_content')),
      const Offset(0, -320),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pick up where you left off'), findsOneWidget);
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

      expect(find.text('Pick up where you left off'), findsOneWidget);
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
      child: _TestRouterApp(router: router),
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

Size _dashboardActionButtonSize(WidgetTester tester, Key key) =>
    tester.getSize(find.byKey(key));

void _expectDashboardActionLabel(Key key, String label) {
  expect(
    find.descendant(of: find.byKey(key), matching: find.text(label)),
    findsOneWidget,
  );
}

GoRouter _dashboardRouter() => GoRouter(
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

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: child,
  );
}

class _TestRouterApp extends StatelessWidget {
  const _TestRouterApp({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    routerConfig: router,
  );
}

/// Captures the cancelled session id so the discard-confirm flow can be tested
/// without binding the real study repository.
class _StubProgressSessionActionController
    extends ProgressSessionActionController {
  String? cancelledSessionId;

  @override
  Future<bool> cancel(String sessionId) async {
    cancelledSessionId = sessionId;
    return true;
  }
}

DashboardResumeSessionItem _resumeItem(String id) => DashboardResumeSessionItem(
  sessionId: id,
  studyType: StudyType.srsReview,
  entryType: StudyEntryType.deck,
  completedSteps: 12,
  totalSteps: 24,
  remainingCount: 12,
  startedAt: 1000,
);

final _studyReadyDashboardState = DashboardOverviewState(
  overdueCount: 3,
  dueTodayCount: 2,
  newCardCount: 7,
  resumeSessions: const <DashboardResumeSessionItem>[],
  folderCount: 2,
  deckCount: 3,
  cardCount: 20,
  masteryPercent: 30,
  deckHighlights: const <DashboardDeckHighlightItem>[],
);

final _resumableDashboardState = DashboardOverviewState(
  overdueCount: 3,
  dueTodayCount: 2,
  newCardCount: 7,
  resumeSessions: <DashboardResumeSessionItem>[_resumeItem('session-001')],
  folderCount: 2,
  deckCount: 3,
  cardCount: 20,
  masteryPercent: 30,
  deckHighlights: const <DashboardDeckHighlightItem>[],
);

final _multiResumableDashboardState = DashboardOverviewState(
  overdueCount: 3,
  dueTodayCount: 2,
  newCardCount: 7,
  resumeSessions: <DashboardResumeSessionItem>[
    _resumeItem('session-001'),
    _resumeItem('session-002'),
  ],
  folderCount: 2,
  deckCount: 3,
  cardCount: 20,
  masteryPercent: 30,
  deckHighlights: const <DashboardDeckHighlightItem>[],
);

final _idleDashboardState = DashboardOverviewState(
  overdueCount: 0,
  dueTodayCount: 0,
  newCardCount: 0,
  resumeSessions: const <DashboardResumeSessionItem>[],
  folderCount: 0,
  deckCount: 0,
  cardCount: 0,
  masteryPercent: 0,
  deckHighlights: const <DashboardDeckHighlightItem>[],
);

final _singleItemDashboardState = DashboardOverviewState(
  overdueCount: 0,
  dueTodayCount: 0,
  newCardCount: 0,
  resumeSessions: const <DashboardResumeSessionItem>[],
  folderCount: 1,
  deckCount: 1,
  cardCount: 1,
  masteryPercent: 1,
  deckHighlights: const <DashboardDeckHighlightItem>[],
);

final _recentDecksDashboardState = DashboardOverviewState(
  overdueCount: 0,
  dueTodayCount: 0,
  newCardCount: 0,
  resumeSessions: const <DashboardResumeSessionItem>[],
  folderCount: 1,
  deckCount: 4,
  cardCount: 32,
  masteryPercent: 25,
  deckHighlights: const <DashboardDeckHighlightItem>[
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

final _fallbackDecksDashboardState = DashboardOverviewState(
  overdueCount: 0,
  dueTodayCount: 0,
  newCardCount: 0,
  resumeSessions: const <DashboardResumeSessionItem>[],
  folderCount: 1,
  deckCount: 1,
  cardCount: 1,
  masteryPercent: 0,
  deckHighlights: const <DashboardDeckHighlightItem>[
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
