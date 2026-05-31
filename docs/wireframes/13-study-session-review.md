---
last_updated: 2026-05-28
route: /library/study/session/:sessionId
study_mode: review
source_specs:
  - docs/business/study/study-flow.md
  - docs/business/srs/srs-review.md
  - docs/business/study-actions/bury-suspend.md
  - docs/business/tts/tts-settings.md
---

# 13 — Study Session: Review Mode

## Purpose

Front + back shown together on a single card. User reads, self-evaluates whether they knew it, then advances by swipe. Lightest mode in the 5-mode cycle; serves as the **anchor screen** that establishes the visual grammar reused by modes 14-17 (top app bar, progress bar, mode pill convention).

> **Mode pill / progress-bar color convention (applies to wireframes 13-17).** Modes split into two visual families:
>
> - **Blue family** (recognition modes): Review, Match, Guess. Progress bar fills with the primary blue token. Mode pill (when shown) uses blue.
> - **Green family** (production modes): Recall, Fill. Progress bar fills with the secondary green token. Mode pill uses green.
>
> This visual cue tells the user at a glance whether the current mode tests recognition (passive) or production (active). Review mode does NOT show a mode pill in the top bar (it is the default mode and uses the bare progress bar); modes 14-17 do show the pill.

## Layout — single state (front + back both visible)

```
┌─────────────────────────────────────────┐
│ ✕   ━━━━━━━━━━━━━━━━━━━━━━     14 / 23 │  ← Exit · progress bar (blue) · count
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │                                     │ │
│ │ KOREAN                              │ │  ← Front-side label (deck.target_language)
│ │                                     │ │
│ │                                     │ │
│ │              먹다                    │ │  ← Front, large centered
│ │                                     │ │
│ │                                     │ │
│ │  ─────────────────────────────────  │ │  ← Divider
│ │                                     │ │
│ │ MEANING                             │ │  ← Back-side label
│ │                                     │ │
│ │                                     │ │
│ │             to eat                  │ │  ← Back, large centered
│ │                                     │ │
│ │       ┌───────────────────┐         │ │
│ │       │ 아침을 먹었어요.    │         │ │  ← Example pill, iff present
│ │       └───────────────────┘         │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│   »  Swipe left for the next card       │  ← Swipe hint footer
└─────────────────────────────────────────┘
```

Both sides render together — there is no "Show answer" tap step in this mode. The user advances by swiping (gesture is the primary input).

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `sessionId` (required path param) | URL | active session id from entry gate |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Session detail (total, answered count) | `study_sessions` + `study_session_items` aggregate | watch |
| Current card front, back, optional `example`, deck `target_language` | `flashcards` joined via session_items | next-card load |
| Card progress (`current_box` for `box_before`) | `flashcard_progress` | next-card load |
| Front-side / back-side label copy (e.g., `KOREAN` / `MEANING`) | derived from `deck.target_language` + l10n keys | once per card |
| Pre-fetched next card | repository call during current grade | parallel with persist |

## Forbidden

- ❌ Add a "Show answer" intermediate step. Review mode shows both sides at once.
- ❌ Hide the `example` field when present. Render it as a pill below the back.
- ❌ Show `note`, `pronunciation`, or `hint` inline (Phase 1; only `example` surfaces here).
- ❌ Use the green progress-bar color in this mode. Review is in the blue family.
- ❌ 4-button "Hard / Easy" grading.
- ❌ Auto-play `back` via TTS. Front-only policy.
- ❌ TTS auto-play when `deck.target_language = unsupported`.
- ❌ Persist grade BEFORE loading next card visually. Order: gesture → persist (background) → next card UI.
- ❌ Allow exit without confirmation when answered > 0.
- ❌ Make swipe optional. In this mode swipe is the **primary** input; tap fallback exists but is secondary.
- ❌ Add a TTS icon inline on the card. TTS surfaces via card-actions sheet only (long-press).
- ❌ Update SRS box outside `GradeAttemptUseCase`.

## Components

| Component | Spec |
| --- | --- |
| Top app bar | `✕` (exit) on the left; progress bar fills the middle; "{answered} / {total}" count on the right. No scope label, no overflow `⋮` in this mode (overflow accessible via long-press on the card — see Actions). |
| Progress bar | Filled bar showing `answered / total`. Color: primary blue (review = blue family). |
| Card | One card occupying most of the viewport. Contains both front and back regions separated by a thin divider. |
| Front-side label | Caption-sized, uppercase, top-left of card. Copy: `KOREAN` / `ENGLISH` / etc., derived from `deck.target_language`. Falls back to `FRONT` when language unsupported. |
| Front | Display-large size, centered horizontally. Wraps to two lines max; shrinks if longer. |
| Divider | Thin horizontal line between front and back regions, indented left/right. |
| Back-side label | Caption-sized, uppercase. Copy: `MEANING`. Falls back to `BACK`. |
| Back | Body-large size, centered. |
| Example pill | Optional. Rounded surface around `flashcards.example`. Only renders when example is non-empty. Center-aligned. |
| Swipe hint footer | Caption-sized, with a `»` chevron prefix. Copy: "Swipe left for the next card". Fades out after the user has swiped 3 times in this session (already learned). |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Card visible | Card opened | Front + back both rendered. Swipe hint shown for first 3 cards of the session, then hidden. |
| Swiping | Drag begins | Card follows finger; releasing past the threshold commits a grade. |
| Grading | Swipe committed (or tap on grade fallback) | Persist attempt + SRS update; advance to next card with horizontal slide. |
| Buried via long-press menu | Long-press the card | Bottom-sheet with Bury / Suspend / History / Audio settings. Bury → toast 5s undo; advance. |
| Last card | Final swipe | Transition to finalization → study result via `pushReplacement`. |
| Exit confirm | ✕ tapped mid-session | Show "Exit session?" dialog. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Swipe right | Drag right past threshold | `result = perfect`; persist; next card. |
| Swipe left | Drag left past threshold | `result = forgot`; persist; next card. |
| Tap card | Tap (fallback) | Open inline Forgot / Perfect prompt (accessibility / motor fallback). |
| Long-press card | Long-press | Open card actions bottom-sheet (Bury / Suspend / History / Audio settings). |
| Tap ✕ | Tap | Show exit confirm dialog. |

## Dialogs and bottom-sheets used

- Exit session confirm — `docs/wireframes/24-shared-dialogs.md` §exit-session.
- Card actions sheet — `docs/wireframes/25-shared-bottom-sheets.md` §card-actions.
- Bury/suspend undo toast — `docs/wireframes/25-shared-bottom-sheets.md` §undo-toast.

## SRS handling on answer

Per `docs/business/srs/srs-review.md`:

- result=`perfect` (swipe right): `box_before = current`, `box_after = min(current+1, 8)`.
- result=`forgot` (swipe left): `box_before = current`, `box_after = 1`. `lapse_count++`.

Insert `study_attempts` row with `box_before`, `box_after`, `result`, `study_mode = 'review'`, `attempted_at = now`. See `docs/contracts/usecase-contracts/study.md` §GradeAttemptUseCase.

## TTS behavior (per `docs/business/tts/tts-settings.md`)

Review mode has **no inline TTS button** in the design. TTS is reachable via the card-actions bottom-sheet (long-press → "Speak front"). Rationale: review mode is a fast-flowing self-grade; a TTS button on the card would compete with the swipe gesture target. Modes 14-17 surface a TTS icon inside the card because their gestures are taps, not swipes.

When `autoPlay = true` AND `deck.target_language` is supported, the engine still auto-plays `front` on card open (silent UI).

## Navigation in

- Auto-redirect from study entry gate.
- Resume from Dashboard / banner.
- Deep link from notification.

## Navigation out

- Last card answered → study result (`pushReplacement`).
- Exit confirmed → pop to caller (Dashboard or scope screen).
- History action (from sheet) → flashcard history (push, returnable).
- Audio settings (from sheet) → audio-speech settings (push, returnable).

## Responsive

- ≥600dp: card centered with max-width ~520dp; vertical spacing increased between front and back regions.
- ≥1024dp: card stays centered; surrounding viewport color matches scaffold background, no extra chrome.
- Landscape: card occupies viewport vertically; swipe gesture unchanged.

## Performance

- Pre-fetch next card on swipe-commit (parallel with persistence).
- Swipe animation runs at 60fps; physics-based simulation, not linear interpolation.
- TTS init at session start; reuse engine across cards.

## Accessibility

- Card announces front and back in sequence on focus.
- Swipe gestures have a tap fallback (tap → inline Forgot/Perfect buttons).
- Reduced-motion users see a cross-fade instead of the horizontal slide on card advance.
- Swipe hint footer carries `Semantics(hint: 'Swipe right for Perfect, swipe left for Forgot')`.

## Rules

- Card MUST render both sides at once. No reveal step.
- Swipe MUST be the primary input. Tap fallback is for accessibility only.
- TTS button is NOT inline in review mode. Surfaces via card-actions sheet.
- Exit confirmation MUST appear before pop unless session has 0 answered cards.
- `box_before` and `box_after` MUST be recorded on every attempt.
- `example` field MUST render as a pill below the back when non-empty. `note`, `pronunciation`, `hint` are NOT shown in this mode (Phase 1).

## Agent rule

- Do NOT introduce a "Show answer" CTA in this mode. Both sides are visible from the start.
- Do NOT add a TTS icon to the card body. TTS lives in the actions sheet.
- Swipe gestures are MANDATORY (not optional). Tap is fallback only.
- Render `example` as a pill below the back. Do not render `note` / `pronunciation` / `hint` here — those surface in card detail, not study session.
- Use blue progress-bar color token. Mismatching family color = bug.

## Implementation refs

**Business specs:**

- `docs/business/study/study-flow.md` (review mode)
- `docs/business/srs/srs-review.md` (perfect / forgot transitions)
- `docs/business/study-actions/bury-suspend.md` (overflow actions via sheet)
- `docs/business/tts/tts-settings.md` (front-only playback)

**Decision rows:**

- S section (review mode), SRS section (perfect/forgot transitions)

**Schema / storage:**

- INSERT `study_attempts` (box_before, box_after, result, study_mode='review', attempted_at)
- UPDATE `flashcard_progress` (current_box, due_at, review_count, lapse_count, last_studied_at)

**Contracts:** `docs/contracts/usecase-contracts/study.md` §GradeAttemptUseCase, `docs/contracts/usecase-contracts/srs.md`, `docs/contracts/usecase-contracts/tts.md`

**Code paths (verified 2026-05-28):**

- Shared shell: `lib/presentation/features/study/screens/study_session_screen.dart` (app bar, progress bar, exit handling).
- Mode view: `lib/presentation/features/study/widgets/study_session/review/review_mode_session_view.dart` + `review_mode_card.dart` + `review_mode_panel.dart`.
- Swipe gesture: `lib/presentation/features/study/widgets/study_session/review/review_page_scroll_behavior.dart` (no standalone `swipe_to_grade.dart`; behavior is embedded in the page scroll behaviour widget).
- Grading: `lib/domain/study/usecases/study_usecases.dart` → `AnswerFlashcardUseCase` (single attempt), `AnswerCurrentModeBatchUseCase` / `AnswerCurrentModeItemGradesBatchUseCase` (batch). **No standalone `grade_attempt_usecase.dart` exists** — grading is the responsibility of these classes in the study use-case module.
- SRS transitions: no standalone `lib/domain/srs/box_transition.dart` exists. Runtime finalization uses `_reviewOutcome` in `lib/data/repositories/study_repo_impl_helpers.dart`; in-session study use cases record attempts and re-queue failed cards.
- TTS: see `lib/presentation/features/study/widgets/study_session/study_speak_button.dart` for the in-mode button; engine lives behind `lib/presentation/features/tts/providers/`.

**Related wireframes:**

- `docs/wireframes/14-study-session-match.md`, `docs/wireframes/15-study-session-guess.md`, `docs/wireframes/16-study-session-recall.md`, `docs/wireframes/17-study-session-fill.md` (other modes; shared shell + progress-bar color convention)
- `docs/wireframes/18-study-result.md` (next after last card)
- `docs/wireframes/25-shared-bottom-sheets.md` §card-actions, §undo-toast
- `docs/wireframes/24-shared-dialogs.md` §exit-session
