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
            builder: (context, state) {
              return Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.popRoute(
                      fallback: () => context.go('/fallback'),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              );
            },
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
            builder: (context, state) {
              return Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.push('/detail'),
                    child: const Text('Open detail'),
                  ),
                ),
              );
            },
          ),
          GoRoute(
            path: '/detail',
            builder: (context, state) {
              return Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.popRoute(
                      fallback: () => context.go('/fallback'),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              );
            },
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
            builder: (context, state) {
              return Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.goStudyEntry(
                      entryType: 'deck',
                      entryRefId: 'deck-001',
                    ),
                    child: const Text('Deck screen'),
                  ),
                ),
              );
            },
          ),
          GoRoute(
            path: '/${RoutePaths.studyEntrySegment}',
            name: RouteNames.studyEntry,
            builder: (context, state) {
              return Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => context.popRoute(
                      fallback: () => context.go('/library'),
                    ),
                    child: const Text('Back'),
                  ),
                ),
              );
            },
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
}
