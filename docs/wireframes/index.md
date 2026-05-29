---
last_updated: 2026-05-26
applies_to: all wireframes
---

# Wireframes Index

Each file in this folder describes one screen (or one tightly-related group of overlays). The wireframes are the visual contract between business specs in `../business/` and the implementation.

Conventions used in every wireframe doc:

- ASCII layout is the source of truth for visual structure.
- Mobile-first portrait (360×800dp baseline). Responsive notes for ≥600dp tablet.
- Every screen lists: purpose, layout, components, states, actions, dialogs/sheets, navigation in/out, source spec.
- Visual order in the ASCII matches DOM order.
- Each interactive element labels its trigger (`tap`, `long-press`, `swipe`).

## Screen map

### Shell + top-level tabs

| # | Screen | File |
| --- | --- | --- |
| 01 | Dashboard (/home) | `docs/wireframes/01-dashboard.md` |
| 02 | Library (/library) | `docs/wireframes/02-library.md` |
| 03 | Progress (/progress) | `docs/wireframes/03-progress.md` |
| 04 | Settings hub (/settings) | `docs/wireframes/04-settings-hub.md` |

### Library tree

| # | Screen | File |
| --- | --- | --- |
| 05 | Folder detail (/library/folder/:id) | `docs/wireframes/05-folder-detail.md` |
| 06 | Flashcard list (/library/deck/:deckId/flashcards) | `docs/wireframes/06-flashcard-list.md` |
| 07 | Flashcard create (/library/deck/:deckId/flashcards/new) | `docs/wireframes/07-flashcard-create.md` |
| 08 | Flashcard edit (/library/deck/:deckId/flashcards/:flashcardId/edit) | `docs/wireframes/08-flashcard-edit.md` |
| 09 | Flashcard history (/library/deck/:deckId/flashcards/:flashcardId/history) | `docs/wireframes/09-flashcard-history.md` |
| 10 | Deck import (/library/deck/:deckId/import) | `docs/wireframes/10-deck-import.md` |
| 11 | Library search (/library/search) | `docs/wireframes/11-library-search.md` |

### Study tree

| # | Screen | File |
| --- | --- | --- |
| 12 | Study entry gate (/library/study/:entryType/:entryRefId, /library/study/today) | `docs/wireframes/12-study-entry-gate.md` |
| 13 | Study session — Review mode | `docs/wireframes/13-study-session-review.md` |
| 14 | Study session — Match mode | `docs/wireframes/14-study-session-match.md` |
| 15 | Study session — Guess mode | `docs/wireframes/15-study-session-guess.md` |
| 16 | Study session — Recall mode | `docs/wireframes/16-study-session-recall.md` |
| 17 | Study session — Fill mode | `docs/wireframes/17-study-session-fill.md` |
| 18 | Study result (/library/study/session/:sessionId/result) | `docs/wireframes/18-study-result.md` |

### Settings tree

| # | Screen | File |
| --- | --- | --- |
| 19 | Account + Drive sync (/settings/account) | `docs/wireframes/19-settings-account.md` |
| 20 | Learning settings (/settings/learning) | `docs/wireframes/20-settings-learning.md` |
| 21 | Audio/Speech settings (/settings/audio-speech) | `docs/wireframes/21-settings-audio-speech.md` |
| 22 | Tag management (/settings/learning/tags) | `docs/wireframes/22-settings-tag-management.md` |

### Cross-cutting overlays

| # | Screen | File |
| --- | --- | --- |
| 23 | Onboarding (first launch / empty state) | `docs/wireframes/23-onboarding.md` |
| 24 | Shared dialogs catalog (resume, discard, confirm-destructive, restore-warning, etc.) | `docs/wireframes/24-shared-dialogs.md` |
| 25 | Shared bottom-sheets catalog (tag picker, move-to-deck, folder picker, deck create, folder create, daily-goal, reminder time) | `docs/wireframes/25-shared-bottom-sheets.md` |

## Reading order for new contributors

1. `docs/wireframes/01-dashboard.md` — entry point and most common screen.
2. `docs/wireframes/02-library.md` — content browsing.
3. `docs/wireframes/12-study-entry-gate.md` + one of `13-17` — study flow.
4. `docs/wireframes/24-shared-dialogs.md` and `docs/wireframes/25-shared-bottom-sheets.md` — reusable patterns.
5. Other screens as needed.

## Cross-references

- Routes: `docs/business/navigation/navigation-flow.md`
- Visual language (Slate Meridian theme, Plus Jakarta Sans): see app theme files.
- UI/UX rules (spacing, breakpoints 600dp/1024dp, calm-technology principles): `docs/ui-ux/ui-ux-contract.md`.
- State management for each screen: `docs/state/state-management-contract.md`.

## Cross-reference conventions

Every wireframe file ends with two sections that link to all required reading for that screen:

### `## Dialogs and bottom-sheets used`

Lists the specific shared dialog (24) and bottom-sheet (25) anchors used in this screen. AI agents implementing this screen MUST resolve these refs to avoid re-inventing shared widgets.

### `## Implementation refs`

A 4-block jump table:

- **Business specs** — required business doc reading
- **Decision rows** — which decision table sections govern behavior
- **Schema / storage** — exact column/key names this screen reads or writes
- **Code paths** — exact `lib/...` file paths where to implement
- **Related wireframes** — other screens in the same flow

If an agent reads only the relevant wireframe's `Implementation refs` block, plus the linked business spec for the feature, that should be sufficient to implement. No need to scan the entire `docs/business/**` tree.

This is enforced by `CLAUDE.md` §Doc-code parity rule.
