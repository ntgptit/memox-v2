# Decision Tables: flashcard_list_screen_test

Test file: `test/presentation/flashcard_list_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `flashcardListQueryProvider(deckId)` is unresolved and retained async state renders the list skeleton branch | flashcard list opens for `deck-001` with a pending `Completer<FlashcardListState>` | the first frame is pumped before the future completes | `flashcard_list_skeleton` is visible and `MxLoadingState` is not rendered | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | loaded deck has two flashcard rows, preview content, progress summary, and manual sort mode | `FlashcardListState` contains deck name `Korean deck`, two items, and deck progress counts | flashcard list renders loaded data | deck name, `Front 1`, `Back 1`, `Front 2`, `Study modes`, `Your progress`, and `Cards` are visible | C0+C1 |
| DT2 | loaded deck has no flashcards and study CTA plus study-mode cards must be visually disabled while creation/import remain available | `FlashcardListState` contains no items, zero progress, and manual sort mode | flashcard list renders the toolbar, empty deck branch, and study mode section | toolbar `Import`, empty-state `No flashcards yet`, and `Add` are visible, primary `Study this deck` has `onPressed == null`, five keyed study-mode `MxCard` surfaces render, and no study-mode chevron is rendered | C0+C1 |
| DT3 | loaded deck has many flashcards and list rendering must stay lazy instead of building every detail card row on entry | `FlashcardListState` contains eighty items, preview limit data, and a mobile viewport | flashcard list first renders, then user scrolls to the final item | `CustomScrollView` and `flashcard_lazy_items` are used, initially built `FlashcardDetailCardRow` widgets are fewer than total items, `Front 79` is absent before scrolling, then `Front 79` and `Back 79` appear after scroll | C0+C1 |
| DT4 | compact deck-detail layout uses decision-first section copy | `FlashcardListState` contains two items and the viewport is compact width | flashcard list renders the deck-detail layout | `Your progress`, `Study flow`, `Cards`, import action, and reorder action are visible, the generic progress subtitle and `Study modes` helper subtitle are hidden, and no widget exception occurs | C0+C1 |
| DT5 | non-selected flashcard card must follow the template action layout instead of the old select-circle rail | `FlashcardListState` contains `card-001` with no selected cards | flashcard list scrolls to the first detail card row | speaker and star outline icons are top-aligned with the front term, spaced by the compact icon gap, the unchecked circle icon is absent, and back text starts below the action row | C0+C1 |
| DT6 | compact deck-detail hierarchy keeps the deck summary study action and card-management toolbar above the preview carousel | `FlashcardListState` contains two items and the viewport is compact width | flashcard list renders the first screen without scrolling | `Study this deck`, `FlashcardToolbarSection`, `MxSearchField`, and `FlashcardPreviewSection` are visible, and the toolbar top is above the preview top | C0+C1 |
| DT7 | loaded deck summary exposes deck context metadata and progress section uses visual progress emphasis | `FlashcardListState` contains breadcrumb parent `Korean`, two items, and `masteryPercent=7` | flashcard list renders the deck summary, then scrolls to progress | summary contains `MxAvatar`, `MxBadge` with `2 cards · 7% mastery`, and progress section contains a `LinearProgressIndicator` with value `0.07` | C0+C1 |
| DT8 | loaded deck has flashcards and study modes must render as design-system cards in the intended flow order | `FlashcardListState` contains two items and the five localized study mode labels | flashcard list scrolls to `Study modes` | five keyed study-mode `MxCard` surfaces render without chevrons, `Review` appears before the second-row modes, and `Guess`, `Recall`, and `Fill` are present | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | flashcard management owns the deck study entry point for non-empty decks | loaded deck has two flashcards and is routed at `/deck/deck-001/flashcards` | user scrolls to and taps `Study this deck` | route path becomes `/study/deck/deck-001` | C0+C1 |
| DT2 | flashcard management header exposes deck-level actions without a separate deck screen | loaded deck has two flashcards and header more action is present | user taps tooltip `More actions` | `Deck actions`, `Edit`, `Move`, `Duplicate`, `Import flashcards`, `Export CSV`, and `Delete` are visible | C0+C1 |
| DT3 | deck action import should route to the deck-scoped import screen | loaded deck `deck-001` is managed from the flashcard list route and deck import route is registered | user opens `Deck actions` and taps `Import flashcards` | deck import destination renders with path parameter `deck-001` | C0+C1 |
| DT4 | study-flow cards share the same deck study entry point as the primary study CTA | loaded deck has two flashcards and is routed at `/deck/deck-001/flashcards` | user scrolls to the study-flow section and taps the `Mix` card | route path becomes `/study/deck/deck-001` | C0+C1 |

## Decision table: onDelete

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | no bulk selection is active and row long-press opens per-card action sheet | loaded list has `card-001` and selection set is empty | user long-presses `Front 1` | `Flashcard actions`, `Edit`, `Move`, `Export`, `Select`, and `Delete` are visible | C0+C1 |

## Decision table: onSelect

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | Select action enters bulk mode, then long-pressing the selected row toggles it off instead of reopening the sheet | loaded list has `card-001` and `card-002` with no initial selection | user long-presses `Front 1`, taps `Select`, then long-presses `Front 1` again | `1 selected` appears after Select, then disappears and `Flashcard actions` stays closed after toggle-off | C0+C1 |
| DT2 | template star action toggles the existing bulk-selection state without adding favorite persistence | loaded list has `card-001` and no initial selection | user taps the star outline inside the `Front 1` card row | `1 selected` appears and the same row renders a filled star | C0+C1 |
| DT3 | preview card face toggle must reveal the back side inline and inside fullscreen dialog | loaded list has preview item `card-001` with front `Front 1` and back `Back 1` | user taps the preview card, opens fullscreen, then taps the dialog card | inline preview changes from `Front 1` to `Back 1`, fullscreen opens on `Back 1`, and dialog tap returns to `Front 1` | C0+C1 |

## Decision table: onMove

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | selected flashcards are moved and learning progress must remain attached | loaded list has `card-001` selected and one valid target deck named `Target deck` | user taps bulk `Move` | destination picker shows `Move flashcards`, `Learning progress will be kept after moving.`, and `Target deck` | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | row Edit action navigates directly to flashcard editor | loaded list is routed at `/deck/deck-001/flashcards` and edit route is registered | user long-presses `Front 1` and taps `Edit` | `flashcard_edit_destination` is rendered | C0+C1 |
