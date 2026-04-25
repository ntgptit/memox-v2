# Decision Tables: deck_detail_screen_test

Test file: `test/presentation/deck_detail_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `deckDetailQueryProvider(deckId)` is unresolved and retained async state renders the deck skeleton branch | deck detail opens for `deck-001` with a pending `Completer<DeckDetailState>` | the first frame is pumped before the future completes | `deck_detail_skeleton` is visible and `MxLoadingState` is not rendered | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | optional deck detail renders overview only and no longer acts as the flashcard management gateway | `DeckDetailState` contains `cardCount=0`, `dueTodayCount=0`, and name `Empty deck` | deck detail renders loaded data | deck title and overview metrics are visible, while `Manage content`, `Study now`, `Open flashcards`, `Add flashcard`, and `Import` are absent | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | header more button opens the shared deck action sheet | zero-card deck detail state is loaded and header action button is present | user taps tooltip `More actions` | `Deck actions`, `Duplicate deck`, and `Export CSV` are visible | C0+C1 |
