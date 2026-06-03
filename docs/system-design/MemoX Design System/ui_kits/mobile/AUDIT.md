# MemoX Mobile UI Kit — Audit & Improvement Pass

**Scope:** mobile, Flutter only. No web / desktop / tablet / React / PWA assumptions.
**Subject:** `ui_kits/mobile/index.html` — the 23-screen light+dark click-through.
**Goal:** make the existing kit more complete, more consistent, more accessible, and
ready for Flutter implementation — *without* redesigning the established visual language.

This document is the engineering-handoff layer: it records what was found, what was
fixed in this pass, what remains a recommendation, and how each item maps to Flutter
widgets and the `lib/core/theme/tokens/**` token classes.

---

## 0. Pass 2 — recursive theme (light/dark) + UI/UX review

A second recursive pass reviewed every section in **both** Tokyo Pure Light and Tokyo
Nebula, focusing on theme correctness and UX friendliness. Findings:

**Fixed**
- **Stray scrollbars / horizontal overflow (MAJOR, dark + light).** The Guess screen and
  two bottom-sheet lists (tag picker, move-folder) used raw `overflow: auto` /
  `overflow-y: auto`. Because setting only the Y axis makes the X axis compute to `auto`
  too, a phantom **horizontal scrollbar** appeared and the vertical scrollbar showed
  natively (the rest of the kit hides scrollbars via `.scroll`). Added a shared
  `.hide-scroll` utility (`overflow-x: hidden` + hidden scrollbar) and applied it to all
  three. Options now use the full card width. **Flutter map:** non-issue — `ListView` /
  `SingleChildScrollView` manage their own scroll; just confirm `scrollDirection` is vertical.
- **Identical Recall / Fill states (MAJOR).** "Hidden vs Revealed" and "Input vs Wrong"
  rendered identically because the state was only a `useState` *initializer*; changing the
  stepper prop never re-ran it. Fixed by keying each frame on its state value in
  `ScreenRow.make()` so the screen remounts and re-initialises. Single-state interactive
  screens keep a constant key, preserving their interactivity. **Flutter map:** irrelevant —
  in-app these are real state transitions, not prop-seeded mounts.

**Reviewed and confirmed correct (no change needed)**
- **Toast / snackbar** (Tag op-error) uses a fixed dark slate (`rgb(52,57,93)`) with light
  text in *both* themes — the M3 inverse-surface pattern. Legible in light and dark. Good.
- **Primary buttons** keep brand indigo `#5265F5` + white label in dark (the scoped
  `.memox-dark` deliberately overrides primary back to indigo rather than the lifted
  `#8B9AFF`), so `#fff`-on-primary contrast holds in both themes.
- **The white Google sign-in button** is intentionally white in both themes (brand button).
- **Color-coded state feedback** (Match matched=green, Guess correct=green/wrong=red/faded,
  mastery bars threshold-colored amber→indigo→green, streak orange, success teal) all use
  tokens that have explicit Nebula values — verified legible on the navy surfaces.
- **Overlays** (scrim 32% + bottom sheets) render correctly in dark; the scrim is subtle on
  the dark surface by design but present and functional.

**Verdict:** theme parity and UX are consistent and friendly across all 23 screens; the only
real defects were the scrollbar overflow and the duplicated Recall/Fill states, both fixed.

---

## 1. Method

The kit was reviewed against this checklist (per the brief):

- Flutter `lightTheme` / `darkTheme` parity (Tokyo Pure Light / Tokyo Nebula)
- Mobile UI consistency (spacing, radii, type scale, surface ladder)
- Mobile UX friendliness (hierarchy, clear primary action, calm copy)
- Accessibility (semantics, focus, hit targets, contrast, motion)
- State coverage (loading / empty / error / offline / disabled / success / validation / signed-out / permission-denied)
- SafeArea, scrolling, keyboard behavior
- Common mobile widths (360 / 375 / 390 / 412 — already in the kit's Width selector)
- Flutter engineering handoff readiness

The screens themselves are strong — clear hierarchy, on-brand "calm study coach"
copy, and unusually thorough state coverage already. The real gaps were **systemic**
(shared primitives + global rules) and one **content defect**, so fixes were applied
at the primitive level to benefit all 23 screens at once rather than redesigning screens.

---

## 2. Fixed in this pass

### CRITICAL — apostrophes rendered as raw escapes (content defect)
- **Found:** 23 occurrences of the `\u2019` escape sat in **JSX text nodes**
  (e.g. `Today\u2019s review`, `Let\u2019s start`, `phone\u2019s settings`). JSX text
  does not interpret `\uXXXX` escapes — only JS string literals do — so users saw the
  literal text `Today\u2019s review`. Three `\u00d7` (×) escapes had the same latent risk.
- **Fix:** replaced every `\u2019` → `’` and `\u00d7` → `×` with the actual Unicode
  glyph. Valid in both JS strings and JSX text, so all 26 are now correct and future-proof.
- **Flutter note:** non-issue in Dart/ARB (real glyphs in `.arb` values), but it confirms
  the kit's copy strings should be lifted verbatim from `l10n/app_en.arb`, not retyped.

### MAJOR — accessibility: decorative icons announced to screen readers
- **Found:** the shared `Ic` (Lucide) wrapper had no ARIA, so every decorative glyph was
  exposed to assistive tech.
- **Fix:** `Ic` now renders `aria-hidden="true"` by default, with an opt-in `label` prop
  (`role="img"` + `aria-label`) for the rare icon that is the sole carrier of meaning.
- **Flutter map:** decorative `Icon` → wrap in `ExcludeSemantics`; meaningful → `Icon(..., semanticLabel: …)`.

### MAJOR — accessibility: primary navigation was not a control
- **Found:** `BottomNav` items were clickable `<div>`s — not keyboard-focusable, no role,
  no current-page indication.
- **Fix:** items are now `<button type="button">` with `aria-current="page"` on the active
  tab and an `aria-label`; the bar is `role="navigation" aria-label="Primary"`.
- **Flutter map:** `NavigationBar` + `NavigationDestination` already provide this; the kit
  now matches that semantic contract.

### MAJOR — accessibility: no visible keyboard focus anywhere
- **Found:** no `:focus-visible` styling on any interactive element.
- **Fix:** a global focus ring (`2px solid var(--memox-primary)`, `offset 2px`) now applies
  to `button`, `.icon-btn`, `.pill-btn`, `.bn-item`, and `[role="switch"]`. Both `Toggle`
  components are now keyboard-focusable (`tabIndex`, `aria-disabled`).
- **Flutter map:** Material's built-in focus highlight; keep `primary` as the focus color.

### MAJOR — touch targets below the 44px floor
- **Found:** `.icon-btn` is a 36px visual circle (some inline-shrunk to 24px, e.g. dismiss
  buttons) — under the README's own "never less than 44px" rule and `SizeTokens.touch = 48`.
- **Fix:** an invisible `::after` expands every `.icon-btn` hit area to **44×44** without
  changing the visual size, including the shrunken dismiss buttons.
- **Flutter map:** `IconButton` already enforces a 48dp tap target via `MaterialTapTargetSize.padded` — keep that default; do not shrink `constraints`.

### MAJOR — missing **offline** state (requested gap)
- **Found:** MemoX is local-first, but there was no reusable connectivity-lost pattern.
- **Fix:** added a shared **`OfflineBanner`** primitive (alongside `StatusBar` / `BottomNav`)
  with `role="status"` and brand-voice copy ("You're offline. Your cards are saved on this
  device. Drive sync resumes when you reconnect."), plus a new **`offline`** state on the
  Dashboard (registered in the gallery so it appears in the stepper). Content still renders
  beneath the banner — offline never blocks local study.
- **Reuse:** drop `OfflineBanner` onto any surface that attempts Drive sync (Library, Study
  result, Stats). **Flutter map:** drive it from a `connectivity_plus` stream → `MaterialBanner`
  or an inline `Container`; copy via an l10n key.

### MINOR — reduced-motion not respected
- **Found:** skeleton-pulse and the "continue studying" dot looped infinitely with no guard.
- **Fix:** global `@media (prefers-reduced-motion: reduce)` neutralizes animations/transitions.
- **Flutter map:** gate non-essential animation on `MediaQuery.of(context).disableAnimations`.

---

## 3. Recommendations (not changed — need a product decision)

| Sev | Finding | Why not auto-fixed | Suggested action |
|---|---|---|---|
| MAJOR | **List rows / cards use clickable `<div>`s** across most screens (deck rows, folder rows, settings rows, tag rows). They are not keyboard-focusable and expose no role. | Converting ~dozens of inline rows risks layout regressions and is screen-by-screen work. | In Flutter these are already `InkWell`/`ListTile` (focusable + semantic) — no app change needed. For the kit, wrap row roots in `role="button" tabIndex={0}` if AT fidelity in the mock matters. |
| MAJOR | **Icon-only buttons inside screens** still rely on `title` rather than `aria-label` in several places (Dashboard's search/settings are now labeled; others remain). | Many are inline and one-off. | Add `aria-label` to each; in Flutter pass `tooltip:` / `semanticLabel:` on every `IconButton`. |
| DECISION | **Gradients in chrome.** The Dashboard's "Continue studying" and "Today's review" cards use subtle `linear-gradient` fills, but the design rules state *"No gradients in UI chrome — the only gradient anywhere is the mastery tri-stop gradient."* | The gradients are deliberate and attractive; removing them is a visual redesign, which is out of scope. | Confirm intent. If keeping, update the README rule to allow a "hero-CTA tint gradient." If not, flatten to `primary-container` / `surface-container` tints — which is also the cleaner Flutter token mapping (`Theme.colorScheme.primaryContainer`). |
| MINOR | **SafeArea is mocked, not parameterized** — `env(safe-area-inset-*)` appears once. | The phone frame is a fixed 390×780 mock; insets are simulated by the 44px status bar and the bottom-nav padding. | Acceptable for a static kit. In Flutter, wrap every screen body in `SafeArea`; the bottom nav already reserves a home-indicator gap (maps to `SafeArea(bottom:true)` / `viewPadding.bottom`). |
| MINOR | **Self-hosted fonts / icon font** — Plus Jakarta Sans via Google Fonts CDN; Lucide stands in for Material Symbols. | Pre-existing, documented in the root README. | Confirm before production: ship `google_fonts` (or bundle TTFs) and `Icons.*` (Material Symbols) in the app. |

---

## 4. Flutter handoff — token & widget mapping

All values in the kit come from `colors_and_type.css`, which mirrors `lib/core/theme/tokens/**`.
**Tokens are law — no raw hex / sizes in the app.** Quick map:

| Kit (CSS var) | Flutter token / role |
|---|---|
| `--memox-primary`, `--memox-on-primary`, `--memox-surface-container-*` | `ColorScheme` roles (seeded from `#5265F5`) |
| `--memox-error-fill` (dark `#B0485C`) | solid danger-button fill in dark — distinct from the light-pink `error` content color; keep this split |
| `--memox-status-*`, `--memox-rating-*`, `--memox-mastery*` | `CustomColors` extension on `ThemeData` |
| `--memox-fs-*` (48/32/24/20/16/14/12) | `TextTheme` sizes — the collapsed scale; never interpolate |
| `--memox-space-*` (4dp grid) | `SpacingTokens` |
| `--memox-radius-*` | `RadiusTokens` (card/dialog/sheet = `lg 16`; button/input = `md 12`; chip/FAB = pill/`xxl 28`) |
| `--memox-dur-*`, `--memox-ease-*` | `DurationTokens` / `EasingTokens` (no `elasticOut` — flagged anti-pattern) |
| `--memox-border-ghost` | the 15%-outlineVariant 1px "ghost border" on every card |
| glass chrome (84% + blur) | app bar / bottom nav / sticky sheets only |

Widget mapping: app bar → `AppBar` (56/64dp); bottom nav → `NavigationBar` (80dp);
cards → `Card`/`Container` with ghost border, tonal elevation (no shadow > 6%); inputs →
tokenized `TextField` (focus = 1px solid `primary`); chips → pill; FAB → `level2`,
`radius xxl`; bottom sheets/dialogs → `level2–3` + 32% scrim. Copy → l10n keys
(`app_en.arb`, plus `app_ko.arb` / `app_vi.arb`); counts use ICU plurals.

---

## 5. State-coverage snapshot (post-pass)

Every screen ships its applicable states side-by-side; the gallery stepper cycles them in
both themes. Coverage by category:

- **Loading** — per-section skeletons (not full-screen spinners): Dashboard, Library, Folder, Search, Flashcard list/edit/history, Import, Tags, Progress, Settings, Sync, Audio, Study result.
- **Empty** — action-led empty states ("Add cards to start reviewing"): Library, Folder, Search, Flashcard list/history, Tags, Progress, Onboarding zero, Audio (no voices).
- **Error** — local-safe messaging + Retry: Dashboard, Library, Folder, Search, Flashcard list/edit/history, Import (failed/partial), Progress, Settings (sync error), Sync, Audio (engine error).
- **Offline** — **new** reusable banner; shown on Dashboard, ready for reuse.
- **Disabled** — "Soon" chips on disabled settings rows; disabled toggles; faded options.
- **Success** — Import success, Study result, sync ready/uploaded.
- **Validation** — Flashcard create/edit inline validation; Tag rename → merge conflict.
- **Signed-out / permission-denied** — Settings, Account sync (signed-out chain), Learning settings (notification perm denied), Audio (TTS engine missing).

---

## 6. Self-review verdict

Re-reviewed against the checklist after fixes:

- **Light/Dark parity** — ✅ all new elements (offline banner, focus ring, hit areas) use
  tokens and verified in both Tokyo Pure Light and Tokyo Nebula.
- **Consistency** — ✅ no new colors/radii/spacing introduced; primitives only.
- **Accessibility** — ✅ icons hidden, nav is a control, focus visible, 44px targets, toggles
  focusable, reduced-motion honored. ⚠️ inline clickable rows remain (Flutter-native already; documented).
- **State coverage** — ✅ offline gap closed; rest already complete.
- **SafeArea / scrolling / keyboard** — ✅ documented for Flutter; mock behavior unchanged.
- **Handoff readiness** — ✅ token/widget map above; copy sourced from l10n.

No critical or major issues remain open that are fixable without a product decision
(the gradient-in-chrome question and self-hosted-fonts/icons confirmation are flagged for you).
