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
| 2026-05-30 | Prompt 04 — Dashboard resume flow | `lib/presentation/features/dashboard/widgets/dashboard_resume_section.dart` (new), `dashboard_paused_sessions_sheet.dart` (new), `dashboard_content.dart`, `dashboard_overview_viewmodel.dart` | Current | Resume card above all content (Continue/Discard + "+N more"); multi-session paused sheet (live refresh); discard via `MxConfirmationDialog` → `CancelStudySessionUseCase` (reuses `progressSessionActionControllerProvider`). State now carries lightweight `resumeSessions` list. |
| 2026-05-30 | Prompt 04 — Start new learning scope picker | `lib/presentation/features/dashboard/widgets/dashboard_scope_picker_sheet.dart` (new), `dashboard_action_list.dart`, `dashboard_overview_viewmodel.dart` (scope-option providers) | Current | Two-step picker (Today/Deck/Folder) → Study Entry Gate; reuses `MxDestinationPickerSheet`. Tag scope excluded (Future). UI-0: compact stacked card actions, no full-width. |
| 2026-05-30 | Prompt 04 — read-only folder scope list | `lib/domain/repositories/folder_repository.dart`, `lib/domain/usecases/folder_usecases.dart` (`ListAllFoldersUseCase`), `lib/data/repositories/folder_repository_impl.dart`, `lib/domain/value_objects/content_read_models.dart` (`FolderScopeOption`), `lib/app/di/content/folder_providers.dart` | Current | Pure read path over existing `FolderDao.listAllFolders()`+breadcrumbs; no schema change, no move-target reuse. |
| 2026-05-30 | Prompt 04 — recent decks confirmed Current | `lib/presentation/features/dashboard/widgets/dashboard_stats_section.dart` | Current | Already implemented via `GetDeckHighlightsUseCase` (limit 3); promoted from matrix `NotStarted` after verification (no code change). |
| 2026-05-30 | Prompt 04 — l10n + tests + docs parity | `lib/l10n/app_en.arb`, `lib/l10n/app_vi.arb`, `test/presentation/dashboard_screen_test.dart`, `test/presentation/button_label_contract_test.dart`, matrix/wireframe/contract docs | Current | 29 dashboard tests (resume/scope/density/recent decks); full suite 804 green; analyzer clean; guard 0 errors. |

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
