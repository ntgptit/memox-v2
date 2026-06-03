---
last_updated: 2026-05-30
status: contract
applies_to: all buttons, CTAs, card actions, toolbars, dialogs, empty states, study actions
---

# Action Hierarchy & Density Contract

The source base ships low-level button primitives (`MxPrimaryButton`,
`MxSecondaryButton`) that expose `size` and `fullWidth` directly. Left
unconstrained, features kept reaching for `MxButtonSize.large` and
`fullWidth: true` inside cards — producing hero-sized CTAs where a compact
action belongs, and multiple competing primaries on one mobile screen.

This contract defines a **semantic action layer** on top of those primitives so
density is a property of *where* an action lives, not a number a feature picks.
Prefer `MxActionButton` (intent-driven) and `MxCardActions` over raw primitives.

> **Quizlet-mobile energy does not mean an oversized full-width CTA everywhere.**
> It means generous touch targets, rounded surfaces, and one clear primary —
> with dense, compact card actions doing the everyday work.

## Core rules (always)

1. Card-level actions MUST NOT use `MxButtonSize.large`.
2. Card-level actions MUST NOT be full-width by default.
3. Full-width buttons are allowed **only** for: bottom action area, form
   submit/footer, full-screen empty state, onboarding/hero, and study
   submit/final actions where the study contract specifies it.
4. A screen has **at most one** visually dominant primary action.
5. Secondary actions MUST be visually lighter than the primary (tonal / text /
   outlined, equal or smaller size).
6. Compact visual height is allowed only while the touch target stays
   **≥ 48dp** (the themed `MaterialTapTargetSize.padded` guarantees this for
   `compact`/`small`/`xsmall`).
7. Dashboard/action cards are **dense action surfaces**, not hero landing blocks.
8. Hero CTAs are reserved for onboarding, empty states, study final/submit, and
   screen-bottom action contexts.
9. Frozen mobile mock density: regular card/study actions use `compact` `40dp`
   visual height; `medium` `48dp` remains for form, dialog, and bottom actions.
10. Compact icon buttons use a `36dp` visual box with a `20dp` icon. Toolbar
    icon buttons may keep the `48dp` appbar touch-safe box.

## Action contexts

Each context maps to an `MxActionIntent`. The "Full-width" column states the
default and whether an explicit `fullWidth:` override is honored.

| Context | Intent | Component | Size | Full-width | Max dominant | Secondary style | Accessibility |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Screen primary | `screenPrimary` | `MxPrimaryButton` | `medium` | off; override allowed | 1 per screen | — | ≥48dp |
| Card primary | `cardPrimary` | `MxPrimaryButton` | `compact` | **never** | 1 per card | — | ≥48dp (padded) |
| Card secondary | `cardSecondary` | `MxSecondaryButton` tonal | `compact` | **never** | — | tonal, lighter than primary | ≥48dp (padded) |
| Inline | `inline` | `MxSecondaryButton` text | `small` | **never** | — | text | ≥48dp (padded) |
| Toolbar | `toolbar` | `MxSecondaryButton` text / `MxIconButton` | `xsmall` | **never** | — | text/icon | ≥48dp (padded) |
| Dialog primary | `dialogPrimary` | `MxPrimaryButton` | `medium` | **never** | 1 per dialog | — | ≥48dp |
| Bottom action | `bottomAction` | `MxPrimaryButton` | `medium` | **on** | 1 per bar | — | ≥48dp |
| Empty state | `emptyState` | `MxPrimaryButton` | `medium` | off; override allowed (host width) | 1 | — | ≥48dp |
| Onboarding hero | `onboardingHero` | `MxPrimaryButton` | `large` | **on** | 1 | — | ≥48dp |
| Study primary | `studyPrimary` | `MxPrimaryButton` | `compact` | off; override allowed where study contract specifies | 1 | — | ≥48dp |

### Examples

- **Dashboard action card** → `MxCardActions(primary: MxActionButton(intent: cardPrimary, ...), secondary: MxActionButton(intent: cardSecondary, ...))`. Compact, trailing-aligned, never full-width.
- **Form footer save** → `MxActionButton(intent: bottomAction, label: 'Save')` (full-width by default) or `MxPrimaryButton(fullWidth: true)`.
- **Empty deck CTA** → `MxEmptyState(actionLabel: ...)` (medium, host-sized).
- **Study submit** → `MxActionButton(intent: studyPrimary, label: 'Check', fullWidth: true)` only where `docs/business/study/study-flow.md` specifies a full-width submit.

### Forbidden patterns

- `MxPrimaryButton(size: MxButtonSize.large)` inside `lib/presentation/features/**` card/list/dashboard widgets.
- `MxPrimaryButton(fullWidth: true)` / `MxSecondaryButton(fullWidth: true)` inside a card/list/dashboard widget that is not a bottom action bar, footer, empty state, onboarding, or specified study submit.
- Two or more dominant primary buttons competing on one mobile screen.
- Relying on the legacy `stretchOnCompact` implicit large→full-width behavior (default is now `false`; full-width must be explicit).

## Enforcement

- `MxActionButton` resolves size + full-width from intent; passing
  `fullWidth: true` to a card/inline/toolbar/dialog intent trips a debug assert.
- `MxPrimaryButton.stretchOnCompact` defaults to `false` — a `large` button no
  longer becomes full-width just because the screen is compact.
- Shared-widget contract tests assert `cardPrimary` is compact (not large), is
  not full-width, that `cardSecondary` and `studyPrimary` resolve compact, that
  `inline < cardPrimary`, that compact icon buttons match `36dp` / `20dp`, and
  that semantic compact actions keep a 48dp target where padded touch targets
  are required.
- `code-verification-guard` flags raw `MxButtonSize.large` / `fullWidth: true`
  in feature card/dashboard/list widgets unless carried by a reviewed
  `// guard:full-width-action-reviewed <reason>` comment.

## Related

- `docs/ui-ux/ui-ux-contract.md` §Button and action density rule
- `docs/system-design/MemoX Design System/README.md` §Components
- `docs/agent/agent-task-template.md` §UI Density Gate
- Source: `lib/presentation/shared/widgets/mx_action_button.dart`,
  `lib/presentation/shared/widgets/mx_card_actions.dart`,
  `lib/presentation/shared/widgets/mx_primary_button.dart`,
  `lib/core/theme/responsive/app_layout.dart`
