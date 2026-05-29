---
last_updated: 2026-05-29
applies_to: product scope
---

# MemoX Product Overview

## Product

MemoX is a local-first flashcard learning app.

It helps users:

- Manage folders (create, rename, move, delete, reorder).
- Manage decks (create, rename, move, delete, reorder, import, export). Each deck declares a target language.
- Manage flashcards (create, edit, delete, reorder, tag, import, export selected, bulk operations).
- Organize content hierarchically through folders.
- Tag cards and filter/study by tag.
- Study cards through multiple modes.
- Review due cards via spaced repetition (Leitner 8-box).
- Bury cards until tomorrow or suspend them indefinitely.
- Resume paused sessions from Dashboard.
- Set a daily goal and build a streak.
- Receive optional daily study reminders.
- Search/filter inside the current screen scope in V1; full global search is Future Proposal.
- View per-card history is Future Proposal, not V1 scope.
- Configure audio/speech (TTS) preferences for Korean and English.
- Optionally link a Google account for Drive AppData backup and restore with conflict protection.

## Feature spec coverage

This overview lists product capabilities. The detailed contract for each lives in a feature doc.

| Capability | Status | Spec location |
| --- | --- | --- |
| Folder CRUD + reorder + move | Specified | `docs/business/folder/folder-management.md` |
| Deck CRUD + reorder + target language | Specified | `docs/business/deck/deck-management.md` |
| Deck import | Specified | `docs/business/flashcard/flashcard-management.md` (import section) |
| Deck export | Specified | `docs/business/export/export.md` |
| Flashcard CRUD + tag | Specified | `docs/business/flashcard/flashcard-management.md` |
| Flashcard import preview/validation | Specified | `docs/business/flashcard/flashcard-management.md` (import section) |
| Flashcard selection export | Specified | `docs/business/export/export.md` |
| Study session | Specified | `docs/business/study/study-flow.md` |
| Resume / continue session | Specified | `docs/business/resume/resume-session.md` |
| Empty scope handling | Specified | `docs/business/study/study-flow.md` (empty scope matrix) |
| SRS review (Leitner 8-box) | Specified | `docs/business/srs/srs-review.md` |
| Bury / suspend cards | Specified | `docs/business/study-actions/bury-suspend.md` |
| Tag filter + study-by-tag + management | Specified | `docs/business/tags/tag-system.md` |
| Bulk operations on flashcards | Specified | `docs/business/bulk/bulk-operations.md` |
| Card history view | Future Proposal — Migration Required | `docs/business/history/card-history.md` |
| Inline/scope-local search | V1 guideline | `docs/business/search/global-search.md` |
| Global search screen | Future Proposal | `docs/business/search/global-search.md`, `docs/wireframes/11-library-search.md` |
| Zero-content guidance / thin onboarding | V1 guideline | `docs/wireframes/23-onboarding.md`, `docs/wireframes/01-dashboard.md`, `docs/wireframes/02-library.md` |
| Full onboarding flow | Future Proposal | `docs/wireframes/23-onboarding.md` |
| Daily goal + streak + reminders | Specified | `docs/business/engagement/dashboard-engagement.md` |
| Progress tracking | Partially specified | `docs/business/srs/srs-review.md` (data only) |
| TTS / audio settings | Specified | `docs/business/tts/tts-settings.md` |
| Account linking (Google) | Specified | `docs/business/account-sync/account-sync.md` |
| Drive sync (backup/restore with safety) | Specified | `docs/business/account-sync/account-sync.md` |
| Per-deck TTS override | Planned | not yet specified |
| Export with metadata (tags, SRS, etc.) | Out of scope | use Drive sync for backup |
| Multi-language TTS | Out of scope (current phase) | English/Korean only; deck `target_language` gates playback |

Agents must not implement capabilities outside this table without first creating or extending a spec doc. Agents also must not implement rows marked Future Proposal without promoting them in `docs/checklist/v1-implementation-scope-2026-05-29.md`.

## Product principles

- Local database is the source of truth.
- Login and backup are optional.
- Core learning must work offline.
- UX must be calm, fast, and mobile-first.
- UI must follow MemoX Design System.
- Business rules must live outside widgets.

## Main entities

See `docs/business/glossary.md` for full definitions.

| Entity | Meaning |
| --- | --- |
| Folder | Organizes subfolders or decks |
| Deck | Contains flashcards |
| Flashcard | Learning unit |
| Flashcard progress | SRS state |
| Study session | Persisted learning/review session |
| Study session item | One queued card task |
| Study attempt | One answer attempt |
| TTS settings | Audio/speech preferences |

## Main app areas

| Area | Responsibility |
| --- | --- |
| Dashboard | Daily summary and quick actions |
| Library | Content management and study entry |
| Progress | Learning progress |
| Settings | Hub for sub-areas below |

Settings sub-areas:

| Sub-area | Responsibility | Spec |
| --- | --- | --- |
| Account | Google account linking + Drive sync | `docs/business/account-sync/account-sync.md` |
| Learning | Study defaults | `docs/business/study/study-flow.md` |
| Audio/Speech | TTS settings | `docs/business/tts/tts-settings.md` |
| Appearance/Locale | Theme mode + language | (covered in code; no separate spec) |

## Study modes

See `docs/business/glossary.md` for the distinction between mode/type/flow.

- `review`
- `match`
- `guess`
- `recall`
- `fill`

## Agent rule

Do not add new product behavior without updating business docs, decision table, and tests.

## Related

**Wireframes:**
- `docs/wireframes/index.md` — screen map for all 25 wireframes corresponding to features here

**Schema:**
- `docs/database/schema-contract.md` — full schema including 6 pending migrations

**Decision table:**
- `docs/decision-tables/memox-core-decision-table.md` — full event-condition-expected matrix

**Related contracts:**
- `docs/architecture/clean-architecture-contract.md`
- `docs/state/state-management-contract.md`
- `docs/ui-ux/ui-ux-contract.md`
- `docs/database/storage-boundaries.md`
- `docs/database/migration-contract.md`

**Per-feature business spec:**
- See "Feature status" table above; each row links to its dedicated business doc.

**Source files to inspect:**
- `lib/main.dart`, `lib/app/**` (app shell, theme, router boot)
