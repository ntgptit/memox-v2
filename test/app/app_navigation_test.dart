import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:memox/app/router/app_navigation.dart';

void main() {
  testWidgets('DT1 onNavigate: popRoute falls back when the current route cannot pop', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/detail',
      routes: [
        GoRoute(
          path: '/detail',
          builder: (context, state) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () =>
                      context.popRoute(fallback: () => context.go('/fallback')),
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
  });

  testWidgets('DT2 onNavigate: popRoute pops the current page when a previous route exists', (
    WidgetTester tester,
  ) async {
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
                  onPressed: () =>
                      context.popRoute(fallback: () => context.go('/fallback')),
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
  });
}
