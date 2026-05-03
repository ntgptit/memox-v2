# Decision Tables: app_config_test

Test file: `test/app/config/app_config_test.dart`

## Decision table: googleOAuthConfig

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | Google client IDs are blank | config is built from blank values | platform capability is checked | web, Android, and iOS are not configured | C0+C1 |
| DT2 | web client ID is present | config has `GOOGLE_WEB_CLIENT_ID` | web and Android capability are checked | web is configured and Android can use the web/server client ID fallback | C0+C1 |
| DT3 | iOS client ID is present | config has `GOOGLE_IOS_CLIENT_ID` | iOS and desktop capability are checked | iOS is configured and Windows remains unsupported | C0+C1 |
| DT4 | app config has no OAuth field value from a legacy or hot-reload instance | `AppConfig` is constructed through a path that omits `googleOAuthConfig` | account config is read | it returns empty Google OAuth config instead of throwing, so account linking is disabled safely | C0+C1 |
