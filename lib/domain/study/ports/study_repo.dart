import '../../enums/study_enums.dart';
import '../entities/study_models.dart';

abstract interface class StudyRepo {
  /// Returns the total flashcard count for [deckId] regardless of progress
  /// state. Used by empty-scope pre-checks (P0-1) to distinguish
  /// `deck_noCards` from `deck_noDueCards`.
  Future<int> countFlashcardsInDeck(String deckId);

  /// Total flashcards in the scope described by [context] (folder subtree or
  /// today = all decks). Used by empty-scope pre-checks (P0-1) to distinguish
  /// `folder_noCards` / `today_noContent`.
  Future<int> countFlashcardsInScope(StudyContext context);

  /// Count of flashcards in [context]'s scope that are due on or before the
  /// end of today. Used by empty-scope pre-checks (P0-1) to distinguish the
  /// `*_noDueCards` / `today_allDone` cases.
  Future<int> countDueCardsInScope(StudyContext context);

  /// Nearest future due date in [context]'s scope (`MIN(due_at)` where
  /// `due_at` is after end of today), or `null` when no future due exists.
  /// Powers the "Next due in {relativeTime}" hint on `*_noDueCards` states.
  Future<DateTime?> nextDueAt(StudyContext context);

  /// Buries [flashcardId] until the next local midnight when [buried] is true,
  /// or clears `buried_until` (unbury) when false. SRS state is never altered.
  /// Spec: `docs/business/study-actions/bury-suspend.md`.
  Future<void> setBuried({required String flashcardId, required bool buried});

  /// Toggles `flashcard_progress.is_suspended` for [flashcardId]. SRS state is
  /// preserved so unsuspend resumes from the same box/due date.
  Future<void> setSuspended({
    required String flashcardId,
    required bool suspended,
  });

  /// Count of suspended cards in [context]'s scope. Used by the empty-scope
  /// `allSuspended` pre-check (Tier 3).
  Future<int> countSuspendedInScope(StudyContext context);

  /// Count of cards in [context]'s scope that are currently buried
  /// (`buried_until > now`) and NOT suspended. Used by the empty-scope
  /// `allBuried` pre-check (Tier 3).
  Future<int> countActiveBuriedInScope(StudyContext context);

  Future<List<StudyFlashcardRef>> loadNewCards(StudyContext context);

  Future<List<StudyFlashcardRef>> loadDueCards(StudyContext context);

  Future<StudySessionSnapshot?> findResumeCandidate(StudyContext context);

  Future<List<StudySessionSnapshot>> listActiveSessions();

  Future<StudySessionSnapshot> startSession({
    required StudyContext context,
    required StudyFlow flow,
    required List<StudyMode> modes,
    required List<StudyFlashcardRef> batch,
  });

  Future<StudySessionSnapshot> loadSession(String sessionId);

  Future<StudySessionSnapshot> answerCurrentItem({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  });

  Future<StudySessionSnapshot> answerCurrentModeItemGradesBatch({
    required String sessionId,
    required Map<String, AttemptGrade> itemGrades,
    required List<StudyMode> modes,
  });

  Future<StudySessionSnapshot> skipCurrentItem(String sessionId);

  Future<StudySessionSnapshot> cancelSession(String sessionId);

  Future<StudySessionSnapshot> finalizeSession({
    required String sessionId,
    required StudyType studyType,
    required StudyFinalizePolicy finalizePolicy,
  });

  Future<StudySessionSnapshot> retryFinalize({
    required String sessionId,
    required StudyType studyType,
    required StudyFinalizePolicy finalizePolicy,
  });
}
