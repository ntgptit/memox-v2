import 'package:flutter/foundation.dart';

import '../../core/config/google_oauth_config.dart';
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
    GoogleOAuthConfig? googleOAuthConfig,
  }) : _googleOAuthConfig = googleOAuthConfig;

  final AppEnv env;
  final String initialLocation;
  final bool showDebugBanner;
  final bool enableRouterDiagnostics;
  final bool enableTalkerConsoleLogs;
  final bool enableTalkerRouteLogging;
  final bool enableRiverpodDiagnostics;
  final bool exposeInternalErrorDetails;
  final GoogleOAuthConfig? _googleOAuthConfig;

  GoogleOAuthConfig get googleOAuthConfig {
    return _googleOAuthConfig ?? GoogleOAuthConfig.empty;
  }

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
      googleOAuthConfig: GoogleOAuthConfig.fromEnvironment(),
    );
  }
}
