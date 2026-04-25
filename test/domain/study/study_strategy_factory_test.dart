import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/enums/study_enums.dart';
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

    test('DT1 selectStrategy: throws on duplicate strategy registration', () {
      expect(
        () => StudyStrategyFactory(const <StudyStrategy>[
          NewStudyStrategy(),
          NewStudyStrategy(),
        ]),
        throwsStateError,
      );
    });
  });
}
