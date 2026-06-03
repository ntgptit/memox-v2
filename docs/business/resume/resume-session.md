---
last_updated: 2026-05-28
applies_to: resuming in-progress study sessions, conflict between resume and new session
---

# Resume Session

## Purpose

A study session can be interrupted at any moment (low battery, incoming call, app switch, crash). The user must be able to pick up exactly where they left off, with zero ceremony. This document spec'd the surfaces and rules.

## Source files to inspect

- `lib/data/datasources/local/tables/study_sessions_table.dart`
- `lib/data/datasources/local/tables/study_session_items_table.dart`
- `lib/domain/study/usecases/**` (look for resume/create session use cases)
- `lib/presentation/features/dashboard/**`
- `lib/presentation/features/study/**`
- `docs/business/study/study-flow.md` (session lifecycle)

## Definition

A "resumable session" is a study session whose status is `in_progress` (see `docs/business/glossary.md`).

Status `draft` is treated as resumable too (created but never started), but it should be rare; created sessions auto-advance to `in_progress` on first answer or first item display, depending on impl.

Statuses `ready_to_finalize`, `completed`, `cancelled`, `failed_to_finalize` are NOT resumable.

## Constraint

At most ONE resumable session may exist per scope at any time. Scope = `(entry_type, entry_ref_id)`.

When the user starts study on a scope that already has a resumable session, the system MUST NOT silently create a second session.

## Surfaces

### 1. Dashboard "Continue studying" card

If at least one resumable session exists, the Dashboard MUST show a "Continue studying" card at the top of the screen, above any other content.

Display:

| Element | Source |
| --- | --- |
| Title | "Continue studying" (l10n) |
| Subtitle | Scope label: deck name, folder name, or "Today's review" |
| Progress | "X / Y cards answered" derived from `study_session_items` |
| Last active | Relative time from `study_sessions.updated_at` (e.g., "2h ago") |
| Primary CTA | "Continue" → navigates to `/library/study/session/{sessionId}` |
| Secondary CTA | "Discard" → confirms then sets status to `cancelled` |

If multiple resumable sessions exist (e.g., user has paused 2 different deck sessions), show the most recently updated one as the card, with "{n - 1} more paused sessions" below leading to a list.

### 2. Deck / folder / tag context banner

When the user opens a screen whose scope has a resumable session:

| Screen | Behavior |
| --- | --- |
| Flashcard list (`/library/deck/:deckId/flashcards`) | Banner at top: "You have a paused study session for this deck. [Resume] [Discard]" |
| Folder detail (`/library/folder/:id`) | Banner at top: "You have a paused study session for this folder. [Resume] [Discard]" |
| Tag-filtered flashcard list or tag management entry for the same tag set | Banner: "You have a paused study session for {tagList}. [Resume] [Discard]" |
| Dashboard "Today" card | Replaced by "Continue today's review" if `entry_type=today` session is resumable |

Banner uses `MxBanner` or equivalent shared widget. Banner is dismissible per-visit (not persisted) but reappears next visit until session is finalized or cancelled.

Scope matching for tag sessions: a banner appears only when the user's current tag selection (as represented by sorted lowercased comma-joined tag names) exactly matches the resumable session's `entry_ref_id`.

### 3. Start study action conflict

When user taps "Start study" on a scope that already has a resumable session:

```mermaid
flowchart TD
    Tap[User taps Start study] --> Check{Resumable session<br/>exists for scope?}
    Check -->|no| CreateNew[Create new session]
    Check -->|yes| Dialog[Show Resume or Start over dialog]
    Dialog -->|Resume| OpenExisting[Navigate to existing session]
    Dialog -->|Start over| ConfirmDiscard[Confirm discard previous]
    ConfirmDiscard -->|cancel| Abort[No-op]
    ConfirmDiscard -->|confirm| CancelAndCreate[Set previous to cancelled, create new session]
    Dialog -->|Cancel| Abort
```

Dialog content:

| Element | Text (l10n) |
| --- | --- |
| Title | "Resume previous session?" |
| Body | "You started a study session for {scopeName} {relativeTime} ago and answered {x}/{y} cards. Resume where you left off or start over?" |
| Primary | "Resume" |
| Secondary | "Start over" |
| Cancel | "Cancel" |

"Start over" requires a second confirmation because it discards progress.

### 4. Cross-scope resume

Resumable sessions for different scopes coexist. Example:

- User pauses "Korean N5" deck session.
- User starts "Today's review" session → allowed, runs in parallel.
- Both sessions appear in Dashboard "more paused sessions" list.

## Resume use case behavior

On resume:

1. Load session record and all `study_session_items` with answered/unanswered flag.
2. Compute next item index from session state (do not re-derive from scratch; use persisted pointer if present, else first unanswered item by `sort_order`).
3. Open `StudySessionScreen` at the correct item.
4. Update `study_sessions.updated_at` to now.

The session resumes in its current `study_mode` from its `study_flow`. If the flow has multiple modes (e.g., `new_full_cycle`), the resumed mode is whichever was active when paused, persisted via session state.

## Cancel / discard behavior

When user discards a resumable session:

| Action | Outcome |
| --- | --- |
| Discard from Dashboard card | Confirm dialog → `study_sessions.status = cancelled`, items retained for analytics |
| Discard from banner | Confirm dialog → same as above |
| "Start over" path | Same as above, then create new session |

**Implementation status:** Discard from the deck (Flashcard list) and folder
(Folder detail) resume banners is **Current (Prompt 47)**. All three surfaces
(Dashboard card, deck banner, folder banner) share one flow,
`confirmAndDiscardResumeSession`
(`lib/presentation/shared/study/discard_resume_session.dart`): danger
`MxConfirmationDialog` → `CancelStudySessionUseCase` via
`progressSessionActionControllerProvider` (bumps `studySessionDataRevisionProvider`
so every banner refreshes away). Discard never creates a new session and adds no
schema/SRS change. Cancelling the confirmation does nothing. Tag-scoped banners
remain Future/Blocked (no `StudyEntryType.tag`).

Discarded sessions do NOT delete attempts. SRS progress already recorded for answered items in the cancelled session REMAINS (those reviews counted).

## Auto-expiry

A resumable session that has not been touched for **30 days** is auto-cancelled on next app open. The user is shown a one-time notice: "Your paused {scope} session expired and was discarded."

Rationale: prevents stale sessions from clogging UI indefinitely. 30 days is long enough to cover travel/illness but short enough to clean up abandoned sessions.

## Edge cases

| Case | Behavior |
| --- | --- |
| Resumable session, but scope entity deleted (deck removed) | Auto-cancel on next status load. Show notice "Your paused session for a deleted deck was discarded." |
| Resumable session with all items already answered, status stuck at `in_progress` | Treat as `ready_to_finalize` on resume; transition to finalize flow immediately |
| Multiple sessions for same scope (data corruption) | Resume the most recently updated; cancel others silently. Log the anomaly. |
| Resume while another session is `in_progress` on same device | Allowed; user can have multiple paused sessions, but only one open at a time |
| Resume after schema migration changed item structure | Validate item integrity; if invalid, cancel the session with notice |

## Notifications

If a resumable session is older than 1 day:

- Optional daily reminder includes "Continue your paused {scope} session" if user has notification permission and reminders enabled (see `docs/business/engagement/dashboard-engagement.md`).

This is opt-in via notification settings; do not push by default.

## Rules

- Resume MUST NOT create a new session; it reuses the existing one.
- Resume MUST update `updated_at` so the session does not auto-expire.
- "Continue studying" surface MUST appear before any "Start new" CTA on the same screen.
- Discard MUST require explicit confirmation.
- Resume from notification deep-links to `/library/study/session/{sessionId}` directly (skip Dashboard).
- Two sessions for the same scope MUST NEVER coexist in active state. Enforce at session creation use case.

## Required UI states

- Loading: while checking for resumable sessions.
- No resumable: hide all "Continue" surfaces (no empty card).
- One resumable: show single card/banner.
- Multiple resumable: show most recent + count of others.
- Cancelled mid-resume (race): show error state, route back to safe ancestor.

## Performance

- Resumable session check runs on every Dashboard load and on every deck/folder screen open. Must be cheap (single index lookup on `status` + `updated_at`).
- Compute progress (`x / y` answered) via SQL aggregate, not by loading all items into memory.

## Agent rule

- Do not implement "Start study" without first checking for resumable session in the scope.
- Do not silently overwrite a resumable session by creating a new one. Always confirm.
- Auto-expiry runs only on app open, not via background task. Do not add a scheduler for this.
- Resume surfaces (Dashboard card, banner, dialog) MUST share the same query source — do not implement three independent checks.

## Related

**Wireframes:**

- `docs/wireframes/01-dashboard.md` — Resume card on Dashboard (always above other CTAs when present)
- `docs/wireframes/05-folder-detail.md` — folder-scoped resume banner
- `docs/wireframes/06-flashcard-list.md` — deck-scoped resume banner
- `docs/wireframes/12-study-entry-gate.md` — resume-or-start-over routing logic
- `docs/wireframes/24-shared-dialogs.md` §resume-or-start-over, §discard-session
- `docs/wireframes/25-shared-bottom-sheets.md` §paused-sessions

**Schema:**

- `docs/database/schema-contract.md` → `study_sessions` (`status` in_progress / draft / completed / cancelled / failed_to_finalize; `started_at`, `entry_type`, `entry_ref_id`)

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "Resume session" (30-day expiry, scope match)

**Glossary terms:**

- `docs/business/glossary.md` → `study_sessions.status`, `entry_ref_id`, "resumable session", "paused session"

**Related business specs:**

- `docs/business/study/study-flow.md` — session lifecycle parent contract
- `docs/business/engagement/dashboard-engagement.md` — Dashboard Resume card consumer
- `docs/business/tags/tag-system.md` — tag-scope `entry_ref_id` format (sorted, comma-joined, lowercased)
- `docs/business/navigation/navigation-flow.md` — resume navigates with `push` to session; entry gate uses `pushReplacement`

**Source files to inspect (verified 2026-05-28):**

- Use cases live inside `lib/domain/study/usecases/study_usecases.dart`:
  - `ResumeStudySessionUseCase.listActiveSessions()` — multi-resume list query.
  - `ResumeStudySessionUseCase.findCandidate(StudyContext)` — find the most recent in-progress session matching the given entry scope.
  - `ResumeStudySessionUseCase.execute(sessionId)` — load and return the snapshot for an explicit resume.
  - `CancelStudySessionUseCase` — covers the "discard" path (sets status = `cancelled`).
  - `RestartStudySessionUseCase` — restart-from-scratch path.
- Repository: `lib/data/repositories/study_repo_impl.dart` (no separate `study_session_repository.dart` file; the implementation is the unified study repo).
- DAO: `lib/data/datasources/local/daos/` (look for the study session DAO; helpers in `lib/data/repositories/study_repo_impl_helpers.dart`).

> **Drift note**: earlier revisions referenced `find_resumable_session_usecase.dart`, `discard_session_usecase.dart`, and `study_session_repository.dart`. None of those paths exist today. The behaviors live in the methods listed above.
