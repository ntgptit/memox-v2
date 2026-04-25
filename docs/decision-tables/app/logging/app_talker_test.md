# Decision Tables: app_talker_test

Test file: `test/app/logging/app_talker_test.dart`

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | local-like diagnostics environment should create a Talker-backed Riverpod observer | logging setup is requested for an environment that allows local diagnostics | observer factory builds the Riverpod observer list | a Talker observer is created for provider diagnostics | C0+C1 |

## Decision table: logEvent

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | non-local diagnostics environment should not attach Riverpod diagnostics | logging setup is requested for an environment outside the local-like allowlist | observer factory builds the Riverpod observer list | no Talker observer is attached | C0+C1 |
