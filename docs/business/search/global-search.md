---
last_updated: 2026-05-29
applies_to: V1 inline/scope-local search; future global search
status: V1 guideline; full global search is Future Proposal
related_decision: docs/checklist/product-decisions-pending-2026-05-29.md
---

# Search

## V1 decision

MemoX V1 does **not** implement a dedicated global search screen.

V1 implements or standardizes **inline/scope-local search** on existing screens. The full cross-scope global search feature remains a Future Proposal.

## V1 purpose

Users should be able to narrow the content they are currently viewing without leaving the current screen.

## V1 scopes

| Surface | Scope | Searchable fields |
| --- | --- | --- |
| Library overview | Visible/root folders and decks | folder name, deck name |
| Folder detail | Current folder content | folder name, deck name |
| Flashcard list | Current deck only | front, back, note, pronunciation, example, hint where supported |
| Tag management | Tags only | tag name |

## V1 query input

| Aspect | Behavior |
| --- | --- |
| Min characters | 2 chars before database-backed filtering; empty query resets list. |
| Debounce | 300ms when repository/database work is triggered. |
| Case sensitivity | Case-insensitive. |
| Whitespace | Trim around query; collapse repeated internal whitespace. |
| Partial match | Substring match. |
| Special chars | Escape `%` and `_` before LIKE queries. |

## V1 rules

- Search/filter must not mutate data.
- Search must stay inside the current scope.
- No recent-search persistence in V1.
- No popular-tags landing section in V1.
- No cross-scope result grouping in V1.
- No dedicated `/library/search` route in V1.
- Use existing route constants for any result navigation.

## V1 result behavior

| Result type | Behavior |
| --- | --- |
| Folder | Open folder detail. |
| Deck | Open deck flashcard list. |
| Flashcard | Open/select card inside current deck. |
| Tag | Open/select tag management action depending on current screen. |

## Future Proposal: global Library search

Future global search may search across folders, decks, flashcards and tags from a dedicated screen.

Future capabilities:

- `/library/search` route.
- Recent searches in SharedPreferences, capped at 5.
- Popular tags shortcut section.
- Grouped results by Folders / Decks / Flashcards / Tags.
- Cross-scope result deep links.
- Ranking: exact match, starts-with, substring, recency tie-break.

Promotion requires updating the V1 scope guard, matrix, parity audit, use case contract and tests.

## Forbidden patterns

- Do not implement `GlobalSearchUseCase` during V1.
- Do not persist recent searches during V1.
- Do not introduce FTS5 without an ADR/performance task.
- Do not use raw user query as a LIKE pattern.
- Do not add a flat/recursive toggle without product approval.

## Agent rule

When a task mentions search during V1, assume inline/scope-local search unless the prompt explicitly says the global search Future Proposal has been promoted.
