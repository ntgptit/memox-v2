# Decision Tables: app_database_migration_test

Test file: `test/data/datasources/local/app_database_migration_test.dart`

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | database opens a pre-release schema that needs v2 study-table repair | sqlite file contains the older study schema shape before migration | app database opens and migration runs to the current schema | repaired study tables exist with the expected columns and constraints | C0+C1 |
