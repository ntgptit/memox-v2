---
last_updated: 2026-05-29
author: technical lead
status: approved v1 scope guard
purpose: Lock v1 implementation scope so AI coding agents do not implement downgraded target/future specs by accident.
related:
  - docs/checklist/product-decisions-pending-2026-05-29.md
  - docs/checklist/screen-function-task-matrix.md
  - docs/checklist/wireframe-code-parity-assessment.md
---

# MemoX V1 Implementation Scope Guard — 2026-05-29

This file is a **scope gate** for implementation tasks.

Agents MUST read this file before picking work from `docs/checklist/screen-function-task-matrix.md`.

## V1 implementation rule

A feature is safe to implement only when all conditions are true:

1. The matrix row status is `NotStarted` or `Partial`.
2. The row is not blocked by a migration or upstream epic.
3. The related business/wireframe doc is not marked `Future Proposal`.
4. The task prompt explicitly names the row or scope.

If any condition fails, do not code. Update docs or ask for scope clarification instead.

## Approved V1 priorities

| Priority | Area | Allowed scope | Source |
| --- | --- | --- | --- |
| P0 | Empty-scope matrix | Tier 1 only: `deck_noDueCards`, `folder_noCards`, `folder_noDueCards`, `today_allDone`, `today_noContent` | `docs/checklist/p0-1-empty-scope-matrix-plan-2026-05-29.md` |
| P0 | Bury / suspend foundation | Migration + domain/repository/use case + UI wiring after migration approval | `docs/business/study-actions/bury-suspend.md`, `docs/database/schema-contract.md` |
| P1 | Tag domain cleanup | Repository interface + use cases before settings UI actions | `docs/business/tags/tag-system.md`, `docs/contracts/usecase-contracts/tag.md` |
| P1 | Dashboard engagement | Streak/daily goal only after concrete source-of-truth use cases are implemented | `docs/business/engagement/dashboard-engagement.md` |
| P1 | Thin zero-content guidance | Improve Library/Dashboard empty states and add explicit restore CTA path | `docs/wireframes/23-onboarding.md`, `docs/wireframes/01-dashboard.md`, `docs/wireframes/02-library.md` |

## Downgraded from V1

These specs remain documented for future planning, but must not be implemented during V1 unless a later docs PR promotes them.

| Feature | V1 decision | Required before promotion |
| --- | --- | --- |
| Flashcard history screen | Future Proposal | Schema migration for `last_reset_at`, `box_before`, `box_after`; route/link approval; history use case/repository contract confirmation |
| Global search screen | Future Proposal | Product approval for cross-scope search, recent search persistence, route, and result grouping |
| Full onboarding flow | Future Proposal | Product approval for welcome screen, onboarding feature folder, restore prompt branch, and first-launch gating |

## Migration blockers

The following features are not safe to implement until the schema migration is included in the same task/PR:

| Blocked area | Missing schema fields |
| --- | --- |
| Bury / suspend | `flashcard_progress.buried_until`, `flashcard_progress.is_suspended` |
| Card history | `flashcard_progress.last_reset_at`, `study_attempts.box_before`, `study_attempts.box_after` |
| TTS per deck target language | `decks.target_language` |

## Agent rules

- Do not treat a complete wireframe as implementation approval.
- Do not create routes for Future Proposal screens.
- Do not wire dead links to Future Proposal screens.
- For Flashcard Editor V1, do not add a live `View history` action, standalone reset-progress action, or history route. The editor may only show the existing learned-content Keep/Reset progress-policy dialog when saving front/back changes on a progressed card.
- Do not implement migration-required behavior without the migration task being explicit.
- When promoting `Future` or `Target` rows to implementable work, update this file, the matrix, the parity audit, and related business/wireframe docs in the same docs PR.
