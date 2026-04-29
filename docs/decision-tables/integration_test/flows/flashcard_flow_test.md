# Decision Tables: app_test flashcard flow

Test file: `integration_test/app_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT5 | flashcard list route points to a deck id that is missing from local storage | the in-memory database is empty and the initial route is `/library/deck/e2e-missing-deck/flashcards` | the flashcard-list provider loads the route id | `Something went wrong` and `Deck not found.` are rendered without an uncaught widget exception | C0+C1 |
| DT6 | flashcard edit route points to a missing flashcard inside an existing deck | `E2E Editor Error Deck` exists but contains no flashcards | the editor provider loads `/flashcards/e2e-missing-card/edit` | `Something went wrong` and `Flashcard not found.` are rendered without an uncaught widget exception | C0+C1 |

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT7 | opened empty deck accepts a flashcard with front and back text | `E2E Card Deck` is open and renders `No flashcards yet` | the user opens `Add flashcard`, enters `E2E Card Front` and `E2E Card Back`, then saves | the flashcard list renders both texts without widget exceptions | C0+C1 |
| DT8 | create-next flow keeps the current deck context after saving a card | `E2E Card Deck` is open and the user starts creating the first card | the user saves `E2E First Next Front` with `Save & add next`, then creates `E2E Second Next Front` | both flashcards are visible in the same deck list and no route context is lost | C0+C1 |
| DT9 | blank front and back are rejected before a flashcard is created | `E2E Card Deck` is open and the new-flashcard editor has empty front and back fields | the user presses `Save flashcard` without entering text | the validation message `front and back are required.` is shown and the user remains on the editor | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT3 | flashcard list contains a card row that can be opened for read/display | `E2E Read Front` and `E2E Read Back` exist in the opened deck | the user taps the flashcard row | the edit screen renders both existing texts for review without widget exceptions | C0+C1 |
| DT6 | flashcard list displays both front and back text after a successful create | `E2E Card Deck` is open and initially renders `No flashcards yet` | the user creates `E2E Row Front` with back `E2E Row Back` | the flashcard list renders both new row texts without widget exceptions | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT6 | opened flashcard edit screen saves changed front and back text | `E2E Before Front` is open in edit mode with an existing back value | the user replaces the front with `E2E After Front`, replaces the back with `E2E After Back`, and saves changes | the flashcard list renders the updated front and back while the old front is absent | C0+C1 |

## Decision table: onDelete

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT5 | existing flashcard deletion is confirmed through the row action sheet | `E2E Delete Front` exists in the opened deck list | the user long-presses the row, chooses `Delete`, and confirms `Delete flashcards` | the flashcard row is absent and the deck returns to `No flashcards yet` without widget exceptions | C0+C1 |
| DT6 | destructive dialog cancellation must keep the selected flashcard | `E2E Keep Card Front` exists in the opened deck list | the user opens `Delete flashcards` and presses `Cancel` | `E2E Keep Card Front` remains visible without widget exceptions | C0+C1 |
| DT7 | bulk delete applies only to selected flashcards and removes them together after confirmation | `E2E Bulk First` and `E2E Bulk Second` are selected in the same deck list | the user presses bulk `Delete` and confirms `Delete flashcards` | both selected cards are removed and the deck returns to `No flashcards yet` | C0+C1 |

## Decision table: onMove

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | selected flashcard move requires one valid target deck and removes the card from the source deck | `E2E Source Deck` and `E2E Target Deck` exist in the same folder, and `E2E Move Front` is selected in the source deck | the user chooses bulk `Move` and selects `E2E Target Deck` | the source deck becomes empty and `E2E Move Front` is visible after opening the target deck | C0+C1 |

## Decision table: onSelect

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | row action sheet selection enters bulk-selection mode without mutating card content | `E2E Select Front` exists in the opened deck list | the user opens the row action sheet and chooses `Select` | `1 selected` is visible and `E2E Select Front` remains in the list | C0+C1 |

## Decision table: onSearchFilterSort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT4 | flashcard search matches the back text as well as the front display text | `E2E Search Alpha` has back `Shared Back` and `E2E Search Beta` has back `Unique Back Needle` | the user searches for `Needle` | only `E2E Search Beta` remains visible in the filtered flashcard list | C0+C1 |
| DT7 | clearing a flashcard search restores the original deck list rows | `E2E Restore Front` exists in the opened deck and the search term has no matching card | the user clears the flashcard search field | `E2E Restore Front` becomes visible again without widget exceptions | C0+C1 |
| DT11 | flashcard search matches front text directly | `E2E Front Needle` and `E2E Front Haystack` both exist in the opened deck | the user searches for `Needle` | `E2E Front Needle` remains visible and `E2E Front Haystack` is removed from the filtered result | C0+C1 |
