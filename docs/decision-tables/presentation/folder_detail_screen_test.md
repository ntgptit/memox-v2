# Decision Tables: folder_detail_screen_test

Test file: `test/presentation/folder_detail_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `folderDetailQueryProvider(folderId)` is unresolved and retained async state renders the folder skeleton branch | folder detail opens for `folder-001` with a pending `Completer<FolderDetailState>` | the first frame is pumped before the future completes | `folder_detail_skeleton` is visible and `MxLoadingState` is not rendered | C0+C1 |

## Decision table: onSearchFilterSort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | query refresh keeps prior data and shows retained refresh bar instead of removing primary actions | folder detail has loaded data, then provider changes to a pending refresh future | widget pumps the refresh frame | FloatingActionButton and add icon remain visible, and `mx_retained_async_refresh_bar` appears | C0+C1 |
| DT2 | `searchTerm` is non-empty and both subfolder/deck collections are empty | folder detail state has `searchTerm='biology'`, deck mode, and no decks | folder detail renders empty search result branch | `No matching items` and `Clear search` are visible, `New deck` is hidden, and FloatingActionButton is absent | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | breadcrumb segment has a parent folder id and should navigate to that folder detail route | child folder detail is loaded with breadcrumb `Japanese` pointing to `folder-000` | user taps the `Japanese` breadcrumb | router path becomes `/folder/folder-000` | C0+C1 |
| DT2 | legacy subfolder read model has `masteryPercent=null` and UI must fall back to zero progress | loaded subfolder item `Legacy` has `masteryPercent=null` | folder detail renders the subfolder row | `Legacy` and `0%` are visible | C0+C1 |
| DT3 | subfolder card exposes recursive study icon instead of a full `Study now` text action | subfolder mode has `folder-002` with two cards and nineteen percent mastery | user taps `folder_recursive_study_folder-002` | route path becomes `/study/folder/folder-002` and progress/icon metadata stays aligned with the row | C0+C1 |
| DT4 | deck card progress action starts study for that deck | deck mode has deck `deck-001` named `Vitamin B1` with one card and forty-two percent mastery | user taps `deck_study_deck-001` | route path becomes `/study/deck/deck-001` | C0+C1 |
| DT5 | deck row tap opens flashcard management instead of the optional deck detail overview | deck mode has deck `deck-001` named `Vitamin B1` | user taps the `Vitamin B1` row body | flashcard management destination renders from the `flashcardList` route | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | subfolder mode has active subfolders with subtree deck and card stats | folder detail state contains subfolder `Vocabulary` with one deck and two cards | folder detail renders loaded subfolder mode | `1 decks · 2 cards` is visible | C0+C1 |
| DT2 | subfolder mode has no subfolders and no search term | folder detail state has `mode=subfolders`, no items, and empty `searchTerm` | folder detail renders empty subfolder branch | `No subfolders yet` and `New subfolder` are visible, while `New deck` is hidden | C0+C1 |
| DT3 | deck mode has no decks and no search term | folder detail state has `mode=decks`, no items, and empty `searchTerm` | folder detail renders empty deck branch | `No decks yet` and `New deck` are visible, while `New subfolder` is hidden | C0+C1 |

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | folder mode is unlocked and empty, so both creation choices are available | loaded folder state has `mode=unlocked` and no subfolders or decks | empty state renders creation options | `This folder is empty`, `New subfolder`, and `New deck` are visible | C0+C1 |

## Decision table: onDelete

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | no reorder mode is active and subfolder long-press opens direct folder actions | subfolder mode contains `Vocabulary` | user long-presses `Vocabulary` | `Folder actions`, `Edit`, `Move`, and `Delete` are visible | C0+C1 |
| DT2 | no reorder mode is active and deck long-press opens direct deck actions | deck mode contains `Vitamin B1` | user long-presses `Vitamin B1` | `Deck actions`, `Edit`, `Move`, `Duplicate deck`, `Export CSV`, and `Delete` are visible | C0+C1 |
