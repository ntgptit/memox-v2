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
    expect(
      find.byKey(const ValueKey('mx_retained_async_refresh_bar')),
      findsNothing,
    );

    final refreshCompleter = Completer<FolderDetailState>();
    controller.future = refreshCompleter.future;
    await tester.pump();

    expect(find.byType(FloatingActionButton), findsOneWidget);
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
    ),
  ],
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
