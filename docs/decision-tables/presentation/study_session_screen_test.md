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
| DT3 | session is in progress and has a current review-mode item | snapshot has `StudyMode.review`, one current item, and one review flashcard | session screen renders active review branch | title `Review`, text settings/audio/more actions, edit/audio card actions, and both card faces are visible | C0+C1 |
| DT4 | review-mode local page index starts at the first card | snapshot has `StudyMode.review` and one review flashcard | review branch renders the progress row | progress label shows `0%` | C0+C1 |
| DT5 | review-mode branch replaces the old grading panel | snapshot has `StudyMode.review` and one review flashcard | review branch renders | `Forgot`, `Remembered`, and `Skip card` are not visible | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | single-card review is already on the last page and auto-submit timer reaches two seconds | review snapshot has exactly one card and repo fake counts batch submits | the first review page remains mounted for two seconds | repo receives one batch submit with `AttemptGrade.remembered` | C0+C1 |
| DT2 | multi-card review has not reached the last card until the user swipes | review snapshot has two cards and repo fake counts batch submits | first page waits two seconds, then user swipes to the last page and waits two more seconds | no batch submit happens on the first page; exactly one batch submit happens after the last-page delay | C0+C1 |
