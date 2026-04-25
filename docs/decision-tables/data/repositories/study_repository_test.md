# Decision Tables: study_repository_test

Test file: `test/data/repositories/study_repository_test.dart`

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | new-study session uses five modes and all attempts are correct | deck has eligible new cards and session flow includes the five learning modes | repository starts the session, answers all queued items correctly, and finalizes | session completes and flashcard advances to SRS box 2 | C0+C1 |

## Decision table: repositoryFlow

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | skip action is requested for the current item | session has a pending current item | repository skips that item | item is requeued without recording a passing attempt | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | finalize is requested for a session already completed by another path | stored session status is completed before stale finalize runs | repository finalize path executes | session is not marked failed | C0+C1 |
| DT2 | cancel is requested for a completed session | stored session status is completed | repository cancel path executes | completed session remains completed and is not overwritten as cancelled | C0+C1 |
| DT3 | restart is requested for an existing session | previous session is active and a new eligible batch exists | repository restarts the session | previous session is cancelled and new session links `restartedFromSessionId` to the old session | C0+C1 |

## Decision table: onRefreshRetry

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | SRS review answer is forgot and should retry in box 1 | due card is loaded in SRS review flow | repository records forgot attempt and finalizes the session | review is treated as retry and flashcard remains or moves to box 1 | C0+C1 |
