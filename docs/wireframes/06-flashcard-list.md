---
last_updated: 2026-05-26
route: /library/deck/:deckId/flashcards
source_specs:
  - docs/business/flashcard/flashcard-management.md
  - docs/business/deck/deck-management.md
  - docs/business/study-actions/bury-suspend.md
  - docs/business/tags/tag-system.md
  - docs/business/bulk/bulk-operations.md
  - docs/business/resume/resume-session.md
---

# 06 — Flashcard List

## Purpose

Manage flashcards in one deck: browse, filter, edit, multi-select for bulk operations. Primary launch point for deck-level study.

## Layout — normal mode

```
┌───────────────────────────────────────┐
│ ← Korean N5                    🔍  ⋮  │
├───────────────────────────────────────┤
│ Library / Korean / N5                 │
│ 42 cards · Korean target language     │  ← Subtitle = total + lang
├───────────────────────────────────────┤
│                                       │
│ ⚠ You have a paused study session     │  ← RESUME BANNER (when applicable)
│   for this deck.                      │
│   [Resume]  [Discard]                 │
├───────────────────────────────────────┤
│                                       │
│ ┌─────────────────┐  ┌─────────────┐ │
│ │ Study deck      │  │ Today (12)  │ │  ← Deck-level study CTAs
│ │ ▸               │  │ ▸           │ │
│ └─────────────────┘  └─────────────┘ │
│                                       │
│ ┌──────────────────────────────────┐  │
│ │ Filter: All ▾   Tag: + Add tag▾  │  │  ← Filter row (status + tag)
│ └──────────────────────────────────┘  │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ 안녕하세요             #greet     │ │  ← Card row: front + tags + state
│ │ Hello                             │ │     back as subtitle
│ ├───────────────────────────────────┤ │
│ │ 감사합니다            #greet      │ │
│ │ Thank you                         │ │
│ ├───────────────────────────────────┤ │
│ │ 미안합니다     🔇 SUSPENDED       │ │  ← Suspended badge
│ │ Sorry                             │ │
│ ├───────────────────────────────────┤ │
│ │ 사랑해요       🌙 BURIED TODAY    │ │  ← Buried badge
│ │ I love you                        │ │
│ └───────────────────────────────────┘ │
│                                       │
│                            ┌───┐      │
│                            │ + │      │  ← FAB
│                            └───┘      │
└───────────────────────────────────────┘
```

## Layout — selection mode

```
┌───────────────────────────────────────┐
│ ✕   3 selected             [Select all]│  ← Selection app bar
├───────────────────────────────────────┤
│                                       │
│ ☑ 안녕하세요          #greet         │  ← Checkbox replaces leading
│ ☑ 감사합니다          #greet         │
│ ☐ 미안합니다          🔇             │
│ ☑ 사랑해요            🌙             │
│ ☐ ...                                 │
│                                       │
├───────────────────────────────────────┤
│ 🗑  📦   🏷+   🏷-   ⏸    ⏯    ↻      │  ← Bulk action bar
│ del move tag+ tag- susp unsusp reset  │
└───────────────────────────────────────┘
```

## Layout — empty state (no flashcards)

```
┌───────────────────────────────────────┐
│ ← Korean N5                    🔍  ⋮  │
├───────────────────────────────────────┤
│ Library / Korean / N5                 │
├───────────────────────────────────────┤
│                                       │
│              🃏                        │
│                                       │
│      No flashcards yet                │
│                                       │
│   Add cards manually or import from   │
│   a file.                             │
│                                       │
│   ┌──────────────────────────────┐   │
│   │ + Add flashcard              │   │
│   └──────────────────────────────┘   │
│   ┌──────────────────────────────┐   │
│   │ ⬇ Import from CSV / Excel    │   │
│   └──────────────────────────────┘   │
│                                       │
└───────────────────────────────────────┘
```

## Layout — filtered empty state

```
┌───────────────────────────────────────┐
│ ← Korean N5                    🔍  ⋮  │
├───────────────────────────────────────┤
│ Filter: Suspended ▾   Tag: #weak ▾   │
├───────────────────────────────────────┤
│                                       │
│              🃏                        │
│                                       │
│   No cards match these filters.       │
│                                       │
│   [Clear filters]                     │
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `deckId` (required path param) | URL | resolves to `decks.id`; 404 if invalid |
| `filter` (optional query) | URL | one of: `all`, `active`, `due`, `suspended`, `buried`. Default `all`. |
| `tag[]` (optional, repeatable) | URL | multi-select AND filter |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Deck detail (name, target_language, count, parent path) | `decks` + folder chain | watch |
| Flashcards filtered | `flashcards JOIN flashcard_progress JOIN flashcard_tags` with WHERE clause matching filters | stream |
| Tag list for current deck (for filter chip) | distinct tags in deck | watch |
| Resumable session for this deck | `study_sessions WHERE entry_type='deck' AND entry_ref_id=:deckId AND status IN (draft, in_progress)` | watch |
| Today's due count for deck (for Today CTA subtitle) | filtered query | watch |
| Per-row computed `CardState` (Suspended > Buried > Due > Active) | derived from flashcard_progress | watch |
| Selection state (mode + selected IDs) | in-memory (NotifierState) | local |

## Forbidden

- ❌ Show note/example/pronunciation/hint inline in row.
- ❌ Remove the resume banner after one view. It persists until session resumed or discarded.
- ❌ Long-press → open context sheet directly. Long-press MUST enter selection mode.
- ❌ Bulk action applies to filtered-out cards. Snapshot selected IDs at confirmation time.
- ❌ "Select all" select beyond filtered set.
- ❌ Persist selection across navigation. Selection is ephemeral.
- ❌ Compute `CardState` on render. Use repository or use case.
- ❌ Hardcode the priority rule in widget. Use shared `CardStateComputer`.

## Components

| Component | Spec |
| --- | --- |
| App bar | Title = deck name. Back. Search (in-deck). Overflow ⋮. |
| Breadcrumb subtitle | "Library / {folderPath} / {deckName}". 2nd line "{n} cards · {targetLanguage}". |
| Resume banner | Visible iff resumable session for this deck. |
| Study CTAs | "Study deck" (`/library/study/deck/:deckId` new learning) and "Today (n)" (`/library/study/deck/:deckId?study_type=srs_review` deck-scoped review of due cards). "Today" hidden if 0 due. |
| Filter row | Status filter dropdown ("All" / "Active" / "Due" / "Suspended" / "Buried") + multi-tag chip picker. Compose with AND. |
| Card row | Front (large), Back (subtitle), tag chips (small, overflow truncated), state badge ("🔇 SUSPENDED" / "🌙 BURIED TODAY"). |
| FAB | Plus → opens action sheet (Add card / Import). |
| Selection app bar | Replaces normal app bar in selection mode. Shows count, X cancel, Select all. |
| Bulk action bar | Bottom bar with 7 icons (per `docs/business/bulk/bulk-operations.md`): delete, move, tag+, tag-, suspend, unsuspend, reset. |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Loading | Initial fetch | Skeleton rows. |
| Populated | Normal | List visible. |
| Empty (zero cards in deck) | No cards | Show empty layout with "Add" and "Import" CTAs. |
| Filtered empty | Filters applied, no match | Show filtered empty with "Clear filters" CTA. |
| Selection mode | Long-press OR Select tapped | App bar swaps; checkboxes show; bulk bar appears. |
| Resume present | Resumable session for deck | Show banner above CTAs. |
| Loading bulk action | After confirm | Disable bulk bar; show progress indicator if > 1s. |
| Bulk error | Transaction failed | Toast error; restore selection state. |

## Actions

### Normal mode

| Action | Trigger | Result |
| --- | --- | --- |
| Tap card | Tap | Navigate to flashcard edit. |
| Long-press card | Long-press | Enter selection mode with that card selected. |
| Tap filter dropdown | Tap | Open filter picker bottom-sheet. |
| Tap tag chip filter | Tap | Open tag picker bottom-sheet (multi-select, AND). |
| Tap "Study deck" | Tap | Navigate to study entry gate `/library/study/deck/:deckId`. |
| Tap resume banner | Tap | Resume session OR show discard dialog. |
| Tap FAB | Tap | Action sheet: New flashcard / Import. |
| Tap overflow ⋮ | Tap | Menu: Edit deck / Move deck / Delete deck / Export / Sort by / Select. |
| Pull to refresh | Pull | Re-run query. |
| Tap search icon | Tap | Navigate to library search pre-filtered to this deck. |

### Selection mode

| Action | Trigger | Result |
| --- | --- | --- |
| Tap card | Tap | Toggle selection. |
| Tap Select all | Tap | Select every card matching current filter. |
| Tap X cancel | Tap | Exit selection mode. |
| Tap 🗑 delete | Tap | Show bulk delete confirm dialog. |
| Tap 📦 move | Tap | Open destination deck picker bottom-sheet. |
| Tap 🏷+ add tag | Tap | Open tag picker bottom-sheet (add mode). |
| Tap 🏷- remove tag | Tap | Open tag picker bottom-sheet (remove mode, tags limited to those present on selection). |
| Tap ⏸ suspend | Tap | Apply bulk suspend; show toast with undo. |
| Tap ⏯ unsuspend | Tap | Apply bulk unsuspend; show toast with undo. |
| Tap ↻ reset progress | Tap | Show reset confirm dialog. |
| System back | Back | Exit selection mode. |

## Dialogs and bottom-sheets used

- Resume discard dialog — `docs/wireframes/24-shared-dialogs.md` §discard-session.
- New flashcard create flow — see screen 07.
- Import flow — see screen 10.
- Filter picker bottom-sheet — `docs/wireframes/25-shared-bottom-sheets.md` §filter-status.
- Tag picker bottom-sheet — `docs/wireframes/25-shared-bottom-sheets.md` §tag-picker.
- Deck destination picker — `docs/wireframes/25-shared-bottom-sheets.md` §deck-picker.
- Bulk delete confirm — `docs/wireframes/24-shared-dialogs.md` §bulk-delete.
- Bulk reset confirm — `docs/wireframes/24-shared-dialogs.md` §reset-progress.
- Card context (single long-press alternative) — `docs/wireframes/25-shared-bottom-sheets.md` §card-context.
- Single delete confirm — `docs/wireframes/24-shared-dialogs.md` §delete-confirm.

## Card row display rules

- Front: line 1, large, ellipsis after 1-2 lines.
- Back: line 2, smaller, ellipsis.
- Tags: up to 3 small chips on the right side. "+N" chip if more.
- State badge: only one badge per row, in this priority — Suspended > Buried > Due > Active. Active doesn't render a badge.
- Note/example/pronunciation/hint NOT shown in row (per spec; reserved for future).

## Filter interaction

| Filter combo | Result |
| --- | --- |
| Status = All, Tag = none | Show all cards in deck. |
| Status = Active, Tag = #weak | Show non-suspended, non-buried cards tagged #weak. |
| Status = Suspended, Tag = #weak | Show only suspended cards tagged #weak. |
| Filter changes | URL updates with `?filter=...&tag=...` so refresh restores. |

## Navigation in

- Tap deck row in Library or Folder detail.
- Search result tap on deck.
- Deep link from notification (rare).
- Back from Flashcard create/edit/import/history.

## Navigation out

- Card tap → flashcard edit.
- "Study deck" → study entry gate.
- "Today" → study entry gate (deck-scoped review).
- Resume → session.
- FAB → create or import.
- Card history (from context sheet) → flashcard history screen.

## Responsive

- ≥600dp: 2-col grid for card rows. Bulk bar stays full-width.
- ≥1024dp: 3-col grid. Filter row inline on top.

## Performance

- Stream-based filtered query. SQLite handles status + tag filters efficiently with proposed indexes (see schema-contract.md).
- Selection state in-memory; doesn't persist across navigation.
- Bulk action: single transaction. Show indeterminate progress if > 1s.
- Tag chip list cached per deck for 60s.

## Accessibility

- Card row announces "{front}, {back}, {n} tags{, suspended|buried}".
- Selection toggle announces state change.
- Bulk bar buttons all labeled.
- Long-press alternative: a dedicated "Select" overflow item for users who cannot long-press.

## Rules

- Selection mode is ephemeral; navigating away clears it.
- Filter URL params MUST round-trip correctly.
- State badge priority MUST be: Suspended > Buried > Due > Active.
- Bulk action MUST run as single transaction.
- "Select all" selects only cards matching the CURRENT filter, not all in deck.

## Agent rule

- Do NOT show note/example/pronunciation/hint inline in row.
- Do NOT remove the resume banner after one view; it persists until session is resumed or discarded.
- Long-press card MUST default to entering selection mode, NOT opening a context sheet. (Context sheet is accessible via card edit screen overflow or alternative gesture.)
- Bulk operation snapshots selected IDs at action confirmation time, not action execution time (per bulk spec).

## Implementation refs

**Business specs:**
- `docs/business/flashcard/flashcard-management.md`
- `docs/business/bulk/bulk-operations.md`
- `docs/business/study-actions/bury-suspend.md` (state badge priority)
- `docs/business/tags/tag-system.md` (tag filter)
- `docs/business/resume/resume-session.md` (banner)

**Decision rows:**
- Flashcard management, Bulk operations, Bury/Suspend (badge priority), Tags (TG filter)

**Schema / storage:**
- `flashcards`, `flashcard_progress.is_suspended`, `flashcard_progress.buried_until`, `flashcard_progress.due_at`, `flashcard_tags`
- URL params for filter/tag state

**Contracts:** `docs/contracts/usecase-contracts/flashcard.md`, `docs/contracts/usecase-contracts/bulk.md`, `docs/contracts/usecase-contracts/study.md` (bury/suspend), `docs/contracts/repository-contracts/flashcard-repository.md`

**Code paths:**
- `lib/presentation/features/flashcard_list/screens/flashcard_list_screen.dart`
- `lib/presentation/features/flashcard_list/notifiers/flashcard_list_notifier.dart`
- `lib/presentation/features/flashcard_list/notifiers/selection_controller.dart`
- `lib/presentation/features/flashcard_list/widgets/bulk_action_bar.dart`
- `lib/domain/usecases/bulk/**`
- `lib/app/router/route_names.dart` → `RouteNames.flashcardList`

**Related wireframes:**
- `docs/wireframes/07-flashcard-create.md`, `docs/wireframes/08-flashcard-edit.md`, `docs/wireframes/09-flashcard-history.md`, `docs/wireframes/10-deck-import.md`
- `docs/wireframes/24-shared-dialogs.md` §bulk-delete, §reset-progress, §discard-session
- `docs/wireframes/25-shared-bottom-sheets.md` §tag-picker, §deck-picker, §filter-status, §undo-toast, §card-context
