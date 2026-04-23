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
  void goFolderDetail(String folderId) {
    goNamed(
      RouteNames.folderDetail,
      pathParameters: {RoutePaths.folderIdParam: folderId},
    );
  }

  void goDeckDetail(String deckId) {
    goNamed(
      RouteNames.deckDetail,
      pathParameters: {RoutePaths.deckIdParam: deckId},
    );
  }

  void goFlashcardList(String deckId) {
    goNamed(
      RouteNames.flashcardList,
      pathParameters: {RoutePaths.deckIdParam: deckId},
    );
  }

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

  void pushDeckDetail(String deckId) {
    pushNamed(
      RouteNames.deckDetail,
      pathParameters: {RoutePaths.deckIdParam: deckId},
    );
  }

  void pushFlashcardList(String deckId) {
    pushNamed(
      RouteNames.flashcardList,
      pathParameters: {RoutePaths.deckIdParam: deckId},
    );
  }

  void pushFlashcardCreate(String deckId) {
    pushNamed(
      RouteNames.flashcardCreate,
      pathParameters: {RoutePaths.deckIdParam: deckId},
    );
  }

  void pushFlashcardEdit({
    required String deckId,
    required String flashcardId,
  }) {
    pushNamed(
      RouteNames.flashcardEdit,
      pathParameters: {
        RoutePaths.deckIdParam: deckId,
        RoutePaths.flashcardIdParam: flashcardId,
      },
    );
  }

  void pushDeckImport(String deckId) {
    pushNamed(
      RouteNames.deckImport,
      pathParameters: {RoutePaths.deckIdParam: deckId},
    );
  }

  // --- Back navigation -------------------------------------------------------

  /// Pops the current route if possible; otherwise runs [fallback].
  ///
  /// Wrapped here so callers don't have to reach into the navigator directly
  /// and so deep-link fallback behavior stays consistent.
  Future<bool> popRoute({VoidCallback? fallback}) async {
    final didPop = await Navigator.of(this).maybePop();
    if (didPop) {
      return true;
    }
    if (!mounted) {
      return false;
    }
    fallback?.call();
    return false;
  }
}
