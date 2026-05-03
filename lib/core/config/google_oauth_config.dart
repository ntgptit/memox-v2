import 'package:flutter/foundation.dart';

import '../utils/string_utils.dart';

@immutable
class GoogleOAuthConfig {
  const GoogleOAuthConfig({
    required this.webClientId,
    required this.iosClientId,
    required this.serverClientId,
  });

  static const String webClientIdKey = 'GOOGLE_WEB_CLIENT_ID';
  static const String iosClientIdKey = 'GOOGLE_IOS_CLIENT_ID';
  static const String serverClientIdKey = 'GOOGLE_SERVER_CLIENT_ID';
  static const GoogleOAuthConfig empty = GoogleOAuthConfig(
    webClientId: null,
    iosClientId: null,
    serverClientId: null,
  );

  final String? webClientId;
  final String? iosClientId;
  final String? serverClientId;

  bool get hasAnyClientId =>
      webClientId != null || iosClientId != null || serverClientId != null;

  bool get isConfiguredForCurrentPlatform {
    return isConfiguredFor(platform: defaultTargetPlatform, isWeb: kIsWeb);
  }

  bool isConfiguredFor({
    required TargetPlatform platform,
    required bool isWeb,
  }) {
    if (isWeb) {
      return webClientId != null;
    }

    return switch (platform) {
      TargetPlatform.android => serverClientId != null || webClientId != null,
      TargetPlatform.iOS || TargetPlatform.macOS => iosClientId != null,
      TargetPlatform.fuchsia ||
      TargetPlatform.linux ||
      TargetPlatform.windows => false,
    };
  }

  static GoogleOAuthConfig fromEnvironment() {
    return fromValues(
      webClientId: const String.fromEnvironment(webClientIdKey),
      iosClientId: const String.fromEnvironment(iosClientIdKey),
      serverClientId: const String.fromEnvironment(serverClientIdKey),
    );
  }

  static GoogleOAuthConfig fromValues({
    String? webClientId,
    String? iosClientId,
    String? serverClientId,
  }) {
    return GoogleOAuthConfig(
      webClientId: StringUtils.trimToNull(webClientId),
      iosClientId: StringUtils.trimToNull(iosClientId),
      serverClientId: StringUtils.trimToNull(serverClientId),
    );
  }
}
