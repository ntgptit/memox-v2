# Decision Tables: app_test coverage expansion flow

Test file: `integration_test/app_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT9 | app config initial route targets the Home shell branch | `initialLocation` is `/home` with an empty in-memory database | the app shell boots from the configured route | `Today's study focus` is visible and no widget exception is recorded | C0+C1 |
| DT10 | app config initial route targets the Progress shell branch | `initialLocation` is `/progress` with no active study sessions | the app shell boots from the configured route | `No active study sessions` is visible and no widget exception is recorded | C0+C1 |
| DT11 | app config initial route targets the Settings shell branch | `initialLocation` is `/settings` with mocked preferences | the app shell boots from the configured route | `Appearance` is visible and no widget exception is recorded | C0+C1 |
| DT12 | compact viewport opens the Library shell branch directly | `initialLocation` is `/library` and the viewport is `integrationTestCompactSurfaceSize` | the app shell boots from the configured route | `No folders yet` is visible on the compact layout | C0+C1 |
| DT13 | study entry route contains an unsupported entry type | the app starts at `/library/study/invalid/e2e-entry` | the study entry provider parses the route params | `Something went wrong` and `Study action failed.` are visible | C0+C1 |
| DT14 | study result route points to a missing session id | the app starts at `/library/study/session/e2e-missing-result/result` with no session rows | the study result provider loads the session id | `Something went wrong` and `Study action failed.` are visible | C0+C1 |
| DT15 | flashcard edit route has no matching flashcard in storage | the app starts at `/library/deck/e2e-missing-deck/flashcards/e2e-missing-card/edit` with an empty database | the editor draft provider loads the flashcard id | `Something went wrong` and `Flashcard not found.` are visible | C0+C1 |
| DT16 | compact viewport opens a folder route whose id is missing | the app starts at `/library/folder/e2e-compact-missing` on compact viewport | the folder detail provider loads the route id | `Something went wrong` and `Folder not found.` are visible | C0+C1 |
| DT17 | compact viewport opens a flashcard-list route whose deck id is missing | the app starts at `/library/deck/e2e-compact-missing/flashcards` on compact viewport | the flashcard list provider loads the route id | `Something went wrong` and `Deck not found.` are visible | C0+C1 |
| DT18 | compact viewport opens an unknown route | the app starts at `/unknown-compact-route` on compact viewport | the router resolves the initial location | `Navigation error` and `Something went wrong.` are visible | C0+C1 |
| DT19 | direct Today route opens study entry with review mode available | the app starts at `/library/study/today` | the study entry screen loads default settings | `Start a study session` and `SRS Review` are visible | C0+C1 |
| DT20 | create-flashcard route opens for an existing empty deck | `E2E Create Route Deck` exists and the app starts at its `/flashcards/new` route | the editor draft provider builds a new-card draft | `New flashcard` and `Save flashcard` are visible | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT8 | dashboard has no due cards | the Home branch opens with an empty in-memory database | the dashboard overview renders | `Due today` and `0` are visible | C0+C1 |
| DT9 | dashboard library health has no folders, decks, or cards | the Home branch opens with an empty in-memory database | the dashboard Library health card renders | `Library health` and `0 folders · 0 decks · 0 cards` are visible | C0+C1 |
| DT10 | dashboard mastery metric has no source cards | the Home branch opens with an empty in-memory database | the dashboard Library health card renders mastery | `Mastery` and `0%` are visible | C0+C1 |
| DT11 | progress page has no active sessions | the Progress branch opens with an empty in-memory database | the progress screen renders | `No active study sessions` is visible | C0+C1 |
| DT12 | progress page empty state points users back to Library | the Progress branch opens with an empty in-memory database | the progress empty state renders | `Start studying from Library. Sessions that are in progress or waiting to finalize will appear here.` is visible | C0+C1 |
| DT13 | settings appearance group renders all theme choices | the Settings branch opens with mocked light theme preference | the settings list renders | `Appearance`, `System`, `Light`, and `Dark` are visible | C0+C1 |
| DT14 | settings language group renders locale choices | the Settings branch opens with mocked English locale preference | the settings list renders | `Language`, `English`, and `Vietnamese` are visible | C0+C1 |
| DT15 | settings speech group renders speech preferences | the Settings branch opens with no-op TTS service | the settings list renders | `Speech` and `Auto-play in study` are visible | C0+C1 |
| DT16 | empty Library branch renders onboarding copy | the Library branch opens with an empty in-memory database | the library overview renders | `No folders yet` and `Create your first folder to start building your library.` are visible | C0+C1 |
| DT17 | unlocked folder body exposes both content-direction actions | `E2E Unlocked Display Folder` exists and has no children | the user opens the folder detail route | `New subfolder` and `New deck` are visible | C0+C1 |
| DT18 | subfolder-mode folder header displays child count | `E2E Subfolder Count Parent` contains one child folder | the parent folder detail rerenders after child creation | `Contains 1 subfolders` is visible | C0+C1 |
| DT19 | flashcard list renders the empty deck state | `E2E Empty Overview Deck` exists with no flashcards | the flashcard-list route opens | `E2E Empty Overview Deck` and `No flashcards yet` are visible | C0+C1 |
| DT20 | flashcard list keeps creation and import entry points for an empty deck | `E2E Never Studied Deck` exists with no flashcards | the flashcard-list route opens | `E2E Never Studied Deck`, `Add flashcard`, and `Import` are visible | C0+C1 |
| DT21 | flashcard list route renders seeded card text | `E2E Seeded List Deck` contains one flashcard | the flashcard list route opens | `E2E Seeded List Front` and `E2E Seeded List Back` are visible | C0+C1 |
| DT22 | study entry screen renders explanatory subtitle | `E2E Study Subtitle Front` is visible in a seeded deck | the user opens the study entry screen | `Choose a flow and snapshot settings for this session.` is visible | C0+C1 |
| DT23 | Today study entry explains review-only v1 scope | the app starts at `/library/study/today` | the study entry screen renders the flow section | `Today supports SRS Review due and overdue cards in v1.` is visible | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT3 | dashboard primary action navigates to Library when no cards are due | the Home branch shows `Open library` because due count is zero | the user taps `Open library` | the Library branch opens and `No folders yet` is visible | C0+C1 |
| DT4 | progress empty-state action navigates to Library | the Progress branch shows `Open library` in the empty state | the user taps `Open library` | the Library branch opens and `No folders yet` is visible | C0+C1 |
| DT5 | Settings shell destination can return to Library | the app starts on Settings with shell navigation visible | the user taps `Library` | the Library branch opens and `No folders yet` is visible | C0+C1 |
| DT6 | Library shell destination can open Home | the app starts on Library with shell navigation visible | the user taps `Home` | the Home branch opens and `Today's study focus` is visible | C0+C1 |
| DT7 | Library shell destination can open Settings | the app starts on Library with shell navigation visible | the user taps `Settings` | the Settings branch opens and `Appearance` is visible | C0+C1 |
| DT8 | Home shell destination can open Progress | the app starts on Home with shell navigation visible | the user taps `Progress` | the Progress branch opens and `No active study sessions` is visible | C0+C1 |

## Decision table: onSearchFilterSort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT12 | library search trims surrounding whitespace before matching | `E2E Trim Alpha Folder` and `E2E Trim Beta Folder` both exist | the user searches for `  Beta  ` | only `E2E Trim Beta Folder` remains visible | C0+C1 |
| DT13 | folder no-result clear action restores filtered rows | `E2E Clear Button Folder` exists and search has no matches | the user taps `Clear search` from the no-results state | `E2E Clear Button Folder` becomes visible again | C0+C1 |
| DT14 | deck search trims surrounding whitespace before matching | `E2E Search Alpha Deck` and `E2E Search Beta Deck` both exist in one folder | the user searches for `  Beta  ` | only `E2E Search Beta Deck` remains visible | C0+C1 |
| DT15 | flashcard back-text search trims surrounding whitespace before matching | `E2E Search Alpha` has unrelated back text and `E2E Search Beta` has back text containing `Needle` | the user searches for `  Needle  ` | only `E2E Search Beta` remains visible | C0+C1 |
| DT16 | unmatched flashcard search renders empty state instead of stale rows | `E2E Search Alpha` and `E2E Search Beta` exist in the opened deck | the user searches for `missing flashcard term` | `No flashcards yet` is visible and `E2E Search Alpha` is absent | C0+C1 |
| DT17 | clearing unmatched flashcard search restores both rows | `E2E Search Alpha` and `E2E Search Beta` exist and an unmatched search is active | the user clears the search field | both flashcard rows become visible again | C0+C1 |

## Decision table: onSelect

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT2 | selecting a second flashcard extends the active selection | one flashcard is already selected in a two-card deck | the user taps the second visible row | `2 selected` is visible without deleting or moving cards | C0+C1 |
| DT3 | Select all expands a partial flashcard selection | one flashcard is selected in a two-card deck | the user taps `Select all` | `2 selected` is visible | C0+C1 |
| DT4 | Clear removes a complete flashcard selection | both visible flashcards are selected | the user taps `Clear` | `2 selected` is absent and the rows remain in the deck | C0+C1 |
| DT5 | tapping an already-selected flashcard removes the single selection | one flashcard is selected in a two-card deck | the user taps the selected row again | `1 selected` is absent and no mutation occurs | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT10 | settings accepts Dark theme selection | the Settings branch opens with the light theme override | the user taps `Dark` | `Settings updated.` is visible | C0+C1 |
| DT11 | settings accepts System theme selection | the Settings branch opens with the light theme override | the user taps `System` | `Settings updated.` is visible | C0+C1 |
| DT12 | settings accepts Vietnamese locale selection | the Settings branch opens with English locale active | the user taps `Vietnamese` | `Settings updated.` is visible | C0+C1 |
| DT13 | study entry increment control respects the New Study max batch size | a seeded deck opens its study entry screen with SharedPreferences default New Study batch size seeded to `20` | the user taps `Increase batch size` | `Batch size: 20` remains visible and no session is started | C0+C1 |

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT10 | library accepts a second root folder after the first root folder exists | `E2E First Root Folder` already exists in the Library list | the user creates `E2E Second Root Folder` | both root folder rows are visible without widget exceptions | C0+C1 |
| DT11 | flashcard editor accepts multiline front and back content | an empty deck is open on the flashcard list route | the user creates a card with newline-separated front and back text | both multiline values are visible in the flashcard list | C0+C1 |
