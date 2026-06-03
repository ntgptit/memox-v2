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
import 'package:memox/presentation/features/folders/widgets/library_skeleton.dart';
import 'package:memox/presentation/shared/dialogs/mx_dialog.dart';
import 'package:memox/presentation/shared/widgets/mx_deck_card.dart';
import 'package:memox/presentation/shared/widgets/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/mx_folder_tile.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

void main() {
  testWidgets('DT1 onOpen: shows skeleton folder rows while library loads', (
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

    expect(find.byType(LibrarySkeleton), findsOneWidget);
    // Skeleton is a calm placeholder: no folder rows are tappable while data
    // is absent.
    expect(find.byType(MxFolderTile), findsNothing);
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
    'DT3b onInsert: empty library create CTA opens existing folder-create flow',
    (WidgetTester tester) async {
      final createdNames = <String>[];
      final container = ProviderContainer(
        overrides: [
          libraryOverviewQueryProvider.overrideWith(
            (ref) => Future<LibraryOverviewState>.value(_emptyLibraryState),
          ),
          libraryOverviewActionControllerProvider.overrideWith(
            () => _FakeLibraryOverviewActionController(
              onCreateFolder: createdNames.add,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TestApp(child: LibraryOverviewView()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create folder').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Korean');
      await tester.pump();
      await tester.tap(find.text('Create').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(createdNames, <String>['Korean']);
      expect(find.text('Folder created.'), findsOneWidget);
      expect(find.textContaining('onboarding'), findsNothing);
    },
  );

  testWidgets(
    'DT4 onSearch: truly empty library keeps the empty state even with an active search term',
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

      // Type a term over a library that holds zero folders.
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'zzz-nope');
      await tester.pumpAndSettle();

      // totalFolderCount == 0 → still truly empty, NOT no-results.
      expect(find.text('No folders yet'), findsOneWidget);
      expect(find.text('Create folder'), findsWidgets);
      expect(
        find.byKey(const ValueKey('library_search_no_results')),
        findsNothing,
      );
      expect(find.text('No matching items'), findsNothing);
    },
  );

  testWidgets(
    'DT4b onSearch: populated library with a non-matching term shows no-results, not empty',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            libraryOverviewQueryProvider.overrideWith(
              (ref) => Future<LibraryOverviewState>.value(
                _searchNoResultLibraryState,
              ),
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

      // folders.isEmpty && searchTerm && totalFolderCount > 0 → no-results.
      expect(
        find.byKey(const ValueKey('library_search_no_results')),
        findsOneWidget,
      );
      expect(find.text('No matching items'), findsOneWidget);
      expect(find.text('No folders yet'), findsNothing);
    },
  );

  testWidgets(
    'DT5 onSearch: clearing the no-results search restores the populated folder rows',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Mirror the real query: filtered-empty while a term is active,
            // populated once the term is cleared.
            libraryOverviewQueryProvider.overrideWith((ref) {
              final query = ref.watch(libraryToolbarStateProvider);
              return Future<LibraryOverviewState>.value(
                query.hasSearchTerm
                    ? _searchNoResultLibraryState
                    : _sampleLibraryState,
              );
            }),
          ],
          child: const _TestApp(child: LibraryOverviewView()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Korean1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'zzz-nope');
      await tester.pumpAndSettle();
      expect(find.text('No matching items'), findsOneWidget);

      // The no-results CTA clears the scope-local search term.
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.text('No matching items'), findsNothing);
      expect(find.text('Korean1'), findsOneWidget);
    },
  );

  testWidgets(
    'DT6 onDisplay: loaded library shows folder rows and no root-level deck card',
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

      expect(find.byType(MxFolderTile), findsOneWidget);
      // Root-level decks are Rejected / Out of Scope: never rendered here.
      expect(find.byType(MxDeckCard), findsNothing);
    },
  );

  testWidgets(
    'DT7 onSelect: folder overflow kebab opens approved folder actions only',
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

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Approved current actions present.
      expect(find.text('Folder actions'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Move'), findsOneWidget);
      expect(find.text('Import flashcards'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Unsupported mock actions are absent.
      expect(find.text('Study due cards'), findsNothing);
      expect(find.text('Archive folder'), findsNothing);
    },
  );

  testWidgets('DT8 onError: shows safe library error copy with retry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryOverviewQueryProvider.overrideWith(
            (ref) =>
                Future<LibraryOverviewState>.error(StateError('db boom 0xFF')),
          ),
        ],
        child: const _TestApp(child: LibraryOverviewView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MxErrorState), findsOneWidget);
    expect(find.text("Couldn't load your library"), findsOneWidget);
    // Retry affordance present; raw exception text never surfaced.
    expect(find.text('Try again'), findsOneWidget);
    expect(find.textContaining('boom'), findsNothing);
    expect(find.textContaining('StateError'), findsNothing);
  });

  testWidgets('DT8b onError: retry re-runs the library query', (
    WidgetTester tester,
  ) async {
    var calls = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryOverviewQueryProvider.overrideWith((ref) {
            calls++;
            if (calls == 1) {
              return Future<LibraryOverviewState>.error(StateError('boom'));
            }
            return Future<LibraryOverviewState>.value(_sampleLibraryState);
          }),
        ],
        child: const _TestApp(child: LibraryOverviewView()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MxErrorState), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.byType(MxErrorState), findsNothing);
    expect(find.text('Korean1'), findsOneWidget);
  });

  testWidgets(
    'Negative scope: loaded library exposes no out-of-scope actions',
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

      // No root deck creation / global search / history / streak surfaces.
      expect(find.byType(MxDeckCard), findsNothing);
      expect(find.text('New deck'), findsNothing);
      expect(find.text('Create deck'), findsNothing);
      expect(find.text('Flashcard history'), findsNothing);
      expect(find.textContaining('streak'), findsNothing);
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
  totalFolderCount: 0,
  folders: <LibraryFolder>[],
);

// Library that holds folders, but the active scope-local search filtered them
// all out: no visible rows yet `totalFolderCount > 0`.
const _searchNoResultLibraryState = LibraryOverviewState(
  greeting: LibraryOverviewGreeting(
    salutation: 'Good morning',
    userName: 'Lan',
  ),
  dueToday: 0,
  totalFolderCount: 3,
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

class _FakeLibraryOverviewActionController
    extends LibraryOverviewActionController {
  _FakeLibraryOverviewActionController({required this.onCreateFolder});

  final void Function(String name) onCreateFolder;

  @override
  FutureOr<void> build() {}

  @override
  Future<bool> createFolder(String name) async {
    onCreateFolder(name);
    state = const AsyncData<void>(null);
    return true;
  }
}
