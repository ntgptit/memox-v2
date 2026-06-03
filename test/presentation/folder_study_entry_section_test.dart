import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/domain/enums/content_sort_mode.dart';
import 'package:memox/domain/study/usecases/folder_study_entry_usecase.dart';
import 'package:memox/domain/value_objects/content_read_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/screens/folder_detail_screen.dart';
import 'package:memox/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart';
import 'package:memox/presentation/features/folders/viewmodels/folder_study_entry_provider.dart';

void main() {
  testWidgets('P45 onDisplay: empty study scope renders no study banners', (
    tester,
  ) async {
    await _pumpFolderDetail(tester, studyEntry: const FolderStudyEntry.empty());

    expect(find.byKey(const ValueKey('folder_study_card')), findsNothing);
    expect(find.byKey(const ValueKey('folder_resume_banner')), findsNothing);
  });

  testWidgets(
    'P45 onDisplay: folder with cards but none due shows Study folder only',
    (tester) async {
      await _pumpFolderDetail(
        tester,
        studyEntry: const FolderStudyEntry(
          totalCardCount: 30,
          dueCount: 0,
          resumeSessionId: null,
        ),
      );

      expect(find.byKey(const ValueKey('folder_study_card')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('folder_study_folder_action')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('folder_study_today_action')),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('folder_resume_banner')), findsNothing);
    },
  );

  testWidgets(
    'P45 onDisplay: folder with due cards shows Today CTA with due count',
    (tester) async {
      await _pumpFolderDetail(
        tester,
        studyEntry: const FolderStudyEntry(
          totalCardCount: 30,
          dueCount: 4,
          resumeSessionId: null,
        ),
      );

      expect(
        find.byKey(const ValueKey('folder_study_today_action')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('folder_study_folder_action')),
        findsOneWidget,
      );
      expect(find.text('4 cards due today'), findsOneWidget);
    },
  );

  testWidgets('P45 onDisplay: paused folder session shows resume banner', (
    tester,
  ) async {
    await _pumpFolderDetail(
      tester,
      studyEntry: const FolderStudyEntry(
        totalCardCount: 0,
        dueCount: 0,
        resumeSessionId: 'session-009',
      ),
    );

    expect(find.byKey(const ValueKey('folder_resume_banner')), findsOneWidget);
    expect(find.byKey(const ValueKey('folder_resume_action')), findsOneWidget);
    expect(find.byKey(const ValueKey('folder_study_card')), findsNothing);
  });

  testWidgets(
    'P45 onNavigate: tapping Study folder enters folder-scoped study entry gate',
    (tester) async {
      await _pumpStudyRouter(
        tester,
        studyEntry: const FolderStudyEntry(
          totalCardCount: 30,
          dueCount: 0,
          resumeSessionId: null,
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey('folder_study_folder_action')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gate folder folder-001 default'), findsOneWidget);
    },
  );

  testWidgets(
    'P45 onNavigate: tapping Today enters folder-scoped review study entry gate',
    (tester) async {
      await _pumpStudyRouter(
        tester,
        studyEntry: const FolderStudyEntry(
          totalCardCount: 30,
          dueCount: 4,
          resumeSessionId: null,
        ),
      );

      await tester.tap(find.byKey(const ValueKey('folder_study_today_action')));
      await tester.pumpAndSettle();

      expect(find.text('Gate folder folder-001 srs_review'), findsOneWidget);
    },
  );

  testWidgets(
    'P45 onNavigate: tapping Resume opens the existing session, not the gate',
    (tester) async {
      await _pumpStudyRouter(
        tester,
        studyEntry: const FolderStudyEntry(
          totalCardCount: 0,
          dueCount: 0,
          resumeSessionId: 'session-009',
        ),
      );

      await tester.tap(find.byKey(const ValueKey('folder_resume_action')));
      await tester.pumpAndSettle();

      expect(find.text('Session session-009'), findsOneWidget);
    },
  );
}

Future<void> _pumpFolderDetail(
  WidgetTester tester, {
  required FolderStudyEntry studyEntry,
}) async {
  const folderId = 'folder-001';
  final container = ProviderContainer(
    overrides: [
      folderStudyEntryProvider.overrideWith((ref, _) => studyEntry),
      folderDetailQueryProvider(
        folderId,
      ).overrideWith((ref) => Future<FolderDetailState>.value(_deckFolderState)),
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
}

Future<void> _pumpStudyRouter(
  WidgetTester tester, {
  required FolderStudyEntry studyEntry,
}) async {
  const folderId = 'folder-001';
  final container = ProviderContainer(
    overrides: [
      folderStudyEntryProvider.overrideWith((ref, _) => studyEntry),
      folderDetailQueryProvider(
        folderId,
      ).overrideWith((ref) => Future<FolderDetailState>.value(_deckFolderState)),
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: '/folder/$folderId',
    routes: [
      GoRoute(
        path: '/folder/:${RoutePaths.folderIdParam}',
        name: RouteNames.folderDetail,
        builder: (context, state) => FolderDetailScreen(
          folderId: state.pathParameters[RoutePaths.folderIdParam]!,
        ),
      ),
      GoRoute(
        path:
            '/study/:${RoutePaths.studyEntryTypeParam}/:${RoutePaths.studyEntryRefIdParam}',
        name: RouteNames.studyEntry,
        builder: (context, state) => Text(
          'Gate '
          '${state.pathParameters[RoutePaths.studyEntryTypeParam]} '
          '${state.pathParameters[RoutePaths.studyEntryRefIdParam]} '
          '${state.uri.queryParameters[RoutePaths.studyTypeQueryParam] ?? 'default'}',
        ),
      ),
      GoRoute(
        path: '/session/:${RoutePaths.studySessionIdParam}',
        name: RouteNames.studySession,
        builder: (context, state) => Text(
          'Session ${state.pathParameters[RoutePaths.studySessionIdParam]}',
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
}

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
      dueToday: 1,
      masteryPercent: 42,
      lastStudiedAt: null,
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
