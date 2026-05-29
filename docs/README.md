# MemoX Documentation

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

This folder is the **`docs/` subtree** of MemoX, a local-first Flutter flashcard learning app.

Project-root files such as `CLAUDE.md` and `AGENTS.md` intentionally live outside this folder.

## Before implementation

Read these in order:

1. `CLAUDE.md` at project root.
2. `AGENTS.md` at project root.
3. `docs/MANIFEST.md`.
4. `docs/checklist/v1-implementation-scope-2026-05-29.md`.
5. The matching row in `docs/checklist/screen-function-task-matrix.md`.
6. Related business, wireframe, database, architecture, state, UI/UX and contract docs.
7. Related source files.

Do not implement from assumption when repo contracts already exist.

## Current V1 scope guard

The authoritative V1 scope guard is:

```text
docs/checklist/v1-implementation-scope-2026-05-29.md
```

Important V1 decisions:

| Feature | V1 status |
| --- | --- |
| Flashcard history screen | Future Proposal |
| Global search screen | Future Proposal |
| Full onboarding flow | Future Proposal |
| Inline/scope-local search patterns | V1 guideline |
| Strong zero-content empty states + restore CTA | V1 scope |
| Empty-scope matrix Tier 1 | V1 P0 |
| Bury / suspend | V1 after migration |
| Tag domain cleanup | V1/P1 |

## Stack

- Flutter, Dart 3
- Material 3
- Riverpod annotation v3
- Drift SQLite
- GoRouter
- fpdart Either (Target; requires approved dependency/API migration before implementation if not adopted)
- freezed
- ARB localization
- MemoX Design System
- code-verification-guard

## Documentation map

| Area | Document |
| --- | --- |
| Docs manifest | `docs/MANIFEST.md` |
| V1 scope guard | `docs/checklist/v1-implementation-scope-2026-05-29.md` |
| Business index | `docs/business/index.md` |
| Glossary | `docs/business/glossary.md` |
| Product overview | `docs/business/system/overview.md` |
| Navigation | `docs/business/navigation/navigation-flow.md` |
| Folder | `docs/business/folder/folder-management.md` |
| Deck | `docs/business/deck/deck-management.md` |
| Flashcard | `docs/business/flashcard/flashcard-management.md` |
| Study | `docs/business/study/study-flow.md` |
| SRS | `docs/business/srs/srs-review.md` |
| Bury / suspend | `docs/business/study-actions/bury-suspend.md` |
| Resume session | `docs/business/resume/resume-session.md` |
| Tag system | `docs/business/tags/tag-system.md` |
| Bulk operations | `docs/business/bulk/bulk-operations.md` |
| Inline/global search | `docs/business/search/global-search.md` |
| Card history | `docs/business/history/card-history.md` |
| Daily engagement | `docs/business/engagement/dashboard-engagement.md` |
| Export | `docs/business/export/export.md` |
| TTS / audio | `docs/business/tts/tts-settings.md` |
| Account + Drive sync | `docs/business/account-sync/account-sync.md` |
| Database schema | `docs/database/schema-contract.md` |
| Storage boundary | `docs/database/storage-boundaries.md` |
| Migration | `docs/database/migration-contract.md` |
| Architecture | `docs/architecture/clean-architecture-contract.md` |
| UI/UX | `docs/ui-ux/ui-ux-contract.md` |
| System design / mock design | `docs/system-design/MemoX Design System/README.md` |
| State management | `docs/state/state-management-contract.md` |
| Decision table | `docs/decision-tables/memox-core-decision-table.md` |
| Implementation checklist | `docs/checklist/implementation-checklist.md` |
| Recursive review | `docs/checklist/recursive-agent-review.md` |
| Acceptance criteria | `docs/acceptance-criteria/README.md` |

## Agent instruction

- Do not create routes for Future Proposal screens.
- Do not wire dead links to Future Proposal screens.
- Do not implement migration-required behavior unless the migration is explicitly part of the task.
- Do not add product behavior without updating business docs, wireframes, matrix, decision table and tests.
