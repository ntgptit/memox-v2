import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/failures.dart';

/// Runtime environment resolved from the `APP_ENV` compile-time define.
enum AppEnv {
  local(AppConstants.appEnvLocal),
  development(AppConstants.appEnvDevelopment),
  staging(AppConstants.appEnvStaging),
  production(AppConstants.appEnvProduction);

  const AppEnv(this.value);

  final String value;

  bool get isLocalLike => switch (this) {
    AppEnv.local || AppEnv.development => true,
    AppEnv.staging || AppEnv.production => false,
  };

  bool get isReleaseLike => switch (this) {
    AppEnv.local || AppEnv.development => false,
    AppEnv.staging || AppEnv.production => true,
  };

  static AppEnv parse(String rawValue) {
    for (final env in AppEnv.values) {
      if (env.value == rawValue) {
        return env;
      }
    }

    throw ConfigurationException(
      message: 'Unsupported APP_ENV value: $rawValue',
      code: FailureCodes.invalidAppEnvironment,
    );
  }

  static AppEnv fromEnvironment() {
    const rawValue = String.fromEnvironment(
      AppConstants.appEnvKey,
      defaultValue: AppConstants.appEnvLocal,
    );

    return parse(rawValue);
  }
}
