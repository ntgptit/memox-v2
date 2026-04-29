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
import 'package:memox/presentation/shared/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/mx_folder_tile.dart';

import 'package:memox/presentation/shared/dialogs/mx_dialog.dart';

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
    'DT1 onDisplay: renders greeting search toolbar and root folders',
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

      expect(find.text('Good morning, Lan'), findsOneWidget);
      expect(find.text('Folders'), findsOneWidget);
      expect(find.text('Korean1'), findsOneWidget);
      expect(find.text('17 cards · 3 due · 5 new'), findsOneWidget);
      expect(find.text('Mastery 19%'), findsOneWidget);
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

  testWidgets(
    'DT1 onNavigate: root folder cards expose recursive study action',
    (WidgetTester tester) async {
      const folderId = 'folder-root-001';
      final router = GoRouter(
        initialLocation: RoutePaths.library,
        routes: [
          GoRoute(
            path: RoutePaths.library,
            name: RouteNames.library,
            builder: (context, state) => const LibraryOverviewView(),
          ),
          GoRoute(
            path: '/${RoutePaths.folderDetailSegment}',
            name: RouteNames.folderDetail,
            builder: (context, state) =>
                const SizedBox(key: ValueKey('folder_detail_destination')),
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

      final studyButton = find.byKey(
        const ValueKey('library_folder_recursive_study_$folderId'),
      );

      expect(studyButton, findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.text('19%'), findsOneWidget);
      expect(find.text('17 cards · 3 due · 5 new'), findsOneWidget);
      expect(find.text('Mastery 19%'), findsOneWidget);
      expect(find.text('17'), findsOneWidget);

      await tester.tap(studyButton);
      await tester.pumpAndSettle();

      expect(
        router.routeInformationProvider.value.uri.path,
        '/study/folder/$folderId',
      );
    },
  );

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
      expect(find.text('Delete'), findsOneWidget);
    },
  );

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
                  onStartStudy: (_) {},
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
    'DT1 onDispose: dialog action using dialog context closes only the dialog',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
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
                );
              },
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
      deckCount: 0,
      itemCount: 17,
      dueCardCount: 3,
      newCardCount: 5,
      masteryPercent: 19,
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
