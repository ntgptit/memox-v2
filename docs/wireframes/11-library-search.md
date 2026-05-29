---
last_updated: 2026-05-29
status: V1 inline/scope-local search guidelines; full global screen is Future Proposal
route: none in V1
future_route: /library/search
source_specs:
  - docs/business/search/global-search.md
related_decision: docs/checklist/product-decisions-pending-2026-05-29.md
---

# 11 — Library Search / Inline Search Guidelines

## V1 decision

V1 does **not** implement a dedicated global search screen.

V1 uses this document as the canonical UX guideline for **inline/scope-local search** in existing screens:

- Library overview search/filter.
- Folder detail search/filter.
- Flashcard list search inside one deck.
- Tag management search/filter.

The full `/library/search` experience with recent searches, popular tags, grouped cross-scope results and deep links is a **Future Proposal**.

## V1 purpose

Help users find content inside the screen/scope they are already using, without introducing a new global route or persistence model.

## V1 supported scopes

| Surface | Scope | V1 behavior |
| --- | --- | --- |
| Library overview | Root folders + root decks shown on Library | Filter visible rows. No cross-deck flashcard search. |
| Folder detail | Direct/recursive content under current folder, depending on existing folder screen behavior | Filter visible folders/decks; keep breadcrumb context. |
| Flashcard list | Flashcards in current deck only | Filter by front/back/note/pronunciation/example/hint where available. |
| Tag management | Tags only | Filter tags by tag name. |

## V1 rules

- Minimum 2 characters before filtering, unless the existing screen already supports empty-query reset.
- Debounce text input by 300ms when the query hits repository/database work.
- Case-insensitive match.
- Trim surrounding whitespace and collapse repeated whitespace.
- Escape special LIKE characters (`%`, `_`) before database search.
- Do not persist recent searches in V1.
- Do not show global result groups in V1.
- Do not navigate to `/library/search` in V1.

## V1 states

| State | Trigger | Behavior |
| --- | --- | --- |
| Empty query | Field cleared | Show normal screen content. |
| Too short | Query length = 1 | Show existing content or a small hint: `Type at least 2 characters.` |
| Loading | Query triggers async work | Show the screen's normal loading style or lightweight inline progress. |
| Results | Matches found | Show filtered list in the current screen only. |
| No results | No match in current scope | Show local empty state: `No results in this {scope}.` |
| Error | Search/filter failure | Keep the user on the current screen and show inline error/toast. |

## V1 result behavior

| Surface | Tap result |
| --- | --- |
| Library overview | Open folder or deck. |
| Folder detail | Open folder or deck. |
| Flashcard list | Open flashcard detail/editor or keep row selected, depending on existing screen behavior. |
| Tag management | Select/open tag action menu, depending on existing screen behavior. |

## V1 forbidden behavior

- Do not add `GlobalSearchUseCase`.
- Do not add `SearchScreen`.
- Do not add `/library/search` route.
- Do not add `SharedPreferences search.recent`.
- Do not add a popular-tags search landing section.
- Do not add cross-scope grouped results.
- Do not use FTS5 without a separate ADR and performance task.

## Future Proposal — full global search screen

The future global screen may use this route:

```text
/library/search
```

Future layout states may include:

- Empty query: recent searches + popular tags.
- Typing: 2-character minimum hint.
- Results: grouped Folders / Decks / Flashcards / Tags.
- No results.
- Section-level errors.

Future global result actions:

| Result type | Future behavior |
| --- | --- |
| Folder | Navigate to `/library/folder/:id`. |
| Deck | Navigate to `/library/deck/:deckId/flashcards`. |
| Flashcard | Navigate to the card's deck and scroll/select the card. |
| Tag | Open a global tag-filtered flashcard list. |

Future implementation requires product promotion in:

- `docs/checklist/v1-implementation-scope-2026-05-29.md`
- `docs/checklist/screen-function-task-matrix.md`
- `docs/checklist/wireframe-code-parity-assessment.md`
- `docs/contracts/usecase-contracts/search.md`

## Agent rule

Implement only inline/scope-local search improvements in V1. Treat every full global search screen detail as Future Proposal until promoted.
