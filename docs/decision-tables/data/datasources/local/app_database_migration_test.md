# Decision Tables: app_database_migration_test

Test file: `test/data/datasources/local/app_database_migration_test.dart`

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | database opens a pre-release schema that needs v2 study-table repair | sqlite file contains the older study schema shape before migration | app database opens and migration runs to the current schema | repaired study tables exist with the expected columns and constraints | C0+C1 |
| DT2 | database opens schema v4 where `flashcard_progress.last_result` does not allow `initial_passed` | sqlite file contains the v4 progress constraint, a legacy New Study `perfect` progress row, and a SRS Review `perfect` progress row | app database opens and migration runs to schema v5 | legacy New Study progress is converted to `initial_passed`, SRS Review progress keeps `perfect`, and updating `last_result` to `initial_passed` succeeds under the migrated constraint | C0+C1 |
| DT3 | database opens with a flashcard that has no progress row | sqlite file contains a valid flashcard row without a matching `flashcard_progress` row | app database opens and migration runs to schema v6 | missing progress is repaired with default box 1, zero counters, null SRS result, null due date, and timestamps copied from the flashcard | C0+C1 |
