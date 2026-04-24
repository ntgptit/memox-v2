import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../di/providers.dart';

part 'route_guards.g.dart';

/// App-wide redirect + guard seam for the router.
///
/// There is no auth or entitlement logic yet, but wiring this boundary now
/// keeps route policy out of `app_router.dart` once those concerns arrive.
final class AppRouteGuards {
  const AppRouteGuards({required this.initialLocation});

  final String initialLocation;

  String? rootRedirect(BuildContext context, GoRouterState state) =>
      redirectLocationFor(state.uri);

  String? redirectLocationFor(Uri uri) {
    if (uri.path == '/') {
      return initialLocation;
    }

    return null;
  }
}

@Riverpod(keepAlive: true)
AppRouteGuards appRouteGuards(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return AppRouteGuards(initialLocation: config.initialLocation);
}
