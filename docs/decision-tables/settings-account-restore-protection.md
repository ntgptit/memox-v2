# Decision Tables: settings_screen_test

Test file: `test/presentation/settings_screen_test.dart`

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT11 | upload succeeds | Drive sync has no remote snapshot | user confirms upload | status and success feedback are visible; upload executes once | C0+C1 |
| DT13 | sync action fails | Drive sync action returns failed result | user confirms the action | safe failure feedback is visible; retry remains available | C1 |
| DT14 | restore selected | Drive sync has a remote snapshot | user selects restore from the sync sheet | destructive restore warning appears and restore has not executed yet | C0+C1 |
| DT14b | restore fails | restore returns failed result | user confirms restore warning | safe failure feedback is visible; restore executes once | C1 |
| DT15 | upload confirmation canceled | upload confirmation is open | user taps Cancel | upload does not execute | C1 |
| DT15b | restore confirmation canceled | restore warning is open | user taps Cancel | restore does not execute | C1 |

