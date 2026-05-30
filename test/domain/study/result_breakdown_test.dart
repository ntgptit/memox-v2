import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/result_breakdown.dart';

void main() {
  group('computeStudyResultBreakdown', () {
    test('returns empty breakdown when there are no attempts', () {
      final breakdown = computeStudyResultBreakdown(
        const <StudyAttempt>[],
        studyType: StudyType.srsReview,
      );
      expect(breakdown.totalResultCount, 0);
    });

    test('SRS Review: classifies cards into perfect / recovered / forgot', () {
      final attempts = <StudyAttempt>[
        _attempt(card: 'card-1', grade: AttemptGrade.correct, oldBox: 2, newBox: 3),
        _attempt(card: 'card-2', grade: AttemptGrade.recovered, oldBox: 3, newBox: 3),
        _attempt(card: 'card-3', grade: AttemptGrade.incorrect, oldBox: 4, newBox: 3),
      ];

      final breakdown = computeStudyResultBreakdown(
        attempts,
        studyType: StudyType.srsReview,
      );
      expect(breakdown.perfectCount, 1);
      expect(breakdown.initialPassedCount, 0);
      expect(breakdown.recoveredCount, 1);
      expect(breakdown.forgotCount, 1);
      expect(breakdown.totalResultCount, 3);
      expect(breakdown.passedCount, 1);
    });

    test('New Study: passing cards bucket as initialPassed (not perfect)', () {
      final attempts = <StudyAttempt>[
        _attempt(card: 'card-1', grade: AttemptGrade.correct, oldBox: 1, newBox: 2),
        _attempt(card: 'card-2', grade: AttemptGrade.correct),
      ];

      final breakdown = computeStudyResultBreakdown(
        attempts,
        studyType: StudyType.newStudy,
      );
      expect(breakdown.initialPassedCount, 2);
      expect(breakdown.perfectCount, 0);
    });

    test('recovered is not counted as perfect when card eventually passes', () {
      final attempts = <StudyAttempt>[
        _attempt(card: 'card-1', grade: AttemptGrade.incorrect, oldBox: 3, newBox: 2),
        _attempt(card: 'card-1', grade: AttemptGrade.correct, oldBox: 2, newBox: 3),
      ];
      final breakdown = computeStudyResultBreakdown(
        attempts,
        studyType: StudyType.srsReview,
      );
      expect(breakdown.perfectCount, 0);
      expect(breakdown.recoveredCount, 1);
      expect(breakdown.forgotCount, 0);
    });

    test('forgot when card has only failing attempts', () {
      final attempts = <StudyAttempt>[
        _attempt(card: 'card-1', grade: AttemptGrade.incorrect, oldBox: 4, newBox: 3),
        _attempt(card: 'card-1', grade: AttemptGrade.incorrect, oldBox: 3, newBox: 2),
      ];
      final breakdown = computeStudyResultBreakdown(
        attempts,
        studyType: StudyType.srsReview,
      );
      expect(breakdown.forgotCount, 1);
      expect(breakdown.recoveredCount, 0);
    });
  });

  group('computeBoxChangeBreakdown', () {
    test('returns empty when no attempts have boxes (e.g. New Study mode)', () {
      final attempts = <StudyAttempt>[
        _attempt(card: 'card-1', grade: AttemptGrade.correct),
      ];
      final breakdown = computeBoxChangeBreakdown(attempts);
      expect(breakdown.totalChangeCount, 0);
    });

    test('derives advanced / stayed / reset / reachedBox8 from oldBox/newBox',
        () {
      final attempts = <StudyAttempt>[
        _attempt(card: 'a', grade: AttemptGrade.correct, oldBox: 2, newBox: 3),
        _attempt(card: 'b', grade: AttemptGrade.recovered, oldBox: 4, newBox: 4),
        _attempt(card: 'c', grade: AttemptGrade.incorrect, oldBox: 5, newBox: 4),
        _attempt(card: 'd', grade: AttemptGrade.correct, oldBox: 7, newBox: 8),
      ];
      final breakdown = computeBoxChangeBreakdown(attempts);
      expect(breakdown.advancedCount, 2);
      expect(breakdown.stayedCount, 1);
      expect(breakdown.resetCount, 1);
      expect(breakdown.reachedBox8Count, 1);
    });

    test('ignores attempts with null oldBox/newBox', () {
      final attempts = <StudyAttempt>[
        _attempt(card: 'a', grade: AttemptGrade.correct),
        _attempt(card: 'b', grade: AttemptGrade.correct, oldBox: 2, newBox: 3),
      ];
      final breakdown = computeBoxChangeBreakdown(attempts);
      expect(breakdown.advancedCount, 1);
      expect(breakdown.totalChangeCount, 1);
    });
  });
}

StudyAttempt _attempt({
  required String card,
  required AttemptGrade grade,
  int? oldBox,
  int? newBox,
}) => StudyAttempt(
  id: 'attempt-$card-${grade.storageValue}-$oldBox-$newBox',
  sessionId: 'session-001',
  sessionItemId: 'item-$card',
  flashcardId: card,
  attemptNumber: 1,
  grade: grade,
  answeredAt: 0,
  oldBox: oldBox,
  newBox: newBox,
  nextDueAt: null,
);
