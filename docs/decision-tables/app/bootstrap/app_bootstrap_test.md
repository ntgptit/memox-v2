# Decision Tables: app_bootstrap_test

Test file: `test/app/bootstrap/app_bootstrap_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | bootstrap error formatting receives a `package:stack_trace` chain and must demangle it before reporting | a chained stack trace is created with package-stack-trace frames | bootstrap error handler formats the stack trace | output contains the demangled Dart stack trace representation expected by Flutter error handling | C0+C1 |
