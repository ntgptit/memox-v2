import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../core/errors/error_mapper.dart';
import '../../core/errors/failures.dart';
import '../../presentation/features/dashboard/routes/dashboard_routes.dart';
import '../../presentation/features/flashcards/routes/flashcard_routes.dart';
import '../../presentation/features/folders/routes/folder_routes.dart';
import '../../presentation/features/progress/routes/progress_routes.dart';
import '../../presentation/features/settings/routes/settings_routes.dart';
import '../../presentation/features/study/routes/study_routes.dart';
import '../../presentation/shared/widgets/mx_error_state.dart';
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
        builder: (context, state, navigationShell) => AppShell(
            navigationShell: navigationShell,
            hideNavigation: _shouldHideShellNavigation(state),
          ),
        branches: [
          StatefulShellBranch(routes: dashboardBranchRoutes()),
          StatefulShellBranch(
            routes: libraryBranchRoutes(
              childRoutes: [
                ...flashcardLibraryRoutes(),
                ...studyLibraryRoutes(),
              ],
            ),
          ),
          StatefulShellBranch(routes: progressBranchRoutes()),
          StatefulShellBranch(routes: settingsBranchRoutes()),
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

bool _shouldHideShellNavigation(GoRouterState state) {
  const hiddenRoutes = {
    RouteNames.deckImport,
    RouteNames.flashcardCreate,
    RouteNames.flashcardEdit,
    RouteNames.settingsAccount,
    RouteNames.settingsLearning,
    RouteNames.settingsAudioSpeech,
    RouteNames.studySession,
  };
  return hiddenRoutes.contains(state.topRoute?.name) ||
      hiddenRoutes.contains(state.name);
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

  String _localizedMessage(AppLocalizations l10n) => switch (failure.code) {
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
