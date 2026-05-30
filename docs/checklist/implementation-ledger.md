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
| 2026-05-30 | Prompt 05 — Study Entry Gate resume/start-over dialog | `lib/presentation/shared/dialogs/mx_dialog_resume_or_start_over.dart` (new), `lib/presentation/features/study/screens/study_entry_screen.dart`, `lib/presentation/features/study/providers/study_entry_notifier.dart` | Current | Replaced silent auto-resume with the spec'd Resume / Start over choice (`MxDialogResumeOrStartOver` → typed `MxResumeChoice`); Start over → `MxConfirmationDialog` discard confirm → restart. Resume is offered for any resumable session with the same scope `(entry_type, entry_ref_id)`, even when the requested mode flow differs; Cancel pops back, no session created. Async-safe (`mounted` guards after every await). |
| 2026-05-30 | Prompt 05 — flow-preserving restart | `lib/domain/study/usecases/study_usecases.dart` (`RestartStudySessionUseCase`) | Current | Added optional `modes` (defaults to `strategy.modes`, backward-compatible) so Start-over preserves a single-mode entry's flow; notifier threads selected modes through. Existing full-cycle / SRS restart callers unchanged. |
| 2026-05-31 | Prompt 06 — Fill strict matcher + hint policy promoted to domain | `lib/domain/study/fill/fill_answer_matcher.dart` (new), `lib/domain/study/fill/fill_hint_policy.dart` (new), `lib/presentation/features/study/widgets/study_session/fill/fill_mode_session_view.dart`, `lib/presentation/features/study/widgets/study_session/fill/fill_actions.dart`, `test/domain/study/fill_answer_matcher_test.dart` (new), `test/domain/study/fill_hint_policy_test.dart` (new), `test/presentation/fill_mode_session_view_test.dart` (new), `docs/checklist/wireframe-code-parity-assessment.md`, `docs/checklist/screen-function-task-matrix.md` | Partial | Strict matcher: trim + strict char equality; no case folding / diacritic stripping / whitespace collapsing. Hint reveal: `floor(len/2)` cap; per-card reveal count; Try again preserves reveal count for the same card; new card resets; Hint button disabled at cap. Hint button no longer auto-marks incorrect. **Open blocker (P1)**: hint-tainted exact match still grades as `AttemptGrade.correct` → `ReviewResult.perfect`, because the binary `AttemptGrade` enum cannot signal `recovered` without a schema/codec change. Tracked in parity §3.10. |
| 2026-05-30 | Prompt 05 — tests + l10n + docs parity | `lib/l10n/app_en.arb`, `lib/l10n/app_vi.arb`, `test/presentation/study_entry_screen_test.dart`, `test/integration/study_progress_data_flow_test.dart`, matrix/parity/wireframe-12/wireframe-24 docs | Current | 4 new entry-gate tests (shows-choice / Resume / Start over / Cancel / mode-mismatch); integration resume + multi-mode-continue updated to tap Resume; 4 new l10n keys (en+vi). Confirmed today=SRS/fill-only/due-only, deck/folder=newStudy/5-mode, folder recursion via `getSubtreeIds` (not move-target `getDescendantIds`) already Current. |

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
