# Tall-Narrow Responsive Audit

Date: 2026-05-04

## Scope

This audit checks MemoX UI readiness for long but narrow Samsung-like phone
screens. It is audit-only: no production code, generated files, localization,
schema, test files, or Decision Table files were changed.

Primary target from user reference:

| Target | Logical size | Aspect ratio | Use |
| --- | ---: | ---: | --- |
| Samsung Galaxy S20 Ultra | 412 x 915 | 2.22:1 | Primary tall-narrow target |
| Extreme compact fallback | 320 x 740 | 2.31:1 | Stress narrow width |
| Common compact fallback | 360 x 800 | 2.22:1 | Stress common Android width |
| Existing MemoX mobile baseline | 390 x 844 | 2.16:1 | Current test/golden baseline |

Text scale matrix to keep for follow-up executable coverage: `1.0`, `1.2`,
and `1.5`.

## Verification Evidence

| Check | Result | Notes |
| --- | --- | --- |
| Static scan for `MediaQuery`, `LayoutBuilder`, fixed `width`/`height`, `EdgeInsets`, and `TextStyle` | Completed | Used PowerShell because `rg.exe` is blocked with `Access is denied` in this environment. |
| `python tools/guard/run.py --policy memox` | Pass | 138 rules, 0 violations, 0 warnings, 0 errors. |
| `flutter analyze` | Pass | No issues found. |
| `flutter test test/presentation/shared/shared_widget_contract_test.dart` | Pass | 93 tests passed, including shared `onResponsive` coverage. |
| Targeted presentation screen tests | Pass | 160 tests passed across dashboard, library/folder, flashcard, study, progress, and settings screens. |
| `flutter test integration_test/app_test.dart` | Not executed | Flutter required a device selection because Windows, Chrome, and Edge were available. |
| `flutter test -d windows integration_test/app_test.dart` | Interrupted | User interrupted the run; leftover `memox.exe`/test Dart processes from this run were stopped. |

Targeted presentation command that passed:

```powershell
flutter test test/presentation/dashboard_screen_test.dart test/presentation/library_overview_screen_test.dart test/presentation/folder_detail_screen_test.dart test/presentation/flashcard_list_screen_test.dart test/presentation/flashcard_editor_screen_test.dart test/presentation/deck_import_screen_test.dart test/presentation/study_entry_screen_test.dart test/presentation/study_session_screen_test.dart test/presentation/study_result_screen_test.dart test/presentation/progress_screen_test.dart test/presentation/settings_screen_test.dart
```

## Current Coverage

Foundation:

- `lib/core/theme/responsive/app_breakpoints.dart:30` classifies screens by
  width only through `MediaQuery.sizeOf(this).width`.
- `lib/core/theme/responsive/app_layout.dart:45` centralizes page padding.
- `lib/core/theme/responsive/app_layout.dart:81` centralizes content max width.
- `lib/presentation/shared/layouts/mx_content_shell.dart:39` routes screen
  bodies through `context.contentMaxWidth(...)`.
- `lib/presentation/shared/layouts/mx_adaptive_scaffold.dart:82` uses compact
  `NavigationBar` for compact windows.

Shared widgets:

- `docs/decision-tables/presentation/shared/shared_widget_contract_test.md:140`
  declares `onResponsive`.
- `test/presentation/shared/shared_widget_contract_test.dart:3011` covers
  widths `320`, `360`, `390`, and `430`.
- `test/presentation/shared/shared_widget_contract_test.dart:3024` pumps those
  widths at height `700`.
- `test/presentation/shared/shared_widget_contract_test.dart:2891` and
  `test/presentation/shared/shared_widget_contract_test.dart:2913` cover text
  scale `1.2` and `1.5` for important shared controls.
- No test or docs currently reference `412` or `915`.

Flow-level tests:

- Flashcard list has compact coverage at `390 x 844` in
  `test/presentation/flashcard_list_screen_test.dart:96`,
  `test/presentation/flashcard_list_screen_test.dart:200`, and
  `test/presentation/flashcard_list_screen_test.dart:243`.
- Deck import long preview has compact coverage at `390 x 844` in
  `test/presentation/deck_import_screen_test.dart:506`.
- Settings has first-viewport compact coverage at `390 x 844` in
  `test/presentation/settings_screen_test.dart:286`, plus compact text-scale
  fallback at `320 x 640` / `TextScaler.linear(1.4)` in
  `test/presentation/settings_screen_test.dart:441`.
- Study session has short-keyboard coverage at `390 x 620` in
  `test/presentation/study_session_screen_test.dart:561`.
- Integration compact baseline is hardcoded as `390 x 844` in
  `integration_test/test_app.dart:26`.

## Findings

| Severity | Area | Finding | Evidence | Follow-up |
| --- | --- | --- | --- | --- |
| High | Flow coverage | The user-specified Samsung target `412 x 915` has no executable test or Decision Table coverage. Existing tests prove nearby compact behavior, not this exact target. | Search for `412`, `915`, `S20`, and `Galaxy` under `test`, `integration_test`, and `docs` returned no hits. | Add a Samsung tall-narrow viewport constant and Decision Table rows before treating the target as covered. |
| Medium | Integration coverage | Integration compact flow is locked to `390 x 844`, so app-shell/full-flow tests cannot be rerun at `412 x 915` without changing test support. | `integration_test/test_app.dart:26` defines `integrationTestCompactSurfaceSize = Size(390, 844)`. | Add `integrationTestSamsungTallSurfaceSize = Size(412, 915)` or parameterize the compact matrix. |
| Medium | Feature screens | Flow-level compact tests are uneven. Flashcards/settings/deck import/study have selected compact cases; dashboard, library, folder detail, study entry/result, and progress do not consistently run at the tall-narrow matrix. | Screen tests passed, but compact surface hits are concentrated in flashcard list, deck import, settings, and one study keyboard case. | Add `onResponsive` rows per high-value screen for `412 x 915`, then add targeted tests. |
| Medium | Feature layout thresholds | Some feature widgets make local layout decisions that need review at `412 x 915`, even though guards currently pass. | Dashboard uses a `460` action switch point at `dashboard_action_list.dart:14` and a `152` action width at `dashboard_action_list.dart:16`; flashcard toolbar switches at `constraints.maxWidth < 600` in `flashcard_toolbar_section.dart:109` and `:196`. | Run visual/widget assertions at `412 x 915` before changing these thresholds. |
| Low | Height-sensitive study widgets | Match and Guess mode option/tile heights divide available height; tall screens are likely safer, but the exact Samsung target is not locked. | `match_board.dart:82` divides `constraints.maxHeight / slotCount`; `guess_mode_session_view.dart:305` divides `(constraints.maxHeight - gapTotal) / options.length`. | Add study-mode matrix coverage for Review, Match, Guess, Recall, and Fill at `412 x 915`. |
| Low | Reorder panel height | Reorder panel helpers are height-ratio based and should be verified on tall screens, though this is not an immediate failure. | `mx_feature_layout.dart:14` and `mx_feature_layout.dart:24` calculate reorder panel heights from viewport height. | Include folder reorder and flashcard reorder scenarios in the Samsung target matrix if those flows are in scope. |

No production overflow or analyzer/guard failure was confirmed by the executed
tests. The main result is a coverage gap: MemoX has meaningful compact
coverage, but it does not yet lock the `412 x 915` Samsung target.

## Flow Checklist

| Flow | Current evidence | Samsung `412 x 915` status |
| --- | --- | --- |
| Shared components | Strong: `320/360/390/430`, long data, accessibility text scales, goldens all pass. | Missing exact `412 x 915`, but nearest shared width `430` and `390` reduce risk. |
| Dashboard | Tests pass; compact action geometry is asserted. | Needs exact viewport test for first viewport and action layout. |
| Library overview | Tests pass; uses `MxContentShell` and scrollable layout. | Needs exact viewport test for search/header/folder list. |
| Folder detail | Tests pass; uses `MxContentShell` and lazy scrollable layout. | Needs exact viewport test for header actions, empty states, and reorder entry. |
| Flashcard list | Has `390 x 844` compact coverage and lazy long-list coverage. | Needs `412 x 915` coverage for toolbar, study/progress sections, bulk mode, and reorder mode. |
| Flashcard editor | Tests pass for behavior, but compact/tall keyboard evidence is not explicit. | Needs `412 x 915` keyboard/text-field coverage. |
| Deck import | Has `390 x 844` long-preview coverage. | Needs `412 x 915` coverage for Excel/Text modes, option groups, and preview actions. |
| Study entry | Tests pass for flow options and defaults. | Needs `412 x 915` first-viewport and text-scale coverage. |
| Study session | Has short keyboard coverage and mode behavior coverage. | Needs `412 x 915` coverage across all study modes. |
| Study result | Tests pass for result states. | Needs `412 x 915` first-viewport/content hierarchy coverage. |
| Progress | Has a medium-width metrics-row test at `800 x 1000`. | Needs compact/tall coverage for active session cards and overview metrics. |
| Settings | Has `390 x 844` first-viewport and `320 x 640` text-scale fallback coverage. | Needs exact `412 x 915` with text scales `1.0`, `1.2`, `1.5`. |

## Recommended Next Change

Keep production UI unchanged until the target is executable. In the next pass:

1. Add Decision Table rows for Samsung tall-narrow coverage:
   - Shared `onResponsive`: include `412 x 915` explicitly.
   - Integration flow coverage: add a compact Samsung target row under
     `docs/decision-tables/integration_test/flows/coverage_expansion_test.md`.
   - High-value presentation screens: dashboard, library, flashcard list,
     deck import, study entry, study session, progress, and settings.
2. Add a test helper/constant for `const Size(412, 915)` and reuse it instead
   of scattering the size through tests.
3. Run the same verification chain:
   `python tools/guard/run.py --policy memox`, `flutter analyze`, targeted
   presentation tests, and `flutter test -d windows integration_test/app_test.dart`
   when a device target is selected.
4. Only fix production layout if one of the new `412 x 915` tests exposes a
   concrete overflow, clipped action, hidden input, broken first viewport, or
   bad text-scale fallback.

