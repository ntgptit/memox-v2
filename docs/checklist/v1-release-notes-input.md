---
last_updated: 2026-06-02
status: current release docs package
source: docs/checklist/v1-release-readiness-cutline.md
---

# V1 Release Notes Input

This file is a concise release-note input for the MemoX V1 release candidate.
It summarizes the release cutline without promoting Future/Target work.

## A. Release Candidate Summary

MemoX V1 is a scoped personal flashcard learning app.

It supports folder/deck/card management, import, study sessions, SRS review,
progress overview, settings, TTS, account sync basics, and tag management.

It intentionally excludes Future features listed in this document and in
`docs/checklist/v1-release-readiness-cutline.md`.

## B. Shippable V1 Features

### Dashboard

- Shows due/new/mastery summary, recent decks, and current study entry actions.
- Surfaces resumable sessions, including the paused-sessions sheet.
- Starts Today, Deck, or Folder learning through current study entry flows.

### Library / Folder Detail

- Library is folders-first with top-level folders, recursive counts, and local search.
- Folder Detail browses child folders/decks with local search, sort, creation, and row actions.
- Invalid folder/deck ownership cases resolve to safe error or lock-mode feedback.

### Deck Management

- Supports folder-owned deck create, rename, move, delete, duplicate, export, and import entry.
- Keeps root-level deck creation out of V1.

### Flashcard List

- Shows deck cards with loading, error, empty, and no-results states.
- Supports local search, sort/reorder, row actions, and V1 bulk Delete/Move/Export flows.
- Owns study and import entry for the current deck.

### Flashcard Create/Edit

- Uses the shared editor for create and edit routes.
- Guards dirty exits and supports destination-aware saving.
- Uses the learned-content Keep/Reset policy dialog when progressed card text changes.

### Deck Import

- Imports CSV, structured text, and Excel content through the V1 inline preview flow.
- Validates rows before commit and writes accepted content transactionally.
- Initializes card progress and skips exact duplicates according to the current import rules.

### Study Entry

- Starts Deck, Folder, or Today study flows.
- Handles current empty-scope and resume/start-over cases safely.
- Keeps Tag entry blocked out of V1.

### Core Learning Loop

- Supports the frozen current study loop from entry through session completion.
- Persists study sessions and SRS outcomes through the current repository/use-case flow.
- Keeps the Leitner 8-box review behavior unchanged for V1.

### Study Session

- Supports Review, Match, Guess, Recall, and Fill modes.
- Provides current session exit protection and shared card actions.
- Finalizes sessions into the current result flow.

### Study Result

- Shows session summary, failed-finalize recovery, and Done routing.
- Provides Study more for Today/Deck/Folder through the current scope picker.
- Includes the current per-card review section.

### Progress Overview

- Shows due/new/mastery summary and active-session recovery.
- Supports Continue/Finalize/Retry/Cancel on recoverable sessions.
- Keeps analytics charts, history, and engagement widgets out of V1.

### Settings Hub

- Provides route-safe rows for Account, Learning, Audio/Speech, and Manage tags.
- Keeps Appearance and Language as disabled Future rows.
- Uses the current About dialog; the About bottom sheet remains Target.

### Account Settings

- Supports Google sign-in, sign-out, disconnect, and safe auth error handling.
- Supports manual Drive upload and manual Drive restore basics with destructive restore warning, cancel/confirm protection, duplicate-running guard, and visible restore success/failure feedback.
- Keeps full restore-protection features such as pre-restore snapshots, restore history, cloud comparison/conflict resolution, Upload local first, second destructive confirmation, and account-removal strong-confirm out of V1.

### Learning Settings

- Supports current study defaults and shared study toggles.
- Shows the runtime SRS interval table.
- Links to Manage tags.

### Audio/Speech Settings

- Supports current global/front-language TTS settings.
- Provides auto-play, front language, voice, rate, pitch, volume, and preview.
- Handles preview failures with safe feedback.

### Tag Management

- Shows global tag list/count with local search and V1 sort modes.
- Supports rename, merge, and delete through UseCase -> Repository -> DAO.
- Keeps Study/View tag actions out of V1.

### Shared Dialogs / Bottom Sheets

- Uses current shared primitives for confirmations, names, resume/start-over, bottom-sheet hosting, action lists, destination picking, and study card actions.
- Uses current composed sheets for paused sessions and Today/Deck/Folder study scope.
- Keeps the full target overlay catalog as Future/Target unless explicitly implemented.

## C. Partial But Accepted V1 Areas

- Library is folders-first; root-level decks remain Future.
- Dashboard has a static `0 days` streak stat placeholder only.
- Settings Hub has current rows and routes; some dynamic subtitles and the About sheet remain Target.
- Account manual Drive upload/restore exists with Prompt 41 current restore warning/guard/feedback; full restore-protection remains Target.
- Learning Settings has current study defaults; daily goal, streak, and reminders remain Future.
- Shared Dialogs/Bottom Sheets have current primitives; the full target catalog remains Future/Target.

## D. Explicitly Not Included In V1

- Global Search
- Flashcard History
- tag-scoped study
- full onboarding wizard
- root-level decks
- full restore-protection
- engagement/streak/daily goal/reminders
- independent TTS language tabs/settings
- strong-confirm account removal
- dedicated `SortOptionsSheet`
- active-session undo reinsert
- Dashboard-as-landing default boot behavior

## E. User-Facing Caveats

- Search is local to the current screen.
- Streak is shown as a simple placeholder, not a full engagement system.
- Tags can be managed, but studying by tag is not included.
- Drive sync is basic/manual; current restore warning/guard/feedback exists, but advanced restore protection is not complete.
- The app currently opens Library by default; Dashboard remains available from the Home tab.

## F. Internal Release Classification

Prompt 33 uses the existing cutline classification from
`docs/checklist/v1-release-readiness-cutline.md`: Current release docs package.
Future, Target, and Blocked rows remain excluded from the V1 release candidate.
