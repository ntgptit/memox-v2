import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/config/app_config.dart';
import 'package:memox/app/config/env.dart';
import 'package:memox/core/config/google_oauth_config.dart';

void main() {
  test('DT1 googleOAuthConfig: blank client IDs are not configured', () {
    final config = GoogleOAuthConfig.fromValues(
      webClientId: ' ',
      iosClientId: '',
      serverClientId: null,
    );

    expect(config.hasAnyClientId, isFalse);
    expect(
      config.isConfiguredFor(platform: TargetPlatform.android, isWeb: false),
      isFalse,
    );
    expect(
      config.isConfiguredFor(platform: TargetPlatform.iOS, isWeb: false),
      isFalse,
    );
    expect(
      config.isConfiguredFor(platform: TargetPlatform.android, isWeb: true),
      isFalse,
    );
  });

  test('DT2 googleOAuthConfig: web client ID configures web and Android', () {
    final config = GoogleOAuthConfig.fromValues(
      webClientId: 'web-client-id.apps.googleusercontent.com',
    );

    expect(config.hasAnyClientId, isTrue);
    expect(
      config.isConfiguredFor(platform: TargetPlatform.android, isWeb: true),
      isTrue,
    );
    expect(
      config.isConfiguredFor(platform: TargetPlatform.android, isWeb: false),
      isTrue,
    );
  });

  test('DT3 googleOAuthConfig: iOS client ID configures iOS only', () {
    final config = GoogleOAuthConfig.fromValues(
      iosClientId: 'ios-client-id.apps.googleusercontent.com',
    );

    expect(
      config.isConfiguredFor(platform: TargetPlatform.iOS, isWeb: false),
      isTrue,
    );
    expect(
      config.isConfiguredFor(platform: TargetPlatform.windows, isWeb: false),
      isFalse,
    );
  });

  test(
    'DT4 googleOAuthConfig: legacy app config falls back to empty config',
    () {
      const appConfig = AppConfig(
        env: AppEnv.local,
        initialLocation: '/library',
        showDebugBanner: false,
        enableRouterDiagnostics: false,
        enableTalkerConsoleLogs: false,
        enableTalkerRouteLogging: false,
        enableRiverpodDiagnostics: false,
        exposeInternalErrorDetails: true,
      );

      expect(appConfig.googleOAuthConfig, same(GoogleOAuthConfig.empty));
      expect(appConfig.googleOAuthConfig.hasAnyClientId, isFalse);
    },
  );
}
