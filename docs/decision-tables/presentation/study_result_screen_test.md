# Decision Tables: study_result_screen_test

Test file: `test/presentation/study_result_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `studySessionStateProvider(sessionId)` is unresolved and result screen enters loading branch | result route opens with a pending `Completer<StudySessionSnapshot>` | the first frame is pumped before the future completes | `MxLoadingState` is rendered exactly once | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | session status is completed and card outcome differs from attempt accuracy after retries | snapshot has `SessionStatus.completed`, total cards four, mastered cards four, six completed attempts, five correct attempts, and two retry cards | result screen renders loaded data | `Session summary`, `Completed`, `Cards mastered: 4/4`, `Attempt accuracy`, `83%`, `Retry cards`, `Review more`, and `Study again` are visible, while the ambiguous `Accuracy` label is absent | C0+C1 |
| DT2 | session status is cancelled and must use a distinct status label | snapshot has `SessionStatus.cancelled` with the same summary metrics | result screen renders loaded data | `Cancelled` is visible and `Completed` is absent | C0+C1 |
