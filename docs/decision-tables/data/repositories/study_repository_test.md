# Decision Tables: study_repository_test

Test file: `test/data/repositories/study_repository_test.dart`

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | new-study session uses five modes and all attempts are correct | deck has eligible new cards and session flow includes the five learning modes | repository starts the session, answers all queued items correctly, and finalizes | session completes and flashcard advances to SRS box 2 | C0+C1 |
| DT2 | New Study is requested from the today entry point | today entry has only due cards available | start session is requested with `studyType=newStudy` and `entryType=today` | request fails because today supports SRS Review only in v1 | C0+C1 |
| DT3 | SRS Review is requested from the today entry point | global pool contains a new card, a due card, and an overdue card | start session is requested with today SRS Review | session batch contains only due and overdue cards from the daily pool | C0+C1 |
| DT4 | folder entry contains cards in nested deck folders | parent folder has a child folder that contains a deck with new cards | New Study starts from the parent folder | recursive folder scope loads cards from the child deck | C0+C1 |

## Decision table: repositoryFlow

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | skip action is requested for the current item | session has a pending current item | repository skips that item | item is requeued without recording a passing attempt | C0+C1 |
| DT2 | New Study answer fails in the current mode | new-study session has one pending Review item | repository records an incorrect answer | same flashcard is requeued in Review round 2 and no SRS progress is committed | C0+C1 |
| DT3 | SRS Review answer is incorrect before later passing | due card starts in box 4 | repository records incorrect, then correct, and finalizes | review result is recovered, box decreases by one, and lapse count increments once | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | finalize is requested for a session already completed by another path | stored session status is completed before stale finalize runs | repository finalize path executes | session is not marked failed | C0+C1 |
| DT2 | cancel is requested for a completed session | stored session status is completed | repository cancel path executes | completed session remains completed and is not overwritten as cancelled | C0+C1 |
| DT3 | restart is requested for an existing session | previous session is active and a new eligible batch exists | repository restarts the session | previous session is cancelled and new session links `restartedFromSessionId` to the old session | C0+C1 |
| DT4 | SRS Review answer is correct on first attempt | due card starts in box 4 and no failing attempts are recorded | repository finalizes the review session | review result is perfect, box increases to 5, and due date uses the box 5 interval | C0+C1 |
| DT5 | due pool exceeds review batch size and overdue priority is enabled | daily pool has one due card and one overdue card with batch size 1 | repository starts SRS Review | overdue card is selected before due card | C0+C1 |
| DT6 | cancel is requested for an in-progress session | session has pending items and recorded attempts may be absent | repository cancels the session | status becomes cancelled and pending items are abandoned | C0+C1 |

## Decision table: onRefreshRetry

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | SRS review answer is forgot and should retry in box 1 | due card is loaded in SRS review flow | repository records forgot attempt and finalizes the session | review is treated as retry and flashcard remains or moves to box 1 | C0+C1 |
| DT2 | New Study has no eligible new cards | deck contains only already learned cards with due dates | start session is requested for New Study | request fails with no eligible flashcards and no session is created | C0+C1 |
| DT3 | deck entry is missing an entry reference | study context has `entryType=deck` and null `entryRefId` | start session is requested | request fails fast with a validation error before a session is created | C0+C1 |
