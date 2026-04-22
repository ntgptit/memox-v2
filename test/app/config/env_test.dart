import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/config/env.dart';
import 'package:memox/core/errors/app_exception.dart';

void main() {
  group('AppEnv.parse', () {
    test('returns a matching enum for supported values', () {
      expect(AppEnv.parse('local'), AppEnv.local);
      expect(AppEnv.parse('development'), AppEnv.development);
      expect(AppEnv.parse('staging'), AppEnv.staging);
      expect(AppEnv.parse('production'), AppEnv.production);
    });

    test('throws a configuration exception for unsupported values', () {
      expect(
        () => AppEnv.parse('qa'),
        throwsA(isA<ConfigurationException>()),
      );
    });
  });
}
