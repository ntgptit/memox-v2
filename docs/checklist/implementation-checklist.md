---
last_updated: 2026-05-26
applies_to: every implementation task
---

# Implementation Checklist

Use before reporting a task as complete.

## Read

- [ ] `CLAUDE.md` (đặc biệt section "🔴 Doc-code parity rule")
- [ ] `AGENTS.md`
- [ ] `docs/business/glossary.md`
- [ ] Related business doc(s)
- [ ] Related wireframe(s) in `docs/wireframes/`
- [ ] Related use case contract in `docs/contracts/usecase-contracts/`
- [ ] Related repository contract in `docs/contracts/repository-contracts/`
- [ ] `docs/contracts/error-contract.md` for Failure types involved
- [ ] `docs/contracts/types-catalog.md` for enums/value objects involved
- [ ] `docs/contracts/code-style.md` if touching new file/class types
- [ ] `docs/testing/test-strategy.md` for required tests
- [ ] `docs/quality/performance-contract.md` if perf-sensitive
- [ ] `docs/quality/observability-contract.md` if adding log sites
- [ ] `docs/ui-ux/l10n-copy-contract.md` if adding user-facing strings
- [ ] Related database doc(s)
- [ ] Related architecture/UI/state doc(s)
- [ ] Related decision table rows
- [ ] Related source files (from "Source files to inspect" sections)

## Drift detection (do FIRST after reading)

- [ ] Code and related docs are consistent.
- [ ] No legacy term/route/field refs left over from previous renames.
- [ ] If drift detected → reported to user and waited for direction.

## Doc-code parity check (8-step, from `CLAUDE.md`)

Run before declaring task done. Tick each:

- [ ] **(1) User-visible behavior change?** If yes → business/wireframe doc updated.
- [ ] **(2) Schema/persistence change?** If yes → `docs/database/**` updated.
- [ ] **(3) Route/navigation change?** If yes → `docs/business/navigation/navigation-flow.md` + route constants updated.
- [ ] **(4) SRS/study mode/flow change?** If yes → `docs/business/srs/srs-review.md` + `docs/business/study/study-flow.md` + decision table updated.
- [ ] **(5) Rule/edge case/validation change?** If yes → relevant doc updated. No silent rule changes.
- [ ] **(6) New testable branch?** If yes → decision table row added + test written.
- [ ] **(7) Status transition?** (Specified ↔ implemented ↔ not specified) → `docs/business/system/overview.md` updated.
- [ ] **(8) Refs to old term/route/field after rename?** Run `grep -rn "{old}" docs/` and confirm zero results.

## Business

- [ ] Behavior matches business contract.
- [ ] No invented product behavior.
- [ ] Edge cases handled (loading, empty, error, validation, retry).
- [ ] Decision table updated when behavior changes.

## Navigation

- [ ] Uses `RouteNames`/`RoutePaths`.
- [ ] No hardcoded paths.
- [ ] Push vs go matches `docs/business/navigation/navigation-flow.md` table.
- [ ] Invalid params handled.
- [ ] Protected study exit checked.
- [ ] Shell navigation visibility checked.
- [ ] Deep link rules respected.

## Persistence

- [ ] Database remains source of truth.
- [ ] Multi-table writes use transaction.
- [ ] Stream vs Future chosen correctly (see `docs/database/storage-boundaries.md`).
- [ ] No persistence in widgets.
- [ ] Schema change includes migration.
- [ ] Migration test added.
- [ ] Generated files created by build runner only.

## Architecture

- [ ] Domain does not import data/presentation.
- [ ] Presentation does not import Drift/DAO directly.
- [ ] Feature does not import another feature's private UI.
- [ ] Shared patterns promoted to shared layer.
- [ ] Use case orchestrates multi-step logic, not notifier or widget.

## UI

- [ ] Uses shared `Mx*` widgets where applicable.
- [ ] Uses tokens/theme (no raw colors/styles/durations).
- [ ] Uses ARB localization (no hardcoded strings).
- [ ] Loading/empty/error/saving states exist.
- [ ] Destructive actions confirm.
- [ ] No narrow-screen overflow.
- [ ] Touch target ≥ 48dp.
- [ ] Performance rules followed (list builder, debounce).

## State

- [ ] Riverpod annotation used.
- [ ] `ref.watch` for render state.
- [ ] `ref.read` in callbacks.
- [ ] No persistent state only in provider memory.
- [ ] Mutation refreshes related providers/revision.
- [ ] AsyncValue used for async state.
- [ ] Notifier does not call `context.push` directly.

## Tests

- [ ] Test added/updated for each decision table row touched.
- [ ] Test names reference decision ID where applicable.
- [ ] Widget tests cover loading/empty/error/saving states.
- [ ] Migration test added for schema changes.

## Verification

Run relevant commands:

```text
dart run build_runner build --delete-conflicting-outputs
python code-verification-guard/guard/run.py check --project .
flutter analyze
flutter test <targeted tests>
```

Analyze / dart-fix pairing:

- If `flutter analyze` reports diagnostics that are safely fixable, run `dart fix --apply`, inspect the diff, then rerun `flutter analyze`.
- Do not run `dart fix --apply` as a standalone cleanup step without the follow-up analyzer pass.
- If a fixable analyzer diagnostic is not applied, report the reason under "Skipped checks or risks".

All must pass. If any is skipped, justify in final report.

## Final report template

```markdown
## Summary
<1-3 sentences>

## Changed code files
- <path>: <reason>

## Changed doc files
- <path>: <reason>

If empty: "No doc changes needed because: <explicit reason, e.g., 'internal refactor with no behavior or contract change'>".

NEVER leave this section silently empty.

## Doc-code parity check
- (1) User-visible behavior: ✓ updated <files> | ✗ N/A because <reason>
- (2) Schema/persistence: ✓ updated <files> | ✗ N/A because <reason>
- (3) Route/navigation: ✓ updated <files> | ✗ N/A because <reason>
- (4) SRS/study: ✓ updated <files> | ✗ N/A because <reason>
- (5) Rule/edge case: ✓ updated <files> | ✗ N/A because <reason>
- (6) New testable branch: ✓ decision table row <ID> + test added | ✗ N/A because <reason>
- (7) Status transition: ✓ updated overview.md | ✗ N/A because <reason>
- (8) Stale refs after rename: ✓ grep clean | ✗ N/A because no rename in this task

## Drift detected during task
<None | description of legacy drift found, whether fixed or deferred>

## Business impact
<which business areas changed>

## Route impact
<which routes added/changed/removed>

## Persistence impact
<schema/migration/transaction changes>

## UI impact
<which screens/widgets changed>

## Decision table/test impact
<which IDs touched, which tests added/updated>

## Verification result
- build_runner: pass/fail/skipped
- guard: pass/fail/skipped
- analyzer: pass/fail/skipped
- tests: <count> passed, <count> failed

## Skipped checks or risks
<anything not done, with reason>
```

A report missing "Changed doc files" section or its explicit-empty justification is incomplete and will be rejected.

## Related

**Repo-level:**

- `CLAUDE.md` — Doc-code parity rule + 8-step pre-commit check
- `AGENTS.md` — reporting format requirement

**Companion checklist:**

- `docs/checklist/recursive-agent-review.md` — review-time checklist

**Contracts referenced by this checklist:**

- `docs/business/index.md`, `docs/business/glossary.md`, `docs/business/system/overview.md`
- `docs/database/schema-contract.md`, `docs/database/migration-contract.md`, `docs/database/storage-boundaries.md`
- `docs/architecture/clean-architecture-contract.md`
- `docs/state/state-management-contract.md`
- `docs/ui-ux/ui-ux-contract.md`
- `docs/decision-tables/memox-core-decision-table.md`

**Wireframes:**

- `docs/wireframes/index.md`
