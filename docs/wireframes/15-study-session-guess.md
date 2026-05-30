---
last_updated: 2026-05-28
route: /library/study/session/:sessionId
study_mode: guess
source_specs:
  - docs/business/study/study-flow.md
  - docs/business/srs/srs-review.md
  - docs/business/tts/tts-settings.md
---

# 15 — Study Session: Guess Mode

## Purpose

Multiple-choice recognition with **rich option cards** showing both the candidate term and its definition snippet. User sees a prompt term on top, picks the correct option among 5 (A/B/C/D/E), receives immediate green/red feedback, and auto-advances. Tests definition-level recognition.

> **Direction.** The prompt shows the **front** of the current card (target-language term); options show candidate **backs** (or definition snippets). The user is identifying "what does this term mean?". This is the canonical guess direction in MemoX v1; a reversed direction (back → front) is a Future Proposal, not part of Phase 1.

> **Mode pill color: blue** (recognition family). See `docs/wireframes/13-study-session-review.md` §Mode pill / progress-bar color convention.

## Layout — awaiting selection

```
┌─────────────────────────────────────────┐
│ ✕  [ GUESS ]  ━━━━━━━━━━━━━━━     5 / 20│  ← Exit · mode pill (blue) · progress · count
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │                                     │ │
│ │           WHAT IS THIS?             │ │  ← Caption label
│ │                                     │ │
│ │              도서관                  │ │  ← Front, large
│ │                                     │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ (A)  kitchen                        │ │  ← Option A
│ │      (description, dimmed)          │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ (B)  library                        │ │  ← Option B
│ │      public building or room with...│ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ (C)  school                         │ │  ← Option C
│ │      institution for educating...    │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ (D)  office                         │ │  ← Option D
│ │      place of business work          │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ (E)  hospital                       │ │  ← Option E
│ │      institution for medical care...│ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

Options list is **scrollable** when content exceeds viewport. Each option card holds:

- A circle label `(A)` / `(B)` / `(C)` / `(D)` / `(E)` on the left.
- Option **title** (the candidate back term).
- Option **description** (a definition snippet — first ~1-2 lines of the candidate's `back` extended with `note` or `example`, truncated).

## Layout — after tap (correct B)

```
│ ┌─────────────────────────────────────┐ │
│ │ (A)  kitchen                        │ │  ← Dimmed
│ │      ...                            │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ (B)  library                       ✓│ │  ← Green border + check icon
│ │      public building or room...     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ (C)  school                         │ │  ← Dimmed
│ │      ...                            │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ (D)  office                         │ │  ← Dimmed
│ │      ...                            │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ (E)  hospital                       │ │  ← Dimmed
│ │      ...                            │ │
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│ NEXT CARD IN 0.8S                       │
│ ━━━━━━━━━━━━━━━━━━━━━━━━                │  ← Countdown progress bar
└─────────────────────────────────────────┘
```

## Layout — after tap (wrong C, correct was B)

```
│ ┌─────────────────────────────────────┐ │
│ │ (B)  library                       ✓│ │  ← Green border (correct)
│ │      ...                            │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ (C)  school                        ✗│ │  ← Red border + cross icon
│ │      institution for educating...    │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ...                                     │
├─────────────────────────────────────────┤
│ NEXT CARD IN 1.5S                       │  ← Longer delay for reflection
│ ━━━━━━━━━━━━━━━━━━━━━━━━                │
└─────────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `sessionId` (required path param) | URL | active session |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Current card front + back | `flashcards` | next card |
| Per-card description snippet (e.g. `note` first line, or `example`, or `back` truncated) | `flashcards` | next card |
| Decoy pool (4 random other cards from scope, with their back + snippet) | `flashcards` in scope, EXCLUDE current.id, random sample of 4 | next card |
| Decoy pool cached for session | repository in-memory cache | invalidated on session end |

## Forbidden

- ❌ Show TTS button on options (could leak the correct pronunciation visually).
- ❌ Reword the `WHAT IS THIS?` caption beyond locale translation.
- ❌ Show only the option title without a description snippet. Both required to maintain visual rhythm.
- ❌ Run when scope has < 5 cards.
- ❌ Adjust the auto-advance countdown below 0.8s (correct) or below 1.5s (wrong).
- ❌ Allow the user to tap a second option after the first is committed (single-tap per card).
- ❌ Persist the attempt AFTER the countdown completes. Persist immediately on tap; the countdown is UI animation only.
- ❌ Use the green progress-bar color. Guess is in the blue family.

## Components

| Component | Spec |
| --- | --- |
| Top app bar | `✕` exit · `GUESS` mode pill (blue) · progress bar (blue) · "{answered} / {total}" count. |
| Prompt card | Caption `WHAT IS THIS?`; below: front term (display-large, centered). |
| Option card | Vertical list of 5 cards. Each card has: circle label `(A)`/`(B)`/`(C)`/`(D)`/`(E)` left; title (the back); description snippet (2-line clamp); state-dependent right icon (✓ / ✗). |
| Option — idle | Neutral surface, default text. |
| Option — selected correct | Green border (2dp), green title text, ✓ right icon. |
| Option — selected wrong | Red border, red title text, ✗ right icon. |
| Option — revealed correct (when user tapped wrong) | Green border, ✓. |
| Option — unselected after answer | Dimmed (opacity ~0.5). |
| Countdown footer | After tap, shows "NEXT CARD IN {seconds}s" + a thin progress bar that depletes. Tappable to skip. |

## Distractor selection rules

- 4 decoys = 4 random other cards from the same `entry_ref` scope (deck / folder / tag).
- Decoy `back` MUST NOT match the current card's `back` (case-insensitive trim).
- Decoy `description` is derived from the decoy card (NOT from the current card).
- If scope has < 5 cards: mode is unavailable; flow validator skips it.
- Decoy order randomized per render (seeded by `sessionId + cardId` so resume yields the same layout).

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Awaiting selection | Card opened | 5 idle options. |
| Selection committed (correct) | Tap correct option | Green border + ✓ on that option; others dim; countdown 0.8s; auto-advance. |
| Selection committed (wrong) | Tap wrong option | Red border + ✗ on tapped; green border + ✓ on the true correct; others dim; countdown 1.5s; auto-advance. |
| Skip countdown | Tap countdown bar / footer | Advance immediately. |
| Last card | Final answer | Finalize → study result. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap option | Tap | Commit selection; show feedback; start countdown; persist attempt. |
| Tap countdown footer | Tap | Skip remaining countdown, advance now. |
| Tap ✕ | Tap | Exit confirm. |
| Long-press option | Long-press | Open card actions sheet targeting the card the option belongs to (current card for A-E; supports bury / suspend / history on the current card). |

## SRS handling

- Correct tap: `result = initial_passed`; `box_after = min(current+1, 8)`.
- Wrong tap: `result = forgot`; `box_after = 1`; `lapse_count++`.

`recovered` does not apply (single-attempt per card in this mode).

## TTS behavior

Guess mode does NOT surface a TTS button on options (could leak pronunciation = leak meaning). For users who want to hear the correct front pronunciation:

- The card-actions sheet (long-press) exposes "Speak front".
- On the study result screen, per-card review of the session also exposes TTS.

If `autoPlay = true` AND `deck.target_language` is supported, the front auto-plays on card open. Stops automatically when the user makes a selection.

## Dialogs and bottom-sheets used

- Exit session confirm — `docs/wireframes/24-shared-dialogs.md` §exit-session.
- Card actions sheet — `docs/wireframes/25-shared-bottom-sheets.md` §card-actions.

## Navigation in/out

Same as Review mode.

## Responsive

- ≥600dp: prompt and options grow proportionally; max-width ~520dp.
- ≥1024dp: prompt left half, options right half (Phase 2 — not in v1).
- Landscape: scroll required; option cards retain full width.

## Performance

- Decoy pool fetched at session start (cached for session).
- Pre-fetch next card during countdown.
- Countdown animation smooth (60fps); does not block tap interaction (tap → skip).

## Accessibility

- Prompt announces caption + front.
- Each option labeled "Option A: {back}. {description}" (and similarly for B-E).
- Feedback announced via live region: "Correct" / "Wrong. The answer was {correct back}.".
- Countdown announced as "Next card in {n} seconds". Skip button has its own label.
- Reduced motion: countdown does not animate; appears as a static remaining-time label.

## Rules

- Mode requires ≥ 5 cards in scope.
- Decoys must be REAL backs from other cards.
- Decoys MUST NOT equal the correct back (case-insensitive).
- TTS button MUST NOT appear on options.
- Countdown durations: 0.8s correct, 1.5s wrong. Configurable per Learning settings only.
- Persistence happens on tap, not after countdown.

## Agent rule

- Do NOT show TTS on option cards.
- Do NOT remove the description snippet line; both title and description are required.
- Decoys MUST sample real other cards' backs and descriptions; never fabricate.
- Countdown is UI; the attempt is already persisted by the time the countdown starts.
- Mode pill copy is exactly `GUESS`. Color: blue family.

## Implementation refs

**Business specs:**

- `docs/business/study/study-flow.md` (guess mode — front → back direction in v1)
- `docs/business/srs/srs-review.md`
- `docs/business/tts/tts-settings.md` (TTS gating; no inline TTS on options)

**Decision rows:**

- Guess mode: front→back direction, description snippet derivation, decoy sampling, countdown durations

**Schema / storage:**

- INSERT `study_attempts` with `study_mode='guess'`
- Decoy pool query: `flashcards` in scope EXCLUDING current card

**Contracts:** `docs/contracts/usecase-contracts/study.md` §GradeAttemptUseCase, `docs/contracts/usecase-contracts/srs.md`, `docs/contracts/usecase-contracts/tts.md`

**Code paths (verified 2026-05-31, Prompt 10):**

- Mode view: `lib/presentation/features/study/widgets/study_session/guess/guess_mode_session_view.dart` + `guess_mode_panel.dart`.
- Option card: `lib/presentation/features/study/widgets/study_session/guess/guess_option_tile.dart` + `guess_option_models.dart`. The tile now binds to `GuessOption` (domain) rather than `StudyFlashcardRef`.
- Distractor sampling: domain `lib/domain/study/guess/guess_option_builder.dart` (`GuessOptionBuilder.build`, `kGuessDecoyLimit = 4`). Deterministic seeded shuffle (`Random(stableSeed(seed))`); correct option included exactly once; dedup by id and normalized `back`; blank/whitespace backs filtered; up to 4 valid decoys → 5 options when available. Presentation (`guess_mode_session_view.dart::_options`) and the notifier helper `studyGuessAnswerOptions` both delegate to the builder; no `dart:math` or `shuffle()` remains in the view.
- Description fallback chain (note → example → back-truncate): no dedicated `option_description_builder.dart` file. Construction happens inline within `guess_option_models.dart`; if the chain becomes more complex, extract to domain.
- Grading: `lib/domain/study/usecases/study_usecases.dart` → `AnswerFlashcardUseCase`. No standalone `grade_attempt_usecase.dart`.
- Motion / countdown: `lib/presentation/features/study/widgets/study_session/guess/guess_motion.dart` re-exports `MxDurations.guessCorrectAdvanceDelay` (800ms) as `guessCorrectAdvanceDelay` and `MxDurations.guessWrongFeedbackDelay` (1500ms) as `guessWrongFeedbackDelay`. Source tokens live in `lib/core/theme/tokens/app_motion.dart` (`AppDurations.guessCorrectAdvanceDelay` / `AppDurations.guessWrongFeedbackDelay`). The footer countdown progress bar and the staged-grade delay both consume the per-grade duration (0.8s on correct selection, 1.5s on wrong selection).
- Tests: `test/domain/study/guess/guess_option_builder_test.dart` (11 cases — correctness, decoy limit, dedup, blank filter, determinism, fewer-decoy fallback); `test/presentation/guess_mode_session_view_test.dart` (option count, no duplicates, 799/800ms correct boundary, 1499/1500ms wrong boundary, stable order, fewer-decoy no crash); `test_support/presentation/study_session_screen_contract.dart` DT8/DT9/DT10/DT27 updated to per-grade durations.

**Related wireframes:**

- `docs/wireframes/13-study-session-review.md` (shared shell + color family convention)
- `docs/wireframes/14-study-session-match.md`, `docs/wireframes/16-study-session-recall.md`, `docs/wireframes/17-study-session-fill.md`
- `docs/wireframes/18-study-result.md`
- `docs/wireframes/25-shared-bottom-sheets.md` §card-actions
