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
  static const String flashcardList = 'flashcard-list';
  static const String flashcardCreate = 'flashcard-create';
  static const String flashcardEdit = 'flashcard-edit';
  static const String deckImport = 'deck-import';
  static const String studyEntry = 'study-entry';
  static const String studyToday = 'study-today';
  static const String studySession = 'study-session';
  static const String studyResult = 'study-result';
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
  static const String flashcardListSegment = 'deck/:deckId/flashcards';
  static const String flashcardCreateSegment = 'deck/:deckId/flashcards/new';
  static const String flashcardEditSegment =
      'deck/:deckId/flashcards/:flashcardId/edit';
  static const String deckImportSegment = 'deck/:deckId/import';
  static const String studyEntrySegment = 'study/:entryType/:entryRefId';
  static const String studyTodaySegment = 'study/today';
  static const String studySessionSegment = 'study/session/:sessionId';
  static const String studyResultSegment = 'study/session/:sessionId/result';

  /// Path-parameter key used by the folder-detail route.
  static const String folderIdParam = 'id';
  static const String deckIdParam = 'deckId';
  static const String flashcardIdParam = 'flashcardId';
  static const String studyEntryTypeParam = 'entryType';
  static const String studyEntryRefIdParam = 'entryRefId';
  static const String studySessionIdParam = 'sessionId';
}

/// Router-owned defaults shared by config/bootstrap layers.
abstract final class RouteDefaults {
  const RouteDefaults._();

  static const String initialLocation = RoutePaths.library;
}
