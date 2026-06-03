---
last_updated: 2026-05-30
applies_to: all UI/UX, shared widgets, theme, l10n
---

# UI UX Contract

## Source files to inspect

- `docs/system-design/MemoX Design System/README.md`
- `lib/core/theme/**`
- `lib/presentation/shared/**`
- `lib/l10n/*.arb`
- Related feature screens/widgets

## UX principles

- Mobile-first.
- Calm and focused.
- Fast daily usage.
- Clear primary action per screen.
- No crowded screen.
- No raw technical errors shown to user.
- No destructive action without confirmation.

## Required screen states

Every screen should handle relevant states:

- Loading.
- Empty.
- Error.
- Saving.
- Disabled action.
- Validation failure.
- Retry/recovery.

Missing any applicable state is a bug.

## Shared widget rule

Use shared `Mx*` widgets first.

Preferred primitives:

- `MxAdaptiveScaffold`
- `MxScaffold`
- `MxListScaffold`
- `MxFormScaffold`
- `MxStudyScaffold`
- `MxContentShell`
- `MxRetainedAsyncState`
- `MxEmptyState`
- `MxErrorState`
- `MxLoadingState`
- `MxCard`
- `MxActionButton` (semantic, intent-driven — prefer over raw buttons)
- `MxCardActions` (card-level action layout)
- `MxPrimaryButton` (low-level primitive)
- `MxSecondaryButton` (low-level primitive)

## Button and action density rule

Action density is governed by `docs/ui-ux/action-hierarchy-contract.md`. Read it
before adding any button, CTA, or card action.

Mandatory minimums:

- Prefer the semantic `MxActionButton` (intent-driven) and `MxCardActions` over
  raw `MxPrimaryButton` / `MxSecondaryButton` `size` + `fullWidth`.
- Card-level actions must not use `MxButtonSize.large` and must not be
  full-width by default.
- Full-width is allowed only for: bottom action area, form submit/footer,
  full-screen empty state, onboarding/hero, and specified study submit/final
  actions.
- At most one visually dominant primary action per screen.
- Secondary actions are visually lighter than the primary.
- Compact visual height is fine only while the touch target stays ≥ 48dp.
- "Quizlet-mobile energy" does not mean an oversized full-width CTA everywhere —
  dashboard/library/settings cards use dense card actions.
- Frozen mobile density: card/study actions use `40dp` compact visual height;
  medium `48dp` stays for form/dialog/bottom action contexts; regular cards use
  `12dp` radius and `12dp` padding; compact icon buttons are `36dp` with a
  `20dp` icon.
- This density freeze does not alter business scope: Library root contains
  folders only, root-level decks remain Rejected / Out of Scope, and nullable
  deck parent migration remains Rejected / Not Applicable.

## Theme rule

Use:

- Theme color scheme.
- Theme extensions.
- Text theme.
- App spacing/radius/motion tokens.
- ARB localization for every user-facing string.

Avoid:

- Raw colors (`Color(0xFF...)`, `Colors.red`).
- Raw text styles (`TextStyle(fontSize: 14)`).
- Raw durations (`Duration(milliseconds: 300)`).
- Hardcoded layout constants (`SizedBox(width: 16)` outside spacing tokens).
- Hardcoded user-facing strings.
- Raw route strings.

## Responsive rule

- Must work on narrow mobile (360dp width).
- Must not stretch reading content too wide on desktop (use max content width from shell).
- Use shared layout shell/content width.
- Overflow is a bug.
- Breakpoints: 600dp and 1024dp (mobile / tablet / desktop).

## Performance rule

| Scenario | Rule |
| --- | --- |
| List > 50 items | `ListView.builder`, never `Column` + `map` |
| List > 200 items | Consider pagination or sliver virtualization |
| Search input | Debounce 300ms |
| Tag/autocomplete input | Debounce 200ms |
| Image (network/asset cache) | Use cached image widget; do not rebuild every frame |
| Heavy compute | `compute()` or isolate; never on UI thread |
| Animation | Use AnimatedX widgets; avoid manual setState in tickers |
| Stream listeners | Always cancel in dispose; prefer Riverpod auto-dispose |

## Accessibility rule

- Min touch target: 48dp.
- Semantic label for every interactive widget.
- Contrast ratio meets WCAG AA.
- Form errors announced via Semantics.
- Long press alternatives for swipe actions.

## Confirmation rule

Destructive actions require confirmation dialog:

- Delete folder.
- Delete deck.
- Delete flashcard.
- Cancel study session.
- Discard unsaved form changes.

Confirmation dialog must use `MxConfirmDialog` or equivalent shared widget.
Current V1 implementation uses `MxConfirmationDialog`; destructive confirmations are not barrier-dismissible and must provide an explicit Cancel path.

## Loading state rule

- For lists: skeleton placeholder, not full-screen spinner.
- For full-screen load: `MxLoadingState` only when no content exists yet.
- For action in progress: in-button spinner or disabled state, not blocking overlay.
- For background sync: subtle indicator, not modal.

## Empty state rule

- `MxEmptyState` with illustration + message + CTA.
- CTA leads to the primary action that resolves empty state.
- Place CTA in thumb-reach zone on mobile.

## Error state rule

- `MxErrorState` with message + retry action.
- Map `Failure` to user-friendly message via l10n.
- Never show stack trace or technical error to user.
- Log technical detail for diagnostics.

## Agent rule

Do not build anonymous `Container + Row + hardcoded style` UI when a shared component exists or should be promoted.

When introducing a new shared widget, name it `Mx<Name>` and place in `lib/presentation/shared/widgets/**`.

## Related

**Wireframes:**

- `docs/wireframes/index.md` — all 25 wireframes follow the tokens defined here (Slate Meridian theme, Plus Jakarta Sans, breakpoints 600dp / 1024dp)
- `docs/wireframes/24-shared-dialogs.md` — reusable dialogs
- `docs/wireframes/25-shared-bottom-sheets.md` — reusable bottom-sheets

**Architecture:**

- `docs/architecture/clean-architecture-contract.md` — presentation layer scope

**Repo-level:**

- `CLAUDE.md` — hardcoded styles/colors/durations forbidden

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "UI/UX" (touch target, accessibility, l10n)

**Source files to inspect:**

- `lib/core/theme/**`
- `lib/core/widgets/**` (Mx* shared widgets)
- `lib/l10n/**` (ARB sources)
