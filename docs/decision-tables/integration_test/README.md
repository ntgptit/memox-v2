# Integration Test Decision Tables

This directory documents the executable E2E coverage for
`integration_test/app_test.dart`.

MemoX integration tests use one Flutter entrypoint:

```txt
integration_test/app_test.dart
```

Flow files under `integration_test/cases/**` are module tests imported by the
entrypoint. They must not initialize `IntegrationTestWidgetsFlutterBinding`
directly and must not be named `*_test.dart`.

## Executable Coverage Snapshot

Current executable Decision Table coverage for `integration_test/app_test.dart`:

| Area | Executable cases | Primary event boundaries |
| --- | ---: | --- |
| App shell | 4 | `onOpen`, `onNavigate` |
| Folder flow | 15 | `onOpen`, `onInsert`, `onDisplay`, `onUpdate`, `onDelete`, `onSearchFilterSort` |
| Deck flow | 14 | `onOpen`, `onInsert`, `onDisplay`, `onUpdate`, `onDelete`, `onSearchFilterSort` |
| Flashcard flow | 16 | `onOpen`, `onInsert`, `onDisplay`, `onUpdate`, `onDelete`, `onMove`, `onSelect`, `onSearchFilterSort` |
| Study flow | 7 | `onOpen`, `onDisplay`, `onUpdate`, `onNavigate` |
| Coverage expansion | 50 | `onOpen`, `onDisplay`, `onNavigate`, `onSearchFilterSort`, `onSelect`, `onUpdate`, `onInsert` |

Total executable E2E rows: 106.

Error and exception coverage is required. Missing route targets, missing
persistent entities, validation failures, and provider-load exceptions must be
represented by executable `DT` rows instead of being left to manual review.

## Required E2E Coverage

Persistent content flows must cover the business branches that are visible in
the UI, not only the CRUD happy path.

### App Shell

- Boot the real `MemoxApp` from the integration binding.
- Boot the same app shell on the compact viewport used by mobile-class layouts.
- Render the router error surface for an unknown initial route.
- Switch across Home, Library, Progress, and Settings from shell navigation.

### Folder Flow

- Create root folder.
- Cancel root folder creation.
- Render the folder detail error state when a deep link references a missing
  folder id.
- Create first subfolder and verify parent locks into subfolder mode.
- Open folder detail.
- Open first subfolder detail from its parent.
- Rename folder.
- Cancel folder rename.
- Confirm folder delete.
- Cancel folder delete.
- Confirm deleting a parent folder that already has a child folder.
- Search root folders by name.
- Clear search and restore results.
- Show no-results state for an unmatched folder search.
- Match root folder search case-insensitively.

### Deck Flow

- Create first deck in an unlocked folder.
- Create another deck in a deck-mode folder.
- Cancel deck creation.
- Render the flashcard-list error state when a deep link references a missing
  deck id.
- Open deck flashcard list.
- Rename deck.
- Duplicate deck and verify copied card count.
- Cancel deck rename.
- Confirm deck delete.
- Cancel deck delete and preserve flashcards.
- Search decks by name inside a folder.
- Clear deck search and restore rows.
- Match deck search case-insensitively.
- Show no-results state for an unmatched deck search.

### Flashcard Flow

- Create one flashcard in a deck.
- Save and add another flashcard without leaving deck context.
- Reject blank front/back content.
- Render the flashcard-list error state when its deck id is missing.
- Render the flashcard-editor error state when an edit route references a
  missing flashcard inside an existing deck.
- Open an existing flashcard for edit.
- Display created flashcard front/back text in the deck list.
- Save edited front/back content.
- Confirm single flashcard delete.
- Cancel single flashcard delete.
- Bulk delete selected flashcards.
- Move a selected flashcard to another deck.
- Select one flashcard without mutating content.
- Search flashcards by back text.
- Search flashcards by front text.
- Clear flashcard search and restore rows.

### Study Flow

- Show `Study now` for a seeded flashcard list.
- Render the study-session error state when the session id is missing.
- Open study entry from a seeded deck and verify default flow/settings display.
- Change study-entry batch size locally before the session starts.
- Switch to SRS Review flow before starting.
- Toggle study-entry session settings locally before starting.
- Start a study session from a seeded deck and verify review-mode content.

### Coverage Expansion Flow

- Deep-link directly into Home, Progress, Settings, Library, Today study, and
  create-flashcard routes.
- Render error surfaces for invalid study entry type, missing study result,
  missing flashcard edit entity, missing folder, missing deck, and unknown
  compact routes.
- Verify dashboard, progress, settings, library, folder, deck, flashcard, and
  study-entry display invariants.
- Navigate among shell destinations and empty-state actions.
- Trim search terms, clear no-result searches, and restore filtered rows for
  folder, deck, and flashcard lists.
- Select, expand, clear, and toggle flashcard selections.
- Update settings and pending study batch size without starting a session.
- Insert additional root folders and multiline flashcard content.

## Expansion Backlog

Add executable `DT` rows only when the matching test is committed in
`integration_test/cases/**`.

| Area | Candidate branch | Preferred event |
| --- | --- | --- |
| App shell | Deep-link directly to each top-level branch and recover the selected destination | `onOpen` |
| Folder flow | Reject blank folder names and preserve the dialog state | `onInsert` |
| Folder flow | Move a subfolder back to library root after creation | `onMove` |
| Deck flow | Reject blank deck names and preserve the dialog state | `onInsert` |
| Deck flow | Move a deck into another valid folder | `onMove` |
| Flashcard flow | Cancel moving selected flashcards and keep source deck unchanged | `onMove` |
| Flashcard flow | Select all visible flashcards and clear selection | `onSelect` |
| Study flow | Cancel study entry by navigating back before session creation | `onNavigate` |
| Study flow | Complete review mode and finalize the result screen | `onUpdate` |
| Study flow | Open Progress after starting a session and resume the active session | `onNavigate` |

## Non-E2E Boundaries

The following branches are intentionally better covered by focused widget,
provider, repository, or unit tests rather than Windows E2E:

- Native share sheets for export.
- File picker or platform file access for import.
- Low-level database cascade implementation.
- SRS box and due-date commit math.
- Drag precision for reorder when a lower-level test can assert the ordered ids
  without depending on desktop pointer timing.

If any of these behaviors become critical user journeys, add a stable E2E case
and a matching Decision Table row before relying on it in release verification.
