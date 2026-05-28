---
last_updated: 2026-05-26
applies_to: layer boundaries, dependency rules, file organization
---

# Clean Architecture Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.


## Source files to inspect

- `AGENTS.md`
- `CLAUDE.md`
- `lib/app/**`
- `lib/core/**`
- `lib/domain/**`
- `lib/data/**`
- `lib/presentation/**`

## Layer responsibilities

| Layer | Responsibility |
| --- | --- |
| `app` | Bootstrap, DI, router, shell |
| `core` | Theme, errors, constants, utilities |
| `domain` | Entities, enums, use cases, repository contracts |
| `data` | Drift, DAO, repository implementations, mappers |
| `presentation` | Screens, widgets, viewmodels, UI state |
| `l10n` | User-facing strings |

## Dependency rules

Allowed:

```text
presentation -> domain
data -> domain
app -> any (wiring only)
core -> none (pure utilities)
```

Forbidden:

```text
domain -> data
domain -> presentation
domain -> app
presentation -> data (except via DI)
presentation -> DAO/Drift directly
data -> presentation
feature A -> feature B's private UI
```

## Layer detail

### Domain

- Entities use `freezed`.
- Repository contracts are abstract classes.
- Use cases are single-purpose classes.
- Target async contract returns `Future<Either<Failure, T>>` or `Stream<T>`. If `fpdart` is not adopted yet, keep the existing result/failure pattern until the approved migration is performed.
- No Flutter imports (except for `dart:async`).
- No data layer imports.

### Data

- Repository impls implement domain contracts.
- DAOs are Drift-generated.
- Mappers convert Drift rows to/from domain entities.
- Repository wraps DAO calls in `safeExecute` to produce the target result type (`Either` after the approved fpdart migration, or the current result/failure wrapper before it).
- Imports from domain only (entities, contracts, failures).

### Presentation

- Screens are widgets that compose shared `Mx*` widgets.
- ViewModels/Notifiers use Riverpod annotation.
- Notifiers call use cases, not repositories directly.
- Widget-level state limited to ephemeral UI state (e.g., `TextEditingController`).
- No Drift, no DAO, no SQL.

### App

- Wires DI providers.
- Configures router.
- Configures app shell.
- May import any layer for wiring purposes only.

## Shared UI rule

Reusable UI belongs in `lib/presentation/shared/**`.

Do not duplicate shared UI patterns inside feature folders. When a pattern appears in 2+ features, promote it.

## Feature isolation

```text
lib/presentation/features/<feature>/
  routes/        - GoRoute declarations for this feature
  screens/       - Screen widgets
  widgets/       - Feature-local widgets
  viewmodels/    - State holders
  providers/     - Riverpod providers for this feature
```

Other features may import `routes/` for navigation only. Other features must NOT import widgets/viewmodels/providers from inside another feature.

## Generated file rule

Do not manually edit:

- `*.g.dart`
- `*.freezed.dart`
- `lib/l10n/generated/**`
- Drift generated database files

Regenerate via:

```text
dart run build_runner build --delete-conflicting-outputs
```

## Error handling rule

- Domain layer defines `Failure` types.
- Repository wraps exceptions into `Failure` via `safeExecute`.
- Use case returns `Either<Failure, T>`.
- Notifier maps `Failure` to UI state.
- Widget renders error state from UI state, not from raw exception.

## Anti-patterns observed (or commonly attempted)

- ❌ Calling DAO from a notifier.
- ❌ Building business logic inside `onPressed`.
- ❌ Throwing in use case instead of returning Either.
- ❌ Storing form draft in provider memory across app restarts (use database draft if persistence needed).
- ❌ Direct `Navigator.push` (use `context.push` from GoRouter).
- ❌ Using `setState` for anything other than ephemeral UI state.
- ❌ Importing `package:drift/drift.dart` outside `lib/data/**`.

## Agent rule

Prefer minimal structurally correct change over broad refactor.

When unsure if something belongs to domain or data, ask: does it depend on Drift or external infrastructure? If yes, data. If no, domain.

## Related

**Repo-level:**
- `CLAUDE.md` — Doc-code parity rule
- `AGENTS.md` — agent responsibilities

**Database / state / UI:**
- `docs/database/schema-contract.md`
- `docs/state/state-management-contract.md`
- `docs/ui-ux/ui-ux-contract.md`

**Business specs:**
- All `../business/**` follow this contract for use case / repository orchestration
- Each business spec lists `Source files to inspect` mapping to the layers documented here

**Checklists:**
- `docs/checklist/implementation-checklist.md` — architecture checks
- `docs/checklist/recursive-agent-review.md` — boundary review

**Source files to inspect:**
- `lib/domain/**` (entities, repositories interfaces, use cases)
- `lib/data/**` (repositories implementations, DAO, mappers)
- `lib/presentation/**` (features, widgets, notifiers)
- `lib/core/**` (shared infrastructure)
