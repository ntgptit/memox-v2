---
last_updated: 2026-05-30
status: living
---

# Implementation Handoff

Concise, factual snapshot of where implementation stands between prompts. Update
in the same commit when a prompt completes or scope changes.

## Completed (verified)

- **Prompt 01 — Empty Scope Tier 1**: deck/folder/today empty-state handling.
- **Prompt 02 + 02B — Bury/Suspend**: bury/suspend drops the current item from
  the session (not skip/requeue); all five study mode views expose card actions;
  `DropCurrentStudyItemUseCase` exists.
- **Prompt 03 + 03B — Tag Domain Cleanup**: no `tags` table; tags stored
  lowercase; `AddTagToCardUseCase` returns `Result<void>`; flashcard
  create/update validates tags at the repository boundary.
- **Prompt UI-0 — Action Density Foundation** (2026-05-30): semantic action
  layer (`MxActionButton` + `MxActionIntent`, `MxCardActions`); neutralized
  `MxPrimaryButton.stretchOnCompact` (default now `false`); action-hierarchy
  contract + UI density gate docs; shared-widget contract coverage + dedicated
  density tests; warning-level guard rules for card/list/dashboard action
  density. Does NOT implement any Dashboard feature behavior.
- **Prompt 04 — Dashboard study entry + resume flow** (2026-05-30): resume card
  above all content (Continue/Discard + "+N more" → paused-sessions sheet);
  multi-session paused sheet with live refresh; discard via `MxConfirmationDialog`
  → `CancelStudySessionUseCase`; "Start new learning" two-step scope picker
  (Today/Deck/Folder) → Study Entry Gate (Tag excluded, Future); recent decks
  (top 3) confirmed Current. New read-only `ListAllFoldersUseCase` +
  `FolderScopeOption` for Folder scope (no schema change). UI follows the action
  density contract (compact stacked card actions, no full-width hero CTAs).
  Verified: 804 tests green, analyzer clean, guard 0 errors. The Prompt 04 WIP
  stash was broken (referenced untracked files; pre-UI-0 `fullWidth` actions) and
  was discarded; the feature was reimplemented cleanly on the semantic components.

## In progress

- None.

## Future / blocked (do not implement opportunistically)

- Dashboard engagement: streak chip + history, daily-goal ring, streak-broken
  banner (`Target`; blocked on engagement product decision).
- Dashboard onboarding (zero-content) dedicated route/screen/carousel.
- Tag-scoped study (scope picker Tag tab).
- Library, Flashcard, Global Search, Flashcard History, full Onboarding,
  Drive sync, schema migration.

## Notes for the next agent

- Prefer `MxActionButton` / `MxCardActions` over raw `MxPrimaryButton` /
  `MxSecondaryButton`. Read `docs/ui-ux/action-hierarchy-contract.md` and run
  the UI Density Gate in `docs/agent/agent-task-template.md` for UI work.
- Prompt 04 is complete; there is no Prompt 04 stash to restore (the broken WIP
  stash was discarded and the feature reimplemented on the semantic components).
- Dashboard resume/discard reuses `progressSessionActionControllerProvider`
  (cancel → revision bump → `dashboardOverviewProvider` refresh). The two-step
  scope picker reuses `MxDestinationPickerSheet`; deck/folder lists come from
  `dashboardDeckScopeOptionsProvider` / `dashboardFolderScopeOptionsProvider`.
