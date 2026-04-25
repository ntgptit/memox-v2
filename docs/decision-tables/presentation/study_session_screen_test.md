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
| DT4 | review-mode local page index starts at the first card and progress row uses larger synchronized sizing | snapshot has `StudyMode.review` and one review flashcard | review branch renders the progress row | progress label shows `0%`, the linear progress track uses the large height, and the percent label uses the larger review progress text role | C0+C1 |
| DT5 | review-mode branch replaces the old grading panel | snapshot has `StudyMode.review` and one review flashcard | review branch renders | `Forgot`, `Remembered`, and `Skip card` are not visible | C0+C1 |
| DT6 | review faces use fixed larger non-heavy typography | one review snapshot has a short front/back pair and another has a long back text | review branch renders the first card and then moves to the second card | front text is larger with medium weight, and both short and long answer texts keep the same regular-weight visible style | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | single-card review is already on the last page and auto-submit timer reaches two seconds | review snapshot has exactly one card and repo fake counts batch submits | the first review page remains mounted for two seconds | repo receives one batch submit with `AttemptGrade.remembered` | C0+C1 |
| DT2 | web mouse right-to-left drag advances review vocabulary and only the last card can auto-submit | review snapshot has two cards and repo fake counts batch submits | first page waits two seconds, then mouse drag moves from right to left to the last page and waits two more seconds | the visible vocabulary changes from card 1 to card 2; no batch submit happens on the first page; exactly one batch submit happens after the last-page delay | C0+C1 |
| DT3 | web mouse wheel scroll advances review vocabulary | review snapshot has two cards and repo fake counts batch submits | pointer scroll event fires over the review page with positive wheel delta | the visible vocabulary changes from card 1 to card 2 and no batch submit happens before the two-second last-page delay | C0+C1 |
