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
import 'package:memox/presentation/shared/widgets/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_term_row.dart';

void main() {
  testWidgets(
    'DT1 onOpen: shows layout skeleton instead of full loading state on first load',
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

  testWidgets('DT1 onDisplay: renders flashcard rows for loaded deck data', (
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

    expect(find.text('Korean deck'), findsWidgets);
    expect(find.text('Front 1'), findsOneWidget);
    expect(find.text('Back 1'), findsOneWidget);
    expect(find.text('Front 2'), findsOneWidget);
  });

  testWidgets(
    'DT3 onDisplay: lazily builds long flashcard lists as they scroll',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      const deckId = 'deck-001';
      final state = _largeFlashcardState();
      final container = ProviderContainer(
        overrides: [
          flashcardListQueryProvider(
            deckId,
          ).overrideWith((ref) => Future<FlashcardListState>.value(state)),
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

      final initiallyBuiltRows = find.byType(MxTermRow).evaluate().length;

      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(
        find.byKey(const ValueKey('flashcard_lazy_items')),
        findsOneWidget,
      );
      expect(initiallyBuiltRows, lessThan(state.items.length));
      expect(find.text('Front 79'), findsNothing);

      for (var index = 0; index < 20; index++) {
        if (find.text('Front 79').evaluate().isNotEmpty) {
          break;
        }
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(find.text('Front 79'), findsOneWidget);
      expect(find.text('Back 79'), findsOneWidget);
    },
  );

  testWidgets(
    'DT2 onDisplay: empty deck disables study and keeps creation entry points',
    (WidgetTester tester) async {
      const deckId = 'deck-001';
      final container = ProviderContainer(
        overrides: [
          flashcardListQueryProvider(deckId).overrideWith(
            (ref) => Future<FlashcardListState>.value(_emptyFlashcardState),
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

      final studyButtonFinder = find.widgetWithText(
        MxPrimaryButton,
        'Study now',
      );

      expect(find.text('No flashcards yet'), findsOneWidget);
      expect(find.text('Add flashcard'), findsOneWidget);
      expect(find.text('Import'), findsOneWidget);
      expect(studyButtonFinder, findsOneWidget);
      expect(
        tester.widget<MxPrimaryButton>(studyButtonFinder).onPressed,
        isNull,
      );
    },
  );

  testWidgets('DT1 onNavigate: starts deck study from flashcard management', (
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
          path: '/${RoutePaths.studyEntrySegment}',
          name: RouteNames.studyEntry,
          builder: (context, state) => const SizedBox.shrink(),
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

    await tester.tap(find.text('Study now'));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      '/study/deck/$deckId',
    );
  });

  testWidgets(
    'DT2 onNavigate: header more opens deck actions from flashcard management',
    (WidgetTester tester) async {
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

      await tester.tap(find.byTooltip('More actions'));
      await tester.pumpAndSettle();

      expect(find.text('Deck actions'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Move'), findsOneWidget);
      expect(find.text('Duplicate deck'), findsOneWidget);
      expect(find.text('Export CSV'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    },
  );

  testWidgets('DT1 onDelete: long pressing a flashcard opens row actions', (
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

  testWidgets('DT1 onSelect: flashcard select action enables bulk mode', (
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

  testWidgets(
    'DT1 onUpdate: flashcard edit action keeps direct editor navigation',
    (WidgetTester tester) async {
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
    },
  );
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

const _emptyFlashcardState = FlashcardListState(
  deckId: 'deck-001',
  deckName: 'Korean deck',
  breadcrumb: <BreadcrumbSegmentReadModel>[
    BreadcrumbSegmentReadModel(label: 'Korean', folderId: 'folder-001'),
    BreadcrumbSegmentReadModel(label: 'Korean deck', folderId: null),
  ],
  sortMode: ContentSortMode.manual,
  searchTerm: '',
  items: <FlashcardListItemState>[],
);

FlashcardListState _largeFlashcardState() {
  return FlashcardListState(
    deckId: 'deck-001',
    deckName: 'Korean deck',
    breadcrumb: const <BreadcrumbSegmentReadModel>[
      BreadcrumbSegmentReadModel(label: 'Korean', folderId: 'folder-001'),
      BreadcrumbSegmentReadModel(label: 'Korean deck', folderId: null),
    ],
    sortMode: ContentSortMode.manual,
    searchTerm: '',
    items: List<FlashcardListItemState>.generate(
      80,
      (index) => FlashcardListItemState(
        id: 'card-$index',
        front: 'Front $index',
        back: 'Back $index',
        note: null,
        lastStudiedAt: null,
      ),
    ),
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
