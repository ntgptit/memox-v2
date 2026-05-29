import '../../../core/errors/app_exception.dart';

/// Identifies which empty-scope case rejected a study-session start.
///
/// Spec: `docs/business/study/study-flow.md` §Empty scope matrix.
/// Currently implemented (Tier 1, P0-1):
/// - [deckNoCards]
///
/// Tier 1 remaining (mechanical replication):
/// - deckNoDueCards, folderNoCards, folderNoDueCards,
///   todayAllDone, todayNoContent
/// Tier 2 (blocked on tag entry type): tagNoCards, tagNoDueCards
/// Tier 3 (blocked on P0-2 bury/suspend): allBuried, allSuspended
enum EmptyScopeReason {
  deckNoCards,
}

/// Thrown by `StartStudySessionUseCase` when the requested scope contains no
/// eligible flashcards. The presentation layer matches on [reason] to render
/// a dedicated empty state with an actionable CTA instead of a generic toast.
///
/// Throwable (extends [AppException]) so it propagates through the existing
/// use-case → notifier `try/catch` plumbing without restructuring.
class EmptyScopeException extends AppException {
  const EmptyScopeException(
    this.reason, {
    this.nextDueAt,
    super.code,
  }) : super(
         type: AppExceptionType.validation,
         message: 'Study session rejected: empty scope.',
       );

  final EmptyScopeReason reason;
  final DateTime? nextDueAt;
}
