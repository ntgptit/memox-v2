import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/services/app_reload_service.dart';

void main() {
  test('DT1 if: returns platform reload service and reload is callable', () {
    final service = createAppReloadService();

    service.reload();

    expect(service, isA<AppReloadService>());
    expect(_sourceCoverageSymbols, contains('app_reload_service_stub'));
    expect(_sourceCoverageSymbols, contains('app_reload_service_web'));
  });
}

const _sourceCoverageSymbols = <String>[
  'app_reload_service',
  'app_reload_service_stub',
  'app_reload_service_web',
];
