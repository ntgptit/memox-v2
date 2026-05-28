# AGENTS.md - MemoX

Agent-facing entry point. Complements `CLAUDE.md` — does NOT duplicate it.

> **Read order:** `CLAUDE.md` first, then this file.

## Scope of this file

`CLAUDE.md` defines: required reading by task, doc-code parity rule, pre-commit parity check, mandatory workflow, hard rules.

This file defines: agent **responsibilities** (what an agent must DO at each phase), **reporting** (what report format looks like), **conflict resolution**, **approval gates**.

If a topic appears in both files, **`CLAUDE.md` wins**.

## Identity

MemoX is local-first Flutter flashcard app. Every change must preserve:

- Local-first (core works offline)
- Clean Architecture layer boundaries
- Database = source of truth for data; `docs/` = source of truth for behavior/contract
- MemoX Design System

## 🔴 Doc-code parity (one paragraph; full rule in CLAUDE.md)

Code and docs ship in the SAME commit when behavior, schema, route, rule, or contract changes. Drift accumulates if even one commit ignores this. The 8-step pre-commit check, the trigger map, and the drift detection workflow live in `CLAUDE.md` §Doc-code parity rule. **Read it. Apply it. Don't redefine it here.**

## Agent responsibilities per phase

| Phase | Duty |
| --- | --- |
| Before | Read `CLAUDE.md`, then the docs listed in `CLAUDE.md` §Required reading by task. Do drift check. |
| During | Follow contracts; don't invent behavior; update docs alongside code. |
| After | Run `CLAUDE.md` §Pre-commit parity check. Run verification commands. File report (see below). |

## Drift detection

When you start a task, verify that the docs you read are consistent with the code in your scope. If not:

1. **Stop the task.**
2. Report with format below.
3. Wait for direction.

```
DRIFT DETECTED:
- Code file: lib/...
- Doc file: docs/...
- Mismatch: {specific, with line numbers}
- Direction: doc ahead of code / code ahead of doc / both diverged
- Suggested fix: {update doc | update code | user decides}
```

Drift is legacy debt, not your bug. Reporting it is a positive contribution.

## Reporting format

Every completed task uses the template in `docs/checklist/implementation-checklist.md` §Final report template. The template mandates these sections (any task without them is rejected):

- Summary
- Changed code files
- **Changed doc files** — if empty, requires explicit "no docs needed because: ..."
- **Doc-code parity check** — 8 ticks from CLAUDE.md
- **Drift detected during task** — none, or details
- Business / Route / Persistence / UI impact
- Decision table & test impact
- Verification result (build_runner, analyzer, tests, guard)
- Skipped checks or risks

## Conflict resolution

When docs and code disagree:

1. Never silently pick one side.
2. If docs are explicit and code looks wrong → docs win, update code.
3. If code is explicit and docs look stale → confirm before changing either; docs may have been updated in a direction you haven't seen.
4. If both ambiguous → stop and ask.

Document the resolution in the report regardless.

## Approval needed (stop and ask)

| Change | Reason |
| --- | --- |
| Schema change not yet in `docs/database/migration-contract.md` | Migrations cascade; must be coordinated |
| New dependency in `pubspec.yaml` | Affects bundle, license, security |
| New top-level route | Affects deep links + navigation flow |
| SRS algorithm change (intervals, transitions, box count) | Touches every existing user's data |
| Design token change (color, spacing, font) | Cascades across all screens |
| Cross-feature refactor (>2 feature folders) | Higher coordination cost |
| Rename of any term in `docs/business/glossary.md` | Cascades into many files |

## Forbidden actions

- Inventing a workflow not in business docs.
- Skipping verification commands.
- Skipping the pre-commit parity check.
- Editing generated files (`*.g.dart`, `*.freezed.dart`, l10n generated).
- Bypassing layer boundaries (presentation → domain → data only).
- Hardcoding strings, styles, routes, durations.
- Storing persistent data only in provider memory.
- Marking task done with empty "Changed doc files" and no explicit reason.
- Leaving references to old term/route/field after a rename.
- Trusting docs blindly when code suggests drift.

## Self-audit before declaring done

For every "no" below, the task is NOT done — go back and fix:

1. Verification commands run and passed?
2. Pre-commit parity check (CLAUDE.md §8-step) all green?
3. Every new route in `docs/business/navigation/navigation-flow.md`?
4. Every schema change in `docs/database/schema-contract.md` AND `docs/database/migration-contract.md`?
5. Every new user-facing string in ARB AND referenced in wireframe?
6. Every rename grepped (`grep -rn "{old}" docs/`) and confirmed clean?
7. Every new decision-table-worthy branch added as a row with a test?
8. Report contains "Changed doc files" with explicit content?

## Where to look for what

This file delegates the catalog of "where to look for what" to `CLAUDE.md` §Required reading by task. Do not duplicate that mapping here.
