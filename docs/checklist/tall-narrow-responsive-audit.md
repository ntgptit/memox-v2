# Tall-Narrow Responsive Audit

Date: 2026-05-04

## Scope

This audit checks MemoX UI readiness for long but narrow Samsung-like phone
screens. The original 2026-05-04 pass was audit-only. The 2026-05-23 follow-up
implemented a compact-mobile density layer for `width < 430` through shared
layout and component primitives.

Primary target from user reference:

| Target | Logical size | Aspect ratio | Use |
| --- | ---: | ---: | --- |
| Samsung Galaxy S20 Ultra | 412 x 915 | 2.22:1 | Primary tall-narrow target |
| Extreme compact fallback | 320 x 740 | 2.31:1 | Stress narrow width |
| Common compact fallback | 360 x 800 | 2.22:1 | Stress common Android width |
| Existing MemoX mobile baseline | 390 x 844 | 2.16:1 | Current test/golden baseline |

Text scale matrix to keep for follow-up executable coverage: `1.0`, `1.2`,
and `1.5`.

## 2026-05-23 Compact-Mobile Density Follow-up

Root cause confirmed after implementation: the UI was not globally broken by
theme color, text scale, or one dashboard screen. The app used shared page
shells, cards, buttons, tiles, state widgets, and bottom navigation without a
separate density tier for narrow phone widths. `WindowSize.compact < 600`
correctly remains the structural breakpoint, while `width < 430` now acts only
as a density sub-tier.

Implemented production changes:

- `lib/core/theme/responsive/app_layout.dart` now owns compact-mobile helpers
  for page insets, section gaps, card padding, list-tile padding, leading icon
  tile size, button horizontal padding, bottom navigation height, dashboard
  chart size, and shared state illustration size.
- Shared primitives consume those helpers instead of each screen compensating
  locally: `MxCard`, `MxAdaptiveScaffold`, `MxPrimaryButton`,
  `MxSecondaryButton`, `MxStudySetTile`, `MxListTile`, `MxEmptyState`,
  `MxErrorState`, `MxFlashcard`, and `MxStreakCard`.
- Dashboard and library outliers now consume compact-aware helpers for mastery
  chart geometry and hero-card padding.
- Accessibility text scaling remains enabled. The change does not add
  `TextScaler.noScaling`, a permanent text-scale clamp, or global
  `VisualDensity.compact`.

Observed screenshot outcome after the first implementation: density improved
noticeably, especially bottom navigation, card internals, and chart sizing.
Residual visual weight remains in the study action card because the content
itself is tall: three action rows, full-width buttons, dividers, and multiple
metadata lines. Further tightening should be based on focused component
decisions, not a global scale-down.

## 2026-05-23 Decision-First Copy Density Follow-up

Second root cause after the density pass: the app still felt heavy on
compact-mobile because high-value screens repeated explanatory copy beside
nearby metrics and actions. This was information architecture, not typography
or spacing.

Implemented production changes:

- `AppLayout.showsSupportingCopy(context)` now centralizes copy density.
  `width < 430` keeps decision-critical labels, status, actions, errors,
  empty-state recovery, and destructive warnings, while hiding generic helper
  copy that repeats adjacent data.
- Dashboard compact mobile hides the greeting block, action-row helper
  messages, duplicate action metrics, and the duplicated mastery copy. It keeps
  concise statuses such as `5 due`, `7 new`, and `1 active`.
- Library and folder detail compact mobile collapse decorative hero/header
  explanations while preserving page title, breadcrumbs, search, folder lists,
  and empty-state recovery.
- Flashcard list, progress, study entry, and settings overview now hide generic
  subtitles on compact mobile while keeping the controls/statuses that drive
  the next action.
- Account/sync warning states remain visible on compact mobile; generic
  Drive-ready overview copy is reduced to identity/email.

Rule for future UI work: compact-mobile surfaces should be decision-first.
Only render supportive copy when it prevents confusion, explains an error or
disabled/destructive action, or provides the recovery path for an empty state.

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

2026-05-23 implementation verification:

| Check | Result | Notes |
| --- | --- | --- |
| `python code-verification-guard\guard\run.py check --project .` | Failed on pre-existing unrelated rules | No remaining guard error was reported for the compact-density files. Existing failures include hardcoded sync test tokens and `AsyncValue.when` in settings widgets. |
| `flutter analyze` | Pass | No issues found. |
| `flutter test test\presentation\shared\shared_widget_contract_test.dart` | Pass | 102 tests passed, including `412` width and `412x915` navigation-bar clearance. |
| `flutter test test\presentation\dashboard_screen_test.dart` | Pass | Includes `DT1 onResponsive` for `412x915` dashboard chart/card density. |
| Targeted presentation screen tests | Pass | Library overview, flashcard list, study entry/result, progress, and settings screen tests passed. |
| `flutter test test\core\theme\app_theme_test.dart` | Pass | Confirms app chrome theme still avoids hard-coded heights. |

Targeted presentation command that passed:

```powershell
flutter test test/presentation/dashboard_screen_test.dart test/presentation/library_overview_screen_test.dart test/presentation/folder_detail_screen_test.dart test/presentation/flashcard_list_screen_test.dart test/presentation/flashcard_editor_screen_test.dart test/presentation/deck_import_screen_test.dart test/presentation/study_entry_screen_test.dart test/presentation/study_session_screen_test.dart test/presentation/study_result_screen_test.dart test/presentation/progress_screen_test.dart test/presentation/settings_screen_test.dart
```

## Current Coverage

Foundation:

- `lib/core/theme/responsive/app_breakpoints.dart:30` classifies screens by
  width only through `MediaQuery.sizeOf(this).width`.
- `lib/core/theme/responsive/app_layout.dart` centralizes page padding, content
  max width, and compact-mobile density helpers.
- `lib/presentation/shared/layouts/mx_content_shell.dart:39` routes screen
  bodies through `context.contentMaxWidth(...)`.
- `lib/presentation/shared/layouts/mx_adaptive_scaffold.dart` uses
  `AppLayout.navigationBarHeight(context)` for compact-mobile bottom
  navigation density.

Shared widgets:

- `docs/decision-tables/presentation/shared/shared_widget_contract_test.md:140`
  declares `onResponsive`.
- `test/presentation/shared/shared_widget_contract_test.dart` covers widths
  `320`, `360`, `390`, `412`, and `430`.
- `test/presentation/shared/shared_widget_contract_test.dart` verifies
  `MxAdaptiveScaffold` at `412 x 915`, including compact navigation height and
  body clearance.
- `test/presentation/shared/shared_widget_contract_test.dart:2891` and
  `test/presentation/shared/shared_widget_contract_test.dart:2913` cover text
  scale `1.2` and `1.5` for important shared controls.
- Dashboard and library overview now have screen-level `412 x 915` Decision
  Table rows and executable tests.

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
| Resolved | Shared/dashboard/library coverage | The user-specified Samsung target `412 x 915` now has shared, dashboard, and library Decision Table/test coverage. | Shared `onResponsive`, dashboard `onResponsive`, and library `onResponsive` rows now reference `412` or `412x915`. | Extend exact-target coverage to the remaining high-value screens when their layout is touched. |
| Medium | Integration coverage | Integration compact flow is locked to `390 x 844`, so app-shell/full-flow tests cannot be rerun at `412 x 915` without changing test support. | `integration_test/test_app.dart:26` defines `integrationTestCompactSurfaceSize = Size(390, 844)`. | Add `integrationTestSamsungTallSurfaceSize = Size(412, 915)` or parameterize the compact matrix. |
| Medium | Feature screens | Flow-level compact tests are still uneven outside shared primitives, dashboard, and library. | Screen tests pass, but exact `412 x 915` surface hits are not yet universal. | Add `onResponsive` rows per high-value screen as each area is edited. |
| Medium | Feature layout thresholds | Some feature widgets make local layout decisions that need review at `412 x 915`, even though guards currently pass. | Dashboard uses a `460` action switch point at `dashboard_action_list.dart:14` and a `152` action width at `dashboard_action_list.dart:16`; flashcard toolbar switches at `constraints.maxWidth < 600` in `flashcard_toolbar_section.dart:109` and `:196`. | Run visual/widget assertions at `412 x 915` before changing these thresholds. |
| Low | Height-sensitive study widgets | Match and Guess mode option/tile heights divide available height; tall screens are likely safer, but the exact Samsung target is not locked. | `match_board.dart:82` divides `constraints.maxHeight / slotCount`; `guess_mode_session_view.dart:305` divides `(constraints.maxHeight - gapTotal) / options.length`. | Add study-mode matrix coverage for Review, Match, Guess, Recall, and Fill at `412 x 915`. |
| Low | Reorder panel height | Reorder panel helpers are height-ratio based and should be verified on tall screens, though this is not an immediate failure. | `mx_feature_layout.dart:14` and `mx_feature_layout.dart:24` calculate reorder panel heights from viewport height. | Include folder reorder and flashcard reorder scenarios in the Samsung target matrix if those flows are in scope. |

No production overflow was confirmed by the executed tests. The original
coverage gap is now closed for shared primitives, dashboard, and library
overview, while the remaining screens should gain exact `412 x 915` coverage
incrementally.

## Flow Checklist

| Flow | Current evidence | Samsung `412 x 915` status |
| --- | --- | --- |
| Shared components | Strong: `320/360/390/412/430`, long data, accessibility text scales, navigation-bar clearance, and goldens all pass. | Covered for compact-mobile density foundation. |
| Dashboard | Tests pass; compact action geometry and `412 x 915` progress chart density are asserted. | Covered for the first compact-mobile density pass; remaining visual tuning should be component-specific. |
| Library overview | Tests pass; uses `MxContentShell` and scrollable layout. | Covered for first viewport hero/folder visibility and compact hero padding. |
| Folder detail | Tests pass; uses `MxContentShell` and lazy scrollable layout. | Covered for compact unlocked header copy density; still needs exact viewport coverage for reorder entry. |
| Flashcard list | Has `390 x 844` compact coverage and lazy long-list coverage. | Covered for compact study/progress copy density; still needs `412 x 915` coverage for bulk mode and reorder mode. |
| Flashcard editor | Tests pass for behavior, but compact/tall keyboard evidence is not explicit. | Needs `412 x 915` keyboard/text-field coverage. |
| Deck import | Has `390 x 844` long-preview coverage. | Needs `412 x 915` coverage for Excel/Text modes, option groups, and preview actions. |
| Study entry | Tests pass for flow options and defaults. | Covered for compact first-viewport copy density; still needs compact text-scale coverage. |
| Study session | Has short keyboard coverage and mode behavior coverage. | Needs `412 x 915` coverage across all study modes. |
| Study result | Tests pass for result states. | Needs `412 x 915` first-viewport/content hierarchy coverage. |
| Progress | Has a medium-width metrics-row test at `800 x 1000`. | Covered for compact overview/active-session copy density; still needs active-session card coverage at `412 x 915`. |
| Settings | Has `390 x 844` first-viewport and `320 x 640` text-scale fallback coverage. | Covered for compact first-viewport copy density; still needs exact `412 x 915` with text scales `1.0`, `1.2`, `1.5`. |

## Recommended Next Change

The target is now executable for shared primitives, dashboard, and library.
Next work should be incremental:

1. Add a shared test helper/constant for `const Size(412, 915)` before adding
   more screen-level cases.
2. Extend `onResponsive` coverage to folder detail, flashcard list, deck
   import, study entry, study session, study result, progress, and settings as
   those areas are edited.
3. Treat remaining visual weight as a copy-density and component-density
   question: remove repeated helper/status lines first, then review divider
   usage, button full-width behavior, and vertical gaps before changing
   typography or global scaling.
4. Keep text scaling enabled and verify `1.2` / `1.5` text scale on compact
   surfaces instead of disabling accessibility.
5. Continue using the repo verification chain:
   `python code-verification-guard\guard\run.py check --project .`,
   `flutter analyze`, targeted presentation tests, and integration tests when a
   device target is selected.
