# Decision Tables: flashcard_list_screen_test

Test file: `test/presentation/flashcard_list_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `flashcardListQueryProvider(deckId)` is unresolved and retained async state renders the list skeleton branch | flashcard list opens for `deck-001` with a pending `Completer<FlashcardListState>` | the first frame is pumped before the future completes | `flashcard_list_skeleton` is visible and `MxLoadingState` is not rendered | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | loaded deck has two flashcard rows and manual sort mode | `FlashcardListState` contains deck name `Korean deck` and two items | flashcard list renders loaded data | deck name, `Front 1`, `Back 1`, and `Front 2` are visible | C0+C1 |
| DT2 | loaded deck has no flashcards and study must be disabled while creation/import remain available | `FlashcardListState` contains no items and manual sort mode | flashcard list renders the empty deck branch | `No flashcards yet`, `Add flashcard`, and `Import` are visible, while primary `Study now` has `onPressed == null` | C0+C1 |
| DT3 | loaded deck has many flashcards and list rendering must stay lazy instead of building every row on entry | `FlashcardListState` contains eighty items and a mobile viewport | flashcard list first renders, then user scrolls to the final item | `CustomScrollView` and `flashcard_lazy_items` are used, initially built rows are fewer than total items, `Front 79` is absent before scrolling, then `Front 79` and `Back 79` appear after scroll | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | flashcard management owns the deck study entry point for non-empty decks | loaded deck has two flashcards and is routed at `/deck/deck-001/flashcards` | user taps `Study now` in the toolbar | route path becomes `/study/deck/deck-001` | C0+C1 |
| DT2 | flashcard management header exposes deck-level actions without entering deck detail | loaded deck has two flashcards and header more action is present | user taps tooltip `More actions` | `Deck actions`, `Edit`, `Move`, `Duplicate deck`, `Export CSV`, and `Delete` are visible | C0+C1 |

## Decision table: onDelete

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | no bulk selection is active and row long-press opens per-card action sheet | loaded list has `card-001` and selection set is empty | user long-presses `Front 1` | `Flashcard actions`, `Edit`, `Move`, `Export`, `Select`, and `Delete` are visible | C0+C1 |

## Decision table: onSelect

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | Select action enters bulk mode, then long-pressing the selected row toggles it off instead of reopening the sheet | loaded list has `card-001` and `card-002` with no initial selection | user long-presses `Front 1`, taps `Select`, then long-presses `Front 1` again | `1 selected` appears after Select, then disappears and `Flashcard actions` stays closed after toggle-off | C0+C1 |

## Decision table: onMove

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | selected flashcards are moved and learning progress must remain attached | loaded list has `card-001` selected and one valid target deck named `Target deck` | user taps bulk `Move` | destination picker shows `Move flashcards`, `Learning progress will be kept after moving.`, and `Target deck` | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | row Edit action navigates directly to flashcard editor | loaded list is routed at `/deck/deck-001/flashcards` and edit route is registered | user long-presses `Front 1` and taps `Edit` | `flashcard_edit_destination` is rendered | C0+C1 |
