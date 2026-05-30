import '../enums/study_enums.dart';
import 'entities/study_models.dart';

/// Per-card result categorization from a session's [StudyAttempt] list.
///
/// Buckets (V1 result types — `docs/wireframes/18-study-result.md`):
/// - perfect: SRS Review session AND every attempt has grade==correct (no
///   recovered/incorrect anywhere in the card's attempt history).
/// - initialPassed: New Study session AND every attempt has grade==correct.
///   New Study cards always finalize to box 2 with [ReviewResult.initialPassed]
///   regardless of how many retry attempts ran inside the learning modes.
/// - recovered: at least one attempt with grade==recovered or grade==incorrect,
///   but the card has at least one passing attempt.
/// - forgot: card has attempts but no passing attempt.
///
/// [studyType] is required because after finalization the attempt rows of a
/// New Study card carry oldBox==1/newBox==2 (deterministic placement),
/// which is indistinguishable from a perfect SRS Review without this hint.
StudyResultBreakdown computeStudyResultBreakdown(
  List<StudyAttempt> attempts, {
  required StudyType studyType,
}) {
  if (attempts.isEmpty) {
    return StudyResultBreakdown.empty;
  }
  final attemptsByCard = <String, List<StudyAttempt>>{};
  for (final attempt in attempts) {
    attemptsByCard
        .putIfAbsent(attempt.flashcardId, () => <StudyAttempt>[])
        .add(attempt);
  }
  var perfect = 0;
  var initialPassed = 0;
  var recovered = 0;
  var forgot = 0;
  for (final cardAttempts in attemptsByCard.values) {
    final grades = cardAttempts.map((attempt) => attempt.grade);
    final hasPassing = grades.any((grade) => grade.isPassing);
    final hasIncorrect = grades.any((grade) => grade.isFailing);
    final hasRecoveredGrade =
        grades.any((grade) => grade == AttemptGrade.recovered);
    if (!hasPassing) {
      forgot += 1;
      continue;
    }
    if (hasIncorrect || hasRecoveredGrade) {
      recovered += 1;
      continue;
    }
    switch (studyType) {
      case StudyType.newStudy:
        initialPassed += 1;
      case StudyType.srsReview:
        perfect += 1;
    }
  }
  return StudyResultBreakdown(
    perfectCount: perfect,
    initialPassedCount: initialPassed,
    recoveredCount: recovered,
    forgotCount: forgot,
  );
}

/// Box-change counts derived from attempt oldBox/newBox transitions
/// (NEVER from the current `flashcard_progress` snapshot).
///
/// For each card, uses the last attempt that has both oldBox and newBox
/// populated. Cards whose attempts all have null boxes (New Study before
/// finalize) are ignored.
BoxChangeBreakdown computeBoxChangeBreakdown(List<StudyAttempt> attempts) {
  final perCard = <String, StudyAttempt>{};
  for (final attempt in attempts) {
    if (attempt.oldBox == null || attempt.newBox == null) {
      continue;
    }
    perCard[attempt.flashcardId] = attempt;
  }
  if (perCard.isEmpty) {
    return BoxChangeBreakdown.empty;
  }
  var advanced = 0;
  var stayed = 0;
  var reset = 0;
  var reachedBox8 = 0;
  for (final attempt in perCard.values) {
    final oldBox = attempt.oldBox!;
    final newBox = attempt.newBox!;
    final delta = newBox.compareTo(oldBox);
    if (delta > 0) {
      advanced += 1;
    }
    if (delta == 0) {
      stayed += 1;
    }
    if (delta < 0) {
      reset += 1;
    }
    if (newBox == 8 && oldBox < 8) {
      reachedBox8 += 1;
    }
  }
  return BoxChangeBreakdown(
    advancedCount: advanced,
    stayedCount: stayed,
    resetCount: reset,
    reachedBox8Count: reachedBox8,
  );
}
