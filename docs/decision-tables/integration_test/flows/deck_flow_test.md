# Decision Tables: app_test deck flow

Test file: `integration_test/app_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT4 | flashcard-list route points to a deck id that is missing from local storage | the in-memory database is empty and the initial route is `/library/deck/e2e-missing-deck/flashcards` | the flashcard list provider loads the route id | `Something went wrong` and `Deck not found.` are rendered without an uncaught widget exception | C0+C1 |

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT4 | unlocked root folder accepts the deck branch when the user chooses `New deck` | `E2E Deck Folder` is open and shows the unlocked empty-folder state | the user taps `New deck`, enters `E2E Deck`, and confirms | `E2E Deck` is visible in the folder detail list and no widget exception is recorded | C0+C1 |
| DT5 | deck-mode folder accepts another sibling deck and blocks subfolder creation UI | `E2E Multi Deck Folder` already contains `E2E First Deck` | the user creates `E2E Second Deck` in the same folder | both deck rows are visible and `New subfolder` is absent from the folder actions | C0+C1 |
| DT6 | create-deck dialog cancellation must not mutate the folder | `E2E Deck Cancel Folder` is open in the unlocked empty-folder state | the user opens `Create deck`, enters `E2E Cancelled Deck`, and presses `Cancel` | the folder remains empty and `E2E Cancelled Deck` is absent | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT2 | folder detail contains a deck row that can be opened for read/display | `E2E Read Deck` exists inside `E2E Deck Read Folder` | the user taps the deck row | the flashcard list renders `E2E Read Deck` and `No flashcards yet` without widget exceptions | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT3 | opened deck accepts a non-blank rename through its action sheet | `E2E Deck Before` is open on the deck flashcard-list route | the user opens `More actions`, chooses `Edit`, enters `E2E Deck After`, and saves | `E2E Deck After` replaces the old deck title without widget exceptions | C0+C1 |
| DT4 | duplicate deck copies the source flashcards into a new deck in a valid target folder | `E2E Source Deck` contains one flashcard and is open on the flashcard-list route | the user chooses `Duplicate deck` and selects `Current folder` as the target | `E2E Source Deck Copy` opens on its flashcard-list route and renders the copied front/back text | C0+C1 |
| DT5 | rename cancellation must preserve the current deck metadata | `E2E Stable Deck` is open on the deck flashcard-list route | the user opens `Rename deck`, enters `E2E Ignored Deck`, and presses `Cancel` | `E2E Stable Deck` remains visible and `E2E Ignored Deck` is absent | C0+C1 |

## Decision table: onDelete

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT3 | opened deck deletion is confirmed through the destructive dialog | `E2E Delete Deck` is open on the deck flashcard-list route | the user opens `More actions`, chooses `Delete`, and confirms `Delete deck` | the route returns to `E2E Deck Delete Folder`, the folder body is empty, and `E2E Delete Deck` is absent | C0+C1 |
| DT4 | destructive dialog cancellation must keep the deck and its flashcards | `E2E Keep Deck` contains `E2E Keep Front` and is open on the flashcard-list route | the user opens `Delete deck` and presses `Cancel` | the deck remains open and `E2E Keep Front` is still visible | C0+C1 |

## Decision table: onSearchFilterSort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT3 | folder-level deck search filters deck rows by normalized deck name | `E2E Alpha Deck` and `E2E Beta Deck` both exist in `E2E Deck Search Folder` | the user types `Beta` into the folder search field | `E2E Beta Deck` remains visible and `E2E Alpha Deck` is removed from the filtered result | C0+C1 |
| DT6 | clearing a folder-level deck search restores the deck row list | `E2E Restore Deck` exists in `E2E Deck Restore Folder` and the search term has no matching deck | the user clears the folder search field | `E2E Restore Deck` becomes visible again without widget exceptions | C0+C1 |
| DT9 | folder-level deck search matches deck names case-insensitively | `E2E Mixed Case Deck` and `E2E Other Deck` both exist in `E2E Deck Case Folder` | the user searches for lowercase `mixed case` | `E2E Mixed Case Deck` remains visible and `E2E Other Deck` is removed from the filtered result | C0+C1 |
| DT10 | unmatched folder-level deck search renders the no-results state instead of stale deck rows | `E2E Searchable Deck` exists in `E2E Deck Empty Search Folder` | the user searches for `No matching deck` | `No matching items` is visible and `E2E Searchable Deck` is absent from the filtered result | C0+C1 |
