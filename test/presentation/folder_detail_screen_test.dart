import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/enums/content_sort_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
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
}

const _sampleFolderState = FolderDetailState(
  header: FolderDetailHeader(
    id: 'folder-001',
    name: 'Japanese N5',
    breadcrumb: <String>['Library', 'Japanese N5'],
  ),
  mode: FolderDetailMode.subfolders,
  sortMode: ContentSortMode.manual,
  searchTerm: '',
  subfolders: <FolderSubfolderItem>[
    FolderSubfolderItem(
      id: 'folder-002',
      name: 'Vocabulary',
      icon: Icons.folder_copy_outlined,
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
