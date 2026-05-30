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

## In progress

- **Prompt 04 — Dashboard**: local WIP (resume section, scope picker sheet,
  paused sessions sheet, action list, l10n keys). Stashed during Prompt UI-0 to
  keep the foundation change isolated. Re-apply before resuming Prompt 04.

## Future / blocked (do not implement opportunistically)

- Dashboard study entry / resume / recent decks (Prompt 04 scope).
- Library, Flashcard, Global Search, Flashcard History, full Onboarding,
  Drive sync, tag-scoped study, schema migration.

## Notes for the next agent

- Prefer `MxActionButton` / `MxCardActions` over raw `MxPrimaryButton` /
  `MxSecondaryButton`. Read `docs/ui-ux/action-hierarchy-contract.md` and run
  the UI Density Gate in `docs/agent/agent-task-template.md` for UI work.
- When restarting Prompt 04, restore the stash and migrate its action surfaces
  to the semantic components per the density contract.
