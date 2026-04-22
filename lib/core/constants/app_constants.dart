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
  static const String localDatabaseName = 'memox';

  static const Duration connectivityDebounce = Duration(milliseconds: 250);
}
