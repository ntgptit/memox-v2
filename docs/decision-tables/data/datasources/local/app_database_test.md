# Decision Tables: app_database_test

Test file: `test/data/datasources/local/app_database_test.dart`

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | new database starts empty and must create schema version one | in-memory database has no existing tables | app database opens for the first time | schema version one tables and indexes are created | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | opening a pre-release v2 database resets incompatible study tables | database file contains pre-release study rows and old table shape | app database migration runs | incompatible study tables are recreated without stale rows | C0+C1 |

## Decision table: onDelete

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | deck delete should cascade through flashcards and study progress rows | database contains a deck, flashcards for that deck, and progress records tied to those flashcards | deck row is deleted | related flashcards and progress records are removed by cascade | C0+C1 |
