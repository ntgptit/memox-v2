/// Canonical list of GoRouter route names + paths for the MemoX app.
///
/// All navigation call sites must reference these symbols instead of
/// hardcoding path literals. The router tree in [app_router.dart] consumes
/// the same constants, so a single rename updates both the tree and every
/// call site.
abstract final class RouteNames {
  const RouteNames._();

  // --- Top-level destinations (StatefulShellRoute branches) ---
  static const String home = 'home';
  static const String library = 'library';
  static const String progress = 'progress';
  static const String settings = 'settings';

  // --- Nested routes under /library ---
  static const String folderDetail = 'folder-detail';
}

/// Path layout mirroring [RouteNames]. Kept separate so the router tree can
/// register `path` strings while call sites stay on `name` lookups.
abstract final class RoutePaths {
  const RoutePaths._();

  static const String home = '/home';
  static const String library = '/library';
  static const String progress = '/progress';
  static const String settings = '/settings';

  /// Relative segment registered under `/library`. Keep the `:id` placeholder
  /// in sync with [folderIdParam].
  static const String folderDetailSegment = 'folder/:id';

  /// Path-parameter key used by the folder-detail route.
  static const String folderIdParam = 'id';
}

/// Router-owned defaults shared by config/bootstrap layers.
abstract final class RouteDefaults {
  const RouteDefaults._();

  static const String initialLocation = RoutePaths.library;
}
