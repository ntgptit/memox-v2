import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/result_breakdown.dart';

void main() {
  group('computeStudyResultCardReviewItems', () {
    test('returns empty list when there are no attempts', () {
      final items = computeStudyResultCardReviewItems(
        attempts: const <StudyAttempt>[],
        flashcards: const <StudyFlashcardRef>[],
        studyType: StudyType.srsReview,
      );
      expect(items, isEmpty);
    });

    test('includes recovered and forgot cards; excludes perfect/initialPassed',
        () {
      final attempts = <StudyAttempt>[
        _attempt(card: 'perfect-1', grade: AttemptGrade.correct,
            oldBox: 2, newBox: 3, answeredAt: 100),
        _attempt(card: 'recovered-1', grade: AttemptGrade.recovered,
            oldBox: 3, newBox: 3, answeredAt: 200),
        _attempt(card: 'forgot-1', grade: AttemptGrade.incorrect,
            oldBox: 4, newBox: 3, answeredAt: 300),
      ];
      final flashcards = <StudyFlashcardRef>[
        _ref('perfect-1'),
        _ref('recovered-1'),
        _ref('forgot-1'),
      ];

      final items = computeStudyResultCardReviewItems(
        attempts: attempts,
        flashcards: flashcards,
        studyType: StudyType.srsReview,
      );

      final ids = items.map((item) => item.flashcardId).toList();
      expect(ids, containsAll(<String>['recovered-1', 'forgot-1']));
      expect(ids, isNot(contains('perfect-1')));
    });

    test('excludes initialPassed (New Study passing) cards', () {
      final attempts = <StudyAttempt>[
        _attempt(card: 'new-1', grade: AttemptGrade.correct,
            oldBox: 1, newBox: 2, answeredAt: 50),
      ];
      final items = computeStudyResultCardReviewItems(
        attempts: attempts,
        flashcards: <StudyFlashcardRef>[_ref('new-1')],
        studyType: StudyType.newStudy,
      );
      expect(items, isEmpty);
    });

    test('forgot cards sort before recovered cards', () {
      final attempts = <StudyAttempt>[
        _attempt(card: 'recovered-1', grade: AttemptGrade.recovered,
            oldBox: 2, newBox: 2, answeredAt: 500),
        _attempt(card: 'forgot-1', grade: AttemptGrade.incorrect,
            oldBox: 3, newBox: 2, answeredAt: 100),
      ];
      final items = computeStudyResultCardReviewItems(
        attempts: attempts,
        flashcards: <StudyFlashcardRef>[
          _ref('recovered-1'),
          _ref('forgot-1'),
        ],
        studyType: StudyType.srsReview,
      );
      expect(items.first.flashcardId, 'forgot-1');
      expect(items.last.flashcardId, 'recovered-1');
    });

    test('within same bucket, most recently answered comes first', () {
      final attempts = <StudyAttempt>[
        _attempt(card: 'forgot-old', grade: AttemptGrade.incorrect,
            oldBox: 2, newBox: 1, answeredAt: 100),
        _attempt(card: 'forgot-new', grade: AttemptGrade.incorrect,
            oldBox: 4, newBox: 3, answeredAt: 500),
      ];
      final items = computeStudyResultCardReviewItems(
        attempts: attempts,
        flashcards: <StudyFlashcardRef>[
          _ref('forgot-old'),
          _ref('forgot-new'),
        ],
        studyType: StudyType.srsReview,
      );
      expect(items.map((item) => item.flashcardId).toList(),
          <String>['forgot-new', 'forgot-old']);
    });

    test('attemptCount reflects all attempts for the card', () {
      final attempts = <StudyAttempt>[
        _attempt(card: 'r-1', grade: AttemptGrade.incorrect,
            oldBox: 3, newBox: 2, answeredAt: 100),
        _attempt(card: 'r-1', grade: AttemptGrade.correct,
            oldBox: 2, newBox: 3, answeredAt: 200),
      ];
      final items = computeStudyResultCardReviewItems(
        attempts: attempts,
        flashcards: <StudyFlashcardRef>[_ref('r-1')],
        studyType: StudyType.srsReview,
      );
      expect(items, hasLength(1));
      expect(items.single.attemptCount, 2);
      expect(items.single.isRecovered, isTrue);
    });

    test('oldBox/newBox come from the last attempt that has both populated',
        () {
      final attempts = <StudyAttempt>[
        _attempt(card: 'r-1', grade: AttemptGrade.incorrect,
            oldBox: 5, newBox: 4, answeredAt: 100),
        _attempt(card: 'r-1', grade: AttemptGrade.correct,
            oldBox: 4, newBox: 5, answeredAt: 200, nextDueAt: 12345),
      ];
      final items = computeStudyResultCardReviewItems(
        attempts: attempts,
        flashcards: <StudyFlashcardRef>[_ref('r-1')],
        studyType: StudyType.srsReview,
      );
      expect(items.single.oldBox, 4);
      expect(items.single.newBox, 5);
      expect(items.single.nextDueAt, 12345);
    });

    test('missing flashcard ref skips the card without crashing', () {
      final attempts = <StudyAttempt>[
        _attempt(card: 'ghost', grade: AttemptGrade.incorrect,
            oldBox: 3, newBox: 2, answeredAt: 100),
        _attempt(card: 'r-1', grade: AttemptGrade.recovered,
            oldBox: 2, newBox: 2, answeredAt: 200),
      ];
      final items = computeStudyResultCardReviewItems(
        attempts: attempts,
        flashcards: <StudyFlashcardRef>[_ref('r-1')],
        studyType: StudyType.srsReview,
      );
      expect(items.map((item) => item.flashcardId), <String>['r-1']);
    });

    test('card review count matches breakdown recovered+forgot count', () {
      final attempts = <StudyAttempt>[
        _attempt(card: 'p', grade: AttemptGrade.correct,
            oldBox: 2, newBox: 3, answeredAt: 100),
        _attempt(card: 'r', grade: AttemptGrade.recovered,
            oldBox: 3, newBox: 3, answeredAt: 200),
        _attempt(card: 'f', grade: AttemptGrade.incorrect,
            oldBox: 4, newBox: 3, answeredAt: 300),
      ];
      final flashcards = <StudyFlashcardRef>[
        _ref('p'),
        _ref('r'),
        _ref('f'),
      ];
      final breakdown = computeStudyResultBreakdown(
        attempts,
        studyType: StudyType.srsReview,
      );
      final items = computeStudyResultCardReviewItems(
        attempts: attempts,
        flashcards: flashcards,
        studyType: StudyType.srsReview,
      );
      expect(
        items.length,
        breakdown.recoveredCount + breakdown.forgotCount,
      );
    });
  });
}

StudyAttempt _attempt({
  required String card,
  required AttemptGrade grade,
  int? oldBox,
  int? newBox,
  int answeredAt = 0,
  int? nextDueAt,
}) => StudyAttempt(
  id: 'attempt-$card-${grade.storageValue}-$answeredAt',
  sessionId: 'session-001',
  sessionItemId: 'item-$card',
  flashcardId: card,
  attemptNumber: 1,
  grade: grade,
  answeredAt: answeredAt,
  oldBox: oldBox,
  newBox: newBox,
  nextDueAt: nextDueAt,
);

StudyFlashcardRef _ref(String id) => StudyFlashcardRef(
  id: id,
  deckId: 'deck-1',
  front: 'front-$id',
  back: 'back-$id',
  sourcePool: SessionItemSourcePool.due,
);
