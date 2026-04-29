import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/enums/study_enums.dart';
import '../../domain/study/entities/study_models.dart';
import '../../domain/study/study_settings_policy.dart';

final class StudySettingsStore {
  const StudySettingsStore(this._preferences);

  final SharedPreferences _preferences;

  StudySettingsSnapshot loadNewStudyDefaults() {
    final batchSize =
        _preferences.getInt(AppConstants.sharedPrefsDefaultNewBatchSizeKey) ??
        AppConstants.defaultNewStudyBatchSize;
    return StudySettingsSnapshot(
      batchSize: StudySettingsPolicy.clampBatchSize(
        batchSize,
        StudyType.newStudy,
      ),
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
    final batchSize =
        _preferences.getInt(
          AppConstants.sharedPrefsDefaultReviewBatchSizeKey,
        ) ??
        AppConstants.defaultReviewBatchSize;
    return StudySettingsSnapshot(
      batchSize: StudySettingsPolicy.clampBatchSize(
        batchSize,
        StudyType.srsReview,
      ),
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

  Future<void> saveNewStudyDefaults(StudySettingsSnapshot settings) async {
    await _preferences.setInt(
      AppConstants.sharedPrefsDefaultNewBatchSizeKey,
      settings.batchSize,
    );
    await _saveSharedDefaults(settings);
  }

  Future<void> saveReviewDefaults(StudySettingsSnapshot settings) async {
    await _preferences.setInt(
      AppConstants.sharedPrefsDefaultReviewBatchSizeKey,
      settings.batchSize,
    );
    await _saveSharedDefaults(settings);
  }

  Future<void> _saveSharedDefaults(StudySettingsSnapshot settings) async {
    await _preferences.setBool(
      AppConstants.sharedPrefsShuffleFlashcardsKey,
      settings.shuffleFlashcards,
    );
    await _preferences.setBool(
      AppConstants.sharedPrefsShuffleAnswersKey,
      settings.shuffleAnswers,
    );
    await _preferences.setBool(
      AppConstants.sharedPrefsPrioritizeOverdueKey,
      settings.prioritizeOverdue,
    );
  }
}
