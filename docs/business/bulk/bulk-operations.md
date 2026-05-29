---
last_updated: 2026-05-26
applies_to: multi-select bulk operations on flashcards
---

# Bulk Operations

## Purpose

Selection-based export exists today, but other multi-card workflows (delete a page of bad cards, retag, move to another deck) require one-by-one operations. This doc specs the full bulk operations set on flashcards.

Folders and decks are not covered here; they typically have low cardinality and single-item operations suffice.

## Selection mode

Flashcard list (`/library/deck/:deckId/flashcards`) enters selection mode via:

| Trigger | Behavior |
| --- | --- |
| Long-press a card | Enters selection mode with that card selected |
| Toolbar "Select" action | Enters selection mode with no cards selected |
| "Select all" within selection mode | Selects every visible (filtered) card |

Exit selection mode via:

- Toolbar "Cancel" action.
- System back gesture.
- Deselecting last card (returns to normal mode).

## Selection UI

| Element | Behavior |
| --- | --- |
| Card tap in selection mode | Toggle selection |
| Counter | "{n} selected" in app bar |
| Select-all checkbox | Selects all rows matching current filters |
| Action bar | Bottom or top bar with bulk action icons (depends on platform) |

Selection state is ephemeral (in-memory). Navigating away or filter change clears it.

## Supported bulk actions

| Action | Behavior |
| --- | --- |
| Bulk delete | Confirmation → delete selected cards in one transaction. Cascade applies. |
| Bulk move to deck | Picker → select target deck → move selected cards. Validates target deck mode. |
| Bulk add tag(s) | Tag input/picker → append tags to each selected card (deduped). |
| Bulk remove tag(s) | Tag picker (limited to tags present on selection) → remove from each. |
| Bulk suspend | Set `is_suspended = true` for each. See `docs/business/study-actions/bury-suspend.md`. |
| Bulk unsuspend | Set `is_suspended = false` for each. |
| Bulk bury | Set `buried_until` to tomorrow's local midnight for each. |
| Bulk unbury | Clear `buried_until` for each. |
| Bulk reset progress | Confirmation → reset `flashcard_progress` (box=1, counters=0, due=now). Attempts retained. |
| Bulk export | Build CSV/Excel from selected (already specified in `docs/business/export/export.md`). |

## Transactional semantics

All bulk operations MUST run in a single transaction:

- Atomicity: all or nothing. Partial application would leave inconsistent state.
- Performance: a single transaction for 1000 row update beats 1000 transactions.

If a bulk operation fails mid-transaction, the entire transaction rolls back and the UI shows an error. No partial commit.

## Confirmation requirements

| Action | Confirmation |
| --- | --- |
| Bulk delete | Required; "Delete {n} cards? This cannot be undone." |
| Bulk reset progress | Required; "Reset SRS progress for {n} cards? They will become due immediately." |
| Bulk move | Not required (reversible via move-back); show toast with undo for 5s |
| Bulk suspend | Not required; toast with undo for 5s |
| Bulk unsuspend | Not required; toast with undo for 5s |
| Bulk bury | Not required; toast with undo for 5s |
| Bulk add/remove tags | Not required; toast with undo for 5s |
| Bulk export | Not required; goes to share sheet (user can cancel there) |

Toast-undo MUST genuinely revert via inverse transaction.

## Move operation rules

- Target deck must exist.
- Target deck must be in a folder whose mode allows decks (existing rule).
- Cards moved retain `flashcard_progress` (SRS state preserved across deck moves).
- Cards moved retain `flashcard_tags` (tags global by name, so they remain).
- `sort_order` recomputed: appended to end of target deck.
- Source deck card count decreases; target deck card count increases.
- If target == source: no-op, dismiss with toast.

## Filter interaction

- Select-all selects cards matching current filter (status + tag).
- After a bulk action that changes filter-relevant state (e.g., bulk suspend while filter = "Active"), affected cards disappear from view. Selection clears.
- Bulk operations always run on the actual selected ID list, NOT re-evaluating filter at execution time. (Snapshot the IDs at action confirmation.)

## Edge cases

| Case | Behavior |
| --- | --- |
| User selects 1000+ cards | Allowed. Transaction handles it. Show progress indicator for slow ops. |
| Some selected cards deleted by another session (rare; single-user app) | Transaction proceeds for surviving cards; report "X cards no longer exist and were skipped" |
| Bulk move target deck is empty | Allowed. Cards become its first cards. |
| Bulk move target deck reaches a max size constraint (none today) | Reject with explanation if such constraint is added |
| Undo within toast window, but transaction not yet acknowledged | Queue undo; apply when first transaction completes |
| Two bulk actions in rapid succession | UI prevents queue overlap; second action waits for first to finalize |

## Rules

- Selection mode is ephemeral and screen-scoped.
- Bulk action transaction MUST be atomic.
- Operation runs on selected IDs snapshot, not re-derived from filter.
- Destructive bulk actions (delete, reset progress) MUST require confirmation.
- Non-destructive bulk actions show toast with undo.
- Undo MUST be a real inverse operation, not a "best-effort" stub.
- Bulk operations are account-scoped (no cross-account move possible).
- Bulk "reset progress" MUST set `last_reset_at = now` on each affected `flashcard_progress` row (see `docs/business/history/card-history.md`). It MUST NOT delete attempts.

## Performance

- 1000 rows update: typically < 1 second. Profile before declaring acceptable.
- Indexes on `flashcards(id)`, `flashcards(deck_id)`, `flashcard_progress(flashcard_id)`, `flashcard_tags(flashcard_id)` already exist; verify.
- Avoid per-row reads inside the transaction; use bulk SQL (`UPDATE ... WHERE id IN (?, ?, ...)`).
- Watch out for SQLite parameter limit (~999 by default); chunk IN clauses if needed.

## Required UI states

- Selection mode entry/exit animations.
- Counter visible.
- Action bar with available bulk actions.
- Confirmation dialog for destructive.
- Toast with undo for reversible.
- Progress indicator for long operations (> 1 sec).

## Agent rule

- Do NOT split bulk operations into separate transactions per row.
- Do NOT skip undo for non-destructive bulk actions.
- Bulk move MUST respect folder content mode rules (target folder must be `decks` or `unlocked`).
- Bulk reset progress MUST NOT delete attempts.
- Toast undo MUST genuinely revert; do not show fake undo button.
- Filter-driven "Select all" snapshots IDs at the moment of selection, not at action execution.

## Related

**Wireframes:**

- `docs/wireframes/06-flashcard-list.md` — selection mode + bulk action bar (7 icons: delete, move, tag+, tag-, suspend, unsuspend, reset)
- `docs/wireframes/24-shared-dialogs.md` §bulk-delete, §reset-progress (bulk variant)
- `docs/wireframes/25-shared-bottom-sheets.md` §tag-picker (add/remove modes), §deck-picker (move target), §undo-toast (non-destructive ops)

**Schema:**

- `docs/database/schema-contract.md` → atomic transactions across `flashcards`, `flashcard_progress`, `flashcard_tags`

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "Bulk operations" (atomicity, snapshot-at-confirm rule)

**Glossary terms:**

- `docs/business/glossary.md` → "selection mode", "bulk operation", "undo toast"

**Related business specs:**

- `docs/business/flashcard/flashcard-management.md` — single-card semantics that bulk extends
- `docs/business/tags/tag-system.md` — bulk tag add/remove validation
- `docs/business/study-actions/bury-suspend.md` — bulk suspend / unsuspend
- `docs/business/history/card-history.md` — bulk reset progress sets `last_reset_at` per card
- `docs/business/deck/deck-management.md` — bulk move-to-deck destination rules

**Source files to inspect:**

- `lib/domain/usecases/bulk/**`
- `lib/data/repositories/flashcard_bulk_repository.dart`
- `lib/presentation/features/flashcard_list/selection_controller.dart`
