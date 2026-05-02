import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/content_providers.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/theme/tokens/app_icon_sizes.dart';
import 'package:memox/core/errors/result.dart';
import 'package:memox/domain/entities/flashcard_entity.dart';
import 'package:memox/domain/enums/content_sort_mode.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/usecases/flashcard_usecases.dart';
import 'package:memox/domain/value_objects/content_actions.dart';
import 'package:memox/domain/value_objects/content_queries.dart';
import 'package:memox/domain/value_objects/content_read_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/screens/flashcard_list_screen.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_detail_card_row.dart';
import 'package:memox/presentation/shared/layouts/mx_space.dart';
import 'package:memox/presentation/shared/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_secondary_button.dart';

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

    await _scrollToText(tester, 'Korean deck');
    expect(find.text('Korean deck'), findsWidgets);
    await _scrollToText(tester, 'Study modes');
    expect(find.text('Study modes'), findsOneWidget);
    await _scrollToText(tester, 'Your progress');
    expect(find.text('Your progress'), findsOneWidget);
    await _scrollToText(tester, 'Cards');
    expect(find.text('Cards'), findsOneWidget);
    await _scrollToRowText(tester, 'Front 1');
    expect(find.text('Front 1'), findsWidgets);
    expect(find.text('Back 1'), findsOneWidget);
    expect(find.text('Front 2'), findsWidgets);
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

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('flashcard_lazy_items')),
        400,
        scrollable: _verticalScrollable(),
      );
      await tester.pumpAndSettle();

      final initiallyBuiltRows = find
          .byType(FlashcardDetailCardRow)
          .evaluate()
          .length;

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

      await _scrollToText(tester, 'No flashcards yet');
      expect(find.text('No flashcards yet'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('Import'), findsOneWidget);

      final studyButtonFinder = find.widgetWithText(
        MxPrimaryButton,
        'Study this deck',
      );
      await tester.scrollUntilVisible(
        studyButtonFinder,
        300,
        scrollable: _verticalScrollable(),
      );
      expect(studyButtonFinder, findsOneWidget);
      expect(
        tester.widget<MxPrimaryButton>(studyButtonFinder).onPressed,
        isNull,
      );
    },
  );

  testWidgets(
    'DT4 onDisplay: compact layout renders study, progress, and toolbar sections',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

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

      await _scrollToText(tester, 'Study modes');
      expect(find.text('Study modes'), findsOneWidget);
      await _scrollToText(tester, 'Your progress');
      expect(find.text('Your progress'), findsOneWidget);
      await _scrollToText(tester, 'Cards');
      expect(find.text('Cards'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byIcon(Icons.file_upload_outlined),
        300,
        scrollable: _verticalScrollable(),
      );
      expect(find.byIcon(Icons.file_upload_outlined), findsOneWidget);
      expect(find.byTooltip('Reorder'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('DT5 onDisplay: flashcard card uses template top action row', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

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

    await _scrollToRowText(tester, 'Front 1');

    final row = _rowForText('Front 1');
    final speakerIcon = find.descendant(
      of: row,
      matching: find.byIcon(Icons.volume_up_outlined),
    );
    final starIcon = find.descendant(
      of: row,
      matching: find.byIcon(Icons.star_border_rounded),
    );
    final oldSelectIcon = find.descendant(
      of: row,
      matching: find.byIcon(Icons.radio_button_unchecked_rounded),
    );
    final frontText = find.descendant(of: row, matching: find.text('Front 1'));
    final backText = find.descendant(of: row, matching: find.text('Back 1'));
    final frontTop = tester.getTopLeft(frontText).dy;
    final speakerTop = tester.getTopLeft(speakerIcon).dy;
    final starTop = tester.getTopLeft(starIcon).dy;

    expect(speakerIcon, findsOneWidget);
    expect(starIcon, findsOneWidget);
    expect(oldSelectIcon, findsNothing);
    expect((speakerTop - frontTop).abs(), lessThanOrEqualTo(6));
    expect((starTop - frontTop).abs(), lessThanOrEqualTo(6));
    expect(speakerTop, lessThan(tester.getTopLeft(backText).dy));
    expect(
      tester.getTopLeft(starIcon).dx,
      greaterThanOrEqualTo(
        tester.getTopLeft(speakerIcon).dx + AppIconSizes.xl + MxSpace.xs,
      ),
    );
  });

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

    await tester.scrollUntilVisible(
      find.text('Study this deck'),
      300,
      scrollable: _verticalScrollable(),
    );
    await tester.tap(find.text('Study this deck'));
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
      expect(find.text('Duplicate'), findsOneWidget);
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

    await _scrollToRowText(tester, 'Front 1');
    await tester.longPress(_rowText('Front 1'));
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

    await _scrollToRowText(tester, 'Front 1');
    await tester.longPress(_rowText('Front 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);

    await tester.longPress(_rowText('Front 1'));
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsNothing);
    expect(find.text('Flashcard actions'), findsNothing);
  });

  testWidgets('DT2 onSelect: card star action enables bulk mode', (
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

    await _scrollToRowText(tester, 'Front 1');
    await tester.tap(_rowIcon('Front 1', Icons.star_border_rounded));
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);
    expect(_rowIcon('Front 1', Icons.star_rounded), findsOneWidget);
  });

  testWidgets('DT1 onMove: move destination picker states progress is kept', (
    WidgetTester tester,
  ) async {
    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        flashcardListQueryProvider(deckId).overrideWith(
          (ref) => Future<FlashcardListState>.value(_sampleFlashcardState),
        ),
        getFlashcardMoveTargetsUseCaseProvider.overrideWithValue(
          GetFlashcardMoveTargetsUseCase(
            const _MoveTargetsFlashcardRepository([
              DeckMoveTarget(
                id: 'deck-target-001',
                name: 'Target deck',
                breadcrumb: <String>['Korean', 'Target deck'],
              ),
            ]),
          ),
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

    await _scrollToRowText(tester, 'Front 1');
    await tester.longPress(_rowText('Front 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MxSecondaryButton, 'Move'));
    await tester.pumpAndSettle();

    expect(find.text('Move flashcards'), findsOneWidget);
    expect(
      find.text('Learning progress will be kept after moving.'),
      findsOneWidget,
    );
    expect(find.text('Target deck'), findsOneWidget);
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

      await _scrollToRowText(tester, 'Front 1');
      await tester.longPress(_rowText('Front 1'));
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
  folderId: 'folder-001',
  deckName: 'Korean deck',
  breadcrumb: <BreadcrumbSegmentReadModel>[
    BreadcrumbSegmentReadModel(label: 'Korean', folderId: 'folder-001'),
    BreadcrumbSegmentReadModel(label: 'Korean deck', folderId: null),
  ],
  sortMode: ContentSortMode.manual,
  searchTerm: '',
  progress: FlashcardDeckProgressState(
    newCount: 1,
    learningCount: 1,
    masteredCount: 0,
    masteryPercent: 7,
  ),
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
  folderId: 'folder-001',
  deckName: 'Korean deck',
  breadcrumb: <BreadcrumbSegmentReadModel>[
    BreadcrumbSegmentReadModel(label: 'Korean', folderId: 'folder-001'),
    BreadcrumbSegmentReadModel(label: 'Korean deck', folderId: null),
  ],
  sortMode: ContentSortMode.manual,
  searchTerm: '',
  progress: FlashcardDeckProgressState(
    newCount: 0,
    learningCount: 0,
    masteredCount: 0,
    masteryPercent: 0,
  ),
  items: <FlashcardListItemState>[],
);

FlashcardListState _largeFlashcardState() {
  return FlashcardListState(
    deckId: 'deck-001',
    folderId: 'folder-001',
    deckName: 'Korean deck',
    breadcrumb: const <BreadcrumbSegmentReadModel>[
      BreadcrumbSegmentReadModel(label: 'Korean', folderId: 'folder-001'),
      BreadcrumbSegmentReadModel(label: 'Korean deck', folderId: null),
    ],
    sortMode: ContentSortMode.manual,
    searchTerm: '',
    progress: const FlashcardDeckProgressState(
      newCount: 80,
      learningCount: 0,
      masteredCount: 0,
      masteryPercent: 0,
    ),
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

Finder _rowText(String text) {
  return find.descendant(
    of: find.byType(FlashcardDetailCardRow),
    matching: find.text(text),
  );
}

Finder _rowForText(String text) {
  return find
      .ancestor(
        of: _rowText(text),
        matching: find.byType(FlashcardDetailCardRow),
      )
      .first;
}

Finder _rowIcon(String rowText, IconData icon) {
  return find.descendant(of: _rowForText(rowText), matching: find.byIcon(icon));
}

Finder _verticalScrollable() {
  return find
      .byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      )
      .first;
}

Future<void> _scrollToText(WidgetTester tester, String text) async {
  await _scrollUntilAny(tester, find.text(text));
}

Future<void> _scrollToRowText(WidgetTester tester, String text) async {
  await _scrollUntilAny(tester, _rowText(text));
}

Future<void> _scrollUntilAny(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 24; attempt++) {
    if (finder.evaluate().isNotEmpty) {
      await tester.ensureVisible(finder.first);
      await tester.pumpAndSettle();
      return;
    }
    await tester.drag(_verticalScrollable(), const Offset(0, -300));
    await tester.pump();
  }
  await tester.pumpAndSettle();
  expect(finder, findsWidgets);
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

final class _MoveTargetsFlashcardRepository implements FlashcardRepository {
  const _MoveTargetsFlashcardRepository(this.targets);

  final List<DeckMoveTarget> targets;

  @override
  Future<List<DeckMoveTarget>> getFlashcardMoveTargets({
    required String deckId,
    required List<String> flashcardIds,
  }) async {
    return targets;
  }

  @override
  Future<FlashcardEntity> getFlashcard(String flashcardId) {
    throw UnimplementedError();
  }

  @override
  Future<FlashcardListReadModel> getFlashcards(
    String deckId,
    ContentQuery query,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Result<FlashcardEntity>> createFlashcard({
    required String deckId,
    required FlashcardDraft draft,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<FlashcardEntity>> updateFlashcard({
    required String flashcardId,
    required FlashcardDraft draft,
    FlashcardProgressEditPolicy progressPolicy =
        FlashcardProgressEditPolicy.keepProgress,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteFlashcards(List<String> flashcardIds) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> moveFlashcards({
    required List<String> flashcardIds,
    required String targetDeckId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> reorderFlashcards({
    required String deckId,
    required List<String> orderedFlashcardIds,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<FlashcardImportPreparation>> prepareImport({
    required String deckId,
    required ImportSourceFormat format,
    required String rawContent,
    FlashcardImportDuplicatePolicy duplicatePolicy =
        FlashcardImportDuplicatePolicy.skipExactDuplicates,
    ImportStructuredTextSeparator structuredTextSeparator =
        ImportStructuredTextSeparator.auto,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<int>> commitImport({
    required String deckId,
    required FlashcardImportPreparation preparation,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<ExportData>> exportFlashcards(List<String> flashcardIds) {
    throw UnimplementedError();
  }
}
