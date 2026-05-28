---
last_updated: 2026-05-26
source_specs:
  - docs/business/folder/folder-management.md
  - docs/business/deck/deck-management.md
  - docs/business/tags/tag-system.md
  - docs/business/study/study-flow.md
  - docs/business/resume/resume-session.md
  - docs/business/engagement/dashboard-engagement.md
---

# 25 — Shared Bottom-Sheets Catalog

## Purpose

Reusable bottom-sheet patterns. Identified by anchor (`§name`). Bottom-sheets are preferred over dialogs when:

- Multiple choice (radio / multi-select / list picker).
- Action menu with > 3 items.
- Inline content longer than 3-4 lines (e.g., a list).

Dialogs (24) are for binary confirmations or short forms.

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
| §paused-sessions | List all resumable sessions |
| §streak-history | Streak calendar / history view |
| §daily-goal | Adjust daily goal slider |
| §reminder-time | Pick reminder time |
| §scope-picker | Pick what to study (deck / folder / tag / today) |
| §library-fab | Library FAB action menu |
| §deck-create | Create a new deck (with target_language) |
| §item-context | Context actions for a folder or deck row |
| §card-context | Context actions for a flashcard row (single, not bulk) |
| §folder-picker | Pick a folder destination |
| §deck-picker | Pick a deck destination |
| §filter-status | Status filter picker for flashcard list |
| §tag-picker | Multi-select tag picker |
| §undo-toast | Undoable action toast (snackbar variant) |
| §about | App info, version, licenses |

## Common structure

Material 3 modal bottom-sheet. Drag handle on top. Title row (optional). Body. Action row at bottom for confirm flows. Tap outside or drag down to dismiss (when non-confirmation).

```
┌───────────────────────────────────────┐
│         ─── drag handle ───           │
│                                       │
│ Title (optional)                  ✕   │  ← Close button optional
│                                       │
│ {body content}                        │
│                                       │
│ [ Action 1 ]    [ Action 2 ]          │  ← When confirm needed
└───────────────────────────────────────┘
```

---

## §paused-sessions

Used by: Dashboard resume card "{n-1} more paused sessions" link.

```
┌───────────────────────────────────────┐
│         ─────                         │
│                                       │
│ Paused sessions (3)               ✕   │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ Korean N5                         │ │
│ │ 12 / 24 cards · 2h ago            │ │
│ │ [ Resume ]  [ Discard ]           │ │
│ ├───────────────────────────────────┤ │
│ │ English Idioms                    │ │
│ │ 8 / 20 cards · yesterday          │ │
│ │ [ Resume ]  [ Discard ]           │ │
│ ├───────────────────────────────────┤ │
│ │ #weak                             │ │
│ │ 3 / 15 cards · 3 days ago         │ │
│ │ [ Resume ]  [ Discard ]           │ │
│ └───────────────────────────────────┘ │
│                                       │
└───────────────────────────────────────┘
```

- Discard triggers `docs/wireframes/24-shared-dialogs.md` §discard-session.
- Resume navigates to session via push, closing sheet.
- Auto-expired sessions (> 30 days) are excluded here (auto-cancelled).

---

## §streak-history

Used by: Dashboard streak chip, study result streak block.

```
┌───────────────────────────────────────┐
│         ─────                         │
│                                       │
│ Streak history                    ✕   │
│                                       │
│ 🔥 Current: 7 days                    │
│ ⭐ Longest: 14 days                    │
│                                       │
│ Last 30 days                          │
│ ┌───────────────────────────────────┐ │
│ │   M  T  W  T  F  S  S             │ │  ← Calendar grid
│ │   ✓  ✓  ✓  ✓  ─  ─  ✓             │ │     ✓ = goal met
│ │   ✓  ✓  ✓  ✓  ✓  ✓  ✓             │ │     ─ = not met
│ │   ✓  ✓  ─  ✓  ...                 │ │
│ └───────────────────────────────────┘ │
│                                       │
│ Goal: 20 cards/day                    │
│                                       │
└───────────────────────────────────────┘
```

- Read-only.
- Tap any day → toast "{date}: {n} cards" (optional).

---

## §daily-goal

Used by: Dashboard goal ring tap, Settings Learning row.

```
┌───────────────────────────────────────┐
│         ─────                         │
│                                       │
│ Daily goal                        ✕   │
│                                       │
│ Cards per day                         │
│ ◀── ━━━━━━●━━━━━━ ──▶                 │
│           20                          │
│                                       │
│ ⓘ Range 5–200, step 5. Aim for what   │
│   you can do consistently.            │
│                                       │
│        [ Cancel ]  [ Save ]           │
└───────────────────────────────────────┘
```

- Save persists to preferences and recomputes Dashboard ring.
- Cancel reverts.

---

## §reminder-time

Used by: Settings Learning row tap on time.

Platform-native time picker preferred. If not available, a bottom-sheet variant:

```
┌───────────────────────────────────────┐
│         ─────                         │
│                                       │
│ Reminder time                     ✕   │
│                                       │
│      ┌───────┐   ┌───────┐            │
│      │   8   │ : │   00  │  PM ▾      │
│      └───────┘   └───────┘            │
│                                       │
│ ⓘ Reminder fires in your local        │
│   timezone.                           │
│                                       │
│        [ Cancel ]  [ Save ]           │
└───────────────────────────────────────┘
```

- Save persists time + reschedules notification.

---

## §scope-picker

Used by: Dashboard "Start new learning" CTA, study result "Study more" CTA.

```
┌───────────────────────────────────────┐
│         ─────                         │
│                                       │
│ What do you want to study?       ✕    │
│                                       │
│ ┌─[ Today ]─[ Deck ]─[ Folder ]─[ Tag ]┐
│ └───────────────────────────────────┘ │
│                                       │
│ ── Today tab ──                       │
│   18 cards due across 3 decks         │
│   [ Start ]                           │
│                                       │
│ ── Deck tab ──                        │
│   Search decks                        │
│   List of decks (radio)               │
│   [ Start ]                           │
│                                       │
│ ── Folder tab ──                      │
│   Search folders                      │
│   List of folders (radio)             │
│   [ Start ]                           │
│                                       │
│ ── Tag tab ──                         │
│   Multi-select tag chips              │
│   "All selected cards (AND)"          │
│   [ Start ]                           │
│                                       │
└───────────────────────────────────────┘
```

- Start CTA navigates to study entry gate with chosen scope.
- Tag tab uses lowercased comma-joined sorted tag names as `entry_ref_id`.

---

## §library-fab

Used by: Library (02) FAB tap.

```
┌───────────────────────────────────────┐
│         ─────                         │
│                                       │
│  📁 New folder                        │
│  📚 New deck                          │
│  ⬇ Import from CSV / Excel            │
│  ─────────────────────────────────    │
│  ✕ Cancel                             │
└───────────────────────────────────────┘
```

- New folder → §folder-create dialog (24).
- New deck → §deck-create bottom-sheet.
- Import → pick destination deck flow → deck import screen.

---

## §deck-create

Used by: Library FAB, folder detail FAB (when in decks/unlocked mode), onboarding paths.

```
┌───────────────────────────────────────┐
│         ─────                         │
│                                       │
│ New deck                          ✕   │
│                                       │
│ Name *                                │
│ ┌─────────────────────────────────┐   │
│ │                                 │   │
│ └─────────────────────────────────┘   │
│                                       │
│ Target language *                     │
│ ◉ Korean                               │
│ ○ English                              │
│ ○ Unsupported (no TTS)                │
│                                       │
│ Parent folder                         │
│ Library / Korean ▾                   │  ← Folder picker
│                                       │
│ ⓘ The target language controls        │
│   speech support. You can change it   │
│   later in Edit deck.                 │
│                                       │
│        [ Cancel ]  [ Create ]         │
└───────────────────────────────────────┘
```

- Default parent = caller context.
- On Create: create deck, navigate to flashcard list of new deck (with first-card empty state CTA).

### Validation

| Rule | Message |
| --- | --- |
| Name empty | "Deck name is required." |
| Name > 100 chars | "Deck name too long (max 100)." |
| Duplicate name in same parent | "A deck with this name already exists in this folder." |
| Parent mode = subfolders (locked) | Parent picker filters this out; can't reach. |

---

## §item-context

Used by: Library row long-press, folder detail row long-press.

```
┌───────────────────────────────────────┐
│         ─────                         │
│                                       │
│ {entity name}                         │
│ {Folder / Deck} · {subtitle}          │
│                                       │
│ ✏ Rename                              │
│ 📦 Move to folder                     │
│ 🗑 Delete                              │
│ ─────────────────────────────────     │
│ ✕ Cancel                              │
└───────────────────────────────────────┘
```

For decks, add:
```
│ ⬇ Export                              │
│ ⬇ Import                              │
```

---

## §card-context

Used by: flashcard row long-press alternative (when not in selection mode), card menu in study session.

```
┌───────────────────────────────────────┐
│         ─────                         │
│                                       │
│ {front truncated}                     │
│ {back truncated}                      │
│                                       │
│ ✏ Edit                                 │
│ 📊 View history                       │
│ ⏸ Suspend / ⏯ Unsuspend                │
│ 🌙 Bury until tomorrow                │
│ ↻ Reset progress                      │
│ 📦 Move to deck                       │
│ 🗑 Delete                              │
│ ─────────────────────────────────     │
│ ✕ Cancel                              │
└───────────────────────────────────────┘
```

In study session, omit Edit (already in study context) and add "End session here".

---

## §folder-picker

Used by: move folder, move deck, move card (target folder of new deck location), deck create parent picker.

```
┌───────────────────────────────────────┐
│         ─────                         │
│                                       │
│ Move to folder                    ✕   │
│                                       │
│ ┌─ 🔍 Search folders... ─────────────┐│
│ └───────────────────────────────────┘ │
│                                       │
│ ◉ Library (root)                       │
│ ○ Library / Korean                     │
│ ○ Library / Korean / Grammar           │
│ ○ Library / English                     │
│ ○ ...                                  │
│                                       │
│ ⓘ Disabled folders are locked to       │
│   {subfolders|decks} mode and don't   │
│   accept this item.                   │
│                                       │
│        [ Cancel ]  [ Move ]           │
└───────────────────────────────────────┘
```

- Disabled rows greyed with reason.
- Default selection = current parent.

---

## §deck-picker

Used by: move card, bulk move cards, import target deck pre-step.

```
┌───────────────────────────────────────┐
│         ─────                         │
│                                       │
│ Move to deck                      ✕   │
│                                       │
│ ┌─ 🔍 Search decks... ───────────────┐│
│ └───────────────────────────────────┘ │
│                                       │
│ ◉ Korean N5 (current)                  │
│ ○ Korean N4                            │
│ ○ Korean Honorifics                    │
│ ○ English Idioms                       │
│ ○ ...                                  │
│                                       │
│ ⓘ Card progress and tags transfer     │
│   with the card.                      │
│                                       │
│        [ Cancel ]  [ Move ]           │
└───────────────────────────────────────┘
```

---

## §filter-status

Used by: flashcard list (06) filter dropdown.

```
┌───────────────────────────────────────┐
│         ─────                         │
│                                       │
│ Show                              ✕   │
│                                       │
│ ◉ All                                  │
│ ○ Active                               │
│ ○ Due                                  │
│ ○ Suspended                            │
│ ○ Buried                               │
│                                       │
│        [ Cancel ]  [ Apply ]          │
└───────────────────────────────────────┘
```

- Single-select.
- On Apply: URL updates with `?filter=...`.

---

## §tag-picker

Used by: flashcard list (06) tag filter chip, scope picker tag tab, bulk add/remove tag, tag input on create/edit.

```
┌───────────────────────────────────────┐
│         ─────                         │
│                                       │
│ Pick tags                         ✕   │
│                                       │
│ ┌─ 🔍 Search or create... ───────────┐│
│ └───────────────────────────────────┘ │
│                                       │
│ Selected (2)                          │
│ #verb ×    #N5 ×                      │  ← Chips with × to remove
│                                       │
│ Suggested                             │
│ ☐ #greet     42                       │
│ ☑ #verb      80                       │
│ ☐ #adj       30                       │
│ ☑ #N5        60                       │
│ ☐ #weak      12                       │
│                                       │
│ + Create "#new-tag"                   │  ← Visible iff search doesn't match
│                                       │
│        [ Cancel ]  [ Apply ]          │
└───────────────────────────────────────┘
```

- Multi-select via checkboxes.
- Selection is AND filter (per spec).
- Create new tag inline iff search text doesn't match existing tag (case-insensitive).
- Validation per `docs/business/tags/tag-system.md`: no commas, max 50 chars.
- Apply persists selection to caller context.

### Mode variants

| Caller | Behavior difference |
| --- | --- |
| Filter | Apply sets filter for current list. |
| Scope picker tag tab | Apply uses lowercased comma-joined sorted as `entry_ref_id`. |
| Bulk add tag | Apply adds selected tags to all selected cards (transaction). |
| Bulk remove tag | List filtered to tags present on selection only. Apply removes. |
| Card tag input | Apply replaces card's tag list with selected set. |

---

## §undo-toast

Used by: bury, suspend, bulk non-destructive actions, single non-destructive actions.

Material 3 snackbar variant. Bottom-aligned, above bottom nav if visible.

```
┌───────────────────────────────────────┐
│ Card buried until tomorrow.   [Undo]  │
└───────────────────────────────────────┘
```

- Visible 5 seconds, then auto-dismisses.
- Tap Undo within 5s: reverse the operation (single transaction).
- Multiple toasts queue rather than stack.

### Actions covered

| Action | Toast copy | Undo behavior |
| --- | --- | --- |
| Bury single | "Card buried until tomorrow." | Restore `buried_until = NULL`. |
| Bury bulk | "{n} cards buried until tomorrow." | Restore for all. |
| Suspend single | "Card suspended." | Restore `is_suspended = false`. |
| Suspend bulk | "{n} cards suspended." | Restore for all. |
| Unsuspend single | "Card resumed." | Re-suspend. |
| Bulk add tag | "{n} cards tagged #{tag}." | Remove tag from all. |
| Bulk remove tag | "{n} cards untagged #{tag}." | Re-add tag. |
| Bulk move | "{n} cards moved to {deck}." | Move back. |

Destructive ops (bulk delete, single delete, reset progress) do NOT get undo toasts — they use confirm dialogs instead.

---

## §about

Used by: Settings hub About row.

```
┌───────────────────────────────────────┐
│         ─────                         │
│                                       │
│       ╱─────────╲                     │
│      │  MemoX   │                     │
│       ╲─────────╱                     │
│                                       │
│         Version 1.0.0                 │
│                                       │
│ Open-source libraries                 │
│ Privacy policy                        │
│ Send feedback                         │
│ View on GitHub                        │
│                                       │
│ Made with care for memory.            │
│                                       │
└───────────────────────────────────────┘
```

Each link opens browser or in-app web view.

---

## Accessibility (cross-cutting)

- Each bottom-sheet MUST announce its title when opened.
- Drag handle MUST have accessible label "Drag to dismiss" or equivalent, and a tap on it MUST also dismiss for users who can't drag.
- Close button (✕) MUST be focusable and labeled "Close".
- Focus order: title → primary content (list/form) → action row at bottom.
- For multi-select sheets (e.g., §tag-picker): each checkbox MUST announce its label and state ("Checked, #verb, 80 cards" / "Not checked, #greet, 42 cards").
- For radio pickers (e.g., §folder-picker, §deck-picker, §filter-status): selection MUST announce on change ("Selected: Library / Korean").
- For action menus (e.g., §library-fab, §item-context, §card-context): each row is a button with clear action verb in its label.
- For toast variants (§undo-toast): the toast MUST be announced via live region (assertive politeness) so screen-reader users hear it before it dismisses. Undo button MUST remain focusable for the full 5s.
- For confirmation flows inside sheets (e.g., §deck-create with Create button): Save/Create button enabled/disabled state MUST be announced when state changes.
- Disabled rows (e.g., locked folders in §folder-picker) MUST announce reason: "Disabled, this folder is locked to decks mode".
- System back gesture MUST dismiss the sheet, equivalent to tap-outside or Cancel.

## Forbidden (catalog-level)

- ❌ Replace dialogs with bottom-sheets for binary confirmations. Use right pattern.
- ❌ Introduce a new bottom-sheet without adding it to this catalog first.
- ❌ Tweak undo toast duration per action. Exactly 5s.
- ❌ Skip inline validation in §tag-picker. Reject comma + over-50-chars before Apply.
- ❌ Hide invalid destinations in pickers. Disable them with reason; disabling teaches the rule.
- ❌ Stack toasts. Queue rather than stack.
- ❌ Use bottom-sheet for a single-line input (use dialog).
- ❌ Hardcode sheet copy. All strings from ARB.

## Cross-cutting rules

- Bottom-sheets MUST be dismissible by drag-down OR tap outside, unless they're in a destructive confirm sub-flow.
- All bottom-sheets MUST have a drag handle visible.
- Maximum height = 90% of screen; longer content scrolls inside the sheet.
- Confirmation flows in bottom-sheets show actions sticky at bottom.

## Agent rule

- Do NOT replace dialogs with bottom-sheets for binary confirmations. Use the right pattern.
- Do NOT introduce new bottom-sheets without adding them here first.
- Undo toast duration is exactly 5s. Do not tweak per action.
- Tag picker MUST validate inline (no commas, max length); rejection visible before Apply.
- Folder/deck pickers MUST disable invalid destinations (mode rules), not hide them — disabling teaches the rule.

## Implementation refs

**Business specs (per sheet):**
- §paused-sessions, §scope-picker → `docs/business/study/study-flow.md`, `docs/business/resume/resume-session.md`
- §streak-history, §daily-goal, §reminder-time → `docs/business/engagement/dashboard-engagement.md`
- §library-fab → `docs/business/folder/folder-management.md`, `docs/business/deck/deck-management.md`
- §deck-create → `docs/business/deck/deck-management.md`
- §item-context, §card-context → respective business specs
- §folder-picker, §deck-picker → `docs/business/folder/folder-management.md`, `docs/business/deck/deck-management.md`
- §filter-status → `docs/business/flashcard/flashcard-management.md`, `docs/business/study-actions/bury-suspend.md`
- §tag-picker → `docs/business/tags/tag-system.md`
- §undo-toast → `docs/business/bulk/bulk-operations.md`, `docs/business/study-actions/bury-suspend.md`
- §about → app metadata

**Decision rows:**
- Sheet interaction rules (drag handle, dismiss semantics, undo toast 5s timeout, locked-row disabling)

**Contracts:** Sheets are dispatched from screens to invoke use cases per anchor. Primary refs across the catalog: `docs/contracts/usecase-contracts/study.md` (paused-sessions, scope-picker), `docs/contracts/usecase-contracts/engagement.md` (streak-history, daily-goal, reminder-time), `docs/contracts/usecase-contracts/folder.md`/`docs/contracts/usecase-contracts/deck.md` (library-fab, deck-create, item-context, folder-picker, deck-picker), `docs/contracts/usecase-contracts/tag.md` (tag-picker), `docs/contracts/usecase-contracts/bulk.md` + `docs/contracts/usecase-contracts/study.md` §bury/suspend (undo-toast).

**Code paths:**
- `lib/core/widgets/sheets/**`
- Naming: `MxSheetPausedSessions`, `MxSheetStreakHistory`, `MxSheetDailyGoal`, `MxSheetReminderTime`, `MxSheetScopePicker`, `MxSheetLibraryFab`, `MxSheetDeckCreate`, `MxSheetItemContext`, `MxSheetCardContext`, `MxSheetFolderPicker`, `MxSheetDeckPicker`, `MxSheetFilterStatus`, `MxSheetTagPicker`, `MxSheetAbout`
- Undo toast: `MxUndoToast` widget + `UndoToastController` provider with 5s timer

**Related wireframes:**
- Used by virtually every screen; see "Used by:" list in each sheet section
