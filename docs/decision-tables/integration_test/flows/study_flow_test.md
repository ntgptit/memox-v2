# Decision Tables: app_test study flow

Test file: `integration_test/app_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT7 | study session route points to a missing session id and the provider throws during load | the in-memory database contains no study session for `e2e-missing-session` | the study-session provider loads the initial route | `Something went wrong` and `Study action failed.` are rendered without an uncaught widget exception | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT4 | study entry renders default flow and session settings before a session is created | the seeded deck route contains `E2E Entry Prompt` and the flashcard list exposes `Study now` | the user opens the study entry screen but does not confirm the start action | `Start a study session`, `New Study`, `SRS Review`, `Batch size: 10`, and all session toggles are visible | C0+C1 |
| DT7 | seeded flashcard list displays the study entry action before navigation | the seeded deck route contains `E2E Action Prompt` and at least one flashcard exists | the flashcard list route renders | the flashcard front and `Study now` action are visible without widget exceptions | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT7 | study entry batch-size controls mutate only the pending session settings snapshot | the seeded deck route opens the study entry screen with `Batch size: 10` | the user decreases the batch size and then increases it again | the UI shows `Batch size: 9` after decrement and restores `Batch size: 10` after increment without starting a session | C0+C1 |
| DT8 | study entry lets the user switch from new-study flow to SRS review flow before starting | the seeded deck route opens the study entry screen with both flow segments visible | the user selects `SRS Review` | the study entry remains open with the `SRS Review` segment available and no session is started | C0+C1 |
| DT9 | study entry toggles session settings locally without creating a session | the seeded deck route opens the study entry screen with all three setting toggles visible | the user toggles shuffle flashcards, shuffle answers, and prioritize overdue | the session settings section remains visible and the user stays on the study entry screen | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | flashcard list has at least one card, so `Study now` is enabled and starts a new-study session | the in-memory database contains `E2E Study Deck` with flashcard front `E2E Prompt` and back `E2E Answer` | the robot opens the seeded flashcard list, taps `Study now`, confirms the study entry action, and waits for the session | review mode shows `Review`, `E2E Prompt`, and `E2E Answer`, with no widget exception recorded | C0+C1 |
