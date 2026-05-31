import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/models/library_folder.dart';
import 'package:memox/presentation/features/folders/screens/library_overview_screen.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/features/folders/widgets/library_folder_list.dart';
import 'package:memox/presentation/shared/dialogs/mx_dialog.dart';
import 'package:memox/presentation/shared/widgets/mx_folder_tile.dart';
import 'package:memox/presentation/shared/widgets/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

void main() {
  testWidgets('DT1 onOpen: shows loading state while library folders load', (
    WidgetTester tester,
  ) async {
    final completer = Completer<LibraryOverviewState>();
    addTearDown(() {
      if (!completer.isCompleted) {
        completer.complete(_sampleLibraryState);
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryOverviewQueryProvider.overrideWith((ref) => completer.future),
        ],
        child: const _TestApp(child: LibraryOverviewView()),
      ),
    );
    await tester.pump();

    expect(find.byType(MxLoadingState), findsOneWidget);
  });

  testWidgets(
    'DT1 onDisplay: renders greeting search toolbar and structural folder metadata',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            libraryOverviewQueryProvider.overrideWith(
              (ref) => Future<LibraryOverviewState>.value(_sampleLibraryState),
            ),
          ],
          child: const _TestApp(child: LibraryOverviewView()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Korean1'), findsOneWidget);
      expect(
        find.text('1 subfolder · 1 deck · 17 cards · 3 due'),
        findsOneWidget,
      );
      expect(find.text('17 cards · 3 due · 5 new'), findsNothing);
    },
  );

  testWidgets(
    'DT1 onResponsive: keeps library first viewport dense on Samsung 412x915',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(412, 915);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            libraryOverviewQueryProvider.overrideWith(
              (ref) => Future<LibraryOverviewState>.value(_sampleLibraryState),
            ),
          ],
          child: const _TestApp(child: LibraryOverviewView()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Manage your folder tree'), findsNothing);
      expect(find.text('Korean1'), findsOneWidget);
      expect(find.text('Due today: 3'), findsNothing);
    },
  );

  testWidgets(
    'DT2 onDisplay: falls back to zero subfolders for legacy folder count',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            libraryOverviewQueryProvider.overrideWith(
              (ref) => Future<LibraryOverviewState>.value(_legacyLibraryState),
            ),
          ],
          child: const _TestApp(child: LibraryOverviewView()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Korean1'), findsOneWidget);
      expect(
        find.text('0 subfolders · 1 deck · 17 cards · 3 due'),
        findsOneWidget,
      );
    },
  );

  testWidgets('DT1 onInsert: library add FAB uses the generic add icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) =>
                  buildLibraryOverviewFab(context, ref),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.create_new_folder_outlined), findsNothing);
  });

  testWidgets('DT1 onNavigate: root folder cards open folder detail on tap', (
    WidgetTester tester,
  ) async {
    String? openedFolderId;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryOverviewQueryProvider.overrideWith(
            (ref) => Future<LibraryOverviewState>.value(_sampleLibraryState),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                LibraryFolderSliver(
                  folders: _sampleLibraryState.folders,
                  onOpenFolder: (folderId) => openedFolderId = folderId,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MxTappable));
    await tester.pump();

    expect(openedFolderId, 'folder-root-001');
  });

  testWidgets(
    'DT1 onSelect: root folder long press opens direct folder actions',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: RoutePaths.library,
        routes: [
          GoRoute(
            path: RoutePaths.library,
            name: RouteNames.library,
            builder: (context, state) => const LibraryOverviewView(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            libraryOverviewQueryProvider.overrideWith(
              (ref) => Future<LibraryOverviewState>.value(_sampleLibraryState),
            ),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Korean1'));
      await tester.pumpAndSettle();

      expect(find.text('Folder actions'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Move'), findsOneWidget);
      expect(find.text('Import flashcards'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    },
  );

  testWidgets('DT2 onSelect: subfolder-mode root folder actions hide import', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryOverviewQueryProvider.overrideWith(
            (ref) =>
                Future<LibraryOverviewState>.value(_subfolderModeLibraryState),
          ),
        ],
        child: const _TestApp(child: LibraryOverviewView()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Korean1'));
    await tester.pumpAndSettle();

    expect(find.text('Folder actions'), findsOneWidget);
    expect(find.text('Import flashcards'), findsNothing);
  });

  testWidgets(
    'DT2 onNavigate: root folder tap still calls open-folder callback',
    (WidgetTester tester) async {
      String? openedFolderId;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                LibraryFolderSliver(
                  folders: _sampleLibraryState.folders,
                  onOpenFolder: (folderId) => openedFolderId = folderId,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MxFolderTile));
      await tester.pumpAndSettle();

      expect(openedFolderId, 'folder-root-001');
    },
  );

  testWidgets(
    'DT3 onDisplay: truly empty library shows the create-folder empty state',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            libraryOverviewQueryProvider.overrideWith(
              (ref) => Future<LibraryOverviewState>.value(_emptyLibraryState),
            ),
          ],
          child: const _TestApp(child: LibraryOverviewView()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No folders yet'), findsOneWidget);
      expect(find.text('Create folder'), findsWidgets);
      expect(find.text('No matching items'), findsNothing);
    },
  );

  testWidgets(
    'DT4 onSearch: empty search result shows no-results state distinct from empty library',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            libraryOverviewQueryProvider.overrideWith(
              (ref) => Future<LibraryOverviewState>.value(_emptyLibraryState),
            ),
          ],
          child: const _TestApp(child: LibraryOverviewView()),
        ),
      );
      await tester.pumpAndSettle();

      // Open inline search and type a term that matches no folder.
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'zzz-nope');
      await tester.pumpAndSettle();

      // No-results surface, NOT the misleading empty-library copy/CTA.
      expect(find.text('No matching items'), findsOneWidget);
      expect(find.text('No folders yet'), findsNothing);
    },
  );

  testWidgets(
    'DT5 onSearch: clearing the no-results search restores the library state',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            libraryOverviewQueryProvider.overrideWith(
              (ref) => Future<LibraryOverviewState>.value(_emptyLibraryState),
            ),
          ],
          child: const _TestApp(child: LibraryOverviewView()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'zzz-nope');
      await tester.pumpAndSettle();
      expect(find.text('No matching items'), findsOneWidget);

      // The no-results CTA clears the scope-local search term.
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.text('No matching items'), findsNothing);
      expect(find.text('No folders yet'), findsOneWidget);
    },
  );

  testWidgets(
    'DT1 onDispose: dialog action using dialog context closes only the dialog',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  MxDialog.show<void>(
                    context: context,
                    title: 'Create folder',
                    child: const Text('Dialog body'),
                    actions: [
                      Builder(
                        builder: (dialogContext) => TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  );
                },
                child: const Text('Open dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Dialog body'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Open dialog'), findsOneWidget);
    },
  );
}

const _sampleLibraryState = LibraryOverviewState(
  greeting: LibraryOverviewGreeting(
    salutation: 'Good morning',
    userName: 'Lan',
  ),
  dueToday: 0,
  folders: <LibraryFolder>[
    LibraryFolder(
      id: 'folder-root-001',
      name: 'Korean1',
      icon: Icons.folder_outlined,
      subfolderCount: 1,
      deckCount: 1,
      itemCount: 17,
      dueCardCount: 3,
      newCardCount: 5,
      masteryPercent: 19,
      canImportFlashcards: true,
    ),
  ],
);

const _emptyLibraryState = LibraryOverviewState(
  greeting: LibraryOverviewGreeting(
    salutation: 'Good morning',
    userName: 'Lan',
  ),
  dueToday: 0,
  folders: <LibraryFolder>[],
);

const _legacyLibraryState = LibraryOverviewState(
  greeting: LibraryOverviewGreeting(
    salutation: 'Good morning',
    userName: 'Lan',
  ),
  dueToday: 0,
  folders: <LibraryFolder>[
    LibraryFolder(
      id: 'folder-root-001',
      name: 'Korean1',
      icon: Icons.folder_outlined,
      subfolderCount: null,
      deckCount: 1,
      itemCount: 17,
      dueCardCount: 3,
      newCardCount: 5,
      masteryPercent: 19,
      canImportFlashcards: true,
    ),
  ],
);

const _subfolderModeLibraryState = LibraryOverviewState(
  greeting: LibraryOverviewGreeting(
    salutation: 'Good morning',
    userName: 'Lan',
  ),
  dueToday: 0,
  folders: <LibraryFolder>[
    LibraryFolder(
      id: 'folder-root-001',
      name: 'Korean1',
      icon: Icons.folder_outlined,
      subfolderCount: 1,
      deckCount: 0,
      itemCount: 0,
      dueCardCount: 0,
      newCardCount: 0,
      masteryPercent: 0,
      canImportFlashcards: false,
    ),
  ],
);

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}
