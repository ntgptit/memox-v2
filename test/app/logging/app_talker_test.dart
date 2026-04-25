import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/config/app_config.dart';
import 'package:memox/app/config/env.dart';
import 'package:memox/app/logging/app_talker.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:talker_flutter/talker_flutter.dart';

final _sampleProvider = Provider<int>((ref) => 1);

void main() {
  test('DT1 onInsert: creates a Talker-backed Riverpod observer for local diagnostics', () {
    final config = _testConfig(
      env: AppEnv.local,
      enableRiverpodDiagnostics: true,
    );
    final talker = createAppTalker(config);
    final container = ProviderContainer(
      observers: createAppProviderObservers(talker: talker, config: config),
    );
    addTearDown(container.dispose);

    expect(container.read(_sampleProvider), 1);

    expect(
      talker.history.any((entry) => entry.key == TalkerKey.riverpodAdd),
      isTrue,
    );
  });

  test('DT1 logEvent: does not attach Riverpod diagnostics outside local-like envs', () {
    final config = _testConfig(
      env: AppEnv.production,
      enableRiverpodDiagnostics: false,
    );
    final talker = createAppTalker(config);

    expect(createAppProviderObservers(talker: talker, config: config), isEmpty);
  });
}

AppConfig _testConfig({
  required AppEnv env,
  required bool enableRiverpodDiagnostics,
}) {
  return AppConfig(
    env: env,
    initialLocation: RouteDefaults.initialLocation,
    showDebugBanner: false,
    enableRouterDiagnostics: false,
    enableTalkerConsoleLogs: false,
    enableTalkerRouteLogging: false,
    enableRiverpodDiagnostics: enableRiverpodDiagnostics,
    exposeInternalErrorDetails: false,
  );
}
