import '../../enums/study_enums.dart';
import '../entities/study_models.dart';

abstract interface class StudyRepo {
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

  Future<StudySessionSnapshot> answerCurrentModeBatch({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  });

  Future<StudySessionSnapshot> answerCurrentMatchModeBatch({
    required String sessionId,
    required Map<String, AttemptGrade> itemGrades,
    required List<StudyMode> modes,
  });

  Future<StudySessionSnapshot> skipCurrentItem(String sessionId);

  Future<StudySessionSnapshot> cancelSession(String sessionId);

  Future<StudySessionSnapshot> finalizeSession({
    required String sessionId,
    required StudyType studyType,
  });

  Future<StudySessionSnapshot> retryFinalize({
    required String sessionId,
    required StudyType studyType,
  });
}
