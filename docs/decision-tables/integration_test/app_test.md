# Decision Tables: app_test

Test file: `integration_test/app_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | integration entrypoint initializes robot harness only | app test starts without imported flow case modules | integration binding initializes before robot flows are registered | integration binding exists and no feature journey is executed | C0+C1 |
