# Decision Tables: flashcard_editor_screen_test

Test file: `test/presentation/flashcard_editor_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | editor args contain a deck id and no flashcard id, so create mode is selected | `FlashcardEditorScreen` opens with `deckId='deck-001'` and default `flashcardId=null` | first frame settles | `New flashcard`, `Save & add next`, and `Save flashcard` are visible | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | create-mode draft seeds three multiline text fields | editor opens with an empty create draft | editor form is rendered | three `TextFormField`s, `Front`, `Back`, `Note`, and long-content helper text for Front and Back are visible | C0+C1 |
