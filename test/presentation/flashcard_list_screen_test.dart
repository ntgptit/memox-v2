import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/domain/enums/content_sort_mode.dart';
import 'package:memox/domain/value_objects/content_read_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/screens/flashcard_list_screen.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/shared/states/mx_loading_state.dart';

void main() {
  testWidgets(
    'shows layout skeleton instead of full loading state on first load',
    (WidgetTester tester) async {
      const deckId = 'deck-001';
      final container = ProviderContainer(
        overrides: [
          flashcardListQueryProvider(
            deckId,
          ).overrideWith((ref) => Completer<FlashcardListState>().future),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('flashcard_list_skeleton')),
        findsOneWidget,
      );
      expect(find.byType(MxLoadingState), findsNothing);
    },
  );

  testWidgets('long pressing a flashcard opens row actions', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        flashcardListQueryProvider(deckId).overrideWith(
          (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Front 1'));
    await tester.pumpAndSettle();

    expect(find.text('Flashcard actions'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Move'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Select'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('flashcard select action enables bulk mode', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        flashcardListQueryProvider(deckId).overrideWith(
          (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FlashcardListScreen(deckId: deckId)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Front 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);

    await tester.longPress(find.text('Front 1'));
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsNothing);
    expect(find.text('Flashcard actions'), findsNothing);
  });

  testWidgets('flashcard edit action keeps direct editor navigation', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        flashcardListQueryProvider(deckId).overrideWith(
          (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/deck/$deckId/flashcards',
      routes: [
        GoRoute(
          path: '/${RoutePaths.flashcardListSegment}',
          name: RouteNames.flashcardList,
          builder: (context, state) => FlashcardListScreen(
            deckId: state.pathParameters[RoutePaths.deckIdParam]!,
          ),
        ),
        GoRoute(
          path: '/${RoutePaths.flashcardEditSegment}',
          name: RouteNames.flashcardEdit,
          builder: (context, state) =>
              const SizedBox(key: ValueKey('flashcard_edit_destination')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Front 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('flashcard_edit_destination')),
      findsOneWidget,
    );
  });
}

const _sampleFlashcardState = FlashcardListState(
  deckId: 'deck-001',
  deckName: 'Korean deck',
  breadcrumb: <BreadcrumbSegmentReadModel>[
    BreadcrumbSegmentReadModel(label: 'Korean', folderId: 'folder-001'),
    BreadcrumbSegmentReadModel(label: 'Korean deck', folderId: null),
  ],
  sortMode: ContentSortMode.manual,
  searchTerm: '',
  items: <FlashcardListItemState>[
    FlashcardListItemState(
      id: 'card-001',
      front: 'Front 1',
      back: 'Back 1',
      note: null,
      lastStudiedAt: null,
    ),
    FlashcardListItemState(
      id: 'card-002',
      front: 'Front 2',
      back: 'Back 2',
      note: null,
      lastStudiedAt: null,
    ),
  ],
);

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
