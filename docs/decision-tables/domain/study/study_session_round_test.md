# Decision Tables: study_session_round_test

Test file: `test/domain/study/study_session_round_test.dart`

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | current round list is empty and a current item exists | snapshot has `currentRoundItems=[]`, one pending current item, two session cards, and New Study flow has five modes | local round helpers are evaluated | helper returns the current item as the only local item, initial index is zero, round key includes the item id, and overall progress adds one local correct answer over ten total New Study mode-card units | C0+C1 |

## Decision table: onSearchFilterSort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | current round contains mixed status items out of queue order | snapshot has two pending items and one completed item with queue positions `3`, `2`, and `1` | local round helper filters and sorts the round | completed item is excluded, pending items are returned in queue order, initial index points at the current item, and round key follows sorted ids | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | session type is SRS review instead of New Study | snapshot has `StudyType.srsReview`, two session cards, and one locally correct answer | overall progress is evaluated | SRS review uses a single-mode denominator, so one local correct answer over two cards returns 50% instead of New Study's five-mode denominator | C0+C1 |
| DT2 | persisted and local answers include incorrect grades | snapshot has four persisted attempts but only two persisted correct attempts, and local staged grades contain one `correct` plus one `incorrect` | display-ready study mode progress is evaluated from staged grades | progress counts only the three correct units over ten total mode-card units, returns 30%, and ignores the incorrect persisted/local answers | C0+C1 |
| DT3 | persisted plus local correct answers exceed total mode-card units | snapshot has one total mode-card unit that is already correct and one additional local correct answer | display-ready study mode progress is evaluated | progress value is clamped to 1.0 and percent is clamped to 100 | C0+C1 |
