# Decision Tables: env_test

Test file: `test/app/config/env_test.dart`

## Decision table: loadConfig

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | config value matches a supported environment enum | loader receives supported environment string values such as local or production | config parser maps the raw value | returned enum matches the supported value | C0+C1 |
| DT2 | config value is unsupported or explicitly empty and should fail fast | loader receives an unknown environment string or an explicit empty value | config parser maps the raw value | `ConfigurationException` is thrown with invalid value context | C0+C1 |
| DT3 | `APP_ENV` is missing in a non-release build | loader has no compile-time env value and the build mode is not release | config resolver maps the missing value | `AppEnv.local` is returned for development and test commands | C0+C1 |
| DT4 | `APP_ENV` is missing in a release build | loader has no compile-time env value and the build mode is release | config resolver maps the missing value | `AppEnv.production` is returned so diagnostics stay off by default | C0+C1 |
| DT5 | production env builds app config | resolver returns `AppEnv.production` | app config is built from the environment | router, Talker, Riverpod diagnostics, and internal error details are disabled | C0+C1 |
