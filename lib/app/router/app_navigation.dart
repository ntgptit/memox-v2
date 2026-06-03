import 'dart:async';

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

  void pushSettingsAccount() => pushNamed(RouteNames.settingsAccount);
  void pushSettingsLearning() => pushNamed(RouteNames.settingsLearning);
  void pushSettingsLearningTags() => pushNamed(RouteNames.settingsLearningTags);
  void pushSettingsAudioSpeech() => pushNamed(RouteNames.settingsAudioSpeech);

  void goFolderDetail(String folderId) {
    goNamed(
      RouteNames.folderDetail,
      pathParameters: {RoutePaths.folderIdParam: folderId},
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
    unawaited(
      pushNamed(
        RouteNames.folderDetail,
        pathParameters: {RoutePaths.folderIdParam: folderId},
      ),
    );
  }

  void pushFlashcardList(String deckId) {
    unawaited(
      push(
        namedLocation(
          RouteNames.flashcardList,
          pathParameters: {RoutePaths.deckIdParam: deckId},
        ),
      ),
    );
  }

  void pushFlashcardCreate(String deckId) {
    unawaited(
      pushNamed(
        RouteNames.flashcardCreate,
        pathParameters: {RoutePaths.deckIdParam: deckId},
      ),
    );
  }

  void pushFlashcardEdit({
    required String deckId,
    required String flashcardId,
  }) {
    unawaited(
      pushNamed(
        RouteNames.flashcardEdit,
        pathParameters: {
          RoutePaths.deckIdParam: deckId,
          RoutePaths.flashcardIdParam: flashcardId,
        },
      ),
    );
  }

  void pushDeckImport(String deckId) {
    unawaited(
      pushNamed(
        RouteNames.deckImport,
        pathParameters: {RoutePaths.deckIdParam: deckId},
      ),
    );
  }

  void goStudyEntry({
    required String entryType,
    required String entryRefId,
    String? studyMode,
    String? studyType,
    bool preserveStack = true,
  }) {
    final queryParameters = <String, String>{
      RoutePaths.studyModeQueryParam: ?studyMode,
      RoutePaths.studyTypeQueryParam: ?studyType,
    };
    if (!preserveStack) {
      goNamed(
        RouteNames.studyEntry,
        pathParameters: {
          RoutePaths.studyEntryTypeParam: entryType,
          RoutePaths.studyEntryRefIdParam: entryRefId,
        },
        queryParameters: queryParameters,
      );
      return;
    }
    unawaited(
      pushNamed(
        RouteNames.studyEntry,
        pathParameters: {
          RoutePaths.studyEntryTypeParam: entryType,
          RoutePaths.studyEntryRefIdParam: entryRefId,
        },
        queryParameters: queryParameters,
      ),
    );
  }

  void goStudyToday() {
    goNamed(RouteNames.studyToday);
  }

  void pushStudyToday() {
    unawaited(pushNamed(RouteNames.studyToday));
  }

  void goStudySession(String sessionId) {
    unawaited(
      pushNamed(
        RouteNames.studySession,
        pathParameters: {RoutePaths.studySessionIdParam: sessionId},
      ),
    );
  }

  void replaceStudySession(String sessionId) {
    replaceNamed(
      RouteNames.studySession,
      pathParameters: {RoutePaths.studySessionIdParam: sessionId},
    );
  }

  void goStudyResult(String sessionId) {
    replaceNamed(
      RouteNames.studyResult,
      pathParameters: {RoutePaths.studySessionIdParam: sessionId},
    );
  }

  /// Leave the Study Result screen via `go` (per nav-flow contract): the
  /// result screen MUST NOT remain in the back stack. Picks the safest
  /// existing destination from the session's entry context:
  ///
  /// - deck entry with refId → deck flashcard list
  /// - folder entry with refId → folder detail
  /// - today entry → Home/Dashboard (Today sessions are launched from there)
  /// - unknown / missing refId → library (top-level shell branch)
  void goStudyResultDone({
    required String entryType,
    String? entryRefId,
  }) {
    if (entryType == 'deck' && entryRefId != null && entryRefId.isNotEmpty) {
      goFlashcardList(entryRefId);
      return;
    }
    if (entryType == 'folder' && entryRefId != null && entryRefId.isNotEmpty) {
      goFolderDetail(entryRefId);
      return;
    }
    if (entryType == 'today') {
      goHome();
      return;
    }
    goLibrary();
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
