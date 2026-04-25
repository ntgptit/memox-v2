# Decision Tables: content_viewmodels_test

Test file: `test/presentation/content_viewmodels_test.dart`

## Decision table: onSearchFilterSort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | library overview query listens to content revisions and should refresh after root folder creation | repository starts empty and `libraryOverviewQueryProvider` is actively listened to | `libraryOverviewActionControllerProvider.createFolder('Japanese N5')` succeeds and provider pump flushes | subscription now contains folder `Japanese N5` with `Icons.folder_outlined` | C0+C1 |
| DT2 | folder detail query listens to content revisions and should refresh after subfolder creation | root folder exists in unlocked mode and `folderDetailQueryProvider(root.id)` is actively listened to | `folderActionControllerProvider(root.id).createSubfolder('Vocabulary')` succeeds and provider pump flushes | state switches to subfolder mode and contains `Vocabulary` with `Icons.folder_copy_outlined` | C0+C1 |
| DT3 | folder detail presenter aggregates descendant deck and flashcard counts for subfolder rows | root folder has child folder, the child has one deck, and that deck has two flashcards | `folderDetailQueryProvider(root.id)` resolves | subfolder item for child has `deckCount=1` and `itemCount=2` | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | deck action controller update succeeds and must not leave provider in error state | root folder and deck `Core vocabulary` exist | `deckActionControllerProvider(deck.id).updateDeck('Core vocabulary updated')` is called | result is true, controller state has no error, and repository deck name is updated | C0+C1 |

## Decision table: onRefreshRetry

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | flashcard editor save with `keepCreating=true` refreshes list and clears draft | deck exists, list query is listened to, and editor draft has front, back, and note | `flashcardEditorControllerProvider(args).save(keepCreating: true)` succeeds and provider pump flushes | flashcard list has one item with front `Hello`, and editor draft front/back/note are empty | C0+C1 |
| DT2 | import preview blocks invalid content, then valid commit refreshes list and resets import draft | import draft first has missing back text, then valid CSV content | `preparePreview` runs for invalid content, then valid content, then `commitImport` runs | invalid preparation has one issue and cannot commit, valid preparation can commit, one card is inserted, and import draft is reset | C0+C1 |

## Decision table: onDelete

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | flashcard action controller deletes selected ids successfully without publishing an error state | deck has one flashcard `flashcard-001` | `flashcardActionControllerProvider(deck.id).deleteFlashcards([flashcard.id])` is called | result is true, controller state has no error, and repository flashcard list becomes empty | C0+C1 |
