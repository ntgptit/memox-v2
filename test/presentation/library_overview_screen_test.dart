import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/models/library_folder.dart';
import 'package:memox/presentation/features/folders/screens/library_overview_screen.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';

import 'package:memox/presentation/shared/dialogs/mx_dialog.dart';

void main() {
  testWidgets('library add FAB uses the generic add icon', (
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

  testWidgets('root folder cards expose recursive study action', (
    WidgetTester tester,
  ) async {
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
    expect(find.text('17'), findsOneWidget);
    expect(
      tester.getCenter(studyButton).dy,
      closeTo(tester.getCenter(find.text('Korean1')).dy, 16),
    );

    await tester.tap(studyButton);
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      '/study/folder/$folderId',
    );
  });

  testWidgets('dialog action using dialog context closes only the dialog', (
    WidgetTester tester,
  ) async {
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
  });
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
      masteryPercent: 19,
    ),
  ],
);
