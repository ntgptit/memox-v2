# Integration Test Robot Harness

The executable E2E test cases for `integration_test/app_test.dart` are
currently cleared. Keep this area as the robot-test harness only until new E2E
coverage is added intentionally.

MemoX keeps one Flutter integration entrypoint:

```txt
integration_test/app_test.dart
```

That entrypoint only validates `IntegrationTestWidgetsFlutterBinding` for the
robot harness. No app flow or feature journey is registered. Robot helpers and
app-pump configuration remain in:

```txt
integration_test/test_app.dart
integration_test/robots/**
```

When executable E2E cases are restored, add module files under
`integration_test/cases/**`, import them from `integration_test/app_test.dart`,
and add matching Decision Table rows under this directory in the same change.
