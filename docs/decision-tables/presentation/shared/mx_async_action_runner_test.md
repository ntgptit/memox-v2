# Decision Tables: mx_async_action_runner_test

Test file: `test/presentation/shared/mx_async_action_runner_test.dart`

## Decision table: runResult

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | result action succeeds | runner is mounted and action returns `Success` | result action is executed | states move from loading to data, success callback receives the value, and the method returns true | C0+C1 |
| DT2 | result action returns failure | runner is mounted and action returns `FailureResult` with an `AppFailure` | result action is executed | states move from loading to error with the same failure and the method returns false | C0+C1 |
| DT3 | result action completes after disposal | runner reports unmounted after the awaited action returns | result action is executed | loading is kept, no success state is emitted, and the method returns false | C0+C1 |

## Decision table: run

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | action throws a domain exception | runner is mounted and action throws a validation exception | throwing action is executed | states move from loading to an `AppFailure` error mapped by `ErrorMapper` and the method returns false | C0+C1 |
