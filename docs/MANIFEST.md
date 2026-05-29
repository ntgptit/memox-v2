# MemoX Documentation Package

Generated: 2026-05-29
Source: github.com/ntgptit/memox-v2
Scope: `docs/` subtree only

This archive contains the **MemoX documentation subtree**. It intentionally does **not** contain project-root agent entry files.

In the real project layout, the files live like this:

```text
project-root/
├── CLAUDE.md          # AI-agent entry rules, lives at project root
├── AGENTS.md          # agent responsibilities, lives at project root
├── README.md          # project README, lives at project root
├── pubspec.yaml
├── lib/
├── test/
└── docs/              # this package content
    ├── MANIFEST.md
    ├── README.md
    ├── business/
    ├── wireframes/
    ├── database/
    ├── checklist/
    └── ...
```

## Reading order for first-time agents

1. `CLAUDE.md` at project root — read fully, especially Doc-code parity rule and Path convention.
2. `AGENTS.md` at project root — short agent contract.
3. `docs/MANIFEST.md` — this file.
4. `docs/checklist/v1-implementation-scope-2026-05-29.md` — current V1 scope guard.
5. `docs/business/glossary.md` — domain terms.
6. `docs/business/index.md` — feature map.
7. `docs/business/system/overview.md` — product capability map.
8. `docs/contracts/error-contract.md` — Failure taxonomy target.
9. `docs/contracts/types-catalog.md` — enums and value objects.
10. `docs/contracts/code-style.md` — naming and structure.
11. For any task: the matching row in `docs/checklist/screen-function-task-matrix.md` and the matching wireframe `docs/wireframes/NN-{screen}.md`.

## Current vs Target documentation rule

MemoX docs are allowed to describe both current implementation and target architecture.

Use these labels consistently:

- **Current**: already implemented, or treated as current baseline for documentation purposes.
- **Target**: intended architecture, schema, API, UX, or behavior. Not automatically approved for the current sprint.
- **Migration Required**: target behavior that needs schema migration, dependency adoption, generated-code update, refactor, or test migration before implementation.
- **Future Proposal**: useful direction, but explicitly out of V1 unless promoted by a later docs PR.

AI agents must not delete target architecture only because implementation has not caught up yet.
AI agents also must not implement `Migration Required` or `Future Proposal` behavior unless the task explicitly promotes it and includes required migration/decomposition work.

## V1 scope decision summary

The V1 scope guard is `docs/checklist/v1-implementation-scope-2026-05-29.md`.

| Feature | V1 status | Notes |
| --- | --- | --- |
| Flashcard history screen | Future Proposal | Keep docs; hide/disable entry links in V1. |
| Global search screen | Future Proposal | V1 uses inline/scope-local search guidelines only. |
| Full onboarding flow | Future Proposal | V1 uses stronger zero-content empty states + restore CTA. |
| Empty-scope matrix Tier 1 | Approved V1 | Safe to implement from the P0 plan. |
| Bury / suspend | Approved after migration | Must include schema migration. |
| Tag domain cleanup | Approved V1/P1 | Must start in domain/repository layer. |

## Migration-required specs

The following business specs depend on pending schema changes. See `docs/database/schema-contract.md` §Pending schema changes and §V1 migration gate.

- `docs/business/deck/deck-management.md` — `decks.target_language`
- `docs/business/study-actions/bury-suspend.md` — `flashcard_progress.buried_until`, `is_suspended`
- `docs/business/history/card-history.md` — Future Proposal; also requires `flashcard_progress.last_reset_at`, `study_attempts.box_before`, `box_after`
- `docs/business/srs/srs-review.md` — history persistence depends on `study_attempts.box_before/after`
- `docs/business/tts/tts-settings.md` — depends transitively on `decks.target_language`

Migration MUST run before implementing features that read/write these columns.

## Path convention

All backtick markdown references use **repo-root absolute paths, no leading slash**.

Correct:

```text
docs/business/folder/folder-management.md
```

Incorrect:

```text
/business/folder/folder-management.md
../business/folder/folder-management.md
```

## Source-of-truth ownership

| Concern | Lives in |
| --- | --- |
| Agent hard rules, path convention, import direction | project-root `CLAUDE.md` |
| Agent responsibilities and reporting | project-root `AGENTS.md` |
| V1 scope gate | `docs/checklist/v1-implementation-scope-2026-05-29.md` |
| Business behavior, edge cases | `docs/business/**` |
| UI states, copy, layout | `docs/wireframes/**` |
| Use case signatures, preconditions, rules, errors | `docs/contracts/usecase-contracts/**` |
| Tables touched per mutation, transaction span, index dependencies | `docs/contracts/repository-contracts/**` |
| Failure type definitions | `docs/contracts/error-contract.md` |
| Cross-cutting enum / value object definitions | `docs/contracts/types-catalog.md` |
| Naming, file layout, import order | `docs/contracts/code-style.md` |
| Test layer mapping, mock framework | `docs/testing/test-strategy.md` |
| Performance budgets | `docs/quality/performance-contract.md` |
| Logging policy, PII rule | `docs/quality/observability-contract.md` |
| L10n copy and key naming | `docs/ui-ux/l10n-copy-contract.md` |
| System design, mock design, tokens, assets | `docs/system-design/MemoX Design System/**` |
| Agent task prompt template | `docs/agent/agent-task-template.md` |
| Pending schema migrations | `docs/database/schema-contract.md` §Pending schema changes |
| Sprint acceptance criteria | `docs/acceptance-criteria/**` |

## Docs subtree structure

```text
docs/
├── MANIFEST.md
├── README.md
├── business/            # business specs + index + glossary + overview
├── wireframes/          # 25 wireframes + index
├── database/            # schema, migration, storage boundaries
├── architecture/        # Clean Architecture contract
├── state/               # state management contract
├── ui-ux/               # UI tokens + l10n copy contract
├── system-design/       # MemoX Design System + mock design UI kit
├── decision-tables/     # event-condition-expected matrix
├── checklist/           # implementation, parity, scope and recursive review checklists
├── contracts/           # error, types, code style + usecase/repository contracts
├── testing/             # test strategy
├── quality/             # performance + observability contracts
├── agent/               # agent task template
└── acceptance-criteria/ # sprint/epic acceptance criteria
```

## Cross-reference integrity

Intentional external references:

- `CLAUDE.md` and `AGENTS.md` refer to project-root files, not files inside `docs/`.
- `lib/**`, `test/**`, `pubspec.yaml` references are repo-root paths.

All docs-internal `.md` references should resolve under `docs/**` unless explicitly marked as a project-root file or future placeholder.
