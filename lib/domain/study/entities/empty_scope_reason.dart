import '../../../core/errors/app_exception.dart';

/// Identifies which empty-scope case rejected a study-session start.
///
/// Spec: `docs/business/study/study-flow.md` §Empty scope matrix.
/// Implemented (Tier 1, P0-1):
/// - [deckNoCards], [deckNoDueCards],
///   [folderNoCards], [folderNoDueCards],
///   [todayAllDone], [todayNoContent]
///
/// Tier 2 (blocked on tag entry type): tagNoCards, tagNoDueCards
enum EmptyScopeReason {
  /// Deck scope contains zero flashcards (any study type).
  deckNoCards,

  /// Deck scope has flashcards but none are due now (srs_review).
  deckNoDueCards,

  /// Folder subtree contains zero flashcards (any study type).
  folderNoCards,

  /// Folder subtree has flashcards but none are due now (srs_review).
  folderNoDueCards,

  /// Today scope has flashcards but none are due now (srs_review).
  todayAllDone,

  /// User has no flashcards at all (today scope, srs_review).
  todayNoContent,

  /// Every card in scope is buried for today (Tier 3, P0-2).
  allBuried,

  /// Every card in scope is suspended (Tier 3, P0-2).
  allSuspended,
}

/// Thrown by `StartStudySessionUseCase` when the requested scope contains no
/// eligible flashcards. The presentation layer matches on [reason] to render
/// a dedicated empty state with an actionable CTA instead of a generic toast.
///
/// Throwable (extends [AppException]) so it propagates through the existing
/// use-case → notifier `try/catch` plumbing without restructuring.
class EmptyScopeException extends AppException {
  const EmptyScopeException(this.reason, {this.nextDueAt, super.code})
    : super(
        type: AppExceptionType.validation,
        message: 'Study session rejected: empty scope.',
      );

  final EmptyScopeReason reason;
  final DateTime? nextDueAt;
}
