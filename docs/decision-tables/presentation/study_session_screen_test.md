# Decision Tables: study_session_screen_test

Test file: `test/presentation/study_session_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `studySessionStateProvider(sessionId)` is unresolved and session screen enters loading branch | study session route opens with a pending `Completer<StudySessionSnapshot>` | the first frame is pumped before the future completes | `MxLoadingState` is rendered exactly once | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | session is in progress and has a current guess-mode item | snapshot has `SessionStatus.inProgress`, one current item, `StudyMode.guess`, round one, and one remaining card | session screen renders active branch | `Guess · round 1`, `front 1`, `Correct`, and `Skip card` are visible | C0+C1 |
| DT2 | session is terminal and has no current item | snapshot has `SessionStatus.completed`, `currentItem=null`, and no session flashcards | session screen renders terminal branch | `This session has ended.` and `View result` are visible | C0+C1 |
