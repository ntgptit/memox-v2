import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:memox/data/settings/study_settings_store.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('DT1 load: clamps persisted out-of-range batch sizes', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.sharedPrefsDefaultNewBatchSizeKey: 100,
      AppConstants.sharedPrefsDefaultReviewBatchSizeKey: 1,
    });

    final store = StudySettingsStore(await SharedPreferences.getInstance());

    expect(store.loadNewStudyDefaults().batchSize, 20);
    expect(store.loadReviewDefaults().batchSize, 5);
  });

  test(
    'DT2 save: round-trips new and review defaults with shared toggles',
    () async {
      final store = StudySettingsStore(await SharedPreferences.getInstance());

      await store.saveNewStudyDefaults(
        const StudySettingsSnapshot(
          batchSize: 12,
          shuffleFlashcards: false,
          shuffleAnswers: false,
          prioritizeOverdue: false,
        ),
      );
      await store.saveReviewDefaults(
        const StudySettingsSnapshot(
          batchSize: 25,
          shuffleFlashcards: true,
          shuffleAnswers: true,
          prioritizeOverdue: true,
        ),
      );

      final newStudy = store.loadNewStudyDefaults();
      final review = store.loadReviewDefaults();

      expect(newStudy.batchSize, 12);
      expect(review.batchSize, 25);
      expect(newStudy.shuffleFlashcards, isTrue);
      expect(newStudy.shuffleAnswers, isTrue);
      expect(newStudy.prioritizeOverdue, isTrue);
      expect(review.shuffleFlashcards, isTrue);
    },
  );
}
