import '../enums/study_enums.dart';
import 'entities/study_models.dart';

/// Per-card session result category, shared by [computeStudyResultBreakdown]
/// and [computeStudyResultCardReviewItems] so they cannot drift.
enum _CardResultCategory { perfect, initialPassed, recovered, forgot }

class _ClassifiedCardResult {
  const _ClassifiedCardResult({
    required this.category,
    required this.attempts,
    required this.lastAnsweredAt,
    required this.oldBox,
    required this.newBox,
    required this.nextDueAt,
  });

  final _CardResultCategory category;
  final List<StudyAttempt> attempts;
  final int lastAnsweredAt;
  final int? oldBox;
  final int? newBox;
  final int? nextDueAt;
}

_CardResultCategory _categorize({
  required bool hasPassing,
  required bool hasIncorrectOrRecovered,
  required StudyType studyType,
}) {
  if (!hasPassing) {
    return _CardResultCategory.forgot;
  }
  if (hasIncorrectOrRecovered) {
    return _CardResultCategory.recovered;
  }
  return switch (studyType) {
    StudyType.newStudy => _CardResultCategory.initialPassed,
    StudyType.srsReview => _CardResultCategory.perfect,
  };
}

Map<String, _ClassifiedCardResult> _classifyAttemptsByCard(
  List<StudyAttempt> attempts, {
  required StudyType studyType,
}) {
  final byCard = <String, List<StudyAttempt>>{};
  for (final attempt in attempts) {
    byCard
        .putIfAbsent(attempt.flashcardId, () => <StudyAttempt>[])
        .add(attempt);
  }
  final result = <String, _ClassifiedCardResult>{};
  byCard.forEach((cardId, cardAttempts) {
    final grades = cardAttempts.map((attempt) => attempt.grade);
    final hasPassing = grades.any((grade) => grade.isPassing);
    final hasIncorrect = grades.any((grade) => grade.isFailing);
    final hasRecoveredGrade =
        grades.any((grade) => grade == AttemptGrade.recovered);
    final _CardResultCategory category = _categorize(
      hasPassing: hasPassing,
      hasIncorrectOrRecovered: hasIncorrect || hasRecoveredGrade,
      studyType: studyType,
    );
    var lastAnsweredAt = cardAttempts.first.answeredAt;
    for (final attempt in cardAttempts) {
      if (attempt.answeredAt > lastAnsweredAt) {
        lastAnsweredAt = attempt.answeredAt;
      }
    }
    StudyAttempt? lastWithBoxes;
    for (final attempt in cardAttempts) {
      if (attempt.oldBox != null && attempt.newBox != null) {
        lastWithBoxes = attempt;
      }
    }
    result[cardId] = _ClassifiedCardResult(
      category: category,
      attempts: cardAttempts,
      lastAnsweredAt: lastAnsweredAt,
      oldBox: lastWithBoxes?.oldBox,
      newBox: lastWithBoxes?.newBox,
      nextDueAt: lastWithBoxes?.nextDueAt,
    );
  });
  return result;
}

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
  final classified = _classifyAttemptsByCard(attempts, studyType: studyType);
  var perfect = 0;
  var initialPassed = 0;
  var recovered = 0;
  var forgot = 0;
  for (final entry in classified.values) {
    switch (entry.category) {
      case _CardResultCategory.perfect:
        perfect += 1;
      case _CardResultCategory.initialPassed:
        initialPassed += 1;
      case _CardResultCategory.recovered:
        recovered += 1;
      case _CardResultCategory.forgot:
        forgot += 1;
    }
  }
  return StudyResultBreakdown(
    perfectCount: perfect,
    initialPassedCount: initialPassed,
    recoveredCount: recovered,
    forgotCount: forgot,
  );
}

/// Per-card review items for the V1 Study Result "Cards to review" section.
///
/// Includes only cards classified as recovered or forgot — perfect and
/// initialPassed cards are not shown. Classification reuses the same shared
/// per-card classifier as [computeStudyResultBreakdown] so the section's
/// count cannot diverge from the result breakdown.
///
/// Sort: forgot first, recovered second; within each bucket the most
/// recently answered card comes first.
List<StudyResultCardReviewItem> computeStudyResultCardReviewItems({
  required List<StudyAttempt> attempts,
  required List<StudyFlashcardRef> flashcards,
  required StudyType studyType,
}) {
  if (attempts.isEmpty) {
    return const <StudyResultCardReviewItem>[];
  }
  final classified = _classifyAttemptsByCard(attempts, studyType: studyType);
  final flashcardsById = <String, StudyFlashcardRef>{
    for (final card in flashcards) card.id: card,
  };
  final items = <StudyResultCardReviewItem>[];
  classified.forEach((cardId, classifiedCard) {
    final type = switch (classifiedCard.category) {
      _CardResultCategory.recovered =>
        StudyResultCardReviewType.recovered,
      _CardResultCategory.forgot => StudyResultCardReviewType.forgot,
      _CardResultCategory.perfect ||
      _CardResultCategory.initialPassed => null,
    };
    if (type == null) {
      return;
    }
    final flashcard = flashcardsById[cardId];
    if (flashcard == null) {
      return;
    }
    items.add(
      StudyResultCardReviewItem(
        flashcardId: cardId,
        front: flashcard.front,
        back: flashcard.back,
        resultType: type,
        attemptCount: classifiedCard.attempts.length,
        lastAnsweredAt: classifiedCard.lastAnsweredAt,
        oldBox: classifiedCard.oldBox,
        newBox: classifiedCard.newBox,
        nextDueAt: classifiedCard.nextDueAt,
      ),
    );
  });
  items.sort((a, b) {
    final aRank = a.resultType == StudyResultCardReviewType.forgot ? 0 : 1;
    final bRank = b.resultType == StudyResultCardReviewType.forgot ? 0 : 1;
    if (aRank != bRank) {
      return aRank.compareTo(bRank);
    }
    return b.lastAnsweredAt.compareTo(a.lastAnsweredAt);
  });
  return List<StudyResultCardReviewItem>.unmodifiable(items);
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
