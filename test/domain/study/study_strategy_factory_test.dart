import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/errors/app_exception.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/strategy/study_mode_strategy.dart';
import 'package:memox/domain/study/strategy/study_strategy.dart';
import 'package:memox/domain/study/strategy/study_strategy_factory.dart';

void main() {
  group('StudyStrategyFactory', () {
    test('DT1 onNavigate: dispatches strategies by study type', () {
      final factory = StudyStrategyFactory(const <StudyStrategy>[
        NewStudyStrategy(),
        SrsReviewStrategy(),
      ]);

      expect(factory.of(StudyType.newStudy), isA<NewStudyStrategy>());
      expect(factory.of(StudyType.srsReview), isA<SrsReviewStrategy>());
      expect(factory.of(StudyType.newStudy).modes, const <StudyMode>[
        StudyMode.review,
        StudyMode.match,
        StudyMode.guess,
        StudyMode.recall,
        StudyMode.fill,
      ]);
      expect(factory.of(StudyType.srsReview).modes, const <StudyMode>[
        StudyMode.fill,
      ]);
    });

    test(
      'DT2 onNavigate: exposes supported entry points for each v1 strategy',
      () {
        const newStudy = NewStudyStrategy();
        const srsReview = SrsReviewStrategy();

        expect(newStudy.supportsEntry(StudyEntryType.deck), isTrue);
        expect(newStudy.supportsEntry(StudyEntryType.folder), isTrue);
        expect(newStudy.supportsEntry(StudyEntryType.today), isFalse);
        expect(srsReview.supportsEntry(StudyEntryType.deck), isTrue);
        expect(srsReview.supportsEntry(StudyEntryType.folder), isTrue);
        expect(srsReview.supportsEntry(StudyEntryType.today), isTrue);
      },
    );

    test('DT1 selectStrategy: throws on duplicate strategy registration', () {
      expect(
        () => StudyStrategyFactory(const <StudyStrategy>[
          NewStudyStrategy(),
          NewStudyStrategy(),
        ]),
        throwsStateError,
      );
    });

    test(
      'DT2 selectStrategy: throws when no strategy is registered for a study type',
      () {
        expect(
          () => StudyStrategyFactory(const <StudyStrategy>[NewStudyStrategy()]),
          throwsStateError,
        );
      },
    );
  });

  group('StudyModeStrategyFactory', () {
    test('DT3 onNavigate: dispatches strategies by study mode', () {
      final factory = _modeStrategyFactory();

      expect(factory.of(StudyMode.review), isA<ReviewModeStrategy>());
      expect(factory.of(StudyMode.match), isA<MatchModeStrategy>());
      expect(factory.of(StudyMode.guess), isA<GuessModeStrategy>());
      expect(factory.of(StudyMode.recall), isA<RecallModeStrategy>());
      expect(factory.of(StudyMode.fill), isA<FillModeStrategy>());
      expect(factory.of(StudyMode.match).batchSize, 5);
      expect(
        factory.of(StudyMode.review).modeCompletionDelay,
        const Duration(seconds: 2),
      );
      expect(
        factory.of(StudyMode.guess).modeCompletionDelay,
        const Duration(milliseconds: 650),
      );
    });

    test(
      'DT3 selectStrategy: throws on duplicate mode strategy registration',
      () {
        expect(
          () => StudyModeStrategyFactory(const <StudyModeStrategy>[
            ReviewModeStrategy(),
            ReviewModeStrategy(),
            MatchModeStrategy(),
            GuessModeStrategy(),
            RecallModeStrategy(),
            FillModeStrategy(),
          ]),
          throwsStateError,
        );
      },
    );

    test(
      'DT4 selectStrategy: throws when a mode strategy is not registered',
      () {
        expect(
          () => StudyModeStrategyFactory(const <StudyModeStrategy>[
            ReviewModeStrategy(),
            MatchModeStrategy(),
            GuessModeStrategy(),
            RecallModeStrategy(),
          ]),
          throwsStateError,
        );
      },
    );

    test(
      'DT1 normalizeUiResult: maps mode UI outcomes to correct or incorrect',
      () {
        const review = ReviewModeStrategy();
        const scoringStrategies = <StudyModeStrategy>[
          MatchModeStrategy(),
          GuessModeStrategy(),
          RecallModeStrategy(),
          FillModeStrategy(),
        ];

        for (final result in StudyModeUiResult.values) {
          expect(review.normalizeUiResult(result), AttemptGrade.correct);
        }
        for (final strategy in scoringStrategies) {
          expect(strategy.acceptedGrades, const <AttemptGrade>{
            AttemptGrade.correct,
            AttemptGrade.incorrect,
          });
          expect(
            strategy.normalizeUiResult(StudyModeUiResult.correct),
            AttemptGrade.correct,
          );
          expect(
            strategy.normalizeUiResult(StudyModeUiResult.remembered),
            AttemptGrade.correct,
          );
          expect(
            strategy.normalizeUiResult(StudyModeUiResult.viewed),
            AttemptGrade.correct,
          );
          expect(
            strategy.normalizeUiResult(StudyModeUiResult.incorrect),
            AttemptGrade.incorrect,
          );
          expect(
            strategy.normalizeUiResult(StudyModeUiResult.forgot),
            AttemptGrade.incorrect,
          );
          expect(
            strategy.normalizeUiResult(StudyModeUiResult.timeout),
            AttemptGrade.incorrect,
          );
          expect(
            strategy.normalizeUiResult(StudyModeUiResult.help),
            AttemptGrade.incorrect,
          );
        }
      },
    );

    test(
      'DT2 normalizeUiResult: builds full-round submission plans with unified grades',
      () {
        const strategy = MatchModeStrategy();

        final plan = strategy.buildSubmission(
          pendingItemIds: const <String>['item-001', 'item-002'],
          itemGrades: const <String, AttemptGrade>{
            'item-001': AttemptGrade.correct,
            'item-002': AttemptGrade.incorrect,
          },
        );

        expect(plan.mode, StudyMode.match);
        expect(plan.itemGrades, const <String, AttemptGrade>{
          'item-001': AttemptGrade.correct,
          'item-002': AttemptGrade.incorrect,
        });
        expect(plan.shouldRetry(AttemptGrade.correct), isFalse);
        expect(plan.shouldRetry(AttemptGrade.incorrect), isTrue);
        expect(
          () => strategy.buildSubmission(
            pendingItemIds: const <String>['item-001', 'item-002'],
            itemGrades: const <String, AttemptGrade>{
              'item-001': AttemptGrade.correct,
            },
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );
  });
}

StudyModeStrategyFactory _modeStrategyFactory() {
  return StudyModeStrategyFactory(const <StudyModeStrategy>[
    ReviewModeStrategy(),
    MatchModeStrategy(),
    GuessModeStrategy(),
    RecallModeStrategy(),
    FillModeStrategy(),
  ]);
}
