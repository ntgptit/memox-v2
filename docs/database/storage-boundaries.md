---
last_updated: 2026-05-26
applies_to: persistence boundary, data access patterns
---

# Storage Boundaries

## Purpose

Define where data belongs and how layers access it.

## Source of truth

Local Drift database is the source of truth for persistent app data.

Provider state is NOT persistent storage.

## Correct flow

```text
Screen -> ViewModel/Notifier -> UseCase -> Repository -> DAO/Drift -> Database
```

## Forbidden flow

```text
Screen -> DAO
Widget -> AppDatabase
Presentation -> Drift table
Domain -> Drift
Provider memory -> persistent source of truth
```

## Read patterns

When reading from database, choose the right pattern.

| Use case | Pattern | API |
| --- | --- | --- |
| List screen, reactive | Stream | `watchAll`, `watchByX` |
| Detail screen, reactive | Stream | `watchById` |
| Form initial load (one-shot) | Future | `getById` |
| Search results | Stream (debounced) | `watchSearch` |
| Count badge | Stream | `watchCount` |
| Background validation | Future | `exists`, `getById` |

Rule: prefer Stream for anything user-visible. Use Future only for one-shot reads.

## Write patterns

| Use case | API | Wraps in transaction |
| --- | --- | --- |
| Single row insert | `repository.add` | No (single op) |
| Single row update | `repository.update` | No |
| Single row delete | `repository.delete` | If cascade cleanup needed |
| Multi-row ops | `repository.bulkX` | Yes |
| Cross-table ops | UseCase orchestrates | Yes |

## Transaction required

Use transaction for:

- Creating subfolder and updating parent mode.
- Creating deck and updating parent mode.
- Deleting folder/deck/flashcard with cleanup.
- Importing flashcards.
- Creating session and session items.
- Recording attempt plus related state changes.
- Finalizing session and updating progress.

## Refresh rule

After mutation:

- Repository emits via watched streams (automatic via Drift).
- For non-streamed reads, invalidate related providers.
- Update content revision mechanism when used.
- Let UI reload from database.
- Do not manually patch UI list as the only source of truth.

## Revision mechanism

When a feature needs to invalidate a non-Drift cache (e.g., aggregated dashboard counts), use a content revision counter:

- Provider exposes `int revision`.
- Mutation use case increments revision.
- Dependent provider watches revision and refetches.

Do not use revision as a substitute for Drift streams in normal list/detail screens.

## DAO access rule

| Layer | Can access DAO? |
| --- | --- |
| Presentation (widget, viewmodel, notifier) | No |
| Domain (use case, repository contract) | No |
| Data (repository impl) | Yes |
| Data (DAO) | Yes (it is the DAO) |
| Data (mapper) | No (works on Drift rows passed to it) |

## Migration

See `docs/database/migration-contract.md` for schema change procedure.

## Agent rule

Persistence logic belongs in data/repository/use case flow, not in widgets or notifiers.

When in doubt about whether to use Stream or Future: use Stream.

## Related

**Schema:**

- `docs/database/schema-contract.md` — what belongs in Drift

**Related contracts:**

- `docs/database/migration-contract.md`
- `docs/state/state-management-contract.md` — provider memory is NOT a persistence boundary

**Business specs touching non-Drift storage:**

- `docs/business/engagement/dashboard-engagement.md` → daily goal, streak, reminder time in SharedPreferences
- `docs/business/tts/tts-settings.md` → per-language TTS settings in SharedPreferences
- `docs/business/search/global-search.md` → recent searches in SharedPreferences
- `docs/business/account-sync/account-sync.md` → Drive manifest (remote), account-scoped DB file path
- `docs/business/flashcard/flashcard-management.md` → "Save and add another" toggle (session memory, NOT persisted)

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "Storage boundaries" (account-scoped DB switching, prefs key prefixes)
