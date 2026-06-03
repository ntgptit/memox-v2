---
last_updated: 2026-06-03
status: rejected / not applicable
applies_to: nullable deck parent migration for root-level decks
---

# Nullable Deck Parent Migration

> **Prompt 43A decision update:** this design is rejected / not applicable.
> Product ownership locked the invariant that Library root contains folders only,
> Folder Detail contains decks, and every deck belongs to exactly one folder.
> Do not implement this migration and do not make `decks.folder_id` nullable.

## A. Summary

Historical goal, now rejected: allow `decks.folder_id` to be nullable so decks
can live at Library root.

Root decks are Rejected / Out of Scope. Folder-owned decks keep the current
behavior: `folder_id` references an existing folder, folder mode rules still
apply, and folder deletion still cascades to child decks.

This document is historical context only. It does not implement schema,
generated Drift, domain, repository, UI, or test changes, and it is not
recommended implementation direction.

## B. Current blockers

- `decks.folder_id` is non-null in `lib/data/datasources/local/tables/decks_table.dart`.
- `DeckEntity.folderId` is non-null in `lib/domain/entities/deck_entity.dart`.
- Deck create/move/reorder/duplicate APIs require concrete folder ids.
- `LibraryOverviewReadModel` has a `folders` channel only; Library root lacks a
  root deck channel.
- Current tests cover folder-owned deck scope, not root deck scope.

## C. Proposed schema change

- Change `decks.folder_id` from `TEXT NOT NULL` to `TEXT NULL`.
- Keep the foreign key valid for non-null folder ids:
  `REFERENCES folders(id) ON DELETE CASCADE`.
- Folder delete behavior for non-null child decks remains cascade. Root decks
  are unaffected by folder deletion because their parent is null.
- Keep or recreate `idx_decks_folder_sort_order ON decks(folder_id, sort_order)`;
  SQLite can use this index for `folder_id IS NULL` root lookups.
- Preserve `sort_order` as the ordering column scoped by parent. Root decks use
  the `folder_id IS NULL` scope; folder-owned decks use `folder_id = ?`.
- Sibling uniqueness must be explicit for both scopes:
  - root decks where `folder_id IS NULL`
  - folder-owned decks where `folder_id = ?`

SQLite unique constraints treat `NULL` values as distinct. If uniqueness is
implemented as `(folder_id, normalized_name)` only, duplicate root deck names
would not be rejected. Prompt 43 should use one of:

- partial unique indexes, for example one unique index for
  `LOWER(name)` where `folder_id IS NULL` and another for
  `(folder_id, LOWER(name))` where `folder_id IS NOT NULL`; or
- a normalized parent-scope column/value object that maps root to a stable
  sentinel before uniqueness checks.

Current production table has no observed sibling-name unique constraint in the
Drift `Decks` table. Prompt 43 must decide whether uniqueness is enforced in
repository validation, database indexes, or both.

## D. Migration strategy

### Option 1 - historical recommendation, rejected

Use a schema-version bump plus a table-recreate migration:

1. Bump `AppDatabase.currentSchemaVersion`.
2. Define `Decks.folderId` as nullable in Drift.
3. Create a replacement decks table with nullable `folder_id`.
4. Copy all existing deck rows into the replacement table.
5. Preserve `id`, `folder_id`, `name`, `sort_order`, `created_at`,
   `updated_at`, `target_language` if already implemented by then, and any
   metadata columns added before this migration.
6. Recreate indexes and constraints, including root-safe sibling uniqueness if
   the project chooses database-backed uniqueness.
7. Drop the old table and rename the replacement table, or use the project
   `TableMigration` pattern if Drift can safely perform the same recreate.
8. Regenerate Drift files with build runner.
9. Add migration tests that open the previous schema, migrate, and assert data
   preservation plus new root-scope constraints.

This option matches the current project pattern for constraint/table changes in
`lib/data/datasources/local/migrations/app_database_migrations.dart`.

### Option 2 - project helper path

If Drift's current `TableMigration(database.decks)` path can safely alter the
nullability and preserve constraints/indexes, use that helper. The same
preservation, generated-file, docs, and tests requirements still apply.

### Chosen strategy

Choose Option 1 unless a small proof in Prompt 43 shows the existing Drift helper
handles nullable FK migration safely for this table. No existing data should be
lost, existing folder-owned decks remain folder-owned, and no root decks are
created during migration.

Rollback is backup/restore only unless the project adds an explicit rollback
migration strategy. Do not move, delete, or force-update `v1.0.0-rc.1`.

## E. Domain/API changes

- `DeckEntity.folderId` becomes nullable, or a `DeckParent` value object is
  introduced before replacing raw nullable ids across domain APIs.
- Repository create/move/reorder APIs accept nullable parent scope:
  `null` means Library root.
- Use cases validate root vs folder parent:
  - root parent: no folder existence check and no folder mode update
  - folder parent: folder must exist and allow decks
- Sibling uniqueness handles root separately from folder-owned decks.
- Duplicate preserves the requested parent. If no target is supplied in a future
  API, duplicating a root deck should remain root and duplicating a folder-owned
  deck should remain in that folder.
- Delete cascade for deck-owned data is unchanged by parent nullability.
- Moving from a folder to root must sync the old folder mode. Moving from root
  to a folder must update the new folder mode. Moving root to root must be a
  no-op or reorder-only path, not a folder mode operation.

## F. DAO/query/read-model changes

- Add DAO methods for root deck scope, e.g. `listRootDecks(query)` using
  `folder_id IS NULL`.
- Keep folder detail deck queries scoped to `folder_id = ?`; Folder Detail must
  exclude root decks.
- Add `nextSortOrder(String? folderId)` or equivalent parent-scope query.
- Add `reorderDecks(parentId: String?, orderedDeckIds: ...)` with `IS NULL`
  handling for root.
- Add read models for Library root decks or a unified root item model. Library
  root combines top-level folders and root decks without changing folder detail.
- Search remains scope-local. Library search may include root decks in the root
  context if the UI promotes root decks, but this is not Global Search.
- Folder subtree aggregate queries continue to include only decks with non-null
  `folder_id` in the relevant subtree.

## G. UI impact

- Library root displays folders and root decks after Prompt 44.
- Library root create deck action becomes available after the migration and root
  deck read model exist.
- Folder Detail remains the owner for folder-owned deck creation.
- Deck row actions can be reused at root where they do not require folder
  context. Actions that currently require `folderId` need nullable-parent
  handling first.
- Move to/from root must be explicitly designed in the destination picker.
- Empty state can mention creating a folder or deck only after root deck create
  is implemented.
- No UI redesign is required.

## H. Routing/study/import impact

- Flashcard List route already opens by `deckId`.
- Deck Import route already opens by `deckId`.
- Study Entry route can start deck study by `entryType=deck` and `entryRefId`
  set to `deckId`.
- Breadcrumbs and action contexts currently call folder breadcrumb helpers with
  `deck.folderId`; root decks need a root-safe breadcrumb.
- No tag-scoped study.
- No Global Search.
- No Dashboard-as-landing.

## I. Test plan

- Migration preserves existing decks.
- Migration keeps folder-owned deck relationships.
- Create root deck.
- Prevent duplicate root deck names.
- Allow the same deck name in different folders/root according to the selected
  sibling uniqueness rule.
- Library root renders root decks.
- Library root renders folders and root decks together.
- Folder Detail does not show root decks.
- Move deck to root if implemented.
- Move root deck to folder if implemented.
- Duplicate root deck if implemented.
- Delete root deck cascades flashcards/progress/sessions.
- Import root deck if route supports `deckId`.
- Study root deck if route supports `deckId`.
- Full regression tests for existing folder-owned decks.

## J. Historical rollout plan, rejected

- Prompt 43: implement nullable deck parent migration plus data/domain/repository
  tests. Rejected / Not Applicable.
- Prompt 44: implement Library root deck UI plus presentation tests. Rejected /
  Out of Scope.
- Prompt 45: implement root deck actions, move/import/study gaps, and any
  remaining presentation regression tests if not completed earlier. Rejected /
  Out of Scope.

## K. Risk assessment

- SQLite `NULL` unique behavior can allow duplicate root deck names.
- Generated Drift output will churn because `Deck.folderId` and companion types
  become nullable.
- Incorrect copy SQL can create orphan decks or lose sort/timestamp/language
  data.
- Folder delete cascade semantics can become ambiguous if root and folder-owned
  deck handling are mixed.
- Route code is mostly deck-id based, but breadcrumb/action contexts still
  assume a concrete folder id.
- UI and test fixtures may hide non-null folder assumptions.
- Root ordering can accidentally share or collide with folder ordering if DAO
  methods do not scope `sort_order` by nullable parent.

## L. Out of scope

- Global Search.
- Flashcard History.
- onboarding.
- tag-scoped study.
- engagement/reminders.
- Dashboard-as-landing.
- SRS changes.
- root-specific advanced sorting beyond the current ordering model.
