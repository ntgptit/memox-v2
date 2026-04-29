# Decision Tables: content_repository_test

Test file: `test/data/repositories/content_repository_test.dart`

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | parent folder mode is unlocked and first child is a subfolder | root folder is created with unlocked mode and no children | repository creates a subfolder under that root | parent folder mode becomes subfolders and the new subfolder is persisted | C0+C1 |
| DT2 | parent folder mode is unlocked and first child is a deck | root folder is created with unlocked mode and no children | repository creates a deck under that root | parent folder mode becomes decks and the new deck is persisted | C0+C1 |
| DT3 | import preview contains both valid rows and validation issues | deck exists and raw import content has one valid row plus one invalid row | import commit is requested with the mixed preparation | no flashcards are written and validation issues remain visible | C0+C1 |
| DT4 | parent folder mode is subfolders and deck creation is requested | root folder already contains a subfolder | repository creates a deck under the same root | creation fails, no deck is written, and the folder remains locked to subfolders | C0+C1 |
| DT5 | parent folder mode is decks and subfolder creation is requested | root folder already contains a deck | repository creates a subfolder under the same root | creation fails, no subfolder is written, and the folder remains locked to decks | C0+C1 |
| DT6 | manual flashcard draft has surrounding whitespace and blank note | deck exists and draft contains padded front/back plus an empty note | repository creates the flashcard | stored content is trimmed, note is null, and SRS progress starts at box 1 without due date | C0+C1 |
| DT7 | valid CSV import preparation has no validation issues | deck exists and CSV contains two valid flashcard rows | repository commits the prepared import | two flashcards are written in source order and each starts as a new SRS card | C0+C1 |
| DT8 | import file contains an exact duplicate and a same-front different-back row | deck exists and raw CSV repeats one `front + back` pair while another row reuses only `front` | repository prepares and commits import with MVP duplicate policy | exact duplicate is skipped, same-front different-back row remains importable, and commit writes only importable rows | C0+C1 |
| DT9 | target deck already contains an exact duplicate | deck contains `hello/xin chao` and import source contains `hello/xin chao` plus `hello/greeting` | repository prepares import with MVP duplicate policy | exact deck duplicate is skipped and same-front different-back row remains importable | C0+C1 |

## Decision table: onDelete

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | parent folder has exactly one subfolder and that subfolder is deleted | root folder mode is subfolders with one child subfolder | repository deletes the last subfolder | parent folder mode resets to unlocked | C0+C1 |
| DT2 | parent folder has exactly one deck and that deck is deleted | folder contains one deck with flashcard progress | repository deletes that deck | deck, flashcard, and progress rows are removed and the parent folder unlocks | C0+C1 |
| DT3 | empty flashcard selection is deleted | deck contains one flashcard and caller passes an empty id list | repository deletes flashcards | no mutation occurs and the existing flashcard remains | C0+C1 |
| DT4 | bulk delete receives selected flashcards | deck contains selected and unselected flashcards with progress | repository deletes the selected flashcards | selected flashcards and progress are removed while unselected flashcards remain | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | learned flashcard content update keeps progress by policy | flashcard has non-default SRS progress | repository updates front/back with `keepProgress` | flashcard content changes and existing progress fields remain unchanged | C0+C1 |
| DT2 | learned flashcard content update resets progress by policy | flashcard has non-default SRS progress | repository updates front/back with `resetProgress` | flashcard content changes and progress row returns to new-card state | C0+C1 |

## Decision table: repositoryFlow

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | folder move destination is the moving folder descendant | root folder has a nested child and move request targets that descendant | repository moves the root folder into the descendant | move is rejected and folder hierarchy is unchanged | C0+C1 |
| DT2 | moving the only deck out of a folder leaves the source folder empty | source folder has one deck with flashcards and progress, and target folder can accept decks | repository moves the deck to the target folder | source folder mode resets and flashcard progress remains attached to the moved deck | C0+C1 |
| DT3 | duplicate deck copies flashcards but not learned progress | deck has flashcard content and progress records | repository duplicates the deck | duplicated deck has copied flashcards and reset progress state | C0+C1 |
| DT4 | folder move destination is the same folder | folder exists and move request targets its own id | repository moves the folder into itself | move is rejected and parent id stays unchanged | C0+C1 |
| DT5 | folder move destination is locked for decks | target folder already contains a deck and source folder is a sibling | repository moves the source folder into the target folder | move is rejected because folder targets may only contain subfolders | C0+C1 |
| DT6 | export deck is requested for a deck with studied cards | deck contains flashcards with SRS progress and history fields | repository exports the deck | CSV contains only front/back/note content and omits SRS fields | C0+C1 |

## Decision table: onSearchFilterSort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | flashcard sort mode is last studied and some cards have never been studied | deck contains studied and never-studied flashcards | repository queries flashcards sorted by last studied | studied cards are ordered first and never-studied cards are placed at the end | C0+C1 |
| DT2 | folder search matches a nested folder name | root and child folders exist with the child matching the query | repository queries library overview by search term | matching child folder is returned with parent breadcrumb context | C0+C1 |
| DT3 | deck sort mode is last studied and some decks have never been studied | folder contains studied and never-studied decks | repository queries decks sorted by last studied | studied deck is ordered first and never-studied deck is placed at the end | C0+C1 |
| DT4 | flashcard search matches back text | deck contains cards whose back values differ | repository queries flashcards by a term found only in back text | matching flashcard is returned with the deck breadcrumb | C0+C1 |

## Decision table: getLibraryOverview

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | daily study pool contains one overdue learned card, one due-today learned card, one future learned card, and one new card | library has two folders, one deck, four flashcards, and progress rows with overdue, today, and future `due_at` values | repository builds the library overview | `overdueCount=1`, `dueTodayCount=1`, `newCardCount=1`, and `totalFolderCount=2` are returned | C0+C1 |
| DT2 | root folder subtree contains overdue, due-today, future, and new cards | root folder contains a nested child folder with one deck, four flashcards, and progress rows with overdue, today, future, and null `due_at` values | repository builds the library overview | the root folder item returns `itemCount=4`, `dueCardCount=2`, and `newCardCount=1` | C0+C1 |

## Decision table: onMove

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | bulk move receives two hundred flashcards with existing progress | source deck has two hundred flashcards and progress records, target deck exists | repository bulk-moves all selected flashcards | all selected cards move transactionally and progress records are preserved | C0+C1 |
| DT2 | empty flashcard selection is moved | source and target decks exist and caller passes an empty id list | repository moves flashcards | no mutation occurs and both decks keep their original cards | C0+C1 |
| DT3 | manual flashcard reorder is requested inside one deck | deck contains three sibling flashcards | repository reorders those flashcards | sort order changes while deck id and SRS progress remain unchanged | C0+C1 |
