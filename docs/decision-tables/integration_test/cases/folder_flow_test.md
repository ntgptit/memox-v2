# Decision Tables: folder_flow_test

Test file: `integration_test/cases/folder_flow_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | library root has no folders in the in-memory database | app opens at the Library route with an empty `folders` table | folder root renders its loaded empty branch | `No folders yet` is visible and the `Create folder` action is reachable | C0+C1 |
| DT2 | folder detail effective mode is `subfolders` after the folder already has one child folder | root folder `TOPIK` has subfolder `Grammar` and no decks | user opens `TOPIK` from the root list | `Grammar` is visible, `New subfolder` is available from the FAB, and `New deck` is absent | C0+C1 |
| DT3 | manual sort keeps sibling subfolders ordered by creation `sortOrder` | user is inside root folder `TOPIK` with no children | user creates `Grammar`, `Vocabulary`, then `Reading` through the visible create flow | all three subfolders render in the same order they were created | C0+C1 |
| DT4 | folder detail effective mode is `decks` after the folder already has one deck | root folder `Korean` has deck `Daily Words` and no subfolders | user opens `Korean` from the root list | `Daily Words` is visible, `New deck` is available from the FAB, and `New subfolder` is absent | C0+C1 |

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | root folder creation receives a non-empty name | user is on the empty folder root screen | user opens `Create folder`, enters `TOPIK`, and confirms | the dialog closes, root folder `TOPIK` appears, and the persisted folder has no parent | C0+C1 |
| DT2 | create folder dialog has a blank name | user opens the create folder dialog and leaves the field empty | the dialog renders its action row | the `Create` confirmation button is disabled | C0+C1 |
| DT3 | root folder creation receives leading and trailing whitespace | user opens `Create folder` on the root screen | user enters `  Korean Vocabulary  ` and confirms | folder `Korean Vocabulary` appears, the raw padded name is absent, and the persisted name is trimmed | C0+C1 |
| DT4 | subfolder creation runs inside an unlocked empty root folder | root has folder `TOPIK` with no children and no decks | user opens `TOPIK`, chooses the subfolder create path, enters `Grammar`, and confirms | subfolder `Grammar` appears inside `TOPIK` | C0+C1 |
| DT5 | deck creation runs inside an unlocked empty root folder | root has folder `Korean` with no children and no decks | user opens `Korean`, chooses the deck create path, enters `Daily Words`, and confirms | deck `Daily Words` appears inside `Korean` and is persisted under that folder | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | root folder rename receives a non-empty replacement name | root has folder `Old Name` | user long-presses `Old Name`, chooses `Edit`, enters `New Name`, and saves | root list shows `New Name`, no longer shows `Old Name`, and the folder id is unchanged | C0+C1 |
| DT2 | rename folder dialog has a blank name after clearing the current name | root has folder `TOPIK` | user opens `Rename folder` and clears the name field | the `Save` confirmation button is disabled | C0+C1 |
| DT3 | parent folder rename must not change child data | root folder `TOPIK` has subfolder `Grammar` | user opens `TOPIK`, renames the current folder to `TOPIK II`, and stays on the renamed detail screen | subfolder `Grammar` remains visible inside the renamed folder | C0+C1 |

## Decision table: onDelete

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | user cancels root folder delete confirmation | root has folder `TOPIK` | user opens folder actions, chooses `Delete`, then taps `Cancel` in the confirmation dialog | delete dialog closes and `TOPIK` remains visible | C0+C1 |
| DT2 | user confirms deletion of an empty root folder | root has empty folder `Empty Folder` | user opens folder actions, chooses `Delete`, then confirms with `Delete` | `Empty Folder` disappears from the root list and is absent from the database | C0+C1 |
| DT3 | deleting a parent folder cascades to its subtree | root folder `TOPIK` has subfolder `Grammar` | user confirms deleting `TOPIK` from the root list | `TOPIK` and `Grammar` are absent from UI/database | C0+C1 |
| DT4 | deleting the last subfolder resets the parent folder to unlocked mode | root folder `TOPIK` has exactly one subfolder `Grammar` | user opens `TOPIK`, confirms deleting `Grammar`, then opens the create FAB | `This folder is empty` is visible and the create sheet offers both `New subfolder` and `New deck` | C0+C1 |

## Decision table: onMove

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | folder detail is in manual subfolder mode and the user saves a drag reorder | root folder `TOPIK` contains subfolders `A`, `B`, `C` ordered by `sortOrder` | user opens `TOPIK`, chooses `Reorder`, drags `C` above `A`, and taps `Save order` | the visible subfolder order becomes `C`, `A`, `B` | C0+C1 |
| DT2 | move target is a different valid parent folder | root has folders `A` and `B`, and `A` contains subfolder `Grammar` | user opens `A`, chooses `Move` for `Grammar`, and selects `B` | `Grammar` disappears from `A`, appears inside `B`, and its persisted parent is `B` | C0+C1 |
| DT3 | move target list excludes the moving folder itself | root has only folder `A` | user opens `Move folder` for root folder `A` | destination picker does not list `A` and shows `No valid destination found.` | C0+C1 |
| DT4 | move target list excludes descendants of the moving folder | folder tree is `A > B > C` | user opens `Move folder` for root folder `A` | destination picker does not list `B` or `C` and shows `No valid destination found.` | C0+C1 |
| DT5 | move target list excludes folders locked for decks | root has deck-mode folder `Deck Folder`, and another folder `A` contains subfolder `Grammar` | user opens `A` and opens `Move folder` for `Grammar` | destination picker does not list `Deck Folder` as a target | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | user opens a nested folder path through visible folder rows | folder tree is `TOPIK > Grammar > Level 4` | user opens `TOPIK`, then `Grammar`, then `Level 4` | folder detail shows `Level 4` as the current empty folder | C0+C1 |
| DT2 | back action from a child folder should return to the parent detail route | root folder `TOPIK` has subfolder `Grammar` and user is viewing `Grammar` | user taps toolbar `Back` | app returns to `TOPIK` and the `Grammar` row is visible again | C0+C1 |
| DT3 | current folder title or breadcrumb reflects the opened folder | root folder `TOPIK` has subfolder `Grammar` | user opens `TOPIK`, then `Grammar` | folder detail shows `Grammar` as the current folder and `TOPIK` remains visible in the breadcrumb | C0+C1 |
| DT4 | folder recursive study entry has one direct deck with a new card | root folder `Korean` has deck `Daily Words` with flashcard `annyeong` / `hello` | user taps the folder study action for `Korean` and starts the default study flow | Study Session opens on the direct deck card and the session batch contains that flashcard id | C0+C1 |
| DT5 | folder recursive study entry spans child folders in the subtree | root folder `TOPIK` has child folders `Grammar` and `Vocabulary`, each with one deck and one new flashcard | user taps the folder study action for `TOPIK` and starts the default study flow | Study Session opens and the original session batch contains flashcards from both child folders | C0+C1 |
| DT6 | folder recursive study entry has no eligible cards | root folder `Empty Folder` has no deck and no flashcards | user taps the folder study action for `Empty Folder` and starts the default study flow | Study Entry stays open and shows `No eligible flashcards are available for this study session.` | C0+C1 |

## Decision table: onExternalChange

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | saved manual subfolder order is read from the database after app restart | file-backed database has `TOPIK` with subfolders `A`, `B`, `C` and the user saved order `C`, `A`, `B` | app is restarted through the integration harness and user opens `TOPIK` again | subfolder order remains `C`, `A`, `B` | C0+C1 |
| DT2 | a root folder created through UI is read after app restart | user creates root folder `TOPIK` in a file-backed test database | app is restarted through the integration harness | root list still shows `TOPIK` | C0+C1 |
| DT3 | a nested folder tree created through UI is read after app restart | user creates `TOPIK > Grammar > Advanced Grammar` in a file-backed test database | app is restarted and user opens `TOPIK > Grammar` | `Advanced Grammar` is still visible inside `Grammar` | C0+C1 |
