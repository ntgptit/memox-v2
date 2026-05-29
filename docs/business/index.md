---
last_updated: 2026-05-26
applies_to: all business areas
---

# Business Documentation Index

This directory is the source of truth for MemoX product behavior.

## Read order

Core content lifecycle:

1. `docs/business/glossary.md`
2. `docs/business/system/overview.md`
3. `docs/business/navigation/navigation-flow.md`
4. `docs/business/folder/folder-management.md`
5. `docs/business/deck/deck-management.md`
6. `docs/business/flashcard/flashcard-management.md`

Study and progress:

1. `docs/business/study/study-flow.md`
2. `docs/business/srs/srs-review.md`
3. `docs/business/study-actions/bury-suspend.md`
4. `docs/business/resume/resume-session.md`

Organization and discovery:

1. `docs/business/tags/tag-system.md`
2. `docs/business/bulk/bulk-operations.md`
3. `docs/business/search/global-search.md`
4. `docs/business/history/card-history.md`

Engagement and supporting features:

1. `docs/business/engagement/dashboard-engagement.md`
2. `docs/business/export/export.md`
3. `docs/business/tts/tts-settings.md`
4. `docs/business/account-sync/account-sync.md`

Cross-cutting contracts (in `docs/` siblings):

1. `docs/database/schema-contract.md`
2. `docs/database/storage-boundaries.md`
3. `docs/architecture/clean-architecture-contract.md`

## Rule

When product behavior changes, update the related business doc before or in the same change.

When docs and code disagree, do not silently choose one. Report the mismatch or update both in the same change.

## Main business areas

| Area | Source of truth |
| --- | --- |
| Vocabulary | `docs/business/glossary.md` |
| App scope | `docs/business/system/overview.md` |
| Route relationship | `docs/business/navigation/navigation-flow.md` |
| Folder rules | `docs/business/folder/folder-management.md` |
| Deck rules | `docs/business/deck/deck-management.md` |
| Flashcard rules + import | `docs/business/flashcard/flashcard-management.md` |
| Study session + empty scope | `docs/business/study/study-flow.md` |
| SRS review | `docs/business/srs/srs-review.md` |
| Bury / suspend | `docs/business/study-actions/bury-suspend.md` |
| Resume session | `docs/business/resume/resume-session.md` |
| Tag system | `docs/business/tags/tag-system.md` |
| Bulk operations | `docs/business/bulk/bulk-operations.md` |
| Global search | `docs/business/search/global-search.md` |
| Card history | `docs/business/history/card-history.md` |
| Daily goal + streak + reminders | `docs/business/engagement/dashboard-engagement.md` |
| Export (CSV/Excel) | `docs/business/export/export.md` |
| TTS / audio | `docs/business/tts/tts-settings.md` |
| Account + Drive sync | `docs/business/account-sync/account-sync.md` |

## Related

**Top-level contracts:**

- `docs/business/glossary.md` — domain terms
- `docs/business/system/overview.md` — feature status matrix

**Wireframes:**

- `docs/wireframes/index.md` — screen index (25 wireframes + index)

**Database / architecture / state / UI:**

- `docs/database/schema-contract.md`
- `docs/database/migration-contract.md`
- `docs/database/storage-boundaries.md`
- `docs/architecture/clean-architecture-contract.md`
- `docs/state/state-management-contract.md`
- `docs/ui-ux/ui-ux-contract.md`

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md`

**Checklists:**

- `docs/checklist/implementation-checklist.md` — per-task checklist with parity rules
- `docs/checklist/recursive-agent-review.md` — code review checklist

**Repo-level:**

- `CLAUDE.md` — agent rules with Doc-code parity contract
- `AGENTS.md` — agent responsibilities
