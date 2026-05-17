# Integration Test Robot Harness

MemoX keeps one Flutter integration entrypoint:

```txt
integration_test/app_test.dart
```

That entrypoint validates `IntegrationTestWidgetsFlutterBinding` and registers
intentional feature flow modules from:

```txt
integration_test/cases/**
```

Robot helpers and app-pump configuration remain in:

```txt
integration_test/test_app.dart
integration_test/robots/**
```

Folder flow coverage is restored in:

```txt
integration_test/cases/folder_flow_test.dart
docs/decision-tables/integration_test/cases/folder_flow_test.md
```

When adding more E2E coverage, keep new modules under
`integration_test/cases/**`, import them from `integration_test/app_test.dart`,
and add matching Decision Table rows under this directory in the same change.
