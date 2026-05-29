import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/domain/study/entities/empty_scope_reason.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/widgets/empty_scope_screen.dart';

/// P0-1 Tier 1: verifies each [EmptyScopeReason] renders its title and that
/// its CTA routes to the expected destination.
void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    required EmptyScopeException failure,
    required String entryType,
    String? entryRefId,
  }) async {
    final router = GoRouter(
      initialLocation: '/empty',
      routes: [
        GoRoute(
          path: '/empty',
          builder: (_, _) => EmptyScopeScreen(
            failure: failure,
            entryType: entryType,
            entryRefId: entryRefId,
          ),
        ),
        GoRoute(
          path: '/study/:${RoutePaths.studyEntryTypeParam}/'
              ':${RoutePaths.studyEntryRefIdParam}',
          name: RouteNames.studyEntry,
          builder: (_, state) => Text(
            'Entry '
            '${state.pathParameters[RoutePaths.studyEntryTypeParam]}/'
            '${state.pathParameters[RoutePaths.studyEntryRefIdParam]}',
          ),
        ),
        GoRoute(
          path: '/library/folder/:${RoutePaths.folderIdParam}',
          name: RouteNames.folderDetail,
          builder: (_, state) =>
              Text('Folder ${state.pathParameters[RoutePaths.folderIdParam]}'),
        ),
        GoRoute(
          path: '/library/deck/:${RoutePaths.deckIdParam}/flashcards',
          name: RouteNames.flashcardList,
          builder: (_, state) =>
              Text('List ${state.pathParameters[RoutePaths.deckIdParam]}'),
        ),
        GoRoute(
          path: '/deck/:${RoutePaths.deckIdParam}/flashcards/new',
          name: RouteNames.flashcardCreate,
          builder: (_, state) =>
              Text('Create ${state.pathParameters[RoutePaths.deckIdParam]}'),
        ),
        GoRoute(
          path: '/home',
          name: RouteNames.home,
          builder: (_, _) => const Text('Home'),
        ),
        GoRoute(
          path: '/library',
          name: RouteNames.library,
          builder: (_, _) => const Text('Library'),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('deckNoCards CTA pushes flashcardCreate', (tester) async {
    await pumpScreen(
      tester,
      failure: const EmptyScopeException(EmptyScopeReason.deckNoCards),
      entryType: 'deck',
      entryRefId: 'deck-1',
    );

    expect(find.text('No flashcards in this deck'), findsOneWidget);
    await tester.tap(find.text('Add flashcards'));
    await tester.pumpAndSettle();
    expect(find.text('Create deck-1'), findsOneWidget);
  });

  testWidgets('deckNoDueCards shows next-due hint and "Study new instead" CTA', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      failure: EmptyScopeException(
        EmptyScopeReason.deckNoDueCards,
        // Margin past the 3-day boundary so Duration.inDays does not truncate
        // to 2 between constructing nextDueAt and the widget reading now().
        nextDueAt: DateTime.now().add(const Duration(days: 3, hours: 6)),
      ),
      entryType: 'deck',
      entryRefId: 'deck-1',
    );

    expect(find.text('All caught up'), findsOneWidget);
    expect(find.textContaining('Next due in 3 days'), findsOneWidget);

    await tester.tap(find.text('Study new instead'));
    await tester.pumpAndSettle();
    expect(find.text('Entry deck/deck-1'), findsOneWidget);
  });

  testWidgets('deckNoDueCards omits subtitle when no future due exists', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      failure: const EmptyScopeException(EmptyScopeReason.deckNoDueCards),
      entryType: 'deck',
      entryRefId: 'deck-1',
    );

    expect(find.text('All caught up'), findsOneWidget);
    expect(find.textContaining('Next due'), findsNothing);
  });

  testWidgets('folderNoCards CTA returns to folder detail', (tester) async {
    await pumpScreen(
      tester,
      failure: const EmptyScopeException(EmptyScopeReason.folderNoCards),
      entryType: 'folder',
      entryRefId: 'folder-1',
    );

    expect(find.text('No cards in this folder'), findsOneWidget);
    await tester.tap(find.text('Add a deck'));
    await tester.pumpAndSettle();
    expect(find.text('Folder folder-1'), findsOneWidget);
  });

  testWidgets('folderNoDueCards CTA re-enters study as new', (tester) async {
    await pumpScreen(
      tester,
      failure: EmptyScopeException(
        EmptyScopeReason.folderNoDueCards,
        nextDueAt: DateTime.now().add(const Duration(days: 2)),
      ),
      entryType: 'folder',
      entryRefId: 'folder-1',
    );

    expect(find.text('All caught up for this folder'), findsOneWidget);
    await tester.tap(find.text('Study new instead'));
    await tester.pumpAndSettle();
    expect(find.text('Entry folder/folder-1'), findsOneWidget);
  });

  testWidgets('todayAllDone CTA returns to dashboard', (tester) async {
    await pumpScreen(
      tester,
      failure: const EmptyScopeException(EmptyScopeReason.todayAllDone),
      entryType: 'today',
    );

    expect(find.text('All done for today!'), findsOneWidget);
    await tester.tap(find.text('Back to dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('todayNoContent CTA opens the library', (tester) async {
    await pumpScreen(
      tester,
      failure: const EmptyScopeException(EmptyScopeReason.todayNoContent),
      entryType: 'today',
    );

    expect(find.text("You haven't created any flashcards yet"), findsOneWidget);
    await tester.tap(find.text('Create your first deck'));
    await tester.pumpAndSettle();
    expect(find.text('Library'), findsOneWidget);
  });

  testWidgets('allBuried CTA re-enters study as new', (tester) async {
    await pumpScreen(
      tester,
      failure: const EmptyScopeException(EmptyScopeReason.allBuried),
      entryType: 'deck',
      entryRefId: 'deck-1',
    );

    expect(find.text('All cards buried'), findsOneWidget);
    await tester.tap(find.text('Study new instead'));
    await tester.pumpAndSettle();
    expect(find.text('Entry deck/deck-1'), findsOneWidget);
  });

  testWidgets('allSuspended CTA opens the flashcard list', (tester) async {
    await pumpScreen(
      tester,
      failure: const EmptyScopeException(EmptyScopeReason.allSuspended),
      entryType: 'deck',
      entryRefId: 'deck-1',
    );

    expect(find.text('All cards suspended'), findsOneWidget);
    await tester.tap(find.text('View flashcards'));
    await tester.pumpAndSettle();
    expect(find.text('List deck-1'), findsOneWidget);
  });
}
