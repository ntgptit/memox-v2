---
last_updated: 2026-06-03
status: rejected / not applicable
applies_to: rejected nullable deck parent migration proposal
---

# Nullable Deck Parent Migration

> **Rejected by product decision. Do not implement this migration.**
>
> MemoX hierarchy is locked: Library root contains folders only, Folder Detail
> contains decks, and every deck belongs to exactly one folder. Therefore
> `decks.folder_id` must remain `NOT NULL`, `DeckEntity.folderId` must remain
> non-null, and deck create/move/reorder/duplicate APIs must continue requiring a
> concrete folder id.

## A. Decision

Root-level decks are **Rejected / Out of Scope**.

The previously proposed nullable deck parent direction is **Rejected / Not
Applicable**. This file is kept only as a decision record so future agents do not
revive the same design.

## B. Correct invariant

Current and intended product model:

- Library root contains folders.
- Folder Detail contains decks.
- Decks are created inside a folder.
- Every deck belongs to exactly one folder.
- Moving a deck means moving it from one concrete folder to another concrete
  folder.
- Deleting a folder continues to own the behavior for its child decks according
  to the current schema/business rules.

Current and intended data model:

- `decks.folder_id` remains `TEXT NOT NULL`.
- `decks.folder_id` remains a foreign key to `folders.id`.
- `DeckEntity.folderId` remains non-null.
- Repository and use-case APIs continue to require concrete folder ids for deck
  create, move, reorder, duplicate, and folder-scoped listing.

## C. Rejected proposal, kept as historical context

Prompt 42B explored this rejected direction:

- make `decks.folder_id` nullable
- represent root decks with `folder_id = null`
- add root-scope DAO queries using `folder_id IS NULL`
- update domain APIs to accept nullable parent ids
- add root deck UI at Library root
- handle SQLite `NULL` uniqueness with partial unique indexes or repository
  validation

Do **not** implement those items unless the product owner explicitly reverses the
folder-owned deck invariant in a future decision record.

## D. Why the nullable proposal was rejected

The nullable proposal conflicts with the product hierarchy. It also creates
unnecessary complexity:

- Library root would need to mix folders and decks.
- Deck row actions would need root-specific context handling.
- Move/reorder rules would need null-parent branches.
- Breadcrumbs and action contexts would need root-safe special cases.
- SQLite `NULL` uniqueness would require extra handling.
- Future agents could accidentally implement a data model that contradicts the
  product owner decision.

The simpler and correct model is to keep deck ownership folder-bound.

## E. Future reversal process

Only reopen this direction if a future product decision explicitly says all of
the following:

1. Library root should contain decks as well as folders.
2. Decks may exist without a parent folder.
3. `decks.folder_id` may become nullable.
4. Root deck UI, migration, repository, tests, and docs are approved as one
   dedicated scope.

Until then, treat this file as a rejected decision record.

## F. Related docs

- `docs/business/deck/deck-management.md`
- `docs/database/schema-contract.md`
- `docs/contracts/repository-contracts/deck-repository.md`
- `docs/contracts/usecase-contracts/deck.md`
- `docs/wireframes/02-library.md`
- `docs/wireframes/05-folder-detail.md`
- `docs/checklist/v1-post-rc-backlog.md`
- `docs/checklist/v1-release-readiness-cutline.md`
- `docs/system-design/mock-design-doc-mapping.md`

## G. Out of scope

- Root-level decks.
- Nullable deck parent migration.
- Root deck Library UI.
- Root deck move/reorder/action flows.
- Global Search.
- Flashcard History.
- Onboarding.
- Tag-scoped study.
- Engagement/reminders.
- Dashboard-as-landing.
- SRS changes.
