import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/config/app_config.dart';
import 'package:memox/app/config/env.dart';
import 'package:memox/core/config/google_oauth_config.dart';

void main() {
  test('DT1 googleOAuthConfig: blank client IDs keep Android delegated', () {
    final config = GoogleOAuthConfig.fromValues(
      webClientId: ' ',
      iosClientId: '',
      serverClientId: null,
    );

    expect(config.hasAnyClientId, isFalse);
    expect(
      config.isConfiguredFor(platform: TargetPlatform.android, isWeb: false),
      isTrue,
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

  test('DT2 googleOAuthConfig: web client ID configures web only', () {
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
    expect(
      config.isConfiguredFor(platform: TargetPlatform.iOS, isWeb: false),
      isFalse,
    );
    expect(
      config.isConfiguredFor(platform: TargetPlatform.windows, isWeb: false),
      isFalse,
    );
  });

  test('DT3 googleOAuthConfig: iOS client ID configures Apple platforms', () {
    final config = GoogleOAuthConfig.fromValues(
      iosClientId: 'ios-client-id.apps.googleusercontent.com',
    );

    expect(
      config.isConfiguredFor(platform: TargetPlatform.iOS, isWeb: false),
      isTrue,
    );
    expect(
      config.isConfiguredFor(platform: TargetPlatform.macOS, isWeb: false),
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

  test(
    'DT5 googleOAuthConfig: server client ID does not configure platform clients',
    () {
      final config = GoogleOAuthConfig.fromValues(
        serverClientId: 'server-client-id.apps.googleusercontent.com',
      );

      expect(config.hasAnyClientId, isTrue);
      expect(
        config.isConfiguredFor(platform: TargetPlatform.android, isWeb: true),
        isFalse,
      );
      expect(
        config.isConfiguredFor(platform: TargetPlatform.android, isWeb: false),
        isTrue,
      );
      expect(
        config.isConfiguredFor(platform: TargetPlatform.iOS, isWeb: false),
        isFalse,
      );
      expect(
        config.isConfiguredFor(platform: TargetPlatform.windows, isWeb: false),
        isFalse,
      );
    },
  );

  test(
    'DT1 webIndexOAuthMetadata: host page declares Google Sign-In web client ID',
    () {
      final indexHtml = File('web/index.html').readAsStringSync();

      expect(
        indexHtml,
        contains(
          '<meta name="google-signin-client_id" '
          'content="267301494133-v4g72254jo0nnfgn8s3uut7hdreae0kc.apps.googleusercontent.com">',
        ),
      );
    },
  );
}
