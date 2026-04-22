# CLAUDE.md — MemoX

Personal flashcard / spaced-repetition app. Flutter 3.11+ / Dart 3.11, Riverpod 3, Drift, Material 3.

This file is the **workspace router**. It takes precedence over generic skills and global defaults per the global priority contract (system → global CLAUDE.md → **this file** → skills → CI).

---

## Non-negotiable: the local guard

Before claiming any code change is done, run:

```bash
python tools/guard/run.py --policy memox
```

Must report **0 errors** and **0 criticals**. Warnings are acceptable only when the rule explicitly allows them.

- Policy lives in `tools/guard/policies/memox/` (`*.yaml`). Read the relevant rule before arguing with it.
- Rule scopes: `ui` (features + shared), `features` (features only), `shared_widget_dirs`, `widget_ui_files`, `app_bootstrap`, `theme_sources`, `theme_extensions`.
- Escape hatch for one-off layout sizes: append `// guard:raw-size-reviewed <reason>` on the literal's line. Use sparingly — prefer tokens.
- When a rule fires, read the rule definition in the YAML before patching. Do not silence rules.

Pair with `flutter analyze` (must also report clean) after every change batch.

---

## Architecture (Clean Architecture, enforced by guard)

```
lib/
├── app/                      # bootstrap, DI, router, global config
│   ├── app.dart              # barrel → re-exports MemoxApp from main.dart
│   ├── bootstrap/  config/  di/  router/
├── main.dart                 # MemoxApp root: MaterialApp + AppLocalizations wiring
├── core/                     # framework-agnostic building blocks
│   ├── theme/                # design-system tokens (see below)
│   ├── constants/ enums/ errors/ extensions/
│   ├── network/ services/ utils/ validators/
├── data/                     # DTOs, mappers, datasources, repo implementations
├── domain/                   # entities, value objects, repo interfaces, use cases, domain services
├── presentation/
│   ├── features/<feature>/   # screens, widgets, providers, viewmodels per feature
│   └── shared/               # cross-feature UI: widgets, layouts, dialogs, feedback, states
└── l10n/                     # ARB sources + generated AppLocalizations
```

**Layer rules**:
- `domain/` must not import `flutter/material.dart`, Drift, or any `data/`/`presentation/`.
- `data/` depends on `domain/` only. Drift transactions stay in `data/` or `core/database/`.
- `presentation/` never imports `data/` implementations or Drift. UI reaches state via providers.
- Do not add new source under `lib/shared/` or `lib/utils/` — use `core/`, `presentation/shared/`, or a feature folder.
- Feature files must not import another feature's screen or widget directly. Promote to `presentation/shared` or depend on domain/app boundaries.

---

## Theme layer (design system)

Tokens live in `lib/core/theme/` as **separate files**, not a single barrel:

| File | Purpose |
|---|---|
| `app_colors.dart` | Raw color palette (Indigo / Amber / Teal + neutrals + success/warning/info + rating grades). **Shared widgets and features must NOT import this directly.** |
| `app_spacing.dart` | `AppSpacing` — spacing + gaps (`xxs`, `xs`, `sm`, `md`, `lg`, `xl`, `xxl`, `xxxl`, `xxxxl`, `screen`). |
| `app_radius.dart` | `AppRadius` — radii + `BorderRadius` helpers (`borderSm`, `borderMd`, `borderLg`, `borderFull`). |
| `app_icon_sizes.dart` | `AppIconSizes` — icon size scale. |
| `app_elevation.dart` | Elevation scale. |
| `app_breakpoints.dart` | Responsive breakpoints. |
| `app_motion.dart` | Animation durations + curves. |
| `app_typography.dart` | Must derive from `TextTheme`. Exposes `AppTypography.textTheme` (base, mobile-first) + `AppTypography.scaledTextTheme(base, WindowSize)` for tier-aware display/headline/title scaling. Do not construct a second font system. |
| `theme_extensions.dart` | `AppOpacity`, `MxColorsExtension` (semantic success/warning/info + rating grades), `RepetitionColorRole` enum + `repetitionColor(role)` mapping. **This is the only theme file UI layers may import besides tokens.** |
| `app_theme.dart` | `AppTheme.light()` / `AppTheme.dark()`. Must not `export` other theme files — the guard forbids barrel re-exports. |
| `light_theme.dart` / `dark_theme.dart` | `buildLightTheme()` / `buildDarkTheme()`. |
| `component_themes/` | Per-component `ThemeData` configuration. See table below. |

**Component themes (`component_themes/*.dart`)** — every Material surface is themed centrally so features get consistent focus / hover / pressed / disabled behavior for free:

| File | Covers |
|---|---|
| `focus_theme.dart` | `AppFocus` state-layer opacities (`hoverOpacity`, `focusOpacity`, `pressedOpacity`, `selectedOpacity`), ring width, `overlay(...)` + `overlayProperty(...)` helpers for `WidgetStateProperty<Color?>`. |
| `app_bar_theme.dart` | `AppBar` surface + title style. |
| `button_theme.dart` | Elevated / Filled / Outlined / Text / IconButton / FAB. Focus routed through `AppFocus`. |
| `card_theme.dart` | `CardTheme`. |
| `chip_theme.dart` | `ChipTheme`. |
| `dialog_theme.dart` | `Dialog`, `BottomSheet`, `SnackBar`. |
| `divider_theme.dart` | `DividerTheme`. |
| `icon_theme.dart` | Default + `onPrimary` `IconThemeData`. |
| `input_theme.dart` | `InputDecorationTheme`. |
| `list_tile_theme.dart` | `ListTileThemeData` — shared padding, shape, selected fill. |
| `navigation_bar_theme.dart` | `NavigationBar` + `NavigationRail`. |
| `popup_menu_theme.dart` | `PopupMenuTheme` + `MenuTheme`. |
| `progress_indicator_theme.dart` | Linear + circular. |
| `scrollbar_theme.dart` | `ScrollbarTheme` — desktop hover/drag states. |
| `segmented_button_theme.dart` | `SegmentedButton`. |
| `text_selection_theme.dart` | Cursor + selection handles. |
| `toggle_theme.dart` | `Switch`, `Checkbox`, `Radio`, `Slider` — state layers via `AppFocus`. |
| `tooltip_theme.dart` | `TooltipTheme`. |

**Rules**:
- New Material component surfaces MUST be configured here before being used in a feature. Do not thread `color:` / `padding:` per call site — add it to the component theme.
- Focus / hover / pressed visuals MUST flow through `AppFocus.overlay(...)` or `AppFocus.overlayProperty(...)`. Do not hand-roll focus rings with `Container + Border` or hardcode alpha values.
- Shared `Mx*` widgets compose on top of these themes; they do not re-declare the same colors or paddings.

**Hard rules enforced by guard**:
- UI code gets colors via `Theme.of(context).colorScheme.*` and `context.mxColors.*`, never from `app_colors.dart`.
- Typography via `Theme.of(context).textTheme.*`, never from `app_typography.dart` directly.
- No raw `Colors.transparent` in presentation — use `MaterialType.transparency` or a themed color.
- No raw alpha literals like `.withOpacity(0.5)` — use `AppOpacity.half` / `AppOpacity.disabled` / `AppOpacity.hover`.
- No inline `TextStyle(...)` in feature UI, no `copyWith` reshaping font weight/size/height/letter-spacing at the render site.
- No raw size literals in regular feature widgets. One-off layout dimensions in **shared** widgets need `// guard:raw-size-reviewed`.
- No `MediaQuery`-based font scaling in feature/widget code. Tier-aware typography is applied ONCE in `MemoxApp.builder` via `AppTypography.scaledTextTheme(...)`; shared widgets and features read `Theme.of(context).textTheme.*` and inherit the scaled values automatically. Screen-percentage layouts only inside dialog/sheet/overlay/fullscreen-modal widgets.
- Repetition colors: always via `customColors.repetitionColor(repetitionOrder.repetitionColorRole)`. Never rotate a raw palette list.

---

## Dark theme contract (Quizlet-style deep navy)

Dark mode targets a **deep-navy + indigo accent** aesthetic, not flat grey:

- Scaffold / base surface: `AppColors.darkNavy10` (`#0A0E27`).
- Card layers: `darkNavy15 → darkNavy25 → darkNavy40` mapped to `surfaceContainerLow → surfaceContainerHigh → surfaceBright`.
- Outline: `darkNavyOutline` / `darkNavyOutlineVariant` — faint indigo strokes, not grey.
- Primary accent: unchanged Indigo palette (`primary50/60/70`).
- Card surfaces in dark mode **must read with a subtle stroke** on busy screens — prefer `MxCardVariant.outlined` for library listings, filter panels, streak cards. Keep `.filled` for ambient containers.
- Text: `onSurface` uses `neutral95` for brighter contrast on navy.

**Rules**:
- Do not introduce new "dark grey" neutrals for backgrounds. Extend `AppColors.darkNavy*` if a new tier is needed.
- Do not hardcode background colors in widgets — always go through `scheme.surface` / `scheme.surfaceContainer*`.
- Test every screen in **both** themes before shipping; a component that only works in light mode is a bug.

---

## Bootstrap contract (`main.dart`)

`lib/main.dart` is the canonical app shell. It must contain all four of these exact patterns (checked by `main_app_uses_l10n`):

1. `import '.../l10n/generated/app_localizations.dart';`
2. `localizationsDelegates: AppLocalizations.localizationsDelegates`
3. `supportedLocales: AppLocalizations.supportedLocales`
4. `onGenerateTitle: (context) => AppLocalizations.of(context).appName`

`lib/app/app.dart` is a barrel that re-exports `MemoxApp` from `main.dart` so tests and tooling can reach it via the standard path.

---

## Shared widget catalogue

All reusable UI lives in `lib/presentation/shared/`. Features MUST reach for a shared widget first; only drop to raw Material widgets when the shared catalogue is a mismatch, and in that case consider promoting the new pattern into `shared/` for the next feature.

### Layouts (`presentation/shared/layouts/`)

| Widget | Use when |
|---|---|
| `MxAdaptiveScaffold` | Top-level shell with destinations. Handles bottom nav → rail → extended rail across tiers. |
| `MxScaffold` | Leaf-screen scaffold (no destinations). |
| `MxContentShell` | Caps reading column width at a `MxContentWidth` role. |
| `MxSection` | Labeled content grouping inside a screen. |

### Widgets (`presentation/shared/widgets/`)

| Widget | Purpose |
|---|---|
| `MxPrimaryButton` / `MxSecondaryButton` | Filled / outlined / text buttons with size variants. |
| `MxIconButton` | Themed icon-only button. |
| `MxTextField` / `MxSearchField` | Input fields, bound to input theme. |
| `MxCard` | Filled / elevated / outlined card container. |
| `MxListTile` | List row with leading/title/subtitle/trailing. |
| `MxChip` / `MxBadge` | Filter chips, status badges. |
| `MxProgressIndicator` | Linear + circular progress with size variants. |
| `MxSegmentedControl` | Two/three-way toggle. |
| `MxBreadcrumbBar` | Navigation breadcrumbs. |
| `MxAvatar` | Circular avatar + optional "Plus" pill badge. |
| `MxPageDots` | Carousel page indicator. |
| `MxSectionHeader` | Title + optional action link ("Xem tất cả"). |
| `MxStudySetTile` | Library row: icon tile + title + meta + owner. |
| `MxFlashcard` | Hero study-card surface (front/back face). |
| `MxStreakCard` | Profile streak surface with flame + 7-day row. |

### Dialogs / Feedback / States

| Widget | Purpose |
|---|---|
| `MxDialog`, `MxConfirmationDialog`, `MxBottomSheet` | Modal surfaces. |
| `MxBanner`, `MxSnackbar` | Inline + transient feedback. |
| `MxEmptyState`, `MxErrorState`, `MxLoadingState`, `MxOfflineState` | Full-area states. |

### Still missing (build when the first feature needs them)

These patterns appear in the target design but are not in the catalogue yet. Build them in `presentation/shared/` and document here, not inside a feature folder:

- **`MxFilterDropdown`** — "Tất cả / Đã tạo / Đã học / Đã tải về" pill + menu.
- **`MxTabBar`** — themed `TabBar` wrapper (Học phần / Thư mục / Lớp học) with the indigo underline indicator.
- **`MxFabCluster`** — the centered raised "+" FAB sitting inside the bottom nav notch.
- **`MxStatChip`** — compact `icon + number + label` inline chip for stats rows.
- **`MxTermRow`** — term/definition two-line row for flashcard set detail.
- **`MxStudyModeTile`** — the "Thẻ ghi nhớ / Học / Kiểm tra / Ghép thẻ / Blast" tile with colored icon square and chevron.
- **`MxProgressRing`** — circular progress-ring variant for rating completion.
- **`MxFolderTile`** — library folder row (folder icon + name + owner).
- **`MxClassTile`** — class card row.
- **`MxAchievementBadge`** — profile achievement icon pill.

Do not let these leak into feature code as anonymous `Container + Row` blobs. If a feature needs one, stop and add it to `shared/` first.

---

## Responsive contract (phone → tablet → desktop)

MemoX must render correctly on **every** window size from phone portrait to extra-large desktop. Responsiveness is not an afterthought — it is enforced at the shell and compose level.

### Window sizes (Material 3 window size classes)

| Tier | Width | Typical device |
|---|---|---|
| `compact` | `< 600` | phone portrait |
| `medium` | `600–839` | phone landscape, small tablet |
| `expanded` | `840–1199` | tablet, small laptop |
| `large` | `1200–1599` | desktop |
| `extraLarge` | `≥ 1600` | wide desktop, TV |

Source of truth: `lib/core/theme/app_breakpoints.dart` (`AppBreakpoints`, `WindowSize`, `context.windowSize`, `context.isCompact`, `context.isMediumOrLarger`, `context.isExpandedOrLarger`).

### Required primitives

Two layers. **Prefer the layout-spec layer.** Drop to the primitive layer only for genuine one-offs.

#### Layer 1 — Layout spec (preferred)

`lib/core/theme/app_layout.dart` holds the repeated layout rules. Every new screen reads here:

| API | Returns | Purpose |
|---|---|---|
| `context.pagePadding` | `EdgeInsets` | Horizontal page gutter for the active tier. |
| `context.contentMaxWidth(MxContentWidth role)` | `double` | Max width for a centered content column by role (`reading` / `wide` / `hero` / `full`). |
| `context.sectionGap` | `double` | Vertical gap between top-level page sections. |
| `context.gridColumns({int base = 1})` | `int` | Column count for card/list grids at the active tier. |
| `context.dialogMaxWidth` | `double` | Max width for dialogs on wide windows. |
| `AppLayout.railWidth` | `double` | Extended rail width. |
| `MxContentShell(width: MxContentWidth)` | widget | Wraps content in the role-based width cap. |
| `MxAdaptiveScaffold` | widget | Top-level shell. Bottom nav → rail → extended rail automatically. |
| `MxScaffold` | widget | Leaf-screen scaffold (no destinations). |

If you need a "responsive number" that is plausibly reused across screens, **add it to `AppLayout` first**, then consume it via the `LayoutContext` extension.

#### Layer 2 — Primitive (one-offs only)

`lib/core/utils/responsive.dart` is the low-level escape hatch. Use **only** for tier-aware values that do not correspond to a layout role:

| API | Purpose |
|---|---|
| `context.windowSize` / `context.isCompact` / `context.isExpandedOrLarger` | Read the current tier (defined in `app_breakpoints.dart`). |
| `context.responsive<T>(compact:, medium:, expanded:, large:, extraLarge:)` | Pick a tier-aware value with mobile-first fallback. |
| `context.adaptive<T>(compact:, expanded:)` | Two-way phone vs. everything-else split. |
| `ResponsiveValue<T>` | Reusable value object when a widget needs to hold its own tier map. |

If you find yourself writing the same `context.responsive(...)` call on three screens → promote it to `AppLayout`. The legacy free function `responsiveColumnCount` was removed — use `context.gridColumns(...)`.

### Rules (non-negotiable)

1. **Every new screen must be usable at all five tiers.** Test at 360 px, 720 px, 1024 px, 1440 px, 1920 px before claiming done.
2. **Top-level tab / destination hierarchies MUST use `MxAdaptiveScaffold`.** Do not hand-roll `BottomNavigationBar` or `NavigationRail` per feature.
3. **Leaf screens wrap content with `MxContentShell`** (or set `constrainBody: true` on `MxAdaptiveScaffold`) so text columns cap via `context.contentMaxWidth(MxContentWidth.reading | wide | hero)`. Never let a reading column stretch edge-to-edge on desktop.
4. **Layout decisions go through `AppLayout` / `LayoutContext`.** `context.responsive<T>(...)` is a primitive — use it only when the value doesn't correspond to a layout role. Recurring tier-aware values must live in `AppLayout`. Do not scatter `if (MediaQuery.sizeOf(context).width > 840)` checks across widgets.
5. **No hardcoded pixel widths for layout structure.** Content max widths come from `AppLayout`; spacing from `AppSpacing` / `MxSpace`; grid counts from `context.gridColumns(...)`. One-off structural widths need `// guard:raw-size-reviewed <reason>`.
6. **No `MediaQuery`-based font scaling.** Typography scales via `TextTheme` and `MediaQuery.textScalerOf(context)` only — the guard `ui_font_size_media_query_scaling` will reject raw math.
7. **Screen-percentage layouts (`MediaQuery.size.width * 0.8` etc.) are allowed only inside dialog / bottom-sheet / overlay / fullscreen-modal widgets** — enforced by `ui_media_query_screen_percentage`.
8. **Flex first, fixed last.** Prefer `Flex`, `Wrap`, `LayoutBuilder`, `FractionallySizedBox`, `AspectRatio` over fixed sizes. When forced to use `SizedBox`, the size must come from a token.
9. **Orientation is not a substitute for tier.** Do not branch on `Orientation.portrait` to decide desktop vs. phone — use `context.windowSize`.
10. **Horizontal scroll is a last resort.** On compact, stack vertically; on expanded+, lay out side-by-side or use `Wrap`. Never force horizontal scroll on a phone content column.
11. **Forms and detail views**: single-column on compact, optional master-detail or two-column on expanded+. Gate the split with `context.isExpandedOrLarger`.
12. **Tap targets remain ≥ 48 dp at every tier** (Material guideline). Do not shrink touch targets on desktop just because cursor precision improved — keyboards and touchscreens are in play.
13. **Overflow is a bug.** `RenderFlex overflowed` or clipped text at any supported tier blocks merge. Use `Expanded`, `Flexible`, `Wrap`, `FittedBox`, or `TextOverflow.ellipsis` with `maxLines`.
14. **Images and illustrations**: use `AspectRatio` or `BoxFit.contain`. Avoid fixed `width`/`height` in logical pixels for art.
15. **Keyboard + pointer**: on expanded+ tiers, actionable widgets should support focus + Enter/Space activation and cursor hover feedback (`InkWell` or `MouseRegion`).
16. **Safe areas**: respect `SafeArea` on compact (notches); on expanded+, respect window insets for docked app chrome.

### Review checklist for every new widget/screen

- [ ] Renders without overflow at compact (360 px) and extraLarge (1920 px).
- [ ] Navigation uses `MxAdaptiveScaffold` (top-level) or `MxScaffold` (leaf).
- [ ] Reading columns capped via `MxContentShell` with a `MxContentWidth` role.
- [ ] Tier-sensitive numbers (columns, paddings, column widths) routed through `AppLayout` / `LayoutContext` — fall back to `context.responsive` only for one-offs.
- [ ] No `MediaQuery` size math for fonts; no `Orientation` branching for desktop.
- [ ] Tap targets ≥ 48 dp; focus + hover states present on expanded+.
- [ ] `flutter analyze` clean; `python tools/guard/run.py --policy memox` clean.

---

## State management

- **Riverpod 3** with annotation-based providers (`riverpod_annotation`).
- Widgets use `ref.watch(...)` for render state and `ref.read(...)` only inside action callbacks.
- `ref.watch` inside callbacks is forbidden. `ref.read` inside `build()` is forbidden.
- Widget `build()` must not trigger navigation directly, run multi-step async chains, do collection processing (sort/group/filter/fold across many lines), or accumulate try/catch blocks. Push that work into providers, notifiers, use cases, or presenters.
- Widgets must not import DAO / Drift / repository implementation files or watch repository providers directly. Go through a domain-facing provider.
- After `await` in UI code, guard `BuildContext` use with `if (!context.mounted) return;`.

---

## Coding contract (global contract + MemoX specifics)

- Minimal change first, fail fast, early return, no unnecessary `else`.
- No magic values — use named constants or tokens.
- Semantic naming; one responsibility per class/file.
- No business logic in controllers or UI.
- Do not invent extra layers/factories/abstractions unless the repo already uses them, the user asks, or the problem requires them.
- UI must not stringify raw errors or depend on low-level network/database exception types — map to user-facing messages via providers/use cases.

---

## Localization

- ARB sources in `lib/l10n/`. Generated delegate at `lib/l10n/generated/app_localizations.dart`.
- `pubspec.yaml` must keep `flutter_localizations` + `generate: true` (checked by `pubspec_enables_l10n_generation`).
- UI strings go through `AppLocalizations.of(context)`. Do not hardcode user-facing text in widgets.

---

## Verification workflow (run in this order)

1. `python tools/guard/run.py --policy memox` — must be clean (0 FAIL).
2. `flutter analyze` — must report **No issues found**.
3. Targeted widget/unit tests for the area touched (when they exist).

If a step is skipped or fails, say so explicitly in the response — do not claim completion.

---

## Output contract for this repo

- Prefer patch/diff/snippet over full-file dumps.
- When reporting guard fixes, cite the rule `id` (e.g. `theme_repetition_semantic_colors`) and the file:line.
- When adding an escape hatch (`// guard:raw-size-reviewed`), state *why* the literal can't become a token.

---

## Sub-agent architecture

This repo defines specialized sub-agents under `.claude/agents/` to save context and increase precision. The main session should delegate scoped tasks to them instead of reimplementing their workflow inline.

Roster: `flutter-code-searcher`, `flutter-ui-reviewer`, `flutter-architecture-reviewer`, `dart-refactor-planner`, `git-workflow-helper`, `test-runner`.

Full decision tree, composition patterns, anti-patterns, and token-budget guidelines: **`.claude/ORCHESTRATION.md`**.

Working-language convention for this repo: **Vietnamese for discussion, English for code / comments / commit messages / PR descriptions.**
