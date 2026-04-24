import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/study/entities/study_models.dart';

final class StudySettingsStore {
  const StudySettingsStore(this._preferences);

  final SharedPreferences _preferences;

  StudySettingsSnapshot loadNewStudyDefaults() {
    return StudySettingsSnapshot(
      batchSize:
          _preferences.getInt(AppConstants.sharedPrefsDefaultNewBatchSizeKey) ??
          AppConstants.defaultNewStudyBatchSize,
      shuffleFlashcards:
          _preferences.getBool(AppConstants.sharedPrefsShuffleFlashcardsKey) ??
          true,
      shuffleAnswers:
          _preferences.getBool(AppConstants.sharedPrefsShuffleAnswersKey) ??
          true,
      prioritizeOverdue:
          _preferences.getBool(AppConstants.sharedPrefsPrioritizeOverdueKey) ??
          true,
    );
  }

  StudySettingsSnapshot loadReviewDefaults() {
    return StudySettingsSnapshot(
      batchSize:
          _preferences.getInt(
            AppConstants.sharedPrefsDefaultReviewBatchSizeKey,
          ) ??
          AppConstants.defaultReviewBatchSize,
      shuffleFlashcards:
          _preferences.getBool(AppConstants.sharedPrefsShuffleFlashcardsKey) ??
          true,
      shuffleAnswers:
          _preferences.getBool(AppConstants.sharedPrefsShuffleAnswersKey) ??
          true,
      prioritizeOverdue:
          _preferences.getBool(AppConstants.sharedPrefsPrioritizeOverdueKey) ??
          true,
    );
  }
}
