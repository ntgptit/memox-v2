# Decision Tables: cloud_account_store_test

Test file: `test/data/settings/cloud_account_store_test.dart`

## Decision table: load

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | no account is saved | SharedPreferences has no `settings.account.cloud_link` value | store loads account | result is `null` | C0+C1 |
| DT2 | saved account uses current schema | SharedPreferences contains valid Google account JSON with Drive appdata scope | store loads account | result restores subject, email, scope, and Drive authorization state | C0+C1 |
| DT3 | saved account JSON is malformed or legacy | SharedPreferences contains malformed JSON or unsupported schema version | store loads account | result is `null` and no exception escapes | C0+C1 |

## Decision table: saveClear

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | save then clear account | valid Google account link exists in memory | store saves then clears account | saved JSON contains no token fields and later load returns `null` | C0+C1 |
