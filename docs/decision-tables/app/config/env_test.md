# Decision Tables: env_test

Test file: `test/app/config/env_test.dart`

## Decision table: loadConfig

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | config value matches a supported environment enum | loader receives supported environment string values such as local or production | config parser maps the raw value | returned enum matches the supported value | C0+C1 |
| DT2 | config value is unsupported and should fail fast | loader receives an unknown environment string | config parser maps the raw value | `ConfigurationException` is thrown with invalid value context | C0+C1 |
