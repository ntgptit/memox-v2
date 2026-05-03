# Decision Tables: app_reload_service_test

Test file: `test/core/services/app_reload_service_test.dart`

## Decision table: if

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | conditional app reload service factory is used | test runtime imports the non-web platform implementation through the conditional factory | `createAppReloadService` returns a service and `reload` is called | returned object implements `AppReloadService`, non-web reload is safe no-op, and web/stub source stems are covered by the shared factory test | C0+C1 |
