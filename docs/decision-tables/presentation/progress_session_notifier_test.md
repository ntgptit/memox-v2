# Decision Tables: progress_session_notifier_test

Test file: `test/presentation/progress_session_notifier_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | active session query succeeds | repository fake has one active in-progress session | `progressStudySessionsProvider.future` is read | provider returns that active session id | C0+C1 |
| DT2 | progress overview query succeeds | content repository fake returns overdue, due today, new-card, folder card-count, and mastery data while study repository fake returns active, ready, and failed sessions | `progressOverviewProvider.future` is read | provider exposes review pressure, new-card count, weighted mastery, total cards, active session count, ready session count, and failed session count | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | cancel action succeeds for an active session | repository fake records cancel calls | progress action controller cancels `session-1` | result is true, repo receives one cancel call, and controller state has no error | C0+C1 |
| DT2 | finalize action succeeds for a ready session | repository fake records finalize calls and snapshot has `readyToFinalize` | progress action controller finalizes the snapshot | result is true, repo receives one finalize call with the session study type, and controller state has no error | C0+C1 |
| DT3 | retry finalize action succeeds for a failed finalize session | repository fake records retry calls and snapshot has `failedToFinalize` | progress action controller retries finalize for the snapshot | result is true, repo receives one retry call with the session study type, and controller state has no error | C0+C1 |
| DT4 | terminal mutation from Progress must refresh cached Study Entry resume state | Study Entry provider has cached an active deck resume candidate and Progress finalizes the same ready session | progress action controller finalizes the ready snapshot and Study Entry state is read again | result is true, fake repo resume-candidate load count increases from one to two, and refreshed Study Entry state has no resume candidate | C0+C1 |
