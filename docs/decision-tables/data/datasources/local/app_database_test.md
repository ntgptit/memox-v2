# Decision Tables: app_database_test

Test file: `test/data/datasources/local/app_database_test.dart`

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | new database starts empty and must create schema version one | in-memory database has no existing tables | app database opens for the first time | schema version one tables and indexes are created | C0+C1 |
| DT2 | TC-DECK-033 deck row references a folder id that does not exist | `decks.folder_id` points to `folder-missing` and all other deck fields are valid | raw deck insert is executed with foreign keys enabled | insert fails and no orphan deck can be stored | C0+C1 |
| DT3 | TC-DECK-034 deck row omits required primary id | valid parent folder exists and raw deck insert leaves out `id` | insert is executed against `decks` | insert fails because deck id is required | C0+C1 |
| DT4 | TC-DECK-035 deck row omits required name | valid parent folder exists and raw deck insert leaves out `name` | insert is executed against `decks` | insert fails because deck name is required | C0+C1 |
| DT5 | TC-DECK-036 deck row omits required sort order | valid parent folder exists and raw deck insert leaves out `sort_order` | insert is executed against `decks` | insert fails because deck sort order is required | C0+C1 |
| DT6 | TC-DECK-037 deck row omits required timestamps | valid parent folder exists and raw deck insert leaves out `created_at` and `updated_at` | insert is executed against `decks` | insert fails because both deck timestamps are required | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | opening a pre-release v2 database resets incompatible study tables | database file contains pre-release study rows and old table shape | app database migration runs | incompatible study tables are recreated without stale rows | C0+C1 |

## Decision table: onDelete

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | deck delete should cascade through flashcards and study progress rows | database contains a deck, flashcards for that deck, and progress records tied to those flashcards | deck row is deleted | related flashcards and progress records are removed by cascade | C0+C1 |
