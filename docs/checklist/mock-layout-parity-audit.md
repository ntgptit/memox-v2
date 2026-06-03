---
last_updated: 2026-06-03
status: audit
scope: docs/system-design/MemoX Design System/ui_kits/mobile/index.html -> lib/presentation/**
purpose: Strict mock/layout parity audit for V1 visual work. Planning only; no production Flutter changes.
---

# Mock / Layout Parity Audit

## Purpose

Prompt 48 audits the gap between the 129-variant MemoX mobile mock gallery and the current Flutter implementation.

This document is planning-only. It does not promote Future, Target, Rejected, or Visual-only mock states to Current. It does not authorize schema, route, SRS, repository, use case, or feature behavior changes.

## Source-of-truth order

1. `docs/business/**`
2. `docs/wireframes/**`
3. `docs/architecture/**`, `docs/state/**`, `docs/contracts/**`, `docs/database/**`
4. `docs/system-design/MemoX Design System/README.md`
5. `docs/system-design/MemoX Design System/colors_and_type.css`
6. `docs/system-design/MemoX Design System/ui_kits/mobile/index.html`
7. `docs/system-design/MemoX Design System/preview/*.html`
8. `docs/system-design/MemoX Design System/uploads/*`

The mock HTML is a visual reference only. Do not copy raw CSS, raw colors, JSX structure, inline styles, temporary data, or mock-only states into Flutter production code.

## Mock Source Inventory

`docs/system-design/mock-design-doc-mapping.md` and `docs/system-design/MemoX Design System/ui_kits/mobile/README.md` both describe the mobile kit as 129 rendered variants across 23 numbered gallery groups plus embedded shared overlays.

| Mock group | Mock variants | Current implementation status | Include in V1 layout parity? | Reason |
| --- | ---: | --- | --- | --- |
| Onboarding | 9 | Future / Visual-only target | No | Full onboarding route/folder remains Future; V1 only has owner-split zero-content guidance. |
| Dashboard | 8 | Partial | Yes | Current resume/scope/recent-deck behavior exists, but engagement/onboarding visual states stay Future/Target. |
| Library overview | 6 | Current for folders-only root | Yes | V1 library root is folders-only; root-level decks are Rejected. |
| Folder detail | 8 | Current for folder-owned decks plus study banners | Yes | V1 browsing, study/today/resume banners, and discard are Current; mastery/new subtitles remain Future. |
| Library search | 5 | Future for global/root search | No | Full global search route/use case is absent by design; only inline owner-screen search patterns may inform parity. |
| Flashcard list | 8 | Current for V1 deck-owned list scope | Yes | Study/today/resume/discard are Current; status/tag filters and bulk suspend/reset/tag remain Future. |
| Flashcard create | 6 | Current shared editor create scope | Yes | Shared editor exists; visual parity can be audited without changing behavior. |
| Flashcard edit | 7 | Current shared editor edit scope | Yes | Shared editor exists; History remains Future and must not be exposed. |
| Flashcard history | 5 | Future / Visual-only target | No | Requires separately promoted history screen and migration. |
| Deck import | 9 | Current inline V1 import, richer states visual target | Yes | Audit current inline import and preview/failure surfaces; do not promote 3-step/result mock. |
| Tag management | 11 | Current for tag list/rename/merge/delete | Yes | Tag-scoped study remains Blocked/Future; global tag-filtered cards remain Future. |
| Study entry gate / empty scope | 0 explicit group | Current for V1 empty-scope tiers except tag | Yes | Use wireframe as source because no explicit rendered gallery group exists. |
| Study review | 1 | Current core learning loop | Yes | Visual/density parity can be audited against mock group 12. |
| Study match | 1 | Current core learning loop | Yes | Visual/density parity can be audited against mock group 13. |
| Study guess | 1 | Current core learning loop | Yes | Visual/density parity can be audited against mock group 14. |
| Study recall | 2 | Current core learning loop | Yes | Hidden/revealed states are Current; timed-out polish remains separate. |
| Study fill | 2 | Current core learning loop | Yes | Input/wrong states are Current. |
| Study result | 6 | Current V1 result scope, engagement states Future | Yes | Audit current completion/error/empty fallback surfaces; do not promote goal/tough-card expansions. |
| Stats | 1 | Legacy visual-only target | No | Production route/docs use Progress. |
| Progress | 7 | Current V1 overview + active-session recovery; analytics Future | Yes | Audit current metrics/recovery; charts/range analytics remain Future. |
| Settings hub | 5 | Partial / route-action Current | Yes | Hub navigation is Current; live subtitles/About polish remain Partial/Target. |
| Account sync | 9 | Current current sync actions | Yes | Prompt 41 restore warning is Current; full restore-protection follow-up stays Future. |
| Learning settings | 5 | Partial | Yes | Current study defaults/read-only interval content only; goal/reminder controls remain Future. |
| Audio/Speech settings | 7 | Current global/front-language settings | Yes | Independent per-language settings remain Future/Target. |
| Shared dialogs | Embedded | V1 primitives Current / catalog Target partial | Yes | Audit primitive shape and composed usages; do not create catalog-only widgets. |
| Shared bottom sheets | Embedded | Partial / V1 primitives Current | Yes | Audit host/action/destination/card/scope sheets; SortOptions and engagement sheets remain Target/Future. |
| Snackbar / feedback | Embedded / preview | Current shared feedback surface | Yes | Audit visual tone, density, and safe error presentation. |
| App shell / navigation / bottom nav | Embedded / preview | Current shell/nav foundation | Yes | Audit mobile floating bottom nav, app bars, gutters, and dark/light parity. |
| Dark mode / light mode consistency | All groups | Foundation Current, screen parity Partial | Yes | Audit surfaces against Tokyo Pure Light and Tokyo Nebula token intent. |

## V1 Included Screens

Dashboard, Library Overview, Folder Detail, Flashcard List, Flashcard Create/Edit shared editor, Deck Import, Study Entry Gate / Empty Scope, Study Session Review, Study Session Match, Study Session Guess, Study Session Recall, Study Session Fill, Study Result, Progress, Settings Hub, Settings Account, Settings Learning, Settings Audio/Speech, Tag Management, shared dialogs, shared bottom sheets, snackbar / feedback surfaces, app shell / navigation / bottom nav, and dark/light consistency.

## Excluded Future / Target Groups

Global Search, Flashcard History, full Onboarding, tag-scoped study, engagement/streak/daily-goal/reminders beyond existing placeholder/current scope, root-level decks, status/tag filter chips if not implemented, bulk suspend/reset/tag if not implemented, independent per-language TTS settings, full restore-protection follow-up, legacy Stats as a production screen, dedicated SortOptionsSheet, engagement sheets, and catalog-only strong-confirm/account-removal/onboarding dialogs.

## Design Foundation Audit

Foundation status: PARTIAL.

| Category | Status | Evidence | Gap | Recommended prompt owner |
| --- | --- | --- | --- | --- |
| Material 3 usage | PASS | `lib/core/theme/schemes/light_theme.dart` and `dark_theme.dart` set `useMaterial3: true`. | None for foundation. | Prompt 49 |
| ColorScheme / seed / light / dark | PARTIAL | Explicit light/dark `ColorScheme` files exist under `lib/core/theme/schemes/**`; design docs describe seeded Tokyo Pure Light/Nebula tokens. | Flutter uses hand-authored schemes rather than generated seed source; acceptable, but Prompt 49 should reconcile token names/seed docs and scheme constants. | Prompt 49 |
| Typography family and type scale | PASS | `lib/core/theme/tokens/app_typography.dart` owns Plus Jakarta Sans and collapsed text theme. | Screen-level hierarchy still needs visual audit. | Prompt 49 |
| Spacing tokens | PARTIAL | `AppSpacing.card = EdgeInsets.all(md)` and `MxSpace` are available; many feature files use `MxGap`/`MxSpace`. | Raw feature/skeleton constants still appear, especially skeleton dimensions and a few direct `AppSpacing` imports in feature widgets. | Prompt 49 |
| Radius tokens | PASS | `AppRadius.card = borderSemi` and button radius tokens match final density freeze. | Verify all prominent card overrides screen-by-screen. | Prompt 49 |
| Elevation / ghost border | PASS | `MxCard` uses ghost border via `outlineVariant.withValues(alpha: AppOpacity.ghostBorder)` and theme elevation. | Accent cards with glow should remain single-CTA only. | Prompt 50 |
| Card padding | PASS | `MxCard` defaults to `AppLayout.cardPadding(context)`, backed by final `AppSpacing.card = 12`. | Some dense list rows need screen-by-screen verification. | Prompt 50 |
| Action density | PARTIAL | `MxActionButton` / `MxCardActions` exist; feature scan found full-width usages mostly in form/footer/study contexts. | `flashcard_toolbar_section.dart` still has a reviewed large/full-width footer-like site; density owner should re-audit all call sites before layout fixes. | Prompt 49 |
| App bar height | PARTIAL | Theme AppBar remains standard 56; mock allows `.appbar` 48 and `.appbar-lg` 56. | Need a screen-level decision for compact custom bars versus scaffold toolbars. | Prompt 49 |
| Bottom nav height | PASS | `MxBottomNav` locks `_mxBottomNavBarHeight = 64` with reviewed guard. | Verify shell placement in mobile screenshots later. | Prompt 50 |
| Page gutters / max content width | PASS | `MxContentShell`, `MxListScaffold`, and `AppLayout` own max widths/gutters. | Screen-specific nested scroll/body padding should be aligned in prompts 51-64. | Prompt 50 |
| Dark mode surfaces | PARTIAL | Light/dark scheme files and shared surfaces exist. | Need visual pass for feature-specific semantic/accent cards and status surfaces. | Prompt 50 |
| No raw hex | PASS | Feature scan found color constants primarily in token/scheme files. | Keep guard active. | Prompt 49 |
| No raw spacing in features unless guarded | PARTIAL | Shared `MxGap`/`MxSpace` are common. | Search found direct raw sizes in skeletons and model tile constants; some are reviewed, some need density audit. | Prompt 49 |
| No raw TextField / InkWell / ad-hoc buttons | PASS | Feature scan found `MxTextField`, `MxCard`, `MxPrimaryButton`, `MxSecondaryButton`, not raw Material controls. | Continue using shared widgets in fix prompts. | Prompt 50 |

## Shared Primitive Audit

| Primitive | Classification | Notes |
| --- | --- | --- |
| `MxScaffold` | Partially aligned | Uses shared app shell but visual parity depends on app-bar density per screen. |
| `MxContentShell` | Aligned | Constrains width and applies responsive gutters. |
| `MxAdaptiveScaffold` | Aligned | Owns shell/navigation adaptation; use it for app shell fixes. |
| `MxListScaffold` | Aligned | Good default for scroll/list screens; check nested list padding by screen. |
| `MxFormScaffold` | Aligned | Correct owner for editor/import/settings form-style footers. |
| `MxStudyScaffold` | Partially aligned | Core study structure exists; individual mode panel hierarchy/density needs visual pass. |
| `MxBottomNav` | Aligned | Floating 64dp glass/ghost-border bottom nav matches density freeze. |
| `MxCard` | Aligned | 12dp padding/radius and ghost border are aligned; accent usage requires restraint. |
| `MxActionButton` | Aligned | Semantic action density exists and asserts bad full-width contexts. |
| `MxCardActions` | Aligned | Correct card-level action layout owner. |
| `MxPrimaryButton` | Partially aligned | Low-level primitive is fine; feature prompts should prefer `MxActionButton` unless footer/form/study context requires primitive. |
| `MxSecondaryButton` | Partially aligned | Same as primary; acceptable as primitive but should not drive feature density ad hoc. |
| Chips / sort / segmented controls | Partially aligned | `MxChip`, `MxSortMenuChip`, `MxSegmentedControl`, and `MxSegmentedStatus` exist; several target mock chips are intentionally unimplemented. |
| Inputs | Aligned | `MxTextField`, `MxSearchField`, `MxSelectField`, `MxTagInput` cover current input surfaces. |
| Dialogs | Partially aligned | `MxDialog`, `MxConfirmationDialog`, `MxNameDialog`, and resume/start-over are Current; catalog-only strong-confirm/account/onboarding dialogs remain Target/Future. |
| Bottom sheets | Partially aligned | Host/action/destination/card/scope sheets are Current; dedicated sort/engagement/global search/history/tag-study sheets remain Target/Future/Blocked. |
| Snackbar / feedback | Aligned | `MxSnackbar`, `MxBanner`, and safe error mapping are present. |
| Retained async/loading/error/empty | Partially aligned | `MxRetainedAsyncState`, `MxLoadingState`, `MxErrorState`, `MxEmptyState` exist; some screens still use `AppAsyncBuilder` plus `MxEmptyState` for errors where visual parity should prefer `MxErrorState`. |

## Screen-by-screen Audit

### Dashboard

Mock variants: `02a`-`02h`.

Flutter files: `lib/presentation/features/dashboard/screens/dashboard_screen.dart`, `lib/presentation/features/dashboard/widgets/**`.

Current layout status: PARTIAL.

Major mismatches:

- Engagement visuals in the mock, including live streak chip/history, daily-goal ring, and goal-off/broken-streak states, remain Target/Future.
- Current `DashboardContent` is behavior-correct but reads as a section list rather than the final dense mobile dashboard hierarchy.

Minor mismatches:

- Verify card action density and recent-deck empty card placement against mock.
- Loading skeleton is present but needs visual comparison against `02b`.

Do not implement:

- Full onboarding handoff, streak persistence, reminder/goal settings, or engagement sheets.

Recommended fix prompt: Prompt 51 - Dashboard Visual Parity.

Estimated complexity: M.

Risk: Medium.

### Library Overview

Mock variants: `03a`-`03f`.

Flutter files: `lib/presentation/features/folders/screens/library_overview_screen.dart`, `lib/presentation/features/folders/widgets/library_*`.

Current layout status: 6 states present; loaded-state visual drift from Prompt 49 fixed in Prompt 49B (2026-06-04). Remaining items are token/density follow-ups, not state coverage.

Resolved in Prompt 49 (6-state visual/layout parity):

- Loading now renders skeleton folder rows (`LibrarySkeleton`) instead of a full-screen spinner.
- Error now renders a tokenized `MxErrorState` with localized copy and a Retry that re-runs the query.
- Overflow sheet is reachable from a visible per-row kebab (plus long-press), exposing only approved folder actions (Edit / Move / Import / Delete).
- Empty vs search-no-results remain distinct; inline scope-local search unchanged.
- Root-level deck rows confirmed absent (Rejected / Out of Scope).

Fixed in Prompt 49B (loaded-state visual drift from Prompt 49):

- Header: sliders/filter affordance (`Icons.tune_rounded`) replaces the search-icon toggle; it is a **visual-only target** (rendered disabled — no approved Library filter/sort sheet exists yet).
- Search is **always visible** inline below the title (no toggle). Static `All` filter chip removed. Still scope-local; Global Search and `/library/search` remain Future.
- Loaded state renders a `{n} FOLDERS` overline section header (count only; no sort control).
- Due summary card (`Icons.bolt_outlined` tile + localized `{n} cards due today`) shows when `dueToday > 0`, hidden otherwise. Non-interactive (state only knows the aggregate count; no folder-span / minutes / study-launch).
- FAB is now a labelled `New folder` pill (`MxFab` extended) wired to the existing create-folder flow. No New deck / Import entry.

Remaining (deferred, not state coverage):

- Folder tile density and card padding/radius are part of the Design Token / Density Foundation follow-up.
- Current sort exists at data/use-case level but no visible Library sort control (mock sort pill remains Future). Due-card subtitle (folder span · est. minutes) remains Future (needs read-model data).

Do not implement:

- Root-level decks, full Global Search, `/library/search` route promotion, root deck FAB action sheet, mock "Study due cards" / "Archive folder" overflow actions.

Fix prompt status: 6-state visual parity delivered under Prompt 49; loaded-state visual drift (header/search/section header/due card/FAB) fixed under Prompt 49B. Token/density reconciliation tracked separately.

Estimated complexity: M.

Risk: Medium.

### Folder Detail

Mock variants: `04a`-`04h`.

Flutter files: `lib/presentation/features/folders/screens/folder_detail_screen.dart`, `lib/presentation/features/folders/widgets/folder_*`.

Current layout status: PARTIAL.

Major mismatches:

- Prompt 45/47 made study/today/resume/discard Current, but visual hierarchy of banners versus breadcrumb/header/list still needs parity review.
- Mock mastery ring and `{n} new` subtitle remain Future and must not be added during layout fixes.

Minor mismatches:

- Verify locked/unlocked/search-empty/loading/error/delete/move-sheet spacing and card density.

Do not implement:

- New mastery/new counters, route bypasses, or broader cascade-copy behavior.

Recommended fix prompt: Prompt 53 - Folder Detail Visual Parity.

Estimated complexity: M.

Risk: Medium.

### Flashcard List

Mock variants: `06a`-`06h`.

Flutter files: `lib/presentation/features/flashcards/screens/flashcard_list_screen.dart`, `lib/presentation/features/flashcards/widgets/flashcard_*`.

Current layout status: PARTIAL.

Major mismatches:

- V1 behavior is Current for deck-owned list scope, but target status/tag filter chips, badges, and bulk suspend/reset/tag remain Future.
- Study/today/resume banners are newly Current and need density/placement parity.

Minor mismatches:

- Reorder/save footer and toolbar actions need density review against compact mobile mock.
- Loading/error/empty/no-results have code coverage but need visual comparison.

Do not implement:

- Flashcard History, Global Search, tag/status filters, bulk suspend/reset/tag.

Recommended fix prompt: Prompt 54 - Flashcard List Visual Parity.

Estimated complexity: M.

Risk: Medium.

### Flashcard Create/Edit Shared Editor

Mock variants: `07a`-`07f`, `08a`-`08g`.

Flutter files: `lib/presentation/features/flashcards/screens/flashcard_editor_screen.dart`, `lib/presentation/features/flashcards/widgets/flashcard_editor_*`.

Current layout status: PARTIAL.

Major mismatches:

- Shared editor behavior is aligned, but create/edit mock variants include validation, saving, load-error, details-open, and delete visuals that need a dedicated visual state pass.
- Editor has allowed full-width form/footer actions; verify they match mock form density, not card-action density.

Minor mismatches:

- Optional sections, preview card, tag input, and dirty-exit dialog spacing need visual QA.

Do not implement:

- Editor-owned History, Bury/Suspend, or independent TTS preview unless separately approved.

Recommended fix prompt: Prompt 55 - Flashcard Editor Visual Parity.

Estimated complexity: L.

Risk: Medium.

### Deck Import

Mock variants: `10a`-`10i`.

Flutter files: `lib/presentation/features/flashcards/screens/deck_import_screen.dart`, `lib/presentation/features/flashcards/widgets/bulk_add_*`.

Current layout status: PARTIAL.

Major mismatches:

- Current V1 is inline bulk-add with preview/commit; the richer multi-step/result mock states are visual targets only.
- Import body is functionally dense and should be compared for mobile scan order and footer behavior.

Minor mismatches:

- File card, paste card, preview list, mixed-invalid rows, and success/error feedback need visual pass.

Do not implement:

- Separate 3-step wizard, result screen, per-row skipped list, or extra duplicate policies.

Recommended fix prompt: Prompt 56 - Deck Import Visual Parity.

Estimated complexity: M.

Risk: Medium.

### Study Entry Gate / Empty Scope

Mock variants: no explicit rendered group.

Flutter files: `lib/presentation/features/study/screens/study_entry_screen.dart`, `lib/presentation/features/study/widgets/empty_scope_screen.dart`.

Current layout status: PARTIAL.

Major mismatches:

- No mock group exists, so wireframe is visual source; current screen direct-starts and only renders loading/error/empty gate surfaces.

Minor mismatches:

- Empty-scope CTA placement and copy hierarchy need wireframe-only visual audit.

Do not implement:

- Tag-scoped study empty cases until `StudyEntryType.tag` is approved.

Recommended fix prompt: Prompt 57 - Study Entry / Empty Scope Visual Parity.

Estimated complexity: S.

Risk: Low.

### Study Session Review

Mock variants: `12`.

Flutter files: `lib/presentation/features/study/screens/study_session_screen.dart`, `lib/presentation/features/study/widgets/study_session/review/**`.

Current layout status: PARTIAL.

Major mismatches:

- Behavior is frozen, but review card hierarchy, rating-row density, and top-bar spacing need mock comparison.

Minor mismatches:

- Dedicated review-mode view test gap remains P3 from Prompt 13.

Do not implement:

- Long-press shortcuts or SRS behavior changes.

Recommended fix prompt: Prompt 58 - Study Review Visual Parity.

Estimated complexity: M.

Risk: Medium.

### Study Session Match

Mock variants: `13`.

Flutter files: `lib/presentation/features/study/widgets/study_session/match/**`.

Current layout status: PARTIAL.

Major mismatches:

- Match board density, two-column/pair tile rhythm, and completion feedback need visual comparison.

Minor mismatches:

- Dedicated match-mode view test gap remains P3 from Prompt 13.

Do not implement:

- Pairing logic changes or long-press shortcuts.

Recommended fix prompt: Prompt 59 - Study Match Visual Parity.

Estimated complexity: M.

Risk: Medium.

### Study Session Guess

Mock variants: `14`.

Flutter files: `lib/presentation/features/study/widgets/study_session/guess/**`.

Current layout status: PARTIAL.

Major mismatches:

- Guess target card, option tile stack, wrong/correct fade treatment, and motion timing need visual comparison.

Minor mismatches:

- Existing dedicated tests cover behavior; visual spacing remains unverified.

Do not implement:

- Distractor sampling or answer-grading changes.

Recommended fix prompt: Prompt 60 - Study Guess Visual Parity.

Estimated complexity: M.

Risk: Medium.

### Study Session Recall

Mock variants: `15a`-`15b`.

Flutter files: `lib/presentation/features/study/widgets/study_session/recall/**`.

Current layout status: PARTIAL.

Major mismatches:

- Hidden/revealed answer card hierarchy and self-grade action density need visual pass.

Minor mismatches:

- Dedicated recall-mode view test gap and timed-out visual variant remain P3.

Do not implement:

- Recall timer/SRS behavior changes.

Recommended fix prompt: Prompt 61 - Study Recall Visual Parity.

Estimated complexity: M.

Risk: Medium.

### Study Session Fill

Mock variants: `16a`-`16b`.

Flutter files: `lib/presentation/features/study/widgets/study_session/fill/**`.

Current layout status: PARTIAL.

Major mismatches:

- Input card, hint/check actions, wrong feedback, and answer comparison need mock visual comparison.

Minor mismatches:

- Full-width study actions are allowed but should be verified against final compact study density.

Do not implement:

- Matcher, hint-taint, or TTS behavior changes.

Recommended fix prompt: Prompt 62 - Study Fill Visual Parity.

Estimated complexity: M.

Risk: Medium.

### Study Result

Mock variants: `17a`-`17f`.

Flutter files: `lib/presentation/features/study/screens/study_result_screen.dart`.

Current layout status: PARTIAL.

Major mismatches:

- Result cards exist, but loaded/loading/save-failed/defensive/tough-empty states need visual comparison.
- Goal-off and tough-card engagement states are Future/Target, not Current.

Minor mismatches:

- Study more scope picker and done/footer behavior need density check.

Do not implement:

- Streak/daily-goal, filtered tough-card route, or History route.

Recommended fix prompt: Prompt 63 - Study Result Visual Parity.

Estimated complexity: M.

Risk: Medium.

### Progress

Mock variants: `19a`-`19g`.

Flutter files: `lib/presentation/features/progress/screens/progress_screen.dart`, `lib/presentation/features/progress/widgets/**`.

Current layout status: PARTIAL.

Major mismatches:

- V1 renders overview metrics and active-session recovery; charts/ranges/history analytics in mock remain Future.
- Current UI is intentionally data-correct but not full analytics visual parity.

Minor mismatches:

- Metric-card density and active-session recovery card action hierarchy need visual pass.

Do not implement:

- Cards/day chart, accuracy chart, box distribution, streak/daily goal, Flashcard History, Global Search links.

Recommended fix prompt: Prompt 64 - Progress / Settings / Shared Surfaces Visual Parity.

Estimated complexity: M.

Risk: Medium.

### Settings Hub

Mock variants: `20a`-`20e`.

Flutter files: `lib/presentation/features/settings/screens/settings_screen.dart`, `lib/presentation/features/settings/widgets/settings_*`.

Current layout status: PARTIAL.

Major mismatches:

- Route/action safety is Current; loading/signed-out/signing-in/sync-error hub visual states need dedicated comparison.
- About bottom sheet remains Target; current About uses Flutter `AboutDialog`.

Minor mismatches:

- Subtitle dynamism and disabled Soon rows need visual polish.

Do not implement:

- New settings routes, full About sheet, engagement settings behavior.

Recommended fix prompt: Prompt 64 - Progress / Settings / Shared Surfaces Visual Parity.

Estimated complexity: M.

Risk: Low.

### Settings Account

Mock variants: `21a`-`21i`.

Flutter files: `lib/presentation/features/settings/screens/account_settings_screen.dart`, `lib/presentation/features/settings/widgets/account_settings_group.dart`, `lib/presentation/features/settings/widgets/drive_sync_settings_group.dart`.

Current layout status: PARTIAL.

Major mismatches:

- Prompt 41 restore warning is Current; full restore protection follow-up remains Future.
- Signed-out/signing-in/failed/no-backup/ready/uploading/restoring/token-expired visual surfaces need comparison.

Minor mismatches:

- Full-width account/footer actions are allowed but need density confirmation.

Do not implement:

- Pre-restore snapshot, restore history, cloud version comparison, conflict resolution, second destructive confirmation, strong-confirm account removal.

Recommended fix prompt: Prompt 64 - Progress / Settings / Shared Surfaces Visual Parity.

Estimated complexity: M.

Risk: Medium.

### Settings Learning

Mock variants: `22a`-`22e`.

Flutter files: `lib/presentation/features/settings/screens/learning_settings_screen.dart`, `lib/presentation/features/settings/widgets/study_settings_group.dart`.

Current layout status: PARTIAL.

Major mismatches:

- Current V1 owns study defaults/read-only interval table; daily-goal/reminder states are Future/Visual-only target.

Minor mismatches:

- Read-only table density and disabled controls need visual pass.

Do not implement:

- Daily goal, streak, reminders, or notification permission behavior.

Recommended fix prompt: Prompt 64 - Progress / Settings / Shared Surfaces Visual Parity.

Estimated complexity: S.

Risk: Low.

### Settings Audio/Speech

Mock variants: `23a`-`23g`.

Flutter files: `lib/presentation/features/settings/screens/audio_speech_settings_screen.dart`, `lib/presentation/features/settings/widgets/speech_*`.

Current layout status: PARTIAL.

Major mismatches:

- Current V1 is one global/front-language TTS settings set; independent per-language tabs/settings remain Future.
- Loading/no-voices/engine-error/playing/saving visuals need comparison.

Minor mismatches:

- Slider and preview text field density need mobile pass.

Do not implement:

- Independent Korean/English setting sets unless promoted.

Recommended fix prompt: Prompt 64 - Progress / Settings / Shared Surfaces Visual Parity.

Estimated complexity: M.

Risk: Low.

### Tag Management

Mock variants: `11a`-`11k`.

Flutter files: `lib/presentation/features/settings/screens/tag_management_screen.dart`, `lib/presentation/features/settings/providers/tag_management_notifier.dart`.

Current layout status: PARTIAL.

Major mismatches:

- Current behavior covers list/loading/empty/search/action/rename/merge/delete/busy/error, but visual state parity against all 11 variants has not been completed.
- Error currently uses `MxEmptyState` in one async error branch; visual parity should prefer a clear error surface.

Minor mismatches:

- Search/sort row and context sheet density need comparison.

Do not implement:

- Tag-scoped study or global "view cards with tag".

Recommended fix prompt: Prompt 64 - Progress / Settings / Shared Surfaces Visual Parity.

Estimated complexity: M.

Risk: Medium.

### Shared Dialogs

Mock variants: embedded overlays.

Flutter files: `lib/presentation/shared/dialogs/**`.

Current layout status: PARTIAL.

Major mismatches:

- Current primitives cover confirmation/name/resume; catalog-only strong-confirm/account/onboarding dialogs remain Target/Future.

Minor mismatches:

- Dialog padding, button density, danger tone, and barrier rules should be screenshot-verified.

Do not implement:

- New catalog widgets without an approved feature owner.

Recommended fix prompt: Prompt 64 - Progress / Settings / Shared Surfaces Visual Parity.

Estimated complexity: S.

Risk: Low.

### Shared Bottom Sheets

Mock variants: embedded overlays.

Flutter files: `lib/presentation/shared/dialogs/mx_bottom_sheet.dart`, `mx_action_sheet_list.dart`, `mx_destination_picker_sheet.dart`, `mx_card_actions_sheet.dart`, `lib/presentation/shared/bottom_sheets/study_scope_picker_sheet.dart`.

Current layout status: PARTIAL.

Major mismatches:

- Current V1 sheets exist; dedicated sort, engagement, Global Search, History, and tag-study sheets remain Target/Future/Blocked.

Minor mismatches:

- Drag handle, keyboard inset, list item gap, and action tone should be screenshot-verified.

Do not implement:

- Dedicated `SortOptionsSheet`, engagement sheets, Global Search sheets, History sheets, or tag-study sheets.

Recommended fix prompt: Prompt 64 - Progress / Settings / Shared Surfaces Visual Parity.

Estimated complexity: S.

Risk: Low.

### Snackbar / Feedback

Mock variants: embedded / preview.

Flutter files: `lib/presentation/shared/feedback/**`.

Current layout status: PARTIAL.

Major mismatches:

- Shared snackbar/banner exists; not yet visually audited against preview toast across success/error/warning/info.

Minor mismatches:

- Verify bottom-nav overlap, dark-mode contrast, and action affordance.

Do not implement:

- Blocking modal feedback for background operations.

Recommended fix prompt: Prompt 64 - Progress / Settings / Shared Surfaces Visual Parity.

Estimated complexity: S.

Risk: Low.

### App Shell / Navigation / Bottom Nav

Mock variants: repeated across core groups.

Flutter files: `lib/presentation/shared/layouts/mx_adaptive_scaffold.dart`, `lib/presentation/shared/widgets/mx_bottom_nav.dart`, `lib/core/theme/component_themes/app_bar_theme.dart`.

Current layout status: PARTIAL.

Major mismatches:

- Bottom nav is aligned to 64dp final density; app-bar density still needs per-screen compact-versus-standard decision.

Minor mismatches:

- Verify glass blur, safe-area bottom offset, selected pill, and rail/tablet behavior.

Do not implement:

- New route structure or Dashboard-as-default boot behavior.

Recommended fix prompt: Prompt 50 - Shared Shell / Navigation Visual Parity.

Estimated complexity: M.

Risk: Medium.

### Dark Mode / Light Mode Consistency

Mock variants: all groups with mobile kit toggle.

Flutter files: `lib/core/theme/schemes/light_theme.dart`, `lib/core/theme/schemes/dark_theme.dart`, feature widgets using semantic surfaces.

Current layout status: PARTIAL.

Major mismatches:

- Theme foundation exists, but feature-specific status/accent surfaces need dark-mode screenshot review.

Minor mismatches:

- Check error, warning, success, rating, mastery, and disabled tones in all shared cards/sheets/dialogs.

Do not implement:

- New colors or token changes without approval; token reconciliation belongs to Prompt 49.

Recommended fix prompt: Prompt 49 - Design Token / Density Foundation.

Estimated complexity: M.

Risk: High if tokens change; Low if audit-only.

## Recommended Prompt Sequence 49-64

| Prompt | Scope | Rule |
| --- | --- | --- |
| Prompt 49 | Design Token / Density Foundation | Reconcile token docs, Flutter theme values, app-bar density, raw-size guard exceptions, and dark/light semantic surfaces before screen fixes. |
| Prompt 50 | Shared Shell / Navigation / Primitives | Align `MxScaffold`, `MxContentShell`, `MxAdaptiveScaffold`, bottom nav, app bars, cards, buttons, chips, inputs, dialogs, sheets, snackbar. |
| Prompt 51 | Dashboard Visual Parity | Fix only current Dashboard layout states; no engagement promotion. |
| Prompt 52 | Library Overview Visual Parity | Folders-only root visual parity; no root decks/global search. |
| Prompt 53 | Folder Detail Visual Parity | Folder-owned decks plus current study/today/resume banners; no new mastery/new data. |
| Prompt 54 | Flashcard List Visual Parity | Current deck-owned list and study banners; no status/tag filters or History. |
| Prompt 55 | Flashcard Editor Visual Parity | Shared create/edit editor visual states; no new editor-owned behavior. |
| Prompt 56 | Deck Import Visual Parity | Current inline import UI only; no wizard/result promotion. |
| Prompt 57 | Study Entry / Empty Scope Visual Parity | Wireframe-driven empty gate visuals; no tag scope. |
| Prompt 58 | Study Review Visual Parity | Review mode layout only; no SRS changes. |
| Prompt 59 | Study Match Visual Parity | Match mode layout only; no pairing changes. |
| Prompt 60 | Study Guess Visual Parity | Guess mode layout only; no distractor changes. |
| Prompt 61 | Study Recall Visual Parity | Recall hidden/revealed layout only; no timer/SRS changes. |
| Prompt 62 | Study Fill Visual Parity | Fill input/wrong layout only; no matcher/hint/TTS changes. |
| Prompt 63 | Study Result Visual Parity | Current result states only; no engagement/history routes. |
| Prompt 64 | Progress / Settings / Shared Surfaces Visual Parity | Progress V1 metrics/recovery, settings sub-screens, tags, dialogs, sheets, snackbar; no Future features. |

## Risk Notes

- Visual parity can accidentally promote mock-only behavior. Every fix prompt must restate excluded Future/Target groups.
- Design token changes require approval because they cascade across the app.
- App-bar density is the highest-impact visual decision because it changes every screen's first viewport.
- Study mode fixes must stay layout-only; SRS intervals, grading, result transitions, session creation, and resume/discard behavior are frozen for current V1.
- Progress and settings have the highest status-inflation risk because the mock contains analytics/engagement/settings controls that current V1 intentionally excludes.
- Do not mark a screen Current solely because it visually renders.

## No Feature Promotion Rule

No feature promotion during layout parity unless explicitly approved. Layout work may adjust spacing, hierarchy, shared primitives, and token usage for already-Current behavior only. Future, Target, Rejected, Blocked, and Visual-only mock states stay non-production until promoted by a separate docs/product decision task.
