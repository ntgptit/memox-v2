---
last_updated: 2026-05-28
route: /library/study/session/:sessionId
study_mode: fill
source_specs:
  - docs/business/study/study-flow.md
  - docs/business/srs/srs-review.md
  - docs/business/tts/tts-settings.md
---

# 17 — Study Session: Fill Mode

## Purpose

Production-mode typed recall. User reads a definition / hint, then types the front term (in the target language) in a free-text field. Strict string matcher decides correct / wrong; user can override `wrong` to `recovered` if it's just a typo. The highest-effort mode in v1; strongest reinforcement.

> **Important deviation from earlier drafts.** Fill mode in v1 uses a **plain free-text input**, NOT a per-character cell row (`▢ ▢ ▢ ▢`). User types the full term in a normal text field. The cell-row UI is a Future Proposal; not part of Phase 1.

> **Mode pill color: green** (production family). See `docs/wireframes/13-study-session-review.md` §Mode pill / progress-bar color convention.

## Layout — typing (hint shown, input active)

```
┌─────────────────────────────────────────┐
│ ✕  [ FILL ]  ━━━━━━━━━━━━━━━━━   12 / 15│  ← Exit · mode pill (green) · progress (green) · count
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │                                ✎   │ │  ← Edit icon (push to flashcard-edit)
│ │                                     │ │
│ │ Make someone laugh / Làm cho cười,  │ │  ← Definition / hint
│ │ gây cười, buồn cười (Động từ, là    │ │     (back + optional note)
│ │ dạng sai khiến của động từ          │ │
│ │ "웃다 – cười", mang nghĩa khiến     │ │
│ │ người khác bật cười hoặc thấy       │ │
│ │ buồn cười).                          │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │                                     │ │
│ │                                     │ │
│ │              웃기│                  │ │  ← Input field (in-card visual);
│ │                                     │ │     cursor visible
│ │                                     │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│  ┌─────────────┐    ┌─────────────┐     │
│  │    Hint     │    │    Check    │     │  ← Outlined / Filled primary
│  └─────────────┘    └─────────────┘     │
└─────────────────────────────────────────┘
```

The input is **visually centered inside the bottom card** (no separate text-field chrome below the card). The Korean / target-language IME is invoked normally.

## Layout — wrong feedback

```
┌─────────────────────────────────────────┐
│ ✕  [ FILL ]  ━━━━━━━━━━━━━━━━━   12 / 15│
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │                                ✎   │ │
│ │                                     │ │
│ │ Make someone laugh / ... (same)     │ │  ← Hint card unchanged
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │                              🔊     │ │  ← TTS icon appears now (correct shown)
│ │                                     │ │
│ │             우겨다                   │ │  ← User input, in RED
│ │                                     │ │
│ │             웃기다                   │ │  ← Correct front, in default text
│ │                                     │ │
│ │ ↺                                   │ │  ← Reset / retry-typing icon
│ └─────────────────────────────────────┘ │
│                                         │
│  ┌─────────────┐    ┌─────────────┐     │
│  │ Mark correct│    │  Try again  │     │  ← Outlined / Filled primary
│  └─────────────┘    └─────────────┘     │
└─────────────────────────────────────────┘
```

## Layout — correct feedback (when match was clean)

```
│ ┌─────────────────────────────────────┐ │
│ │                              🔊     │ │
│ │                                     │ │
│ │             웃기다                   │ │  ← User answer (matches), shown in default
│ │                                     │ │
│ │              ✓                      │ │  ← Check glyph
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│         [     Next  ▸     ]             │  ← Auto-advance after 0.8s, tappable to skip
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `sessionId` (required path param) | URL | active session |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Current card front, back, optional `note`, deck `target_language` | `flashcards` joined via session_items | next-card load |
| Card progress (`current_box` for `box_before`) | `flashcard_progress` | next-card load |
| Hint composition (back + note when present, formatted) | derived | once per card |

## Forbidden

- ❌ Render a per-character cell row (`▢ ▢ ▢ ▢`). Plain text input only in v1.
- ❌ Auto-correct user input. Match against typed input as-is.
- ❌ Apply case folding or diacritic stripping in the matcher. Fill mode is strict character-level match for the target language.
- ❌ Show the TTS icon on the input card DURING typing. Only after feedback (could leak the answer audibly).
- ❌ Auto-advance from wrong feedback. User must explicitly tap Mark correct or Try again.
- ❌ Show "Fill mode skipped" toast when flow validator skips a trivial-front card. Skip is silent.
- ❌ Persist an attempt when the mode is skipped (no card, no attempt).
- ❌ Use the blue progress-bar color. Fill is in the green family.
- ❌ Update SRS box outside `GradeAttemptUseCase`.

## Components

| Component | Spec |
| --- | --- |
| Top app bar | `✕` exit · `FILL` mode pill (green) · progress bar (green) · "{answered} / {total}" count. |
| Hint card | Top stack. Shows the definition / hint composed from `back` (+ optional `note`). Multi-line body. `✎` (edit) top-right. |
| Edit icon `✎` | Top-right of hint card. Tap pushes flashcard-edit. |
| Input card (typing state) | Bottom stack. Shows the user's input centered, large, with a visible caret. Hardware/IME keyboard provides the actual entry; the visual "input" is a styled label that mirrors the buffer. |
| Input card (correct state) | Same surface; shows user input above a `✓` glyph; TTS icon top-right. |
| Input card (wrong state) | Shows user input in red ABOVE the correct front in default text color. `↺` retry-typing icon bottom-left; TTS icon top-right. |
| TTS icon `🔊` | Top-right of input card. Visible **only after feedback** (correct or wrong). Speaks `front`. Hidden when `deck.target_language = unsupported`. |
| Retry icon `↺` | Bottom-left of input card in wrong state. Tap clears feedback and returns to typing state with the previous input pre-filled (one retry per card). |
| Hint button | Bottom row, left. Outlined. Reveals 1 character at a time (max half the front length). Each reveal disables `perfect` upgrade for this card. |
| Check button | Bottom row, right. Filled primary. Enabled iff input is non-empty. Submits the answer. |
| Mark correct button (wrong feedback) | Outlined. Tap maps wrong → `recovered`. |
| Try again button (wrong feedback) | Filled primary. Tap returns to typing state with cleared input. |
| Next button (correct feedback) | Filled primary, full-width. Auto-advance 0.8s; tappable to skip. |

## Matching rules (v1)

- Trim both sides.
- **Strict character match** for the target language (no case folding, no diacritic stripping).
- Result:

| Outcome | Definition | result | box_after |
| --- | --- | --- | --- |
| Exact match | Trimmed user input equals trimmed front | `perfect` (or `recovered` if hint used) | `min(current+1, 8)` (perfect) or `current` (recovered via hint) |
| Mismatch | Otherwise | `forgot` initially; can be overridden to `recovered` via "Mark correct" | `1` for forgot, `current` for recovered |

Hint button usage rule: once the user reveals any hint character, the maximum result for this card is `recovered` (not `perfect`). This is enforced at grade-time, not at hint-tap-time.

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Typing | Card opened OR Try again tapped | Hint card visible; input card empty; Check disabled until input non-empty; Hint button enabled (up to N reveals). |
| Hint partially used | Hint button tapped ≥1 | One more character of the front revealed each tap, up to `floor(length/2)`. Marks card as hint-tainted (max result = recovered). |
| Checking | Check tapped | Compare; show feedback; switch input card to correct or wrong state. |
| Correct | Exact match | Input card shows answer with ✓; TTS icon appears; Next button visible; auto-advance 0.8s. |
| Wrong | Mismatch | Input card shows user input (red) above correct (default); TTS icon appears; Mark correct / Try again buttons visible; no auto-advance. |
| Retry | Try again tapped | Return to typing state; input cleared; hint reveals retained (still tainted); attempt is NOT re-persisted (the prior wrong attempt stays in the history). One retry per card max. |
| Buried via long-press | Long-press hint card | Open card actions sheet. |
| Skipped (mode unavailable) | Front too short or trivial | Auto-skip to next mode in flow without recording attempt. |
| Last card | Final grading | Finalize → study result. |
| Exit confirm | ✕ tapped | Show "Exit session?" dialog. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Type into input | IME | Live update of the input label. |
| Tap Hint | Tap | Reveal one more character; taint card (max result = recovered). |
| Tap Check | Tap | Submit; compute match; show feedback; persist attempt. |
| Tap Mark correct (wrong state) | Tap | Override result to `recovered`; persist; next card. |
| Tap Try again (wrong state, retry available) | Tap | Return to typing; clear input; do not re-persist. |
| Tap Next (correct state) | Tap | Skip auto-advance; next card. |
| Tap ↺ retry icon (wrong state) | Tap | Same as Try again. |
| Tap 🔊 (post-feedback only) | Tap | Speak `front`. |
| Tap ✎ (typing state only) | Tap | Push flashcard-edit. |
| Long-press hint card | Long-press | Open card actions sheet. |
| Tap ✕ | Tap | Exit confirm. |

## SRS handling

| Result | Trigger | box_after |
| --- | --- | --- |
| `perfect` | Exact match, no hint used | `min(current+1, 8)` |
| `recovered` | Exact match with hint used OR Mark correct override on wrong | `current` (stay) |
| `forgot` | Wrong with no override (Try again unused or used and then user gave up) | `1` (`lapse_count++`) |

Persist via `GradeAttemptUseCase` with `study_mode = 'fill'`.

## When fill mode is unavailable

Per flow validator, fill mode requires:

- Front length ≥ 3 graphemes after trim (avoid trivial inputs like "Hi").
- Front contains at least one non-ASCII-digit, non-ASCII-symbol character.

If unmet, the flow validator skips this mode in the current card's mode sequence silently. NO toast, NO error.

This logic lives under `lib/domain/study/strategy/` (see `study_strategy.dart` + `study_strategy_factory.dart`). There is no dedicated `flow_validator.dart` file in the current codebase; the skip rule is enforced inside the active study strategy when computing the per-card mode sequence.

## TTS behavior (per `docs/business/tts/tts-settings.md`)

- TTS icon hidden during typing state (avoid leak via audio).
- TTS icon visible during correct and wrong feedback states (right side of input card).
- Speaks `front` only.
- Hidden for `deck.target_language = unsupported`.
- Auto-play DISABLED in fill mode regardless of settings (the whole point is the user produces the front from memory).

## Dialogs and bottom-sheets used

- Exit session confirm — `docs/wireframes/24-shared-dialogs.md` §exit-session.
- Card actions sheet — `docs/wireframes/25-shared-bottom-sheets.md` §card-actions.
- Bury/suspend undo toast — `docs/wireframes/25-shared-bottom-sheets.md` §undo-toast.

## Navigation in/out

Same as Recall mode:

- In: auto-redirect from study entry gate; resume; deep link.
- Out: last card → study result (`pushReplacement`); exit → pop to caller; edit / history / audio settings push and return.

## Responsive

- ≥600dp: cards retain proportions; input card vertical padding increased.
- ≥1024dp: cards max-width ~520dp, centered.
- Landscape with on-screen keyboard: keep both cards visible by reducing hint card height; never hide the input card.

## Performance

- IME-driven input — no per-keystroke widget rebuild beyond the input label.
- Strict comparison on Check tap is trivial (< 100 chars typical).
- Pre-fetch next card during correct-state countdown.
- TTS engine reused across cards; init at session start.

## Accessibility

- Hint card announces full hint text on focus.
- Input card announces user's input via live region.
- On feedback:
  - Correct: "Correct. {front}." announced.
  - Wrong: "Wrong. You typed {input}. The answer is {front}." announced.
- Hint button labeled "Reveal one character (using hint will reduce score)".
- Mark correct labeled "Override: I knew the answer".
- Try again labeled "Retry typing".
- TTS icon labeled "Speak correct answer".
- Edit icon labeled "Edit this card".
- Reduced motion: no card-transition animation between typing → feedback.

## Rules

- Plain text input ONLY in v1 (no cell row).
- Matching is strict (no case folding, no diacritic stripping).
- Correct → `perfect` (or `recovered` if hint used).
- Wrong → `forgot` (or `recovered` if Mark correct override used).
- Auto-advance only on Correct; Wrong requires explicit action.
- Try again allows ONE retry per card; second wrong commits the original `forgot` attempt.
- TTS icon hidden during typing; appears only after feedback.
- Auto-play TTS disabled in this mode regardless of settings.

## Agent rule

- Do NOT render a per-character cell row (`▢ ▢ ▢`). Plain input only.
- Do NOT apply case-insensitive or diacritic-insensitive matching.
- Do NOT show TTS during typing state.
- Do NOT auto-advance from wrong feedback.
- Hint button is OPTIONAL UX; if implemented, MUST taint card to max result `recovered`.
- Mode pill copy is exactly `FILL`. Color: green family.

## Implementation refs

**Business specs:**

- `docs/business/study/study-flow.md` (fill mode — plain text input, mode unavailability)
- `docs/business/srs/srs-review.md` (perfect / recovered / forgot transitions)
- `docs/business/tts/tts-settings.md` (front-only playback; auto-play disabled here)

**Decision rows:**

- Fill mode: strict matching, hint-tainting, retry budget, mode skip for trivial fronts

**Schema / storage:**

- INSERT `study_attempts` with `study_mode='fill'`

**Contracts:** `docs/contracts/usecase-contracts/study.md` §GradeAttemptUseCase, `docs/contracts/usecase-contracts/srs.md`, `docs/contracts/usecase-contracts/tts.md`

**Code paths (verified 2026-05-28):**

- Mode view: `lib/presentation/features/study/widgets/study_session/fill/fill_mode_session_view.dart` + `fill_mode_panel.dart`.
- Input + actions: `lib/presentation/features/study/widgets/study_session/fill/fill_prompt_card.dart` + `fill_answer_cards.dart` + `fill_actions.dart`.
- Motion: `lib/presentation/features/study/widgets/study_session/fill/fill_motion.dart`.
- Strict matcher: **no standalone `strict_matcher.dart` in `lib/domain/study/`**. Match logic currently lives in the presentation viewmodel / `fill_actions.dart`. Audit `docs/checklist/wireframe-code-parity-assessment.md` §3.10 flags this as a Clean-Architecture violation candidate — promote to domain when scope allows.
- Hint revealer: not extracted to a domain file; hint behavior is implemented inside the fill panel.
- Flow validator (skip rule for trivial fronts): currently lives within `lib/domain/study/strategy/` (see `study_strategy.dart`, `study_strategy_factory.dart`); no dedicated `flow_validator.dart`.
- Grading: `lib/domain/study/usecases/study_usecases.dart` → `AnswerFlashcardUseCase`. No standalone `grade_attempt_usecase.dart`.

**Related wireframes:**

- `docs/wireframes/13-study-session-review.md` (shared shell + color family convention)
- `docs/wireframes/14-study-session-match.md`, `docs/wireframes/15-study-session-guess.md`, `docs/wireframes/16-study-session-recall.md`
- `docs/wireframes/08-flashcard-edit.md` (target of ✎ icon)
- `docs/wireframes/18-study-result.md`
- `docs/wireframes/25-shared-bottom-sheets.md` §card-actions, §undo-toast
