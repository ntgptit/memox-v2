# Decision Tables: deck_flow_test

Test file: `integration_test/cases/deck_flow_test.dart`

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-DECK-001 empty folder accepts its first deck and changes folder mode to decks | folder `Korean` exists with no child content | user opens `Korean`, creates deck `Daily Words`, and returns to the folder list | `Daily Words` is visible, the folder stores `content_mode=decks`, and only deck creation remains available | C0+C1 |
| DT2 | TC-DECK-002 deck-mode folder accepts an additional deck | folder `Korean` already contains deck `Daily Words` | user creates deck `Travel Words` from the same folder | both decks are visible in creation order and stored under `Korean` | C0+C1 |
| DT3 | TC-DECK-003 subfolder-mode folder must not expose deck creation | folder `TOPIK` already contains subfolder `Grammar` | user opens the folder creation surface | `New subfolder` remains available while `New deck` is absent | C0+C1 |
| DT4 | TC-DECK-004 create deck dialog receives only whitespace | empty folder `Korean` has an open `Create deck` dialog | user enters spaces into `Deck name` | the `Create` confirm button is disabled and no deck is inserted | C0+C1 |
| DT5 | TC-DECK-005 create deck trims surrounding whitespace | empty folder `Korean` has an open `Create deck` dialog | user enters `  Korean Basics  ` and confirms | deck row and database store `Korean Basics` without surrounding whitespace | C0+C1 |
| DT6 | TC-DECK-023 duplicate deck in the same folder copies flashcard content | deck `Daily Words` contains flashcard `annyeong/hello` | user opens deck actions and duplicates to `Current folder` | `Daily Words Copy` is created in the same folder with copied front/back content | C0+C1 |
| DT7 | TC-DECK-024 duplicate deck must not copy learned SRS progress | source deck flashcard has non-default SRS progress and a due date | user duplicates the deck to `Current folder` | duplicated flashcard starts with box 1, zero reviews/lapses, and no studied/due timestamps | C0+C1 |
| DT8 | TC-DECK-025 duplicate deck can target another valid folder | folder `Archive` is empty and source folder contains `Daily Words` | user duplicates `Daily Words` and selects `Archive` | `Daily Words Copy` is stored under `Archive` | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-DECK-006 folder deck list is scoped to the current folder id | folder `A` has decks `A1`, `A2`, and folder `B` has deck `B1` | user opens folder `A` | only `A1` and `A2` are visible; `B1` is absent | C0+C1 |
| DT2 | TC-DECK-007 empty folder has no decks and can still choose deck direction | folder `Empty Folder` has no subfolders or decks | user opens the folder | empty state appears and the create-choice sheet offers `New deck` | C0+C1 |
| DT3 | TC-DECK-008 deck row exposes basic list information and actions | folder `Korean` contains deck `Daily Words` with one card | user views the folder and long-presses the deck row | row shows deck name and `1 card`; `Deck actions` shows edit, move, duplicate, and delete commands | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-DECK-009 valid deck rename updates name and `updated_at` | deck `Old Name` exists and the test clock advances | user renames it to `New Name` | UI and database use `New Name`, `Old Name` is gone, and `updated_at` is greater than before | C0+C1 |
| DT2 | TC-DECK-010 rename dialog receives only whitespace | deck `TOPIK` has an open rename dialog | user clears the name to spaces | `Save` is disabled and deck `TOPIK` remains stored | C0+C1 |
| DT3 | TC-DECK-011 rename cancellation discards draft text | deck `Daily Words` has an open rename dialog | user types `Daily Words II` and taps `Cancel` | `Daily Words` remains visible and `Daily Words II` is not stored | C0+C1 |

## Decision table: onDelete

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-DECK-012 confirmed delete removes an empty deck | folder `Korean` contains empty deck `Empty Deck` | user confirms `Delete deck` | `Empty Deck` disappears and no deck row remains in storage | C0+C1 |
| DT2 | TC-DECK-013 confirmed delete hard-deletes deck children by cascade | deck `Daily Words` contains flashcard `flashcard-hello` with progress | user confirms `Delete deck` | deck, flashcard, and progress rows are removed | C0+C1 |
| DT3 | TC-DECK-014 delete cancellation keeps deck data | deck `Daily Words` has an open delete confirmation | user taps `Cancel` | deck row stays visible and remains in storage | C0+C1 |
| DT4 | TC-DECK-015 deleting the only deck resets the parent folder direction | folder `Korean` contains exactly one deck | user deletes that deck | folder shows empty state, both create choices are available, and `content_mode=unlocked` | C0+C1 |

## Decision table: onMove

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-DECK-016 manual reorder changes sibling deck order and sort indexes | folder `TOPIK` contains decks `A`, `B`, `C` in manual order | user drags `C` to the top and saves | UI and database order become `C`, `A`, `B` with normalized `sort_order` values | C0+C1 |
| DT2 | TC-DECK-017 reorder is scoped to the current folder | folder `A` and folder `B` each contain decks | user reorders only folder `A` | folder `B` still shows `B1`, `B2` in its original order | C0+C1 |
| DT3 | TC-DECK-019 deck can move into an empty folder and lock it to decks | deck `Daily Words` belongs to folder `A`, folder `B` is empty | user moves `Daily Words` to `B` | deck disappears from `A`, appears in `B`, and `B` stores `content_mode=decks` | C0+C1 |
| DT4 | TC-DECK-020 deck can move into a folder that already contains decks | folder `B` already has `Existing Deck` | user moves `Daily Words` from `A` to `B` | `B` lists `Existing Deck` then `Daily Words`, and the moved deck stores folder id `B` | C0+C1 |
| DT5 | TC-DECK-021 subfolder-mode folders are not valid deck move targets | target folder `B` contains subfolder `Grammar` | user opens move picker for deck `Daily Words` | destination `B` is absent and the deck remains in source folder `A` | C0+C1 |
| DT6 | TC-DECK-022 moving a deck preserves its flashcards and SRS progress | deck `Daily Words` has flashcard `flashcard-hello` with learned progress | user moves the deck from `A` to `B` | deck folder id changes, flashcard id remains in the deck, and progress values are unchanged | C0+C1 |

## Decision table: onExternalChange

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-DECK-018 saved manual deck order survives app restart | file-backed test database contains folder `TOPIK` with decks `A`, `B`, `C` | user reorders to `C`, `A`, `B`, restarts the app, and reopens `TOPIK` | folder still renders decks as `C`, `A`, `B` | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-DECK-026 deck row tap opens flashcard management for that deck | folder `Korean` has deck `Daily Words` with flashcard `annyeong/hello` | user taps the deck row body | deck detail shows `Daily Words` and the deck flashcard content | C0+C1 |
| DT2 | TC-DECK-027 empty deck detail renders flashcard empty state | folder `Korean` has deck `Empty Deck` with zero flashcards | user opens `Empty Deck` | `No flashcards yet`, add action, and disabled study helper are visible | C0+C1 |
| DT3 | TC-DECK-028 New Study from deck scopes session cards to that deck | `Daily Words` and `Other Words` each have a new flashcard | user taps `deck_study_deck-daily` and starts New Study | study session opens with only `flashcard-korean` | C0+C1 |
| DT4 | TC-DECK-029 SRS Review from deck scopes session cards to due cards in that deck | target deck has one due card and one new card; another deck has a due card | user selects `SRS Review` from target deck study entry | `Fill` study session opens with only target due card `flashcard-due` | C0+C1 |
| DT5 | TC-DECK-030 selected study type has no eligible cards | deck has only a future-due learned card | user selects `SRS Review` and starts study | validation message says no eligible flashcards and no empty session is opened | C0+C1 |

## Decision table: onSearchFilterSort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | TC-DECK-031 search term matches one deck name in the current folder | folder `TOPIK` contains `Grammar`, `Vocabulary`, and `Reading` | user enters search keyword `vocab` | only `Vocabulary` remains visible | C0+C1 |
| DT2 | TC-DECK-032 clearing search restores the full deck list | folder `TOPIK` is filtered down to `Vocabulary` | user clears the search field | `Grammar` and `Vocabulary` are visible again in folder order | C0+C1 |
