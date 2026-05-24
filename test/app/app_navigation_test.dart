import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/app/router/route_names.dart';

void main() {
  testWidgets(
    'DT1 onNavigate: popRoute falls back when the current route cannot pop',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/detail',
        routes: [
          GoRoute(
            path: '/detail',
            builder: (context, state) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.popRoute(
                      fallback: () => context.go('/fallback'),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ),
          ),
          GoRoute(
            path: '/fallback',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Fallback'))),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Fallback'), findsOneWidget);
    },
  );

  testWidgets(
    'DT2 onNavigate: popRoute pops the current page when a previous route exists',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.push('/detail'),
                    child: const Text('Open detail'),
                  ),
                ),
              ),
          ),
          GoRoute(
            path: '/detail',
            builder: (context, state) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.popRoute(
                      fallback: () => context.go('/fallback'),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ),
          ),
          GoRoute(
            path: '/fallback',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Fallback'))),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open detail'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Open detail'), findsOneWidget);
      expect(find.text('Fallback'), findsNothing);
    },
  );

  testWidgets(
    'DT3 onNavigate: deck study entry preserves the previous deck route',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/deck/deck-001/flashcards',
        routes: [
          GoRoute(
            path: '/${RoutePaths.flashcardListSegment}',
            name: RouteNames.flashcardList,
            builder: (context, state) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.goStudyEntry(
                      entryType: 'deck',
                      entryRefId: 'deck-001',
                    ),
                    child: const Text('Deck screen'),
                  ),
                ),
              ),
          ),
          GoRoute(
            path: '/${RoutePaths.studyEntrySegment}',
            name: RouteNames.studyEntry,
            builder: (context, state) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.popRoute(
                      fallback: () => context.go('/library'),
                    ),
                    child: const Text('Back'),
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

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Deck screen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Deck screen'), findsOneWidget);
      expect(find.text('Library'), findsNothing);
    },
  );

  testWidgets(
    'DT4 onNavigate: study session preserves the previous study entry route',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/study/deck/deck-001',
        routes: [
          GoRoute(
            path: '/${RoutePaths.studySessionSegment}',
            name: RouteNames.studySession,
            builder: (context, state) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.popRoute(
                      fallback: () => context.go('/library'),
                    ),
                    child: const Text('Study session'),
                  ),
                ),
              ),
          ),
          GoRoute(
            path: '/${RoutePaths.studyEntrySegment}',
            name: RouteNames.studyEntry,
            builder: (context, state) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.goStudySession('session-001'),
                    child: const Text('Study entry'),
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

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Study entry'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Study session'));
      await tester.pumpAndSettle();

      expect(find.text('Study entry'), findsOneWidget);
      expect(find.text('Library'), findsNothing);
    },
  );

  testWidgets(
    'DT5 onNavigate: study result replaces session while preserving entry',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/study/deck/deck-001',
        routes: [
          GoRoute(
            path: '/${RoutePaths.studySessionSegment}',
            name: RouteNames.studySession,
            builder: (context, state) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.goStudyResult('session-001'),
                    child: const Text('Study session'),
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
                    onPressed: () => context.popRoute(
                      fallback: () => context.go('/library'),
                    ),
                    child: const Text('Study result'),
                  ),
                ),
              ),
          ),
          GoRoute(
            path: '/${RoutePaths.studyEntrySegment}',
            name: RouteNames.studyEntry,
            builder: (context, state) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.goStudySession('session-001'),
                    child: const Text('Study entry'),
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

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Study entry'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Study session'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Study result'));
      await tester.pumpAndSettle();

      expect(find.text('Study entry'), findsOneWidget);
      expect(find.text('Study session'), findsNothing);
      expect(find.text('Library'), findsNothing);
    },
  );

  testWidgets(
    'DT6 onNavigate: pushed Today study entry can pop back to result',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/previous',
        routes: [
          GoRoute(
            path: '/previous',
            builder: (context, state) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () =>
                        context.push('/study/session/session-001/result'),
                    child: const Text('Previous route'),
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
                    onPressed: context.pushStudyToday,
                    child: const Text('Study result'),
                  ),
                ),
              ),
          ),
          GoRoute(
            path: '/${RoutePaths.studyTodaySegment}',
            name: RouteNames.studyToday,
            builder: (context, state) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.popRoute(
                      fallback: () => context.go('/library'),
                    ),
                    child: const Text('Today study'),
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

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Previous route'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Study result'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Today study'));
      await tester.pumpAndSettle();

      expect(find.text('Study result'), findsOneWidget);
      expect(find.text('Library'), findsNothing);
    },
  );
}
