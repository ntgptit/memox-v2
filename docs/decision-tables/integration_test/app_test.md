# Decision Tables: app_test

Test file: `integration_test/app_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | integration entrypoint initializes the robot harness before registering imported flow cases | app test imports the folder, deck, and flashcard flow case modules | integration binding initializes before robot flows execute | integration binding exists so folder, deck, and flashcard robot cases can pump the app through the shared harness | C0+C1 |
