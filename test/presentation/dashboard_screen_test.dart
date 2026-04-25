import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox/presentation/features/folders/models/library_folder.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/shared/states/mx_error_state.dart';
import 'package:memox/presentation/shared/states/mx_loading_state.dart';

void main() {
  testWidgets('shows loading state while dashboard data loads', (tester) async {
    final completer = Completer<LibraryOverviewState>();
    addTearDown(() {
      if (!completer.isCompleted) {
        completer.complete(_sampleLibraryState);
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryOverviewQueryProvider.overrideWith((ref) => completer.future),
        ],
        child: const _TestApp(child: DashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(MxLoadingState), findsOneWidget);
  });

  testWidgets('shows retryable error state when dashboard query fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryOverviewQueryProvider.overrideWith(
            (ref) => Future<LibraryOverviewState>.error(
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
  });

  testWidgets('renders dashboard metrics and study CTA for due cards', (
    tester,
  ) async {
    final router = GoRouter(
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
        ),
        GoRoute(
          path: '/${RoutePaths.studyTodaySegment}',
          name: RouteNames.studyToday,
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryOverviewQueryProvider.overrideWith(
            (ref) => Future<LibraryOverviewState>.value(_sampleLibraryState),
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

    expect(find.text('Today\'s study focus'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1 folders · 12 cards'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('dashboard_study_today_action')),
    );
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/study/today');
  });
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

const _sampleLibraryState = LibraryOverviewState(
  greeting: LibraryOverviewGreeting(
    salutation: 'Good morning',
    userName: 'Lan',
  ),
  dueToday: 2,
  folders: <LibraryFolder>[
    LibraryFolder(
      id: 'folder-root-001',
      name: 'Korean',
      icon: Icons.folder_outlined,
      deckCount: 1,
      itemCount: 12,
      masteryPercent: 30,
    ),
  ],
);
