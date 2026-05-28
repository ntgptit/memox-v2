# MemoX Documentation Package

Generated: 2026-05-27
Source: github.com/ntgptit/memox-v2

This package contains all design, business, contract, and process documents for MemoX, a local-first Flutter flashcard app using Leitner 8-box SRS.

## Reading order for first-time agents

1. `CLAUDE.md` — read fully, especially §Doc-code parity rule and §Path convention
2. `AGENTS.md` — short, delegates reading lists back to CLAUDE.md
3. `docs/business/glossary.md` — domain terms
4. `docs/business/index.md` — feature map
5. `docs/business/system/overview.md` — feature status matrix
6. `docs/contracts/error-contract.md` — Failure taxonomy (target)
7. `docs/contracts/types-catalog.md` — enums + value objects
8. `docs/contracts/code-style.md` — naming + structure
9. For any task: the wireframe `docs/wireframes/NN-{screen}.md`. Its `Implementation refs` block links business spec, decision rows, schema, contracts, and code paths.


## Current vs Target documentation rule

MemoX docs are allowed to describe both the current implementation baseline and the target architecture.

Use these labels consistently:

- **Current**: already implemented, or treated as the current baseline for documentation purposes.
- **Target**: intended architecture, schema, API, UX, or product behavior.
- **Migration Required**: target behavior that needs schema migration, dependency adoption, generated-code update, refactor, or test migration before implementation.
- **Future Proposal**: useful direction, but not scheduled for the near sprint.

AI agents must not delete target architecture only because implementation has not caught up yet.
AI agents also must not implement `Migration Required` behavior unless the task explicitly includes the required migration.

## Migration-required specs

Five business specs are flagged `Status: Target — Migration Required` because they depend on pending schema changes (see `docs/database/schema-contract.md` §Pending schema changes):

- `docs/business/deck/deck-management.md` — `decks.target_language`
- `docs/business/study-actions/bury-suspend.md` — `flashcard_progress.buried_until`, `is_suspended`
- `docs/business/history/card-history.md` — `flashcard_progress.last_reset_at`, `study_attempts.box_before`, `box_after`
- `docs/business/srs/srs-review.md` — depends on `study_attempts.box_before/after` for history persistence
- `docs/business/tts/tts-settings.md` — depends transitively on `decks.target_language`

Migration MUST run before implementing features that read/write these columns.

## Path convention

All backtick markdown references use **repo-root absolute paths, no leading slash**. See `CLAUDE.md` §Path convention for DO/DON'T examples.

## Source-of-truth ownership

| Concern | Lives in |
| --- | --- |
| Business behavior, edge cases | `docs/business/**` |
| UI states, copy, layout | `docs/wireframes/**` |
| Use case signature, preconditions, rules, errors | `docs/contracts/usecase-contracts/**` |
| Tables touched per mutation, transaction span, index dependencies | `docs/contracts/repository-contracts/**` |
| Failure type definitions | `docs/contracts/error-contract.md` |
| Cross-cutting enum / value object definitions | `docs/contracts/types-catalog.md` |
| Naming, file layout, import order | `docs/contracts/code-style.md` |
| Test layer mapping, mock framework | `docs/testing/test-strategy.md` |
| Performance budgets (target, not measured) | `docs/quality/performance-contract.md` |
| Logging policy, PII rule | `docs/quality/observability-contract.md` |
| L10n copy and key naming (suggested) | `docs/ui-ux/l10n-copy-contract.md` |
| System design, mock design, tokens, assets | `docs/system-design/MemoX Design System/**` |
| Agent task prompt template | `docs/agent/agent-task-template.md` |
| Doc-code parity rule + path convention + import direction | `CLAUDE.md` |
| Agent responsibilities, reporting | `AGENTS.md` |
| Pending schema migrations | `docs/database/schema-contract.md` §Pending schema changes |

## Top-level structure

```
.
├── CLAUDE.md
├── AGENTS.md
├── README.md
├── MANIFEST.md
└── docs/
    ├── business/            # 19 business specs + index + glossary + overview
    │                        # (5 flagged Migration Required)
    ├── wireframes/          # 25 wireframes + index
    ├── database/            # schema, migration, storage boundaries
    │                        # schema-contract enumerates 6 pending column migrations
    ├── architecture/        # Clean Architecture contract
    ├── state/               # State management contract (Per-notifier table)
    ├── ui-ux/               # UI tokens + l10n copy contract
    ├── system-design/       # MemoX Design System + mobile mock design UI kit
    ├── decision-tables/     # Event-condition-expected matrix
    ├── checklist/           # Implementation + recursive review checklists
    ├── contracts/           # error-contract, types-catalog, code-style + usecase-contracts/ + repository-contracts/
    ├── testing/             # Test strategy
    ├── quality/             # Performance + observability contracts
    ├── agent/               # Agent task template
    └── acceptance-criteria/ # (Sprint 2+, currently empty)
```

## Cross-reference integrity

All backtick `.md` references resolve to existing files except intentional Sprint 2 placeholders marked in context:
- `../business/folder/folder-management.md` (in `CLAUDE.md` §Path convention DON'T example, no longer in backticks)
- `docs/testing/fixtures-overview.md` (Sprint 2 planned deliverable)

## Target architecture disclaimer coverage

The `Either<Failure, T>` / `fpdart` target architecture disclaimer appears in: all root files (CLAUDE.md, AGENTS.md, MANIFEST.md, README.md), `docs/business/glossary.md`, `docs/architecture/clean-architecture-contract.md`, `docs/contracts/error-contract.md`, `docs/contracts/code-style.md`, and all 12 use case contracts and 7 repository contracts — **except** `docs/contracts/usecase-contracts/srs.md`, which is pure synchronous logic with no IO and therefore never returns `Either`. That file has an explicit in-file note explaining the exemption. If pure-logic files ever introduce IO, the disclaimer must be added.

