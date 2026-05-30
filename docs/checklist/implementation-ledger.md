---
last_updated: 2026-05-30
status: living
---

# Implementation Ledger

Append-only log of implementation changes and their verification status. One row
per meaningful change. Status vocabulary: `Current` (implemented + tested +
verified + docs aligned), `Partial`, `NotStarted`, `Blocked`, `Future`.

| Date | Change | Files (primary) | Status | Notes |
| --- | --- | --- | --- | --- |
| 2026-05-30 | Action Density Foundation: semantic action layer | `lib/presentation/shared/widgets/mx_action_button.dart`, `lib/presentation/shared/widgets/mx_card_actions.dart` | Current | `MxActionButton` + `MxActionIntent` (10 contexts); `MxCardActions` layout. Tested + analyzer clean. |
| 2026-05-30 | Neutralize `stretchOnCompact` auto full-width | `lib/presentation/shared/widgets/mx_primary_button.dart` | Current | Default flipped `true`→`false`. No feature relied on it (only `large` usage already sets `fullWidth: true`). |
| 2026-05-30 | Card-action stacking helper | `lib/core/theme/responsive/app_layout.dart` | Current | `AppLayout.stacksCardActions(...)` + reviewed width-floor constant. |
| 2026-05-30 | Action-hierarchy + density docs | `docs/ui-ux/action-hierarchy-contract.md` (new), `docs/ui-ux/ui-ux-contract.md`, `docs/system-design/MemoX Design System/README.md`, `docs/agent/agent-task-template.md` | Current | 10 action contexts, density rules, UI Density Gate. |
| 2026-05-30 | Action-density guard rules | `code-verification-guard/registries/projects/memox/rules/memox-action-density-rules.yaml` (new) | Partial | `warning` severity — see follow-up below. |

## Follow-ups (open)

- **Promote action-density guard rules to `error`.** The guard engine supports
  only path-glob excludes, not inline `// guard:full-width-action-reviewed`
  waivers. Several legitimate full-width sites exist outside card/list surfaces
  (settings footers, study submit/fill actions, flashcard save bars, empty
  states). Before flipping `memox.no_full_width_button_in_card_surface` /
  `memox.no_large_button_in_card_surface` to `error`, either add inline-waiver
  support to the engine or add a path allowlist for the legitimate contexts, and
  annotate/migrate the existing sites. Tracked from Prompt UI-0 (2026-05-30).
- **Optional `MxCardDensity` role** (`compact`/`standard`/`prominent`/`hero`)
  deferred from Prompt UI-0 — would require broad feature-screen migration;
  implement only as a dedicated task if a need emerges.
