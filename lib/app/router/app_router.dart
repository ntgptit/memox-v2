import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../core/errors/error_mapper.dart';
import '../../core/errors/failures.dart';
import '../../core/theme/responsive/app_layout.dart';
import '../../presentation/features/dashboard/screens/dashboard_screen.dart';
import '../../presentation/features/decks/screens/deck_detail_screen.dart';
import '../../presentation/features/flashcards/screens/deck_import_screen.dart';
import '../../presentation/features/flashcards/screens/flashcard_editor_screen.dart';
import '../../presentation/features/flashcards/screens/flashcard_list_screen.dart';
import '../../presentation/features/folders/screens/folder_detail_screen.dart';
import '../../presentation/features/folders/screens/library_overview_screen.dart';
import '../../presentation/features/settings/screens/settings_screen.dart';
import '../../presentation/features/study/screens/study_entry_screen.dart';
import '../../presentation/features/study/screens/study_result_screen.dart';
import '../../presentation/features/study/screens/study_session_screen.dart';
import '../../presentation/shared/layouts/mx_content_shell.dart';
import '../../presentation/shared/states/mx_empty_state.dart';
import '../../presentation/shared/states/mx_error_state.dart';
import '../app_shell.dart';
import '../di/providers.dart';
import 'route_guards.dart';
import 'route_names.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final guards = ref.watch(appRouteGuardsProvider);
  final talker = ref.watch(talkerProvider);

  return GoRouter(
    initialLocation: guards.initialLocation,
    debugLogDiagnostics: config.enableRouterDiagnostics,
    observers: config.enableTalkerRouteLogging
        ? [TalkerRouteObserver(talker)]
        : const <NavigatorObserver>[],
    routes: [
      GoRoute(path: '/', redirect: guards.rootRedirect),
      StatefulShellRoute.indexedStack(
        builder: (context, _, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.library,
                name: RouteNames.library,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: LibraryOverviewView()),
                routes: [
                  GoRoute(
                    path: RoutePaths.flashcardCreateSegment,
                    name: RouteNames.flashcardCreate,
                    pageBuilder: (_, state) => NoTransitionPage(
                      child: FlashcardEditorScreen(
                        deckId: state.pathParameters[RoutePaths.deckIdParam]!,
                        key: ValueKey(
                          'create-${state.pathParameters[RoutePaths.deckIdParam]}',
                        ),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: RoutePaths.flashcardEditSegment,
                    name: RouteNames.flashcardEdit,
                    pageBuilder: (_, state) => NoTransitionPage(
                      child: FlashcardEditorScreen(
                        deckId: state.pathParameters[RoutePaths.deckIdParam]!,
                        flashcardId:
                            state.pathParameters[RoutePaths.flashcardIdParam]!,
                        key: ValueKey(
                          'edit-${state.pathParameters[RoutePaths.flashcardIdParam]}',
                        ),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: RoutePaths.flashcardListSegment,
                    name: RouteNames.flashcardList,
                    pageBuilder: (_, state) => NoTransitionPage(
                      child: FlashcardListScreen(
                        deckId: state.pathParameters[RoutePaths.deckIdParam]!,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: RoutePaths.deckImportSegment,
                    name: RouteNames.deckImport,
                    pageBuilder: (_, state) => NoTransitionPage(
                      child: DeckImportScreen(
                        deckId: state.pathParameters[RoutePaths.deckIdParam]!,
                        key: ValueKey(
                          'import-${state.pathParameters[RoutePaths.deckIdParam]}',
                        ),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: RoutePaths.studyTodaySegment,
                    name: RouteNames.studyToday,
                    pageBuilder: (_, _) => const NoTransitionPage(
                      child: StudyEntryScreen(
                        entryType: 'today',
                        entryRefId: null,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: RoutePaths.studySessionSegment,
                    name: RouteNames.studySession,
                    pageBuilder: (_, state) => NoTransitionPage(
                      child: StudySessionScreen(
                        sessionId: state
                            .pathParameters[RoutePaths.studySessionIdParam]!,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: RoutePaths.studyResultSegment,
                    name: RouteNames.studyResult,
                    pageBuilder: (_, state) => NoTransitionPage(
                      child: StudyResultScreen(
                        sessionId: state
                            .pathParameters[RoutePaths.studySessionIdParam]!,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: RoutePaths.studyEntrySegment,
                    name: RouteNames.studyEntry,
                    pageBuilder: (_, state) => NoTransitionPage(
                      child: StudyEntryScreen(
                        entryType: state
                            .pathParameters[RoutePaths.studyEntryTypeParam]!,
                        entryRefId: state
                            .pathParameters[RoutePaths.studyEntryRefIdParam],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: RoutePaths.deckDetailSegment,
                    name: RouteNames.deckDetail,
                    pageBuilder: (_, state) => NoTransitionPage(
                      child: DeckDetailScreen(
                        deckId: state.pathParameters[RoutePaths.deckIdParam]!,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: RoutePaths.folderDetailSegment,
                    name: RouteNames.folderDetail,
                    pageBuilder: (_, state) => NoTransitionPage(
                      child: FolderDetailScreen(
                        folderId:
                            state.pathParameters[RoutePaths.folderIdParam]!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.progress,
                name: RouteNames.progress,
                pageBuilder: (context, state) {
                  final l10n = AppLocalizations.of(context);
                  return NoTransitionPage(
                    child: _ShellPlaceholderView(
                      title: l10n.progressTitle,
                      description: l10n.appShellProgressPlaceholderDescription,
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.settings,
                name: RouteNames.settings,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      final failure = ErrorMapper.map(state.error);
      return _RouterErrorView(
        failure: failure,
        showTechnicalDetails: config.exposeInternalErrorDetails,
      );
    },
  );
}

class _ShellPlaceholderView extends StatelessWidget {
  const _ShellPlaceholderView({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return MxContentShell(
      width: MxContentWidth.reading,
      applyVerticalPadding: true,
      child: MxEmptyState(
        icon: Icons.insights_outlined,
        title: title,
        message: description,
      ),
    );
  }
}

class _RouterErrorView extends StatelessWidget {
  const _RouterErrorView({
    required this.failure,
    required this.showTechnicalDetails,
  });

  final AppFailure failure;
  final bool showTechnicalDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final technicalDetail = failure.technicalDetails;
    final message = _localizedMessage(l10n);

    return Scaffold(
      body: MxErrorState(
        title: l10n.appRouterErrorTitle,
        message: message,
        details: showTechnicalDetails ? technicalDetail : null,
      ),
    );
  }

  String _localizedMessage(AppLocalizations l10n) {
    return switch (failure.code) {
      FailureCodes.invalidAppEnvironment => l10n.errorConfiguration,
      FailureCodes.requestTimedOut => l10n.errorRequestTimedOut,
      FailureCodes.invalidData => l10n.errorInvalidData,
      FailureCodes.unsupportedAction => l10n.errorUnsupportedAction,
      FailureCodes.unknown => l10n.errorUnexpected,
      _ => switch (failure.type) {
        FailureType.configuration => l10n.errorConfiguration,
        FailureType.validation => l10n.errorInvalidData,
        FailureType.network => l10n.errorNetwork,
        FailureType.storage => l10n.errorStorage,
        FailureType.notFound => l10n.errorNotFound,
        FailureType.unknown => l10n.errorUnexpected,
      },
    };
  }
}
