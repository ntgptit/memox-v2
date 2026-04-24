import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../core/errors/error_mapper.dart';
import '../../core/errors/failures.dart';
import '../../presentation/features/decks/screens/deck_detail_screen.dart';
import '../../presentation/features/flashcards/screens/deck_import_screen.dart';
import '../../presentation/features/flashcards/screens/flashcard_editor_screen.dart';
import '../../presentation/features/flashcards/screens/flashcard_list_screen.dart';
import '../../presentation/features/folders/screens/folder_detail_screen.dart';
import '../../presentation/features/folders/screens/library_overview_screen.dart';
import '../../presentation/features/study/screens/study_entry_screen.dart';
import '../../presentation/features/study/screens/study_result_screen.dart';
import '../../presentation/features/study/screens/study_session_screen.dart';
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
                pageBuilder: (context, state) {
                  final l10n = AppLocalizations.of(context);
                  return NoTransitionPage(
                    child: _ShellPlaceholderView(
                      title: l10n.homeTitle,
                      description: l10n.appShellHomePlaceholderDescription,
                    ),
                  );
                },
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
                pageBuilder: (context, state) {
                  final l10n = AppLocalizations.of(context);
                  return NoTransitionPage(
                    child: _ShellPlaceholderView(
                      title: l10n.settingsTitle,
                      description: l10n.appShellSettingsPlaceholderDescription,
                    ),
                  );
                },
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
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: textTheme.headlineSmall?.copyWith(
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final technicalDetail = failure.technicalDetails;
    final message = _localizedMessage(l10n);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 40, color: scheme.error),
                const SizedBox(height: 16),
                Text(
                  l10n.appRouterErrorTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (showTechnicalDetails && technicalDetail != null) ...[
                  const SizedBox(height: 16),
                  SelectableText(
                    technicalDetail,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
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
