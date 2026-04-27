# Decision Tables: study_repository_test

Test file: `test/data/repositories/study_repository_test.dart`

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | new-study session uses five modes and all attempts are correct | deck has eligible new cards and session flow includes the five learning modes | repository starts the session, answers all queued items correctly, and finalizes | session completes and flashcard advances to SRS box 2 | C0+C1 |
| DT2 | New Study is requested from the today entry point | today entry has only due cards available | start session is requested with `studyType=newStudy` and `entryType=today` | request fails because today supports SRS Review only in v1 | C0+C1 |
| DT3 | SRS Review is requested from the today entry point | global pool contains a new card, a due card, and an overdue card | start session is requested with today SRS Review | session batch contains only due and overdue cards from the daily pool | C0+C1 |
| DT4 | folder entry contains cards in nested deck folders | parent folder has a child folder that contains a deck with new cards | New Study starts from the parent folder | recursive folder scope loads cards from the child deck | C0+C1 |

## Decision table: loadBatch

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | flashcard shuffle is disabled | deck has four eligible new cards with ascending sort order and batch size two | New Study loads the batch | first two sorted cards are selected in query order | C0+C1 |
| DT2 | flashcard shuffle is enabled for New Study | deck has eight eligible new cards and the repository RNG has advancing state | New Study loads two batches with the same deck and settings | second ordered batch differs from the first because shuffle uses RNG state instead of a stable entry seed | C0+C1 |
| DT3 | SRS Review keeps overdue priority while shuffling | deck has two overdue cards, two due cards, batch size three, shuffle enabled, and overdue priority enabled | SRS Review loads the batch | overdue cards occupy the first two selected positions and one due card follows | C0+C1 |

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | New Study session insert writes session settings and initial Review queue | deck has two eligible new cards and New Study settings set batch size, shuffle flags, and overdue priority | start session is executed for the deck | `study_sessions` stores every session column with the requested settings, `study_session_items` stores every Review item column for both cards, `study_attempts` stays empty, and `flashcard_progress` remains unchanged | C0+C1 |
| DT2 | Review batch submit writes attempts, completes Review items, and inserts the next Match queue | deck New Study has two pending Review items | batch Review submit records `correct` for the current mode | `study_sessions` remains in progress, each Review item stores completed status and completed timestamp, each attempt stores ids/card/result/attempt number/SRS summary columns, each Match item stores pending queue columns, and `flashcard_progress` remains unchanged | C0+C1 |
| DT3 | Match batch submit writes per-item grades, completes Match items, and inserts only failed retry rows | deck New Study has two pending Match items after Review, and the submitted map marks card 1 `incorrect` and card 2 `correct` | batch Match submit records the current board result | `study_sessions` remains in progress, each Match item stores completed status and timestamp, attempts store the exact per-item results and numbers, retry Match round contains only card 1, and `flashcard_progress` remains unchanged | C0+C1 |

## Decision table: repositoryFlow

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | skip action is requested for the current item | session has a pending current item | repository skips that item | item is requeued without recording a passing attempt | C0+C1 |
| DT2 | New Study answer fails in the current mode | new-study session has one pending Review item | repository records an incorrect answer | same flashcard is requeued in Review round 2 and no SRS progress is committed | C0+C1 |
| DT3 | SRS Review answer is incorrect before later passing | due card starts in box 4 | repository records incorrect, then correct, and finalizes | review result is recovered, box decreases by one, and lapse count increments once | C0+C1 |
| DT4 | Review mode batch submit is requested for all pending items in the current Review round | new-study session has two pending Review items | repository batch answer runs with `grade=correct` | two correct attempts are inserted and both Review items become completed | C0+C1 |
| DT5 | Review mode batch submit completes the first New Study mode | new-study session has one pending Review item and Match is the next configured mode | repository batch answer runs with `grade=correct` | session remains in progress and current item advances to `StudyMode.match` with `modeOrder=2` | C0+C1 |
| DT6 | Review batch submit is called after the session has already advanced to Match | new-study session has passed Review and current item is Match | repository batch answer is requested again | request fails fast with validation instead of writing another batch | C0+C1 |
| DT7 | Review batch submit is called after the session is terminal | new-study session has completed all modes and finalized to `completed` | repository batch answer is requested | request fails fast with validation and terminal status is not reopened | C0+C1 |
| DT8 | Match mode batch submit is all correct | new-study session has two pending Match items and Guess is the next configured mode | repository match batch runs with both item ids mapped to `correct` | session remains in progress and current item advances to `StudyMode.guess` with `modeOrder=3` | C0+C1 |
| DT9 | Match mode batch submit contains one incorrect item | new-study session has two pending Match items and one item id is mapped to `incorrect` | repository match batch completes current round | current item stays in `StudyMode.match`, round advances to retry round 2, and only the incorrect flashcard is pending | C0+C1 |
| DT10 | Match batch submit is called outside Match mode | new-study session is still in Review mode | repository match batch is requested | request fails fast with validation and no attempts are inserted | C0+C1 |
| DT11 | Match batch submit omits or adds a pending item id | new-study session has two pending Match items | repository match batch is requested with one missing id or one extra id | request fails fast with validation and the pending Match items remain unchanged | C0+C1 |
| DT12 | Match batch submit uses a grade that is not `correct` or `incorrect` | new-study session has pending Match items | repository match batch is requested with `correct` for one item | request fails fast with validation and no attempts are inserted | C0+C1 |
| DT13 | Guess mode item batch contains one incorrect and one correct item | new-study session has passed Review and Match, leaving two pending Guess items | repository mode item batch records `incorrect` for card 1 and `correct` for card 2 | each Guess item stores completed status and timestamp, attempts store exact ids/results/attempt numbers, retry Guess round contains only card 1, and `flashcard_progress` remains unchanged | C0+C1 |
| DT14 | Recall mode item batch contains one incorrect and one correct item | new-study session has passed Review, Match, and Guess, leaving two pending Recall items | repository mode item batch records `incorrect` for card 1 and `correct` for card 2 | Recall attempts store exact ids/results/attempt numbers, current item remains Recall retry round 2, and retry round contains only card 1 | C0+C1 |
| DT15 | Fill mode item batch completes the last New Study mode | new-study session has passed Review, Match, Guess, and Recall, leaving two pending Fill items | repository mode item batch records both Fill items as `correct` | session status becomes `ready_to_finalize`, ended timestamp is stored, Fill item and attempt rows store exact final-mode fields, and SRS progress is still unchanged until finalize | C0+C1 |

## Decision table: listActiveSessions

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | session list contains active and terminal statuses | stored sessions include `inProgress`, `readyToFinalize`, `failedToFinalize`, `completed`, and `cancelled` statuses with different start times | repository lists active sessions | only the three resumable/manageable statuses are returned, ordered by newest `startedAt` first | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | finalize is requested for a session already completed by another path | stored session status is completed before stale finalize runs | repository finalize path executes | session is not marked failed | C0+C1 |
| DT2 | cancel is requested for a completed session | stored session status is completed | repository cancel path executes | completed session remains completed and is not overwritten as cancelled | C0+C1 |
| DT3 | restart is requested for an existing session | previous session is active and a new eligible batch exists | repository restarts the session | previous `study_sessions` row stores cancelled status and ended timestamp, previous pending item row stores abandoned status, new `study_sessions` row stores every requested setting plus `restarted_from_session_id`, and new Review item row stores every queue column | C0+C1 |
| DT4 | SRS Review answer is correct on first attempt | due card starts in box 4 and no failing attempts are recorded | repository finalizes the review session | `study_sessions`, `study_session_items`, `study_attempts`, and `flashcard_progress` store every final field for a perfect review: completed status, completed item timestamp, attempt SRS summary, box 5, perfect result, and box 5 due date | C0+C1 |
| DT5 | due pool exceeds review batch size and overdue priority is enabled | daily pool has one due card and one overdue card with batch size 1 | repository starts SRS Review | overdue card is selected before due card | C0+C1 |
| DT6 | cancel is requested for an in-progress session | session has pending items and recorded attempts may be absent | repository cancels the session | `study_sessions` stores cancelled status and ended timestamp, and each pending `study_session_items` row stores abandoned status with all queue fields unchanged | C0+C1 |

## Decision table: onRefreshRetry

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | SRS review answer is incorrect and should retry in box 1 | due card is loaded in SRS review flow | repository records incorrect attempt and finalizes the session | review is treated as retry and flashcard remains or moves to box 1 | C0+C1 |
| DT2 | New Study has no eligible new cards | deck contains only already learned cards with due dates | start session is requested for New Study | request fails with no eligible flashcards and no session is created | C0+C1 |
| DT3 | deck entry is missing an entry reference | study context has `entryType=deck` and null `entryRefId` | start session is requested | request fails fast with a validation error before a session is created | C0+C1 |
