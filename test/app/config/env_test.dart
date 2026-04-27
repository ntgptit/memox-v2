import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/config/app_config.dart';
import 'package:memox/app/config/env.dart';
import 'package:memox/core/errors/app_exception.dart';

void main() {
  group('AppEnv.parse', () {
    test('DT1 loadConfig: returns a matching enum for supported values', () {
      expect(AppEnv.parse('local'), AppEnv.local);
      expect(AppEnv.parse('development'), AppEnv.development);
      expect(AppEnv.parse('staging'), AppEnv.staging);
      expect(AppEnv.parse('production'), AppEnv.production);
    });

    test(
      'DT2 loadConfig: throws a configuration exception for unsupported values',
      () {
        expect(
          () => AppEnv.parse('qa'),
          throwsA(isA<ConfigurationException>()),
        );
        expect(() => AppEnv.parse(''), throwsA(isA<ConfigurationException>()));
      },
    );

    test(
      'DT3 loadConfig: returns local for missing environment in non-release build',
      () {
        expect(
          AppEnv.resolve(
            hasEnvironment: false,
            rawValue: '',
            isReleaseMode: false,
          ),
          AppEnv.local,
        );
      },
    );

    test(
      'DT4 loadConfig: returns production for missing environment in release build',
      () {
        expect(
          AppEnv.resolve(
            hasEnvironment: false,
            rawValue: '',
            isReleaseMode: true,
          ),
          AppEnv.production,
        );
      },
    );

    test('DT5 loadConfig: disables diagnostics for production app config', () {
      final config = AppConfig.fromEnv(AppEnv.production);

      expect(config.enableRouterDiagnostics, isFalse);
      expect(config.enableTalkerConsoleLogs, isFalse);
      expect(config.enableTalkerRouteLogging, isFalse);
      expect(config.enableRiverpodDiagnostics, isFalse);
      expect(config.exposeInternalErrorDetails, isFalse);
    });
  });
}
