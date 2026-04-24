/// Centralized non-UI constants shared by bootstrap/config/core layers.
abstract final class AppConstants {
  const AppConstants._();

  static const String appEnvKey = 'APP_ENV';
  static const String appEnvLocal = 'local';
  static const String appEnvDevelopment = 'development';
  static const String appEnvStaging = 'staging';
  static const String appEnvProduction = 'production';

  static const String sharedPrefsThemeModeKey = 'settings.theme_mode';
  static const String sharedPrefsLocaleKey = 'settings.locale';
  static const String sharedPrefsDefaultNewBatchSizeKey =
      'settings.study.default_new_batch_size';
  static const String sharedPrefsDefaultReviewBatchSizeKey =
      'settings.study.default_review_batch_size';
  static const String sharedPrefsShuffleFlashcardsKey =
      'settings.study.shuffle_flashcards';
  static const String sharedPrefsShuffleAnswersKey =
      'settings.study.shuffle_answers';
  static const String sharedPrefsPrioritizeOverdueKey =
      'settings.study.prioritize_overdue';
  static const String localDatabaseName = 'memox';

  static const Duration connectivityDebounce = Duration(milliseconds: 250);

  static const int defaultNewStudyBatchSize = 10;
  static const int defaultReviewBatchSize = 20;
}
