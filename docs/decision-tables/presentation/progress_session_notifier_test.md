# Decision Tables: progress_session_notifier_test

Test file: `test/presentation/progress_session_notifier_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | active session query succeeds | repository fake has one active in-progress session | `progressStudySessionsProvider.future` is read | provider returns that active session id | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | cancel action succeeds for an active session | repository fake records cancel calls | progress action controller cancels `session-1` | result is true, repo receives one cancel call, and controller state has no error | C0+C1 |
| DT2 | finalize action succeeds for a ready session | repository fake records finalize calls and snapshot has `readyToFinalize` | progress action controller finalizes the snapshot | result is true, repo receives one finalize call with the session study type, and controller state has no error | C0+C1 |
| DT3 | retry finalize action succeeds for a failed finalize session | repository fake records retry calls and snapshot has `failedToFinalize` | progress action controller retries finalize for the snapshot | result is true, repo receives one retry call with the session study type, and controller state has no error | C0+C1 |
