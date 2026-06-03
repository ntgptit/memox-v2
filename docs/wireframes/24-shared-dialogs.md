---
last_updated: 2026-06-01
source_specs:
  - docs/business/resume/resume-session.md
  - docs/business/account-sync/account-sync.md
  - docs/business/bulk/bulk-operations.md
  - docs/business/folder/folder-management.md
  - docs/business/deck/deck-management.md
  - docs/business/flashcard/flashcard-management.md
  - docs/business/history/card-history.md
---

# 24 — Shared Dialogs Catalog

## Purpose

Reusable dialog patterns referenced across screens. Each dialog is identified by anchor (`§name`) and used by multiple screens. Defining them here once prevents drift.

## V1 implementation status — Prompt 27, 2026-06-01

Current V1 shared primitives are `MxDialog`, `MxConfirmationDialog`, `MxNameDialog`, and `MxDialogResumeOrStartOver`.

Current V1 return contracts are intentionally mixed:
- `MxConfirmationDialog.show(...)` returns `Future<bool>` where `true` means confirmed and `false` means Cancel/system dismissal.
- `MxNameDialog.show(...)` returns `Future<String?>` where a trimmed name means confirmed and `null` means Cancel/system dismissal.
- `MxDialogResumeOrStartOver.show(...)` returns typed `Future<MxResumeChoice?>` for the current multi-branch resume choice.

Future/Target complex multi-branch dialogs should prefer typed result classes or sealed variants instead of ambiguous raw primitives.

Current composed usages include destructive confirmations for flashcard/folder/deck/tag deletion, tag merge, study-session cancel/discard, account sign-out/disconnect, manual Drive upload/restore confirmation, Prompt 41 destructive Drive restore warning copy, dirty-editor discard, and resume/start-over conflict handling. These reuse existing owner screens and use cases; there is no standalone dialog gallery.

Target/Partial catalog items remain documented below but are not Current unless named in the Current list above. Strong-confirm typed input for account removal is Target only. The full restore-warning two-tier flow, Upload local first branch, second destructive confirmation, and pre-restore snapshot flow remain Partial/Target per `docs/business/account-sync/account-sync.md` and `docs/wireframes/19-settings-account.md`. V1 has no onboarding dialog or wizard flow.

## Invocation inputs

Shared dialogs and bottom-sheets receive only prepared view data and callbacks from the caller screen/notifier.

They must not load persistent data by themselves.

## Data dependencies

The caller owns data loading and mutation orchestration.

Shared dialogs and bottom-sheets may receive:
- immutable display data
- selected ids or labels
- validation state prepared by the caller
- callbacks for confirm/cancel/selection actions

They must not call DAO, repository, or use case directly.

## Catalog index

| Anchor | Use case |
| --- | --- |
| §resume-or-start-over | Resumable session detected when starting new |
| §discard-session | Discard a paused study session |
| §discard-changes | Unsaved form changes |
| §exit-session | Mid-session exit confirmation |
| §delete-confirm | Generic destructive delete |
| §bulk-delete | Multi-card delete |
| §reset-progress | Reset SRS for one card or in bulk |
| §rename | Rename an entity (folder, deck, device label) |
| §folder-create | Create a new folder |
| §restore-warning | Drive restore with fingerprint mismatch |

## Dialog patterns

All dialogs share the same Material 3 structure: title, body, optional inline warning region, action row right-aligned. Destructive actions use theme `error` color. Primary safe action is on the right; cancel on the left.

---

## §resume-or-start-over

Used by: study entry gate (12), Dashboard resume card secondary tap.

```
┌───────────────────────────────────────┐
│  Resume your last session?            │
├───────────────────────────────────────┤
│                                       │
│  You started a study session for      │
│  Korean N5 2 hours ago and answered   │
│  12 / 24 cards. Resume where you left │
│  off or start over?                   │
│                                       │
├───────────────────────────────────────┤
│  [ Start over ]  [ Cancel ]  [Resume] │
└───────────────────────────────────────┘
```

- Primary: Resume (right, default-focused).
- Secondary: Start over → triggers §discard-session next.
- Cancel → pop back to caller.

---

## §discard-session

Used by: §resume-or-start-over (Start over path), Dashboard resume card Discard, deck/folder banner Discard.

```
┌───────────────────────────────────────┐
│  Discard this session?                │
├───────────────────────────────────────┤
│                                       │
│  Your progress for these 12 answered  │
│  cards will be kept (they updated     │
│  your SRS), but the remaining 12      │
│  cards in this session will be reset. │
│                                       │
├───────────────────────────────────────┤
│        [ Cancel ]  [ Discard ]        │
└───────────────────────────────────────┘
```

- Primary destructive: Discard (right, theme error color).
- Confirm sets `study_sessions.status = cancelled`. Already-recorded `study_attempts` are preserved.

---

## §discard-changes

Used by: flashcard create (07), flashcard edit (08), deck import (10) cancel, any form with unsaved changes.

```
┌───────────────────────────────────────┐
│  Discard changes?                     │
├───────────────────────────────────────┤
│                                       │
│  You have unsaved changes. Leave      │
│  without saving?                      │
│                                       │
├───────────────────────────────────────┤
│       [ Keep editing ]  [ Discard ]   │
└───────────────────────────────────────┘
```

- Primary safe (default-focused): Keep editing.
- Destructive: Discard (theme error color).

---

## §exit-session

Used by: study session screens (13-17), tap ✕.

```
┌───────────────────────────────────────┐
│  Exit study session?                  │
├───────────────────────────────────────┤
│                                       │
│  Your progress for the 8 cards you've │
│  answered is saved. You can resume    │
│  the remaining cards later from the   │
│  Dashboard.                           │
│                                       │
├───────────────────────────────────────┤
│       [ Keep studying ]  [ Exit ]     │
└───────────────────────────────────────┘
```

- On Exit: session marked `in_progress` (default), remains resumable.
- If user has 0 answered: skip dialog and pop immediately.

---

## §delete-confirm

Used by: deck delete, folder delete, flashcard delete, tag delete, switch/remove account.

Generic shape:

```
┌───────────────────────────────────────┐
│  Delete {entity name}?                │
├───────────────────────────────────────┤
│                                       │
│  {entity-specific body copy}          │
│                                       │
│  This cannot be undone.               │
│                                       │
├───────────────────────────────────────┤
│        [ Cancel ]  [ Delete ]         │
└───────────────────────────────────────┘
```

### Variants

| Entity | Body copy |
| --- | --- |
| Folder | "Folder {name} and its {n} subfolders / {m} decks will be deleted. All flashcards inside will be deleted too." |
| Deck | "Deck {name} ({n} cards) will be deleted. All cards and their history will be deleted." |
| Flashcard | "This flashcard and its study history will be deleted." |
| Tag | "Tag #{name} will be removed from {n} cards. The cards themselves will be kept." |
| Switch/remove account | Strong variant — requires typed confirmation. |

### Strong variant (account removal)

**Target only.** This typed-confirm variant is not implemented in V1 and must not be exposed until account removal/switch-account scope is promoted with code, tests, and docs.

```
┌───────────────────────────────────────┐
│  ⚠ Remove account and erase data?     │
├───────────────────────────────────────┤
│                                       │
│  This will erase ALL data on this     │
│  device for giap@gmail.com.           │
│                                       │
│  Your Drive backup is NOT affected.   │
│                                       │
│  Type ERASE to confirm:               │
│  ┌─────────────────────────────────┐  │
│  │                                 │  │
│  └─────────────────────────────────┘  │
│                                       │
├───────────────────────────────────────┤
│  [ Cancel ]            [ Erase ]      │
└───────────────────────────────────────┘
```

Erase button disabled until the user types `ERASE` exactly.

---

## §bulk-delete

Used by: flashcard list (06) bulk delete.

```
┌───────────────────────────────────────┐
│  Delete {n} flashcards?               │
├───────────────────────────────────────┤
│                                       │
│  These cards and their study history  │
│  will be deleted. This cannot be      │
│  undone.                              │
│                                       │
├───────────────────────────────────────┤
│        [ Cancel ]  [ Delete {n} ]     │
└───────────────────────────────────────┘
```

Delete button shows count. Single transaction.

---

## §reset-progress

Used by: flashcard edit (08), flashcard history (09), bulk flashcard list (06).

Single variant:

```
┌───────────────────────────────────────┐
│  Reset progress for this card?        │
├───────────────────────────────────────┤
│                                       │
│  The card will return to box 1 and    │
│  be due immediately.                  │
│                                       │
│  Its study history is kept and        │
│  marked as "before reset" in the      │
│  card history timeline.               │
│                                       │
├───────────────────────────────────────┤
│        [ Cancel ]  [ Reset ]          │
└───────────────────────────────────────┘
```

Bulk variant:

```
┌───────────────────────────────────────┐
│  Reset progress for {n} cards?        │
├───────────────────────────────────────┤
│                                       │
│  All selected cards return to box 1   │
│  and are due immediately. Their       │
│  history is preserved.                │
│                                       │
├───────────────────────────────────────┤
│       [ Cancel ]  [ Reset {n} ]       │
└───────────────────────────────────────┘
```

On confirm: set `box = 1`, `due_at = now`, `last_reset_at = now` for each. Attempts unchanged.

---

## §rename

Used by: folder rename, deck rename, device label rename.

```
┌───────────────────────────────────────┐
│  Rename {entity}                      │
├───────────────────────────────────────┤
│                                       │
│  Name *                               │
│  ┌─────────────────────────────────┐  │
│  │ {current name}                  │  │  ← Pre-filled, full-selected
│  └─────────────────────────────────┘  │
│                                       │
├───────────────────────────────────────┤
│        [ Cancel ]  [ Rename ]         │
└───────────────────────────────────────┘
```

### Validation

| Rule | Message |
| --- | --- |
| Empty after trim | "{Entity} name is required." |
| Exceeds max length (per schema; current convention: folder/deck ≤ 100 chars, device label ≤ 50 chars; verify against `decks`/`folders` table constraints) | "Name too long (max {N})." |
| Duplicate name in same parent (folder/deck) | "A {entity} with this name already exists here." |

Rename button disabled until name is valid AND different from current.

---

## §folder-create

Used by: Library FAB and folder detail FAB. Future full onboarding or zero-content guidance may reuse this flow, but V1 has no standalone onboarding dialog or wizard.

```
┌───────────────────────────────────────┐
│  New folder                           │
├───────────────────────────────────────┤
│                                       │
│  Name *                               │
│  ┌─────────────────────────────────┐  │
│  │                                 │  │
│  └─────────────────────────────────┘  │
│                                       │
│  Parent                               │
│  Library / Korean ▾                  │  ← Tap to change parent
│                                       │
├───────────────────────────────────────┤
│        [ Cancel ]  [ Create ]         │
└───────────────────────────────────────┘
```

- Default parent = current screen's folder (or root).
- Tap parent → folder picker bottom-sheet to change.
- Parent picker filters to folders that allow subfolders (mode = subfolders or unlocked).
- Validation same as §rename.

---

## §restore-warning

Used by: settings account (19) Restore button when fingerprint differs.

**Partial/Target only.** Current V1 Account Settings has manual Drive upload/restore confirmation and a busy progress dialog. Prompt 41 adds stronger destructive restore warning copy, cancel/confirm protection, duplicate-running guard, and visible success/failure feedback, but it does not implement this two-tier restore-warning, Upload local first branch, second destructive confirmation, or pre-restore snapshot path.

Two-tier confirmation: primary "Upload local first" CTA + secondary "Restore anyway" requires second tap.

```
┌───────────────────────────────────────┐
│  ⚠  Restore from a different device?  │
├───────────────────────────────────────┤
│                                       │
│  This backup was made on:             │
│    Pixel 8 Pro · 2025-12-01 · 12.4 MB │
│                                       │
│  Your local data (last edited today)  │
│  will be REPLACED. This cannot be     │
│  undone.                              │
│                                       │
│  We recommend uploading your local    │
│  data to Drive first.                 │
│                                       │
│  ┌──────────────────────────────┐    │
│  │ ⬆ Upload local first         │    │  ← Primary (safe)
│  └──────────────────────────────┘    │
│                                       │
│  [ Restore anyway ]                   │  ← Tap once: button shifts to
│  [ Cancel ]                           │     "Tap again to confirm restore"
└───────────────────────────────────────┘
```

After first "Restore anyway" tap:

```
│  [ Tap again to confirm restore ]     │  ← Theme error color
│  [ Cancel ]                           │
```

Only the second tap triggers the destructive flow. Auto-revert to original "Restore anyway" after 5s timeout if not tapped again.

Then the snapshot phase modal (see 19-settings-account.md) runs. If snapshot fails, restore aborts.

When fingerprints match, this dialog still appears but the warning is softer and the "Upload first" CTA is replaced with "Restore now" as primary:

```
┌───────────────────────────────────────┐
│  Restore from Drive?                  │
├───────────────────────────────────────┤
│  This backup matches your device      │
│  (made 2h ago). Restoring will        │
│  replace your current data.           │
│                                       │
│  ┌──────────────────────────────┐    │
│  │ ⬇ Restore now                │    │
│  └──────────────────────────────┘    │
│                                       │
│  [ Cancel ]                           │
└───────────────────────────────────────┘
```

---

## Accessibility (cross-cutting)

- Each dialog MUST have an accessible name announced when it opens (the title).
- Body text MUST be in the dialog's accessibility tree, read after the title.
- Action buttons MUST have unique labels (no two "OK" buttons; use action verbs: "Delete", "Discard", "Reset").
- Destructive actions MUST be announced with their destructiveness, e.g., "Delete folder, destructive action".
- Focus order: title → body → safe action (Cancel/Keep) → destructive action.
- Default focus: safe action when dialog opens (so screen-reader users don't accidentally fire destructive).
- System back gesture MUST trigger Cancel, not the destructive action.
- For strong-variant destructive (typed confirmation): the input field MUST be focused after title is announced, with hint "Type ERASE to confirm".
- For §restore-warning two-tier confirmation, when that Target flow is implemented: the "Tap again to confirm" state MUST be announced via live region when it appears.

## Forbidden (catalog-level)

- ❌ Introduce a new dialog pattern without adding it to this catalog first.
- ❌ Promote §restore-warning to Current without the two-tier confirmation and 5s timeout.
- ❌ Use generic "Are you sure?" copy. Each dialog states the specific consequence.
- ❌ Apply strong-variant destructive (typed confirmation) outside account removal without a spec update.
- ❌ Hardcode dialog copy in widget. All strings from ARB (`error_*`, `dialog_*`).
- ❌ Show dialog from build method. Always from callback.
- ❌ Change Current V1 return contracts for catalog purity: `MxConfirmationDialog` returns `bool`, `MxNameDialog` returns `String?`, and `MxDialogResumeOrStartOver` returns typed `MxResumeChoice?`. For new complex dialogs, avoid ambiguous raw primitives when a typed result class or sealed variant is needed.

## Cross-cutting rules

- Default focus: safe action (Cancel or primary safe).
- Destructive actions: theme error color, right-aligned, secondary visual weight unless the dialog is explicitly destructive-first (e.g., §bulk-delete).
- All dialogs respect system back button (= Cancel).
- All dialogs are dismissible by tapping outside ONLY for non-destructive ones; destructive dialogs require explicit Cancel.
- Counts in titles MUST be live (recomputed on open) not stale.

## Agent rule

- Do NOT introduce new dialog patterns without adding them to this catalog first.
- Do NOT promote §restore-warning to Current without the two-tier confirmation and 5s timeout.
- Do NOT use generic "Are you sure?" copy. Each dialog states the specific consequence.
- Strong-variant destructive (typed confirmation) is reserved for account removal. Don't apply it elsewhere without spec update.
- Keep Current V1 shared dialog return contracts as documented above. For new complex multi-branch dialogs, prefer typed result classes or sealed variants when a primitive would be ambiguous.

## Implementation refs

**Business specs (per dialog):**
- §resume-or-start-over → `docs/business/resume/resume-session.md`
- §discard-session → `docs/business/resume/resume-session.md`
- §discard-changes → `docs/business/flashcard/flashcard-management.md` (and any form)
- §exit-session → `docs/business/study/study-flow.md`
- §delete-confirm → varies by entity (folder/deck/flashcard/tag/account)
- §bulk-delete → `docs/business/bulk/bulk-operations.md`
- §reset-progress → `docs/business/history/card-history.md`
- §rename → folder/deck/`docs/business/account-sync/account-sync.md` (device label)
- §folder-create → `docs/business/folder/folder-management.md`
- §restore-warning → `docs/business/account-sync/account-sync.md`

**Decision rows:**
- Dialog interaction rules (default focus, system-back semantics, 5s timeout for restore secondary confirm)

**Contracts:** Dialogs invoke use cases listed per spec above; primary refs: `docs/contracts/usecase-contracts/study.md` (resume/discard/finalize), `docs/contracts/usecase-contracts/folder.md`/`docs/contracts/usecase-contracts/deck.md`/`docs/contracts/usecase-contracts/flashcard.md` (delete + rename), `docs/contracts/usecase-contracts/bulk.md` (bulk-delete), `docs/contracts/usecase-contracts/history.md` (reset progress), `docs/contracts/usecase-contracts/account-sync.md` (restore-warning). UI behavior shaped by `docs/contracts/error-contract.md` recovery rules.

**Code paths:**
- Shared dialogs live under `lib/presentation/shared/dialogs/**` (each as its own widget file), built on `MxDialog` / `MxConfirmationDialog`.
- Naming: `MxDialogResumeOrStartOver`, `MxDialogDiscardSession`, `MxDialogDiscardChanges`, `MxDialogExitSession`, `MxDialogDeleteConfirm`, `MxDialogBulkDelete`, `MxDialogResetProgress`, `MxDialogRename`, `MxDialogFolderCreate`, `MxDialogRestoreWarning`
- Implemented so far: `MxDialogResumeOrStartOver` (`mx_dialog_resume_or_start_over.dart`, Prompt 05) returns typed `MxResumeChoice?`; §discard-session is composed from `MxConfirmationDialog` (danger tone) by the entry gate, Dashboard/Progress resume surfaces, and (Prompt 47) the deck/folder resume banners via the shared `confirmAndDiscardResumeSession` flow (`lib/presentation/shared/study/discard_resume_session.dart`).
- Return contracts follow the Current V1 list above: confirmation dialogs use `bool`, name dialogs use `String?`, and resume/start-over uses typed `MxResumeChoice?`.

**Related wireframes:**
- Used by virtually every screen; see "Used by:" list in each dialog section
