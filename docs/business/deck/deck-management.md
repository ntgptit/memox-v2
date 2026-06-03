---
last_updated: 2026-06-02
applies_to: deck entity and deck management feature
---

# Deck Management

> **Status: Partial Target — Migration Required for `target_language`; root-level decks Rejected / Out of Scope.** Folder-owned deck CRUD itself is implementable today. However, the `target_language` field (referenced throughout this spec) is a pending column from `docs/database/schema-contract.md` §Pending schema changes:
>
> - `decks.target_language TEXT NOT NULL DEFAULT 'korean'`
>
> Migration backfills existing decks to `'korean'`; user adjusts per-deck after. Blocks (until migration): TTS gating in study modes 13-17, settings audio-speech screen, target-language picker in deck create/edit flows.
>
> Prompt 43A supersedes the Prompt 42/42B root-level deck direction. Product
> ownership rejected root-level decks: every deck must belong to exactly one
> folder, `decks.folder_id` stays non-null, and deck create/move/reorder/duplicate
> APIs remain folder-bound.
>
> The Prompt 42B nullable deck parent design at
> `docs/database/migrations/nullable-deck-parent-migration.md` is retained only as
> a rejected historical note. It must not be used as recommended implementation
> direction.

## Source files to inspect

- `lib/presentation/features/folders/**`
- `lib/presentation/features/flashcards/**`
- `lib/domain/**deck**`
- `lib/data/**deck**`
- `lib/data/datasources/local/tables/decks_table.dart`

## Data

Decks are stored in `decks`.

Important fields:

- `id`
- `folder_id`
- `name`
- `target_language` (TEXT, see below)
- `sort_order`
- `created_at`
- `updated_at`

## Target language

Every deck has a target language indicating what language the FRONT side of its cards is in. This drives TTS behavior and sets explicit expectations about content type.

| Value | Meaning | TTS supported now? |
| --- | --- | --- |
| `korean` | Korean (ko-KR) front content | Yes |
| `english` | English (en-US) front content | Yes |
| `unsupported` | Any other language; TTS disabled for this deck | No |

When user creates or edits a deck, they MUST pick a target language. Default: `korean`.

Rationale: Without explicit language tagging, TTS would attempt to speak Vietnamese/Japanese/etc. with an English voice → wrong pronunciation. Forcing a per-deck declaration prevents silent failure.

### Effects of target language

| Surface | Behavior |
| --- | --- |
| TTS speak action on study session | Enabled only when `targetLanguage` is `korean` or `english`. Disabled (greyed out) for `unsupported`. |
| TTS auto-play | Skipped silently when deck's `targetLanguage = unsupported`. |
| Deck create/edit form | Required field (defaults to `korean`). |
| TTS settings screen | Voice/language picker remains global; future per-deck override planned. |

### Migration

Existing decks (pre-feature) get `target_language = korean` as default during migration. Users can edit each deck to set the correct value.

## Rules

- A deck belongs to exactly one folder.
- Root-level decks are Rejected / Out of Scope.
- `decks.folder_id` must not be made nullable under the rejected root-deck
  direction.
- Deck name is required after trim.
- Deck name max length follows schema constraint.
- Deck target language is required (default `korean`).
- Deck can be created only in folder mode `unlocked` or `decks`.
- Creating deck sets parent folder mode to `decks`.
- Empty deck cannot start study.
- Deleting deck deletes related flashcards and local dependent data through persistence rules.
- Reorder updates `sort_order` only.
- Changing `target_language` does NOT modify flashcards. It only updates TTS behavior going forward.

## Screen behavior

Deck appears through Library/Folder/Flashcard list flows.

Deck actions may include:

- Open flashcard list.
- Create flashcard.
- Import flashcards.
- Start study.
- Rename deck.
- Delete deck.
- Reorder deck inside folder.

## Performance

- Decks list >50 items in a folder: use `ListView.builder`.
- Card count badge: stream from database.
- Due count badge: stream from database, not recomputed in widget.

## Agent rule

Do not add a separate deck detail route unless route contract and navigation docs are updated.

## Related

**Wireframes:**

- `docs/wireframes/02-library.md` — Current V1 Library does not render root-level decks; top-level deck rows are Rejected / Out of Scope
- `docs/wireframes/05-folder-detail.md` — decks listed inside a folder (decks mode)
- `docs/wireframes/06-flashcard-list.md` — deck content view + deck-level CTAs
- `docs/wireframes/10-deck-import.md` — import flow into a deck
- `docs/wireframes/25-shared-bottom-sheets.md` §deck-create, §deck-picker

**Schema:**

- `docs/database/schema-contract.md` → `decks` table (`id`, `folder_id`, `name`, `target_language`, `sort_order`, timestamps). `target_language` is one of the 6 pending migrations.
- `docs/database/migrations/nullable-deck-parent-migration.md` → rejected Prompt
  42B design; nullable `decks.folder_id` is Not Applicable while the folder-owned
  deck invariant holds.

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "Deck management" and "TTS gating" (target_language influences TTS UI in study modes)

**Glossary terms:**

- `docs/business/glossary.md` → `target_language`, `korean`, `english`, `unsupported`

**Related business specs:**

- `docs/business/folder/folder-management.md` — folder mode lock affects whether deck can be created here
- `docs/business/flashcard/flashcard-management.md` — deck owns flashcards
- `docs/business/tts/tts-settings.md` — `target_language` gates TTS at deck level
- `docs/business/export/export.md` — deck is the export unit
- `docs/business/navigation/navigation-flow.md` — `/library/deck/:deckId/...` routes

**Source files to inspect:**

- `lib/data/datasources/local/tables/decks_table.dart`
- `lib/domain/entities/deck.dart`
- `lib/domain/repositories/deck_repository.dart`
- `lib/domain/usecases/deck/**`
- `lib/presentation/features/deck/**`
