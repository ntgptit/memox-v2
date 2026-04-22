import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/router/route_guards.dart';
import 'package:memox/app/router/route_names.dart';

void main() {
  group('AppRouteGuards.redirectLocationFor', () {
    final guards = AppRouteGuards(
      initialLocation: RouteDefaults.initialLocation,
    );

    test('redirects the root path to the configured initial location', () {
      expect(
        guards.redirectLocationFor(Uri.parse('/')),
        RouteDefaults.initialLocation,
      );
    });

    test('does not redirect non-root paths', () {
      expect(
        guards.redirectLocationFor(Uri.parse(RoutePaths.library)),
        isNull,
      );
    });
  });
}
