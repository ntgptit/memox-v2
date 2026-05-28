---
last_updated: 2026-05-26
applies_to: recursive code review tasks
---

# Recursive Agent Review

## Purpose

Use this when asking Claude Code to review implementation recursively against all contracts.

## Review inputs

- `CLAUDE.md`
- `AGENTS.md`
- `docs/business/**`
- `docs/database/**`
- `docs/architecture/**`
- `docs/ui-ux/**`
- `docs/state/**`
- `docs/decision-tables/**`
- Related source files
- Related tests

## Review order

1. Read repository contracts (`CLAUDE.md`, `AGENTS.md`, all docs).
2. Inspect affected source files.
3. Compare behavior with business docs.
4. Compare persistence with database docs.
5. Compare navigation with route constants and `docs/business/navigation/navigation-flow.md`.
6. Compare UI with design system and shared widgets.
7. Compare state management with Riverpod contract.
8. Compare tests with decision table.
9. Run verification.

## Checkpoints

### Business

- [ ] Behavior matches docs.
- [ ] No missing edge case.
- [ ] No invented workflow.
- [ ] Glossary terms used correctly (no confusion between entry_type/study_type/study_flow/study_mode).

### Route

- [ ] Constants used.
- [ ] Route registered correctly.
- [ ] Invalid params handled.
- [ ] Study exit protected.
- [ ] Push vs go matches doc.
- [ ] Deep link safety.

### Persistence

- [ ] DB source of truth.
- [ ] Transactions used per `docs/database/storage-boundaries.md`.
- [ ] Stream vs Future correct.
- [ ] Schema/migration/docs aligned.
- [ ] Generated files not manually edited.
- [ ] Foreign key cascade matches `docs/database/schema-contract.md`.

### SRS (if touched)

- [ ] Box transitions match table in `docs/business/srs/srs-review.md`.
- [ ] Interval table matches code or doc updated.
- [ ] Counters incremented correctly.
- [ ] Finalization in single transaction.

### Architecture

- [ ] Layer dependency valid.
- [ ] Shared UI reused.
- [ ] Feature boundaries respected.
- [ ] Domain has no Flutter/data imports.

### UI/state

- [ ] Shared widgets used.
- [ ] Tokens/l10n used.
- [ ] Loading/empty/error/saving states handled.
- [ ] Provider state does not replace persistence.
- [ ] Performance rules followed.
- [ ] Accessibility minimums met.

### Tests

- [ ] Decision table updated.
- [ ] Targeted tests updated.
- [ ] Test IDs match decision IDs where applicable.
- [ ] Guard/analyzer checked.

## Output format

```markdown
# Recursive Review Result

## Summary
<1-3 sentences>

## Files inspected
- <path>

## Mismatches

| Severity | Area | Finding | Required fix |
| --- | --- | --- | --- |
| critical/major/minor | business/route/persistence/architecture/ui/state/test | <what is wrong> | <how to fix> |

## Missing tests
- <decision ID>: <reason>

## Verification result
- build_runner: pass/fail/skipped
- guard: pass/fail/skipped
- analyzer: pass/fail/skipped
- tests: <count> passed, <count> failed

## Recommendation
PASS / PASS WITH WARNINGS / FAIL
```

## Severity definitions

| Severity | Meaning |
| --- | --- |
| critical | Breaks hard rule (CLAUDE.md), corrupts data, or causes crash |
| major | Violates contract, wrong behavior, missing test for changed branch |
| minor | Style, naming, missing doc update, suboptimal but functional |

## Agent rule

A review that finds no issues in a non-trivial change is suspicious. Re-check before reporting PASS without any findings.

## Related

**Repo-level:**

- `CLAUDE.md` — Doc-code parity rule
- `AGENTS.md` — agent responsibilities

**Companion checklist:**

- `docs/checklist/implementation-checklist.md` — implementation-time checklist

**Contracts referenced:**

- `docs/business/index.md` and downstream business docs
- `docs/database/schema-contract.md`, `docs/database/migration-contract.md`, `docs/database/storage-boundaries.md`
- `docs/architecture/clean-architecture-contract.md`
- `docs/state/state-management-contract.md`
- `docs/ui-ux/ui-ux-contract.md`
- `docs/decision-tables/memox-core-decision-table.md`

**Wireframes:**

- `docs/wireframes/index.md`
