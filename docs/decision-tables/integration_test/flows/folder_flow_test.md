# Decision Tables: app_test folder flow

Test file: `integration_test/app_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT3 | folder detail route points to a folder id that is missing from local storage | the in-memory database is empty and the initial route is `/library/folder/e2e-missing-folder` | the folder detail provider loads the route id | `Something went wrong` and `Folder not found.` are rendered without an uncaught widget exception | C0+C1 |

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | empty library accepts a non-blank root folder name through the visible create-folder UI | the library route renders `No folders yet` with an empty in-memory database | the user opens `Create folder`, enters `E2E Folder`, and confirms | `E2E Folder` is visible in the library list and no widget exception is recorded | C0+C1 |
| DT2 | create-root dialog cancellation must not mutate the library | the library route renders `No folders yet` and the create-folder dialog is opened | the user enters `E2E Cancelled Folder` and presses `Cancel` | the dialog closes, the empty-library state remains visible, and `E2E Cancelled Folder` is absent | C0+C1 |
| DT3 | unlocked folder accepts a first subfolder and locks the parent into subfolder mode | `E2E Parent Folder` is open with the unlocked empty-folder actions | the user creates `E2E Child Folder` through `New subfolder` | `E2E Child Folder` is visible and the deck creation action is no longer rendered in that folder | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | library contains a root folder row that can be opened for read/display | `E2E Read Folder` exists in the library list | the user taps the folder row | the folder detail renders `E2E Read Folder` and the empty-folder body without widget exceptions | C0+C1 |
| DT5 | parent folder contains a subfolder row that can be opened for read/display | `E2E Display Parent Folder` is open and contains `E2E Display Child Folder` | the user taps the child folder row | the child folder detail renders `E2E Display Child Folder` and the empty-folder body without widget exceptions | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | opened root folder accepts a non-blank rename through its action sheet | `E2E Folder Before` is open on the folder detail route | the user opens `More actions`, chooses `Edit`, enters `E2E Folder After`, and saves | `E2E Folder After` replaces the old folder title without widget exceptions | C0+C1 |
| DT2 | rename cancellation must preserve the current folder metadata | `E2E Folder Stable` is open on the folder detail route | the user opens `Rename folder`, enters `E2E Folder Ignored`, and presses `Cancel` | `E2E Folder Stable` remains visible and `E2E Folder Ignored` is absent | C0+C1 |

## Decision table: onDelete

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | opened root folder deletion is confirmed through the destructive dialog | `E2E Delete Folder` is open on the folder detail route | the user opens `More actions`, chooses `Delete`, and confirms `Delete folder` | the route returns to the empty library and `E2E Delete Folder` is absent | C0+C1 |
| DT2 | destructive dialog cancellation must keep the folder subtree | `E2E Keep Folder` is open on the folder detail route | the user opens `Delete folder` and presses `Cancel` | `E2E Keep Folder` remains open and the empty folder body is still visible | C0+C1 |
| DT8 | deleting a parent folder with a child removes the visible subtree from library navigation | `E2E Delete Parent Folder` is open and contains `E2E Delete Child Folder` | the user confirms the parent folder destructive dialog | the route returns to the empty library and the child folder name is absent | C0+C1 |

## Decision table: onSearchFilterSort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | library search filters root folder rows by normalized folder name | `E2E Alpha Folder` and `E2E Beta Folder` both exist in the library | the user types `Beta` into the library search field | `E2E Beta Folder` remains visible and `E2E Alpha Folder` is removed from the filtered result | C0+C1 |
| DT2 | clearing an empty search result restores the original folder list | `E2E Restore Folder` exists and the search term has no matching folder | the user clears the search field | `E2E Restore Folder` becomes visible again without widget exceptions | C0+C1 |
| DT5 | unmatched library search renders the no-results state instead of a stale folder row | `E2E Searchable Folder` exists in the library list | the user searches for `No matching folder` | `No matching items` is visible and `E2E Searchable Folder` is absent from the filtered result | C0+C1 |
| DT8 | library search matches root folders case-insensitively | `E2E Mixed Case Folder` and `E2E Other Folder` both exist in the library | the user searches for lowercase `mixed case` | `E2E Mixed Case Folder` remains visible and `E2E Other Folder` is removed from the filtered result | C0+C1 |
