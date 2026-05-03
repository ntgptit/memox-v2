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
  static const String sharedPrefsTtsAutoPlayKey = 'settings.tts.auto_play';
  static const String sharedPrefsTtsFrontLanguageKey =
      'settings.tts.front_language';
  static const String sharedPrefsTtsBackLanguageKey =
      'settings.tts.back_language';
  static const String sharedPrefsTtsRateKey = 'settings.tts.rate';
  static const String sharedPrefsTtsFrontVoiceNameKey =
      'settings.tts.front_voice_name';
  static const String sharedPrefsTtsBackVoiceNameKey =
      'settings.tts.back_voice_name';
  static const String sharedPrefsCloudAccountLinkKey =
      'settings.account.cloud_link';
  static const String sharedPrefsDriveSyncMetadataKey =
      'settings.sync.google_drive.metadata';
  static const String sharedPrefsDriveSyncDeviceIdKey =
      'settings.sync.google_drive.device_id';
  static const String driveSyncManifestFileName = 'memox.sync.manifest.json';
  static const String driveSyncSnapshotFileName = 'memox.sync.snapshot.zip';
  static const String driveSyncManifestEntryName = 'manifest.json';
  static const String driveSyncDatabaseEntryName = 'memox.sqlite';
  static const String driveSyncSettingsEntryName = 'settings.json';
  static const String driveSyncMimeType = 'application/octet-stream';
  static const String driveSyncManifestMimeType = 'application/json';
  static const String localDatabaseName = 'memox';

  static const Duration connectivityDebounce = Duration(milliseconds: 250);

  static const int defaultNewStudyBatchSize = 10;
  static const int defaultReviewBatchSize = 20;
}
