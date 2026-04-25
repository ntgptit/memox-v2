# Decision Tables: content_repository_test

Test file: `test/data/repositories/content_repository_test.dart`

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | parent folder mode is unlocked and first child is a subfolder | root folder is created with unlocked mode and no children | repository creates a subfolder under that root | parent folder mode becomes subfolders and the new subfolder is persisted | C0+C1 |
| DT2 | parent folder mode is unlocked and first child is a deck | root folder is created with unlocked mode and no children | repository creates a deck under that root | parent folder mode becomes decks and the new deck is persisted | C0+C1 |
| DT3 | import preview contains both valid rows and validation issues | deck exists and raw import content has one valid row plus one invalid row | import commit is requested with the mixed preparation | no flashcards are written and validation issues remain visible | C0+C1 |

## Decision table: onDelete

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | parent folder has exactly one subfolder and that subfolder is deleted | root folder mode is subfolders with one child subfolder | repository deletes the last subfolder | parent folder mode resets to unlocked | C0+C1 |

## Decision table: repositoryFlow

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | folder move destination is the moving folder descendant | root folder has a nested child and move request targets that descendant | repository moves the root folder into the descendant | move is rejected and folder hierarchy is unchanged | C0+C1 |
| DT2 | moving the only deck out of a folder leaves the source folder empty | source folder has one deck with flashcards and progress, and target folder can accept decks | repository moves the deck to the target folder | source folder mode resets and flashcard progress remains attached to the moved deck | C0+C1 |
| DT3 | duplicate deck copies flashcards but not learned progress | deck has flashcard content and progress records | repository duplicates the deck | duplicated deck has copied flashcards and reset progress state | C0+C1 |

## Decision table: onSearchFilterSort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | flashcard sort mode is last studied and some cards have never been studied | deck contains studied and never-studied flashcards | repository queries flashcards sorted by last studied | studied cards are ordered first and never-studied cards are placed at the end | C0+C1 |

## Decision table: onMove

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | bulk move receives two hundred flashcards with existing progress | source deck has two hundred flashcards and progress records, target deck exists | repository bulk-moves all selected flashcards | all selected cards move transactionally and progress records are preserved | C0+C1 |
