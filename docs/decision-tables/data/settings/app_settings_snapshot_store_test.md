# Decision Tables: app_settings_snapshot_store_test

Test file: `test/data/settings/app_settings_snapshot_store_test.dart`

## Decision table: settingsSnapshot

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | SharedPreferences contains syncable settings plus account/sync metadata | theme, locale, study defaults, TTS rate, account link, and sync metadata keys exist | snapshot store loads settings | snapshot includes only allowed app settings and excludes account link plus sync metadata | C0+C1 |
| DT2 | remote settings replace local settings | local SharedPreferences contains old included keys and account link; remote settings contain valid values, invalid typed values, and an ignored account key | snapshot store restores settings | included keys missing from remote are removed, valid remote values are written, invalid values are skipped, and account link remains unchanged | C0+C1 |
