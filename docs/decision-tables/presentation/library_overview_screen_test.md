# Decision Tables: library_overview_screen_test

Test file: `test/presentation/library_overview_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `libraryOverviewQueryProvider` is unresolved and overview enters the loading branch | library overview opens with a pending `Completer<LibraryOverviewState>` | the first frame is pumped before the future completes | `MxLoadingState` is rendered exactly once | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | loaded library overview has greeting data and one root folder | state contains greeting `Good morning, Lan` and folder `Korean1` with seventeen items | library overview renders loaded branch | greeting, `Folders`, folder title, and `17` are visible | C0+C1 |

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | library FAB uses generic add icon as the create entry point | FAB is built through `buildLibraryOverviewFab` inside ProviderScope | FAB is rendered | `Icons.add` is present and `Icons.create_new_folder_outlined` is absent | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | root folder row exposes recursive study icon and routes to folder study entry | root folder `folder-root-001` has seventeen cards and nineteen percent mastery | user taps `library_folder_recursive_study_folder-root-001` | route path becomes `/study/folder/folder-root-001` and progress metadata remains visible | C0+C1 |
| DT2 | normal folder tap still calls the open-folder callback instead of the direct action sheet | `LibraryFolderSliver` is rendered with `onOpenFolder` callback | user taps `MxFolderTile` | callback receives `folder-root-001` | C0+C1 |

## Decision table: onSelect

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | root folder long-press opens direct folder actions | library overview has root folder `Korean1` and no modal is open | user long-presses `Korean1` | `Folder actions`, `Edit`, `Move`, and `Delete` are visible | C0+C1 |

## Decision table: onDispose

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | action built with dialog-local context pops only the dialog route | a dialog is opened from a page that still has an `Open dialog` button behind it | user taps dialog `Cancel` | dialog disappears and the underlying `Open dialog` button remains visible | C0+C1 |
