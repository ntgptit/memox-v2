---
last_updated: 2026-05-28
route: /library/study/session/:sessionId
study_mode: match
source_specs:
  - docs/business/study/study-flow.md
  - docs/business/srs/srs-review.md
---

# 14 — Study Session: Match Mode

## Purpose

Multi-pair matching board. User sees a grid of cards — each card is either a `front` or a `back` from the current batch. User taps two cards in sequence; if they form a valid pair (front and back belong to the same flashcard), both lock in as matched. A "board" covers 5 cards at a time; clearing one board reveals the next. Lighter cognitive load than recall; useful for early-stage learning and for ramping up after a long break.

> **Mode pill color: blue** (recognition family). See `docs/wireframes/13-study-session-review.md` §Mode pill / progress-bar color convention.

## Layout — board fresh

```
┌─────────────────────────────────────────┐
│ ✕  [ MATCH ]  ━━━━━━━━━━━━━━━    0 / 15 │  ← Exit · mode pill (blue) · progress · count
├─────────────────────────────────────────┤
│        BOARD 1 OF 3 · 5 PAIRS LEFT       │  ← Board indicator
│                                         │
│  ┌─────────────┐    ┌─────────────┐     │
│  │   공부하다    │    │   to study  │     │  ← Pair 1 (unmatched, neutral)
│  └─────────────┘    └─────────────┘     │
│                                         │
│  ┌─────────────┐    ┌─────────────┐     │
│  │    먹다      │    │    to eat   │     │  ← Pair 2
│  └─────────────┘    └─────────────┘     │
│                                         │
│  ┌─────────────┐    ┌─────────────┐     │
│  │    하늘      │    │     sky     │     │  ← Pair 3
│  └─────────────┘    └─────────────┘     │
│                                         │
│  ┌─────────────┐    ┌─────────────┐     │
│  │   도서관     │    │   library   │     │  ← Pair 4
│  └─────────────┘    └─────────────┘     │
│                                         │
│  ┌─────────────┐    ┌─────────────┐     │
│  │     책       │    │    book     │     │  ← Pair 5
│  └─────────────┘    └─────────────┘     │
│                                         │
├─────────────────────────────────────────┤
│ ⏱ 0:42                       1 mistake  │  ← Timer · mistake counter
└─────────────────────────────────────────┘
```

The grid is **two columns × five rows** = 10 cells. Cells are shuffled per board (front and back of the same pair are NOT guaranteed in the same row).

## Layout — mid-board (one cell selected, one pair matched)

```
│  ┌─────────────┐    ┌─────────────┐     │
│  │ ✓ 공부하다    │    │ ✓ to study  │     │  ← Matched pair: muted green + ✓
│  └─────────────┘    └─────────────┘     │
│                                         │
│  ┌─────────────┐    ┌─────────────┐     │
│  │    먹다      │    │ ▆▆▆ to eat  │     │  ← One cell selected: solid blue
│  └─────────────┘    └─────────────┘     │
│                                         │
│  ...                                    │
```

- **Unmatched + not selected**: neutral surface, default text.
- **Selected (waiting for second tap)**: solid blue background, white text.
- **Matched**: muted green background, green text, `✓` prefix.
- **Just-wrong-tapped pair (transient, ~600ms)**: brief red flash, then both deselect.

## Layout — board clear → next board

After all 5 pairs match, the board fades, the next board fades in, and the counter advances ("BOARD 2 OF 3"). No explicit "Next" button.

## Layout — last board cleared

After last board clears, the session finalizes and routes to study result.

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `sessionId` (required path param) | URL | active session |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Session detail (total cards, answered count) | `study_sessions` aggregate | watch |
| Current batch of 5 cards (one "board") | `flashcards` joined via session_items, take next 5 | per board |
| Per-card front + back | `flashcards` | per board |
| Card progress (`current_box` for `box_before`) | `flashcard_progress` | per board |

No external decoy pool needed — the 5 cards on the board provide their own distractors via the other fronts and backs in view.

## Forbidden

- ❌ Sample decoys from OUTSIDE the current 5-card board. The board is self-contained.
- ❌ Run match mode when remaining cards in session < 5. Skip silently to next mode OR finalize if all modes exhausted.
- ❌ Show TTS button on cells. TTS could leak the answer for some scopes.
- ❌ Allow more than one selection at a time. Selecting a second cell either matches (success) or wrong-flashes (failure) — no triple-tap state.
- ❌ Re-show a matched pair as tappable. Once matched, the pair is locked.
- ❌ Persist attempts only at board end. Each pair-match (right or wrong) is a per-card attempt persisted immediately.
- ❌ Auto-flip cells. Both sides are visible from the start of the board.
- ❌ Use the green progress-bar color. Match is in the blue family.

## Components

| Component | Spec |
| --- | --- |
| Top app bar | `✕` exit on left; mode pill `MATCH` (blue tint); progress bar (blue); "{boards_done * 5 + matched_in_current} / {total}" count. |
| Board indicator | Caption-sized text above the grid: "BOARD {n} OF {total_boards} · {pairs_left} PAIRS LEFT". |
| Cell grid | Two columns × five rows. Each cell holds one front or one back. Equal-sized cards with generous padding. |
| Cell — unmatched, idle | Neutral surface; default text color. |
| Cell — unmatched, selected | Solid blue surface; white text. |
| Cell — matched | Muted green surface; green text; `✓` prefix. Non-interactive. |
| Cell — wrong-pair flash | Brief (~600ms) red tint on both wrongly-tapped cells, then both deselect. |
| Timer | Bottom-left, monospace, format `M:SS`. Counts up from board start. Does NOT block progress. |
| Mistake counter | Bottom-right. "{n} mistake" / "{n} mistakes" (ICU plural). Counts wrong-pair attempts. |

## Board composition rules

- Each board = the next 5 cards in session order.
- 10 cells total per board: 5 fronts + 5 backs of those same 5 cards, **shuffled** (Fisher-Yates).
- A matched pair always belongs to the SAME flashcard. There is no cross-card decoy concept — match mode is intrinsically self-contained per board.
- If session has fewer than 5 cards remaining at the start of a board, match mode is unavailable for the remainder; flow validator skips to the next mode (per `docs/business/study/study-flow.md`).

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Board idle | Board loaded, no selection | 10 neutral cells, board indicator showing pairs left. |
| One selected | First cell tapped | Cell turns solid blue; await second tap. |
| Pair correct | Second tap on the matching cell | Both turn muted green with `✓`; persist attempt as `initial_passed`; decrement pairs-left. |
| Pair wrong | Second tap on a non-matching cell | Both red-flash for ~600ms; persist attempt as `forgot` against the FIRST-tapped card; both deselect; mistake count++. |
| Board cleared | Last pair matched | Cross-fade to next board (or finalize if last). |
| TTS gating | (Not applicable) | No inline TTS in match mode. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap unmatched cell (no selection) | Tap | Select cell (blue). |
| Tap selected cell (deselect) | Tap the already-selected cell | Deselect (no attempt recorded). |
| Tap another unmatched cell | Tap (second selection) | Evaluate pair: match (green + persist `initial_passed`) or wrong (red flash + persist `forgot`). |
| Tap matched cell | Tap | No-op (cell is locked). |
| Tap ✕ | Tap | Exit confirm dialog. |
| Long-press cell | Long-press | Open card actions sheet (Bury / Suspend / History / Audio settings) targeting the card that owns that cell. |

## Dialogs and bottom-sheets used

- Exit session confirm — `docs/wireframes/24-shared-dialogs.md` §exit-session.
- Card actions sheet — `docs/wireframes/25-shared-bottom-sheets.md` §card-actions.
- Bury/suspend undo toast — `docs/wireframes/25-shared-bottom-sheets.md` §undo-toast.

## SRS handling

Each pair-evaluation persists ONE `study_attempts` row keyed to the **first-tapped cell's card**:

- Pair correct → `result = initial_passed`; `box_after = min(current+1, 8)`.
- Pair wrong → `result = forgot` on the first-tapped card; `box_after = 1`; `lapse_count++`. The second-tapped card is NOT marked at this moment (it gets its own attempt when it is later involved in a match).

Edge case: if the user wrong-taps several times before correctly matching a card, only the LAST attempt for that card on this board is what determines the SRS state, since SRS state is overwritten on each attempt. The `study_attempts` table preserves each attempt for history.

Note: `result = recovered` does NOT apply in match mode (single-attempt-per-card model within the board). For multi-attempt flows in `new_full_cycle`, `recovered` may be triggered via later modes for the same card.

## Navigation in/out

Same as Review mode.

## Responsive

- ≥600dp: same 2×5 grid, cells larger.
- ≥1024dp: optional 5×2 layout (same 5 pairs per board, wider cells) — Phase 2 only.
- Landscape: switch to 5 columns × 2 rows; same pair count.

## Performance

- Board precomputed on entry; no per-tap query.
- Shuffle uses seeded RNG (per session, so resume returns to the same board layout — see resume spec).
- Persist per pair-evaluation in background; UI advances immediately on the visual feedback.

## Accessibility

- Each cell labeled with its text and a "Unmatched" / "Selected" / "Matched" state badge.
- Match success / wrong announced via live region.
- Color-blind: matched cells get the `✓` glyph (not relying on color alone); wrong-flash uses both color and a quick haptic.
- Reduced-motion: cross-fade between boards instead of slide.

## Rules

- Match mode requires ≥ 5 cards remaining in session at board-start. If fewer, mode is unavailable.
- Each pair-evaluation MUST persist an attempt against the first-tapped card (right or wrong).
- A matched pair is permanently locked; the cells become non-interactive.
- Mistake counter is per-session, not per-board.
- TTS button MUST NOT appear on cells.

## Agent rule

- Do NOT introduce decoys from other cards. Board is self-contained.
- Persistence is per-evaluation, not per-board. Wrong-evaluation against the first-tapped card MUST persist `forgot` immediately.
- Auto-flip / reveal is NOT a thing in match mode — both fronts and backs are visible from the start.
- Mistake counter increments only on wrong-pair, not on deselecting the same cell.
- Mode pill copy is exactly `MATCH`. Color: blue family.

## Implementation refs

**Business specs:**

- `docs/business/study/study-flow.md` (match mode — board format, mode availability)
- `docs/business/srs/srs-review.md` (initial_passed / forgot transitions)

**Decision rows:**

- Match mode: board size, mode unavailability (< 5 cards), per-tap attempt persistence

**Schema / storage:**

- INSERT `study_attempts` per pair-evaluation with `study_mode='match'`
- Board layout NOT persisted (recomputed deterministically from `sessionId` + board index using seeded RNG, so resume works)

**Contracts:** `docs/contracts/usecase-contracts/study.md` §GradeAttemptUseCase, `docs/contracts/usecase-contracts/srs.md`

**Code paths (verified 2026-05-28):**

- Mode view: `lib/presentation/features/study/widgets/study_session/match/match_mode_session_view.dart` + `match_mode_panel.dart`.
- Board: `lib/presentation/features/study/widgets/study_session/match/match_board.dart` + `match_mode_tile.dart` + `match_tile_models.dart`.
- Board size: `lib/presentation/features/study/widgets/study_session/match/match_batching.dart` → `const matchVisiblePairLimit = 5`. Take the next 5 items from session order via `visibleMatchBatch(items, startIndex)`.
- Seeded shuffle: `lib/presentation/features/study/widgets/study_session/match/match_seed.dart` (NOT in `lib/domain/study/`). Deterministic per `sessionId + boardIndex` so resume preserves layout.
- Grading: `lib/domain/study/usecases/study_usecases.dart` → `AnswerCurrentMatchModeBatchUseCase` for the match-specific batch grade path; no standalone `grade_attempt_usecase.dart`.

**Related wireframes:**

- `docs/wireframes/13-study-session-review.md` (shared shell + color family convention)
- `docs/wireframes/15-study-session-guess.md`, `docs/wireframes/16-study-session-recall.md`, `docs/wireframes/17-study-session-fill.md`
- `docs/wireframes/18-study-result.md`
- `docs/wireframes/25-shared-bottom-sheets.md` §card-actions, §undo-toast
