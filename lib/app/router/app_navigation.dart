import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

/// Shared BuildContext navigation extension for the MemoX app.
///
/// Every UI call site — widgets, shell, dialogs — must navigate through
/// this extension instead of reaching for raw `context.go(...)` or
/// `GoRouter.of(context)`. That keeps the list of reachable routes
/// discoverable, enforces route-name usage over path literals, and gives
/// us a single seam for adding telemetry or guards later.
///
/// Methods are thin wrappers over `goNamed` / `pushNamed` so route tables
/// stay the source of truth for path shape and parameter names.
extension AppNavigation on BuildContext {
  // --- Top-level destinations ------------------------------------------------

  void goHome() => goNamed(RouteNames.home);
  void goLibrary() => goNamed(RouteNames.library);
  void goProgress() => goNamed(RouteNames.progress);
  void goSettings() => goNamed(RouteNames.settings);

  // --- Library sub-tree ------------------------------------------------------

  /// Navigate to the folder-detail screen for [folderId].
  ///
  /// Uses `push` so the library stack preserves the overview underneath —
  /// the folder-detail back button expects to pop to the library list.
  void pushFolderDetail(String folderId) {
    pushNamed(
      RouteNames.folderDetail,
      pathParameters: {RoutePaths.folderIdParam: folderId},
    );
  }

  // --- Back navigation -------------------------------------------------------

  /// Pops the current route if the stack allows it; no-op otherwise.
  ///
  /// Wrapped here so callers don't have to remember the `canPop` guard and
  /// so future behavior (confirm-before-leaving, analytics) has one seam.
  void popRoute() {
    if (canPop()) pop();
  }
}
