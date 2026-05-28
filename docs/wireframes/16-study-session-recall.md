---
last_updated: 2026-05-27
route: /library/study/session/:sessionId
study_mode: recall
source_specs:
  - docs/business/study/study-flow.md
  - docs/business/srs/srs-review.md
  - docs/business/tts/tts-settings.md
---

# 16 — Study Session: Recall Mode

## Purpose

Active-recall flip card. User sees the front (target-language term), tries to remember the meaning silently in their head, then taps **Show answer** to reveal it and self-grades with **Forgot** or **Got it**. The hardest mode in the recognition family but simpler than fill — no typing, no input matching. Strong reinforcement via active retrieval + immediate honest self-evaluation.

> **Important deviation from earlier drafts.** Recall mode in v1 does NOT include a typed-answer input or fuzzy matcher. It is a **self-graded flip card** (Anki-style: Show answer → Forgot/Got it). Typed-answer recall is a Future Proposal documented separately and not part of Phase 1. Removing the text input means there is no Levenshtein matcher, no override paths, no `recovered` result for this mode in v1.

> **Mode pill color: green** (production family). See `docs/wireframes/13-study-session-review.md` §Mode pill / progress-bar color convention.

## Layout — front shown (top), answer hidden (bottom)

```
┌─────────────────────────────────────────┐
│ ✕  [ RECALL ]  ━━━━━━━━━━━━━━━    8 / 12│  ← Exit · mode pill (green) · progress (green) · count
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │                                 ✎  │ │  ← Edit icon (push to edit card)
│ │                                     │ │
│ │                                     │ │
│ │              연구자                  │ │  ← Front, large centered
│ │                                     │ │
│ │                                     │ │
│ │                              🔊     │ │  ← TTS icon, bottom-right of card
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │                                     │ │
│ │                                     │ │
│ │                                     │ │
│ │                  ▬▬▬                │ │  ← Placeholder dash (answer hidden)
│ │                                     │ │
│ │                                     │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│         [    Show answer    ]           │  ← Primary CTA, full-width
└─────────────────────────────────────────┘
```

## Layout — after Show answer (back revealed)

```
┌─────────────────────────────────────────┐
│ ✕  [ RECALL ]  ━━━━━━━━━━━━━━━    8 / 12│
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │                                 ✎  │ │
│ │              연구자                  │ │  ← Front (same)
│ │                              🔊     │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │                                     │ │
│ │ Researcher / Nhà nghiên cứu —       │ │  ← Back: meaning, note,
│ │ person who conducts research.       │ │     etymology (any combination
│ │ Hán-Việt: Nghiên cứu giả (研究者).  │ │     of back/note fields present)
│ │ 연구 = research, 자 = person.        │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│  ┌─────────────┐    ┌─────────────┐     │
│  │   Forgot    │    │    Got it   │     │  ← Two grading buttons:
│  └─────────────┘    └─────────────┘     │     outlined / filled primary
└─────────────────────────────────────────┘
```

Two cards stacked vertically:

- **Top card** = front. Has `✎` (edit) icon top-right and `🔊` (TTS) icon bottom-right.
- **Bottom card** = back / explanation area. Initially blanked (just a placeholder dash); after Show answer, displays the full back text and any rich content (note, etymology, etc.).

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `sessionId` (required path param) | URL | active session |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Current card front, back, optional `note`, deck `target_language` | `flashcards` joined via session_items | next-card load |
| Card progress (`current_box` for `box_before`) | `flashcard_progress` | next-card load |
| Pre-fetched next card | repository call during current grade | parallel with persist |

## Forbidden

- ❌ Add a typed-answer input. Recall mode is self-graded in v1.
- ❌ Add a Levenshtein / fuzzy matcher. No matching logic — user self-evaluates.
- ❌ Persist a `recovered` result in this mode. Only `perfect` and `forgot` apply in v1.
- ❌ Use the blue progress-bar color. Recall is in the green family.
- ❌ Auto-reveal the back without an explicit Show answer tap.
- ❌ Auto-advance after Show answer; user MUST tap Forgot or Got it.
- ❌ Auto-play `back` via TTS. Front-only policy.
- ❌ Show the TTS icon on the back card. TTS plays the front only.
- ❌ Update SRS box outside `GradeAttemptUseCase`.

## Components

| Component | Spec |
| --- | --- |
| Top app bar | `✕` exit · `RECALL` mode pill (green) · progress bar (green) · "{answered} / {total}" count. |
| Front card | Top stack. Holds the front term (display-large, centered), `✎` (edit) top-right, `🔊` (TTS) bottom-right. |
| Edit icon `✎` | Top-right of front card. Tap pushes flashcard-edit screen for this card (returns on back). |
| TTS icon `🔊` | Bottom-right of front card. Tap speaks `front`. Hidden when `deck.target_language = unsupported`. |
| Back card (hidden state) | Bottom stack. Contains a centered placeholder (short horizontal dash) indicating "answer here". |
| Back card (revealed) | Same surface; shows `back` + optional `note` rendered as body-medium. Multi-line; left-aligned within card; vertical padding generous. |
| Show answer CTA | Full-width primary button below both cards. Visible only in the hidden state. Disappears after tap. |
| Grading row | Visible after Show answer. Two equal-width buttons: `Forgot` (outlined) and `Got it` (filled primary). |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Hidden | Card opened | Front card shown with TTS + edit; back card shows placeholder; Show answer button visible. |
| Revealing | Show answer tapped | Back card fades in; grading row replaces Show answer CTA. |
| Revealed | After fade | Back text fully visible; user can tap Forgot or Got it; can also tap 🔊 to replay front. |
| Grading | Forgot or Got it tapped | Persist attempt + SRS update; advance to next card. |
| Editing | ✎ tapped | Push flashcard-edit; on return, refresh current card data. |
| TTS playing | 🔊 tapped | Icon swaps to ⏸ briefly; speak front; revert. |
| Buried via long-press | Long-press front card | Open card actions sheet. |
| Last card | Grading on final card | Finalize → study result. |
| Exit confirm | ✕ tapped mid-session | Show "Exit session?" dialog. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap Show answer | Tap | Reveal back card; replace CTA with grading row. |
| Tap 🔊 | Tap | Speak front. |
| Tap ✎ | Tap | Push flashcard-edit; return refreshes. |
| Tap Forgot | Tap (revealed only) | `result = forgot`; persist; next card. |
| Tap Got it | Tap (revealed only) | `result = perfect`; persist; next card. |
| Long-press front card | Long-press | Open card actions sheet (Bury / Suspend / History / Audio settings). |
| Tap ✕ | Tap | Exit confirm. |

## SRS handling on answer

- `result = perfect` (Got it): `box_after = min(current+1, 8)`.
- `result = forgot` (Forgot): `box_after = 1`; `lapse_count++`.

Insert `study_attempts` row with `box_before`, `box_after`, `result`, `study_mode = 'recall'`, `attempted_at = now`. See `docs/contracts/usecase-contracts/study.md` §GradeAttemptUseCase.

> No `recovered` in this mode for v1. `recovered` is reserved for typed-answer flows (Future Proposal) or for multi-attempt modes where a card was wrong on attempt 1 and then correct on attempt 2 within the same session item — recall mode is single-attempt-per-card.

## TTS behavior (per `docs/business/tts/tts-settings.md`)

- TTS icon visible on the front card iff `deck.target_language` in (`korean`, `english`).
- Speaks `front` only. NEVER `back`.
- Auto-play on card open if `autoPlay = true` AND language supported.
- Tap-to-replay always allowed.
- Hidden for `target_language = unsupported`.

## Dialogs and bottom-sheets used

- Exit session confirm — `docs/wireframes/24-shared-dialogs.md` §exit-session.
- Card actions sheet — `docs/wireframes/25-shared-bottom-sheets.md` §card-actions.
- Bury/suspend undo toast — `docs/wireframes/25-shared-bottom-sheets.md` §undo-toast.

## Navigation in/out

Same as other modes:

- In: auto-redirect from study entry gate; resume; deep link.
- Out: last card → study result (`pushReplacement`); exit → pop to caller; edit / history / audio settings push and return.

## Responsive

- ≥600dp: cards retain proportions; max-width ~520dp; vertical spacing increased.
- ≥1024dp: cards centered with extra side margin; no chrome added.
- Landscape: stack remains vertical (front above, back below); buttons remain at the bottom.

## Performance

- Pre-fetch next card on Forgot / Got it tap (parallel with persistence).
- TTS init at session start; reuse engine across cards.
- Back card fade-in animation runs at 60fps.

## Accessibility

- Front card announces front on focus.
- Show answer button labeled "Show answer".
- Back card on reveal announces full text via live region.
- Forgot / Got it buttons labeled "Mark forgot" / "Mark got it".
- TTS icon labeled "Speak front" / "Stop speech".
- Edit icon labeled "Edit this card".
- Reduced motion: back card appears instantly (no fade).

## Rules

- Two-card stacked layout MUST be preserved (front top, back bottom).
- Show answer MUST be the only way to reveal the back. No auto-reveal.
- Grading uses ONLY `Forgot` / `Got it`. No third button, no `recovered`, no override path in v1.
- TTS button MUST be on the front card only.
- `box_before` and `box_after` MUST be recorded on every attempt.
- Edit icon MUST push to flashcard-edit and return.

## Agent rule

- Do NOT introduce a text input. Recall mode in v1 is flip-card self-grade.
- Do NOT add `recovered` result in this mode. Only `perfect` / `forgot`.
- Do NOT collapse front and back into one card. Two cards stacked is intentional.
- Edit icon MUST navigate to flashcard-edit; do not show inline editing.
- Mode pill copy is exactly `RECALL`. Color: green family.
- If a future PR adds typed recall, create a new mode (e.g., `recall_typed`) instead of modifying this one.

## Implementation refs

**Business specs:**

- `docs/business/study/study-flow.md` (recall mode — flip-card self-grade in v1)
- `docs/business/srs/srs-review.md` (perfect / forgot transitions)
- `docs/business/tts/tts-settings.md` (front-only playback)

**Decision rows:**

- Recall mode: flip-card model, two-button grading, no input matching in v1

**Schema / storage:**

- INSERT `study_attempts` with `study_mode='recall'`, result ∈ (`perfect`, `forgot`)

**Contracts:** `docs/contracts/usecase-contracts/study.md` §GradeAttemptUseCase, `docs/contracts/usecase-contracts/srs.md`, `docs/contracts/usecase-contracts/tts.md`

**Code paths:**

- `lib/presentation/features/study/widgets/recall_mode_view.dart`
- `lib/presentation/features/study/widgets/flip_card_pair.dart` (front-top, back-bottom layout)
- `lib/domain/usecases/study/grade_attempt_usecase.dart`
- `lib/core/tts/tts_engine.dart`

**Related wireframes:**

- `docs/wireframes/13-study-session-review.md` (shared shell + color family convention)
- `docs/wireframes/14-study-session-match.md`, `docs/wireframes/15-study-session-guess.md`, `docs/wireframes/17-study-session-fill.md`
- `docs/wireframes/08-flashcard-edit.md` (target of ✎ icon)
- `docs/wireframes/18-study-result.md`
- `docs/wireframes/25-shared-bottom-sheets.md` §card-actions, §undo-toast
