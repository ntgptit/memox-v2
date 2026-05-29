import '../../enums/study_enums.dart';
import '../entities/study_models.dart';

abstract interface class StudyRepo {
  /// Returns the total flashcard count for [deckId] regardless of progress
  /// state. Used by empty-scope pre-checks (P0-1) to distinguish
  /// `deck_noCards` from `deck_noDueCards`.
  Future<int> countFlashcardsInDeck(String deckId);

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
