import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/mappers/database_enum_codecs.dart';
import 'package:memox/domain/enums/study_enums.dart';

void main() {
  group('AttemptGrade recovered channel', () {
    test('DT15 onSubmit: recovered is passing but not perfect eligible', () {
      expect(AttemptGrade.correct.isPassing, isTrue);
      expect(AttemptGrade.correct.isFailing, isFalse);
      expect(AttemptGrade.correct.isPerfectEligible, isTrue);

      expect(AttemptGrade.recovered.isPassing, isTrue);
      expect(AttemptGrade.recovered.isFailing, isFalse);
      expect(AttemptGrade.recovered.isPerfectEligible, isFalse);

      expect(AttemptGrade.incorrect.isPassing, isFalse);
      expect(AttemptGrade.incorrect.isFailing, isTrue);
      expect(AttemptGrade.incorrect.isPerfectEligible, isFalse);
    });

    test('DT15 onLoad: codecs round-trip recovered storage values', () {
      expect(
        DatabaseEnumCodecs.attemptGradeFromStorage('recovered'),
        AttemptGrade.recovered,
      );
      expect(
        DatabaseEnumCodecs.rawStudyResultFromStorage('recovered'),
        RawStudyResult.recovered,
      );
    });
  });
}
