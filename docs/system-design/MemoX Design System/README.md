# MemoX Design System

A design system for **MemoX** — a personal flashcard learning app built in Flutter 3.24+ / Dart 3.5+ with 5 study modes (Review, Match, Guess, Recall, Fill), SRS spaced repetition, and Google Drive backup.

This repo contains the brand foundations, tokens, and a high-fidelity UI kit for designing consistent new surfaces, marketing pages, decks, and prototypes for MemoX.

## Product context

MemoX is a calm, focused learning tool. It treats studying as a durable daily practice — the product shell stays quiet so the *cards* themselves can be the loudest thing on screen. The architecture mandates a strict, tokenized design language:

- **Feature-first Clean Architecture** in Flutter. Presentation → Domain ← Data.
- **Material 3** with a seeded `ColorScheme` — the default seed is a deep indigo (`#24389C`).
- **Plus Jakarta Sans** (Google Fonts) everywhere. One family, seven sizes.
- **Tokens are law.** No raw hex, no raw `TextField`, no raw `InkWell`, no raw `else`. Every color, size, radius, duration, and string routes through a typed token or l10n key.
- **Collapsed type scale**: `48 / 32 / 24 / 20 / 16 / 14 / 12`. Nothing in between.
- **Subtle, M3-tonal surfaces** — elevation is carried by surface-container tiers, not shadows.

Five supported study modes and their semantic colors:

| Mode | What it does | Accent |
|---|---|---|
| **Review** | Classic SRS — rate recall Again/Hard/Good/Easy | rating palette |
| **Match** | Drag/tap to pair fronts and backs | primary |
| **Guess** | Multiple choice (A/B/C/D) | primary |
| **Recall** | Write-from-memory, then self-score | mastery green |
| **Fill** | Type the blank in an example sentence | mastery green |

## Sources

Everything in this system was pulled from the MemoX monorepo:

- **Repo:** `github.com/ntgptit/memox` (default branch `main`, sha `1a2d41e2567a`)
- **Design tokens:** `lib/core/theme/tokens/` — `color_tokens.dart`, `typography_tokens.dart`, `spacing_tokens.dart`, `radius_tokens.dart`, `elevation_tokens.dart`, `duration_tokens.dart`, `easing_tokens.dart`, `opacity_tokens.dart`, `size_tokens.dart`
- **Color schemes:** `lib/core/theme/color_schemes/{app_color_scheme,custom_colors}.dart`
- **Text themes:** `lib/core/theme/text_themes/{app_text_theme,custom_text_styles}.dart`
- **Shared widgets:** `lib/shared/widgets/**` (~80 files — buttons, cards, chips, inputs, dialogs, navigation, feedback, progress)
- **Copy (l10n):** `l10n/app_en.arb` (and `app_ko.arb`, `app_vi.arb` for Korean + Vietnamese)
- **Design rules:** `docs/memox-ui-design-rules.md`, `docs/memox-typography-usage-rules.md`, `docs/memox-guard-rules-quickref.md`, `docs/memox-reference.md`
- **Prior web preview:** `docs/memox-design-system/src/App.tsx` + `index.css` — a Tailwind "Theme Foundation Board" that the original authors built to communicate the system. We borrowed the structure but rebuilt the card set from source tokens.

No Figma was attached for this system.

---

## Content fundamentals

**Voice.** Calm, direct, second-person ("you"), never pushy. MemoX talks like a thoughtful study coach, not a gamified app. No hype, no exclamation marks except on genuine completion.

- *"All caught up"* rather than *"Awesome job!!"*
- *"You're offline. Reconnect to keep syncing…"* rather than *"⚠️ Connection lost!"*
- *"Your progress will be saved so you can resume later."* — reassurance is the default.

**Casing.** Sentence case for titles, actions, and body. Only micro-labels and overlines are ALL CAPS (with `+0.06em` letter spacing via `TypographyTokens.sectionSpacing`). Button labels are sentence-case and bold, not uppercase.

**Microcopy patterns.**
- Greetings are time-aware: *"Good morning, learner"* / *"Good evening, Alex"*.
- Empty states always tell you the next action: *"Add cards to start reviewing this deck."*
- Counts are always pluralized properly via ICU (`{count, plural, =1{1 card due} other{{count} cards due}}`).
- Section-complete strings celebrate quietly: *"Session complete"*, *"All matched!"*, *"{N} cards reviewed"*.
- Undo is offered inline after destructive-feeling actions: *"Good selected. Undo?"*.

**I vs you.** Almost always *you*. The product never says *I* or *we*. The user is the protagonist.

**Emoji.** Not used. Nowhere in the codebase does MemoX use emoji in UI text. Icons carry all glyph-level meaning.

**Vibe.** Studious, grown-up, a little Scandinavian — quiet surfaces, clear hierarchy, one accent color doing most of the work, and green reserved for the specific feeling of *mastery*.

---

## Visual foundations

### Color

**Two themes:** *Tokyo Pure Light* (day) and *Tokyo Nebula* (night). Quizlet-mobile energy, not dashboard-web restraint.

- **Tokyo Pure Light** — page is `#F7F9FE` (white with a cool blue cast), cards are pure white with a soft indigo ghost border, text is deep navy `#0F1638`, primary is vibrant indigo `#5265F5`. Outlines lean cool/blue, never warm gray.
- **Tokyo Nebula** — page is deep navy `#0A0E27` (night sky), paper-indigo cards sit on it (`#131A3A`), primary lifts to `#8B9AFF` for AA contrast, and a violet accent `#B5A0FF` enters the system. Outlines are *faded indigo* `#2A3267`, never gray — that's the signature.
- **Seed**: `#5265F5` indigo. The whole light `ColorScheme` is derived from this seed via `ColorScheme.fromSeed`, then primary is darkened slightly so it reads as decisive rather than Material's default bluish primary.
- **Alternate seeds** (user-pickable in Settings): violet `#8B6FF5`, teal `#2BA88B`, rose `#E57373`, amber `#F59E0B`, sage `#81C784`.
- **Surface ladder (Tokyo Pure Light)** — a 6-step cool-blue stack: `#FFFFFF` → `#F7F9FE` (page) → `#F1F4FB` → `#E9EDF7` → `#E2E7F3` → `#DAE0EF`.
- **Surface ladder (Tokyo Nebula)** — `#060925` → `#0A0E27` (page) → `#0F1530` → `#131A3A` (paper) → `#1B2249` → `#232B5A`.
- **Semantic**: success/easy teal `#2BA88B`, mastery green `#1F8A5B`, warning amber `#F59E0B`, error red `#DC2D4E`, streak orange `#F97316`. Nebula maps these to softer night-friendly values (`#6FE0BD`, `#FFC658`, `#FF8FA3`, `#FFAE6E`).
- **Mastery gradient**: coral `#E57373` → amber `#F59E0B` → mastery green `#1F8A5B` — left to right as learning deepens.

### Typography
- **One family:** Plus Jakarta Sans (400/500/600/700/800). Loaded via `google_fonts` at runtime; the CSS in this repo loads the same family from Google Fonts CDN.
- **Collapsed scale:** 48 / 32 / 24 / 20 / 16 / 14 / 12. Never use sizes in between.
- **Letter spacing:** headings `-0.64` (tight), labels `+0.72`, section overlines `+1.2` (ALL CAPS).
- **Line height:** display `1.1`, heading `1.2`, body `1.5`, caption `1.4`, relaxed body `1.6`.
- **Tabular figures** on stat counters (`FontFeature.tabularFigures()`) so numbers don't jitter as they tick.

### Spacing
- **4dp grid.** Tokens: `xxs 2, xs 4, sm 8, md 12, lg 16, xl 24, xxl 32, xxxl 48`.
- **Semantic:** `cardPadding 16`, `screenPadding 24`, `sectionGap 32`, `listItemGap 8`, `fieldGap 20`, `dividerIndent 56`.

### Radii
- `xs 4, sm 8, md 12, lg 16, xl 24, xxl 28, full 100`.
- **Named:** cards & dialogs & sheets use `lg 16`. Buttons & inputs use `md 12`. Chips use `full` (pill). FAB uses `xxl 28`. Avatars are fully round.

### Elevation & shadows
- **M3 tonal elevation, not shadows.** The system prefers stacking surface-container tiers to carry hierarchy. Shadows cap at 6% opacity (`ElevationTokens.shadowOpacity = 0.06`).
- Cards are flat (`level0` dark, `level1` light). FAB is `level2`. Dialogs and sheets get `level2–3`. Nothing pops above `level5`.

### Borders — the "ghost border" rule
- **Ghost border:** `1px` at **15% of outlineVariant**. Every card gets one. This is the defining low-contrast border MemoX uses instead of shadows.
- **Focus border:** the focused input gets a `1px` solid `primary` border (no glow, no ring).
- **Strong accent border:** `4px` solid primary on the left edge — used *only* on comparison/diff highlights in Recall mode and as the focused underline, never as a general card motif.

### Motion & easing
- **Core durations:** instant 50, fast 100, normal 200, slow 300, slower 500 (all ms).
- **Semantic:** `stateChange` 100 (color flips), `contentSwitch` 200 (fades), `pageTransition` 300, `cardFlip` 350, `countUp` 400, `chartDraw` 600.
- **Easing:** `standard = easeInOut` for most UI, `emphasized = easeInOutCubicEmphasized` for large transitions, `enter = easeOut`, `exit = easeIn`. `elasticOut` is explicitly flagged as an **anti-pattern** — do not bounce.

### Hover, press, focus (state layers)
- Hover: 8% tint of onSurface (neutral) or primary (accent).
- Focus: 12% primary tint + primary-border underline on inputs.
- Press: 12% press tint, plus M3 `InkSparkle.splashFactory` for ripple on surface controls.
- Disabled: 38% opacity on content.
- **No scale-down on press.** No shrink animations. Presses are expressed through the state layer only, except on dedicated `ScaleTap` widgets for deliberate tactile feedback on hero CTAs.

### Transparency & blur
- **Glass chrome:** app bar, bottom nav, and sticky top sheets use a page-surface color at **84% opacity** (`OpacityTokens.surfaceGlass`) with a `backdrop-filter: blur(xl)` behind. This is the only place blur is used.
- **Scrims:** 32% black-on-background behind dialogs/sheets (`surfaceScrim`).
- **Faded "other options":** after a wrong answer in Guess/Fill, unselected options fade to 40% opacity (`fadeOut`) to guide attention to the correct one.

### Imagery
- **None shipped.** MemoX has no hero imagery, no illustrations, no stock photos. The product is icon-and-typography only. Marketing surfaces should follow suit: calm, image-light, layout-driven.
- When imagery is added, keep it warm-toned, low-saturation, and cropped geometrically — no bleeding gradients.

### Backgrounds
- Flat single-tone surfaces. No gradients in UI chrome. The *only* gradient anywhere is the mastery tri-stop gradient used on progress bars and charts.
- No repeating patterns, no textures, no grain.

### Layout
- `maxBodyWidth = 720` for readable long-form content.
- `screenPadding = 24` horizontal on mobile.
- Bottom nav is `80dp` tall (M3 `NavigationBar`). App bar is `56dp`, large `64dp`.
- Status dots are `8dp`, chart legend dots `12dp`. Mastery rings are `40dp × 3dp stroke` in list tiles.

### Cards
- Always white (`surfaceContainerLowest`) in light mode.
- `RadiusTokens.lg` (16dp) corners.
- `1px` ghost border, no shadow by default.
- `16dp` internal padding (`cardPadding`).

---

## Iconography

MemoX uses **Material Symbols** via the Flutter built-in `Icons.*` set, at two sizes: `iconSm = 20` (inline/chip) and `iconMd = 24` (standard). Large empty-state glyphs hit `iconXl = 64`.

For this web design system we substitute **Lucide** (loaded via CDN `lucide@latest`) because it is the closest open-source match to Material Symbols in stroke weight (`2px`) and geometry, and it is what the original `docs/memox-design-system` preview used. Documented CDN: `https://unpkg.com/lucide@latest`.

- **No custom icon font.** No sprite. No iconography in PNG.
- **No emoji anywhere in the product.**
- **No unicode symbol icons** (★, ◉, etc.).
- Core icons in use, mapped Material → Lucide:
  - book-open (MemoX logomark), layers (decks), folder, graduation-cap (study), bar-chart-3 (stats), settings, search, plus, flame (streak), brain-circuit (recall/memory), arrow-right, check, x, flag, more-horizontal, chevron-right.

🚩 **Substitution to confirm:** we ship Lucide here instead of Material Symbols. If you'd like pixel-for-pixel parity with the Flutter app, swap the CDN import in `colors_and_type.css` / UI kit `index.html` to the Material Symbols web font.

---

## Index

Root files:
- `README.md` — this file.
- `colors_and_type.css` — CSS custom properties for every token (color, type, spacing, radius, elevation, duration, opacity) plus semantic type selectors.
- `SKILL.md` — portable skill definition so this folder works as an Agent Skill.
- `assets/` — logo SVG and brand marks.
- `fonts/` — (Plus Jakarta Sans loaded via Google Fonts CDN; no self-hosted TTFs shipped).
- `preview/` — the per-token preview cards registered to the Design System tab.
- `ui_kits/mobile/` — the MemoX mobile UI kit: interactive click-through of the home / library / deck / study / stats screens.

Preview cards:
- Type: display, headings, body, labels, stat-display, type-in-use.
- Colors: seed + alternates, surface ladder, on-surface, outline, semantic (success/warning/error), mastery gradient, status palette, rating palette, self-assessment palette, streak, dark-surface.
- Spacing: 4dp grid, semantic spacing, radius scale, elevation/shadow opacity, opacity tokens, duration tokens, easing reference.
- Components: primary/secondary/tertiary/text buttons, app card, deck card, status chip / mode chip / tag chip, mastery ring + bar, text field + search, bottom nav, FAB, rating row, toast, segmented control.
- Brand: MemoX logomark + wordmark, iconography sampler, content voice example, motion reference.

🚩 **Caveats for review**
- No Figma file was provided — everything is derived from source code. If Figma designs exist, attach them and we'll reconcile any drift.
- Plus Jakarta Sans is loaded from Google Fonts CDN, not self-hosted `.ttf` files. If you need offline-safe self-hosted fonts, drop the TTFs into `fonts/` and update `colors_and_type.css`.
- Iconography uses Lucide CDN as a visual stand-in for Flutter's Material Symbols. Confirm direction before production use.
- The UI kit recreates screens from `lib/features/**` source and `l10n/app_en.arb` copy. No screen was copied from a screenshot; if any visual detail is off, it's because the corresponding widget was summarized rather than read byte-for-byte.
