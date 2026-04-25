import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/domain/enums/content_sort_mode.dart';
import 'package:memox/domain/value_objects/content_read_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/presentation/features/folders/screens/folder_detail_screen.dart';
import 'package:memox/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart';
import 'package:memox/presentation/shared/states/mx_loading_state.dart';

void main() {
  testWidgets(
    'shows layout skeleton instead of full loading state on first load',
    (WidgetTester tester) async {
      const folderId = 'folder-001';
      final container = ProviderContainer(
        overrides: [
          folderDetailQueryProvider(
            folderId,
          ).overrideWith((ref) => Completer<FolderDetailState>().future),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TestApp(child: FolderDetailScreen(folderId: folderId)),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('folder_detail_skeleton')),
        findsOneWidget,
      );
      expect(find.byType(MxLoadingState), findsNothing);
    },
  );

  testWidgets('keeps floating action button during query refresh', (
    WidgetTester tester,
  ) async {
    const folderId = 'folder-001';
    final controller = _FutureController<FolderDetailState>(
      Future<FolderDetailState>.value(_sampleFolderState),
    );
    final currentFutureProvider =
        ChangeNotifierProvider<_FutureController<FolderDetailState>>(
          (ref) => controller,
        );
    final container = ProviderContainer(
      overrides: [
        folderDetailQueryProvider(
          folderId,
        ).overrideWith((ref) => ref.watch(currentFutureProvider).future),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FolderDetailScreen(folderId: folderId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(
      find.byKey(const ValueKey('mx_retained_async_refresh_bar')),
      findsNothing,
    );

    final refreshCompleter = Completer<FolderDetailState>();
    controller.future = refreshCompleter.future;
    await tester.pump();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(
      find.byKey(const ValueKey('mx_retained_async_refresh_bar')),
      findsOneWidget,
    );
  });

  testWidgets('tapping ancestor breadcrumb navigates to that folder detail', (
    WidgetTester tester,
  ) async {
    const childFolderId = 'folder-001';
    const parentFolderId = 'folder-000';

    final container = ProviderContainer(
      overrides: [
        folderDetailQueryProvider(childFolderId).overrideWith(
          (ref) => Future<FolderDetailState>.value(_sampleFolderState),
        ),
        folderDetailQueryProvider(parentFolderId).overrideWith(
          (ref) => Future<FolderDetailState>.value(_parentFolderState),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/folder/$childFolderId',
      routes: [
        GoRoute(
          path: '/folder/:${RoutePaths.folderIdParam}',
          name: RouteNames.folderDetail,
          builder: (context, state) => FolderDetailScreen(
            folderId: state.pathParameters[RoutePaths.folderIdParam]!,
          ),
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

    expect(find.text('Japanese N5'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Japanese').first);
    await tester.pumpAndSettle();

    expect(find.text('Japanese'), findsAtLeastNWidgets(1));
    expect(
      router.routeInformationProvider.value.uri.path,
      '/folder/$parentFolderId',
    );
  });

  testWidgets('renders subtree deck and card stats for subfolders', (
    WidgetTester tester,
  ) async {
    const folderId = 'folder-001';
    final container = ProviderContainer(
      overrides: [
        folderDetailQueryProvider(folderId).overrideWith(
          (ref) => Future<FolderDetailState>.value(_sampleFolderState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FolderDetailScreen(folderId: folderId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 decks · 2 cards'), findsOneWidget);
  });

  testWidgets('unlocked folder renders both create choices', (
    WidgetTester tester,
  ) async {
    const folderId = 'folder-001';
    final container = ProviderContainer(
      overrides: [
        folderDetailQueryProvider(folderId).overrideWith(
          (ref) => Future<FolderDetailState>.value(_unlockedFolderState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FolderDetailScreen(folderId: folderId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('This folder is empty'), findsOneWidget);
    expect(find.text('New subfolder'), findsOneWidget);
    expect(find.text('New deck'), findsOneWidget);
  });

  testWidgets('empty subfolder mode renders only subfolder CTA', (
    WidgetTester tester,
  ) async {
    const folderId = 'folder-001';
    final container = ProviderContainer(
      overrides: [
        folderDetailQueryProvider(folderId).overrideWith(
          (ref) => Future<FolderDetailState>.value(_emptySubfolderState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FolderDetailScreen(folderId: folderId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No subfolders yet'), findsOneWidget);
    expect(find.text('New subfolder'), findsOneWidget);
    expect(find.text('New deck'), findsNothing);
  });

  testWidgets('empty deck mode renders only deck CTA', (
    WidgetTester tester,
  ) async {
    const folderId = 'folder-001';
    final container = ProviderContainer(
      overrides: [
        folderDetailQueryProvider(folderId).overrideWith(
          (ref) => Future<FolderDetailState>.value(_emptyDeckFolderState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FolderDetailScreen(folderId: folderId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No decks yet'), findsOneWidget);
    expect(find.text('New deck'), findsOneWidget);
    expect(find.text('New subfolder'), findsNothing);
  });

  testWidgets('search with no results renders clear search action', (
    WidgetTester tester,
  ) async {
    const folderId = 'folder-001';
    final container = ProviderContainer(
      overrides: [
        folderDetailQueryProvider(folderId).overrideWith(
          (ref) => Future<FolderDetailState>.value(_searchNoResultState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FolderDetailScreen(folderId: folderId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No matching items'), findsOneWidget);
    expect(find.text('Clear search'), findsOneWidget);
    expect(find.text('New deck'), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('falls back to zero progress for legacy subfolder data', (
    WidgetTester tester,
  ) async {
    const folderId = 'folder-001';
    final container = ProviderContainer(
      overrides: [
        folderDetailQueryProvider(folderId).overrideWith(
          (ref) => Future<FolderDetailState>.value(_legacyFolderState),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: FolderDetailScreen(folderId: folderId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Legacy'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
  });

  testWidgets('opens recursive folder study from the subfolder card icon', (
    WidgetTester tester,
  ) async {
    const folderId = 'folder-001';
    const subfolderId = 'folder-002';
    final container = ProviderContainer(
      overrides: [
        folderDetailQueryProvider(folderId).overrideWith(
          (ref) => Future<FolderDetailState>.value(_sampleFolderState),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/folder/$folderId',
      routes: [
        GoRoute(
          path: '/${RoutePaths.folderDetailSegment}',
          name: RouteNames.folderDetail,
          builder: (context, state) => FolderDetailScreen(
            folderId: state.pathParameters[RoutePaths.folderIdParam]!,
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

    final studyButton = find.byKey(
      const ValueKey('folder_recursive_study_$subfolderId'),
    );

    expect(find.text('Study now'), findsNothing);
    expect(studyButton, findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.text('19%'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(
      tester.getCenter(studyButton).dy,
      closeTo(tester.getCenter(find.text('Vocabulary')).dy, 16),
    );

    await tester.tap(studyButton);
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      '/study/folder/$subfolderId',
    );
  });

  testWidgets('opens deck study from the deck card progress action', (
    WidgetTester tester,
  ) async {
    const folderId = 'folder-001';
    const deckId = 'deck-001';
    final container = ProviderContainer(
      overrides: [
        folderDetailQueryProvider(folderId).overrideWith(
          (ref) => Future<FolderDetailState>.value(_deckFolderState),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/folder/$folderId',
      routes: [
        GoRoute(
          path: '/${RoutePaths.folderDetailSegment}',
          name: RouteNames.folderDetail,
          builder: (context, state) => FolderDetailScreen(
            folderId: state.pathParameters[RoutePaths.folderIdParam]!,
          ),
        ),
        GoRoute(
          path: '/${RoutePaths.deckDetailSegment}',
          name: RouteNames.deckDetail,
          builder: (context, state) => const SizedBox.shrink(),
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

    final studyButton = find.byKey(const ValueKey('deck_study_$deckId'));

    expect(find.text('Vitamin B1'), findsOneWidget);
    expect(studyButton, findsOneWidget);
    expect(find.text('42%'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(studyButton);
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      '/study/deck/$deckId',
    );
  });
}

const _sampleFolderState = FolderDetailState(
  header: FolderDetailHeader(
    id: 'folder-001',
    name: 'Japanese N5',
    breadcrumb: <BreadcrumbSegmentReadModel>[
      BreadcrumbSegmentReadModel(label: 'Japanese', folderId: 'folder-000'),
      BreadcrumbSegmentReadModel(label: 'Japanese N5', folderId: 'folder-001'),
    ],
  ),
  mode: FolderDetailMode.subfolders,
  sortMode: ContentSortMode.manual,
  searchTerm: '',
  subfolders: <FolderSubfolderItem>[
    FolderSubfolderItem(
      id: 'folder-002',
      name: 'Vocabulary',
      icon: Icons.folder_copy_outlined,
      deckCount: 1,
      itemCount: 2,
      masteryPercent: 19,
    ),
  ],
  decks: <FolderDeckItem>[],
);

const _parentFolderState = FolderDetailState(
  header: FolderDetailHeader(
    id: 'folder-000',
    name: 'Japanese',
    breadcrumb: <BreadcrumbSegmentReadModel>[
      BreadcrumbSegmentReadModel(label: 'Japanese', folderId: 'folder-000'),
    ],
  ),
  mode: FolderDetailMode.subfolders,
  sortMode: ContentSortMode.manual,
  searchTerm: '',
  subfolders: <FolderSubfolderItem>[
    FolderSubfolderItem(
      id: 'folder-001',
      name: 'Japanese N5',
      icon: Icons.folder_copy_outlined,
      deckCount: 1,
      itemCount: 2,
      masteryPercent: 19,
    ),
  ],
  decks: <FolderDeckItem>[],
);

const _legacyFolderState = FolderDetailState(
  header: FolderDetailHeader(
    id: 'folder-001',
    name: 'Japanese N5',
    breadcrumb: <BreadcrumbSegmentReadModel>[
      BreadcrumbSegmentReadModel(label: 'Japanese N5', folderId: 'folder-001'),
    ],
  ),
  mode: FolderDetailMode.subfolders,
  sortMode: ContentSortMode.manual,
  searchTerm: '',
  subfolders: <FolderSubfolderItem>[
    FolderSubfolderItem(
      id: 'folder-legacy',
      name: 'Legacy',
      icon: Icons.folder_copy_outlined,
      deckCount: 0,
      itemCount: 1,
      masteryPercent: null,
    ),
  ],
  decks: <FolderDeckItem>[],
);

const _deckFolderState = FolderDetailState(
  header: FolderDetailHeader(
    id: 'folder-001',
    name: 'Topik I',
    breadcrumb: <BreadcrumbSegmentReadModel>[
      BreadcrumbSegmentReadModel(label: 'Korean', folderId: 'folder-000'),
      BreadcrumbSegmentReadModel(label: 'Topik I', folderId: 'folder-001'),
    ],
  ),
  mode: FolderDetailMode.decks,
  sortMode: ContentSortMode.manual,
  searchTerm: '',
  subfolders: <FolderSubfolderItem>[],
  decks: <FolderDeckItem>[
    FolderDeckItem(
      id: 'deck-001',
      name: 'Vitamin B1',
      cardCount: 1,
      dueToday: 0,
      masteryPercent: 42,
      lastStudiedAt: null,
    ),
  ],
);

const _unlockedFolderState = FolderDetailState(
  header: FolderDetailHeader(
    id: 'folder-001',
    name: 'New branch',
    breadcrumb: <BreadcrumbSegmentReadModel>[
      BreadcrumbSegmentReadModel(label: 'New branch', folderId: 'folder-001'),
    ],
  ),
  mode: FolderDetailMode.unlocked,
  sortMode: ContentSortMode.manual,
  searchTerm: '',
  subfolders: <FolderSubfolderItem>[],
  decks: <FolderDeckItem>[],
);

const _emptySubfolderState = FolderDetailState(
  header: FolderDetailHeader(
    id: 'folder-001',
    name: 'Japanese',
    breadcrumb: <BreadcrumbSegmentReadModel>[
      BreadcrumbSegmentReadModel(label: 'Japanese', folderId: 'folder-001'),
    ],
  ),
  mode: FolderDetailMode.subfolders,
  sortMode: ContentSortMode.manual,
  searchTerm: '',
  subfolders: <FolderSubfolderItem>[],
  decks: <FolderDeckItem>[],
);

const _emptyDeckFolderState = FolderDetailState(
  header: FolderDetailHeader(
    id: 'folder-001',
    name: 'Korean',
    breadcrumb: <BreadcrumbSegmentReadModel>[
      BreadcrumbSegmentReadModel(label: 'Korean', folderId: 'folder-001'),
    ],
  ),
  mode: FolderDetailMode.decks,
  sortMode: ContentSortMode.manual,
  searchTerm: '',
  subfolders: <FolderSubfolderItem>[],
  decks: <FolderDeckItem>[],
);

const _searchNoResultState = FolderDetailState(
  header: FolderDetailHeader(
    id: 'folder-001',
    name: 'Korean',
    breadcrumb: <BreadcrumbSegmentReadModel>[
      BreadcrumbSegmentReadModel(label: 'Korean', folderId: 'folder-001'),
    ],
  ),
  mode: FolderDetailMode.decks,
  sortMode: ContentSortMode.manual,
  searchTerm: 'biology',
  subfolders: <FolderSubfolderItem>[],
  decks: <FolderDeckItem>[],
);

class _FutureController<T> extends ChangeNotifier {
  _FutureController(this._future);

  Future<T> _future;

  Future<T> get future => _future;

  set future(Future<T> value) {
    _future = value;
    notifyListeners();
  }
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
