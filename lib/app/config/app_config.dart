import 'package:flutter/foundation.dart';

import '../router/route_names.dart';
import 'env.dart';

/// Resolved app-level runtime configuration.
///
/// Keep this object free of widget state. It should only describe the
/// immutable runtime contract chosen by [AppEnv].
@immutable
class AppConfig {
  const AppConfig({
    required this.env,
    required this.initialLocation,
    required this.showDebugBanner,
    required this.enableRouterDiagnostics,
    required this.enableTalkerConsoleLogs,
    required this.enableTalkerRouteLogging,
    required this.enableRiverpodDiagnostics,
    required this.exposeInternalErrorDetails,
  });

  final AppEnv env;
  final String initialLocation;
  final bool showDebugBanner;
  final bool enableRouterDiagnostics;
  final bool enableTalkerConsoleLogs;
  final bool enableTalkerRouteLogging;
  final bool enableRiverpodDiagnostics;
  final bool exposeInternalErrorDetails;

  factory AppConfig.fromEnv(AppEnv env) {
    final enableLocalDiagnostics = env.isLocalLike;
    return AppConfig(
      env: env,
      initialLocation: RouteDefaults.initialLocation,
      showDebugBanner: false,
      enableRouterDiagnostics: enableLocalDiagnostics,
      enableTalkerConsoleLogs: enableLocalDiagnostics,
      enableTalkerRouteLogging: enableLocalDiagnostics,
      enableRiverpodDiagnostics: enableLocalDiagnostics,
      exposeInternalErrorDetails: enableLocalDiagnostics,
    );
  }
}
