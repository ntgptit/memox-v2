---
last_updated: 2026-05-29
author: technical lead
status: resolved for v1
related_audit: docs/checklist/wireframe-code-parity-assessment.md (Rev 4)
purpose: Record v1 product-scope decisions for three formerly pending missing-screen specs.
---

# Product Decisions — Resolved for V1 — 2026-05-29

This file replaces the previous “awaiting decisions” state.

The three missing-screen specs remain useful as future product references, but they are **not V1 implementation scope** unless a later docs PR promotes them.

## Final decision summary

| Decision | Final V1 decision | Engineering impact | Docs impact |
| --- | --- | --- | --- |
| Flashcard history | Downgrade to Future Proposal | Do not implement route/screen/use cases in V1. Hide or disable `View history` entry points. | `docs/wireframes/09-flashcard-history.md` and `docs/business/history/card-history.md` marked future + migration-required. |
| Global search | Downgrade full global screen to Future Proposal; keep inline/scope-local search guidelines for V1 | Do not implement `/library/search`, `GlobalSearchUseCase`, recent-search persistence, or grouped cross-scope result screen in V1. | `docs/wireframes/11-library-search.md` and `docs/business/search/global-search.md` rewritten as V1 inline guidelines + future global search. |
| Onboarding | Use thin zero-content empty-state guidance in V1; downgrade full onboarding flow to Future Proposal | Do not create `lib/presentation/features/onboarding/**` or first-launch welcome route in V1. Improve Library/Dashboard empty states and add restore CTA path. | `docs/wireframes/23-onboarding.md` rewritten as V1 thin onboarding / future full onboarding. |

## Decision 1: Flashcard history

**Final decision:** Future Proposal for V1.

Rationale:

- No current user signal proves this is more valuable than P0 empty-scope correctness or Bury/Suspend.
- The raw attempt data exists, so the feature can be built later without losing the strategic option.
- Full value requires schema fields that are not present yet: `flashcard_progress.last_reset_at`, `study_attempts.box_before`, `study_attempts.box_after`.

V1 implementation rule:

- Do not add `/library/deck/:deckId/flashcards/:flashcardId/history`.
- Do not add `GetFlashcardHistoryUseCase`.
- Do not expose `View history` from flashcard edit/card actions.
- If a design still shows a history action, hide it or mark it disabled with future/backlog treatment.

Promotion requirement:

- Approve schema migration.
- Add route, use case, repository query and tests.
- Update `docs/checklist/v1-implementation-scope-2026-05-29.md`, matrix, parity audit and wireframe status in the same docs PR.

## Decision 2: Global search

**Final decision:** Full global search screen is Future Proposal. V1 uses inline/scope-local search guidelines.

Rationale:

- New users normally have a small library; global cross-scope search is low-value early.
- Scope-local search already exists conceptually through shared `MxSearchField` usage.
- The cost of recent searches, grouped results, deep links and cross-scope result ranking is better spent on P0/P1 correctness.

V1 implementation rule:

- Do not add `/library/search`.
- Do not add `GlobalSearchUseCase`.
- Do not add `SharedPreferences search.recent`.
- Do use the V1 inline search behavior documented in `docs/wireframes/11-library-search.md` and `docs/business/search/global-search.md` when improving existing screens.

Promotion requirement:

- Product approval for cross-scope search.
- Clear folder/deck/card/tag result ranking and route behavior.
- Recent-search persistence acceptance criteria.

## Decision 3: Onboarding

**Final decision:** V1 uses stronger zero-content empty states + restore CTA. Full onboarding flow is Future Proposal.

Rationale:

- Most onboarding value is achieved by showing the first useful action at zero content.
- A dedicated first-launch flow adds route/state complexity before the product has enough core feature stability.
- Restore remains discoverable through a clear empty-state CTA and Settings/Account path.

V1 implementation rule:

- Keep initial route aligned with current app behavior unless a separate navigation task changes it.
- Do not add `lib/presentation/features/onboarding/**`.
- Do not add a first-launch welcome carousel/screen.
- Do strengthen empty states with CTAs: Create deck, Import, Restore from Drive.
- Restore must remain opt-in and must not auto-run after sign-in.

Promotion requirement:

- Product approval for welcome screen and first-launch gating.
- Clear storage rule for `firstLaunchCompletedAt`.
- Acceptance criteria for restore prompt and import handoff.

## Side note: root agent files

`CLAUDE.md` and `AGENTS.md` are project-root files, not docs-subtree files. Their absence from this docs archive is intentional. `docs/MANIFEST.md` now states this explicitly.

## Prompt 12 audit — Core Learning Loop findings needing a product decision (2026-05-31)

These are **not implemented changes**; they are open questions surfaced by the Prompt 12 Core Learning Loop audit. The SRS finalize box-transition correctness fix (recovered path) was applied and is documented in `docs/checklist/wireframe-code-parity-assessment.md` row 17. The items below remain pending because they require a product/design decision, not a bug fix.

| Finding | Current behavior | Spec expectation | Pending decision |
| --- | --- | --- | --- |
| `forgot` result is unreachable in the normal study flow | Failed cards are re-queued (`study_repo_impl.dart` mode batch) until passed within a mode, so every finalized card has ≥1 passing attempt. `_reviewOutcome` and `computeStudyResultBreakdown` both have a correct `forgot` branch (no-passing → box reset to 1, lapse +1), but it never triggers. | `srs-review.md` defines `forgot` = "Failed (used up retries or explicit I don't know)", implying a terminal-failure path (retry cap or explicit give-up). | Decide whether V1 needs a terminal `forgot` path (retry cap or "I don't know" that ends the card unrecovered). If yes → new behavior + tests. If no → mark `forgot` explicitly as defensive/Future in `srs-review.md`. |
| SRS interval table doc ≠ code | Code `_intervalForBox` (`study_repo_impl_mapping_helpers.dart`): box1=0, box2=1d, box3=3d, box4=7d, box5=14d, box6=30d, box7=60d, box8=120d. | `srs-review.md` interval table: box1=1d … box5=5d, box6=12d, box7=30d, box8=60d. The doc itself says "source file wins" for intervals but must be updated in the same commit when they diverge. | Decide the canonical interval ladder, then update whichever side is wrong in one PR. Not changed in Prompt 12 (pre-existing drift, no code change to intervals). |
| `CLAUDE.md` trigger map references non-existent `lib/domain/srs/box_intervals.dart` / `box_transition.dart` | Those files do not exist; the box transition lives in `_reviewOutcome` (`study_repo_impl_helpers.dart`). | Trigger map should point to the real implementation. | Already noted as P2-6/P2-7 backlog in the parity assessment; fix in a docs/agent-rules PR. |
