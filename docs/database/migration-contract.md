---
last_updated: 2026-05-31
applies_to: Drift schema migrations
---

# Migration Contract

## When required

Migration is required when changing:

- Table name.
- Column name.
- Column type.
- Constraint.
- Enum values.
- Foreign key.
- Index.
- Required/default value.

## Migration shape

Each migration:

- Bumps `schemaVersion` in `AppDatabase`.
- Adds a step in `MigrationStrategy.onUpgrade`.
- Is irreversible only when justified and documented.
- Preserves data when possible.
- Uses `customStatement` with care; prefer Drift APIs.

## Required updates per migration

- Drift table definition.
- Migration implementation in `lib/data/datasources/local/migrations/**`.
- Generated Drift files via build runner.
- `docs/database/schema-contract.md` (schema_version header and table area if applicable).
- Related business docs (if behavior visible to user).
- Related decision table rows.
- Tests (migration test + affected feature tests).

## Forbidden in migration

- Dropping a column without rename-then-drop sequence across two versions.
- Renaming enum values without data backfill.
- Removing foreign keys.
- Changing timestamp unit.

## Verification

Run in order:

```text
dart run build_runner build --delete-conflicting-outputs
python code-verification-guard/guard/run.py check --project . --ruleset memox
flutter analyze
flutter test test/data/migrations/
flutter test <targeted feature tests>
```

## Migration test contract

For every new migration, add a test that:

- Opens database at previous schema version with sample data.
- Runs migration.
- Asserts data is preserved or transformed as expected.
- Asserts new constraints work.

## Agent rule

Do not claim migration complete without:

- Build runner success.
- Guard pass.
- Analyzer clean.
- Migration test added and passing.
- Targeted feature tests passing.

If any step is skipped, report it explicitly.

## Related

**Schema:**
- `docs/database/schema-contract.md` — full schema with 6 pending migrations enumerated

**Related contracts:**
- `docs/database/storage-boundaries.md` — non-Drift storage that does NOT migrate via Drift
- `docs/architecture/clean-architecture-contract.md`

**Business specs introducing migrations:**
- `docs/business/deck/deck-management.md` → `decks.target_language`
- `docs/business/study-actions/bury-suspend.md` → `flashcard_progress.buried_until`, `is_suspended`
- `docs/business/history/card-history.md` → `flashcard_progress.last_reset_at`, `study_attempts.box_before`, `box_after`
- `docs/wireframes/17-study-session-fill.md` + `docs/business/srs/srs-review.md` → enum/constraint changes for Fill attempt grading channels such as `study_attempts.result = 'recovered'`

**Decision table:**
- `docs/decision-tables/memox-core-decision-table.md` rows under "Migration" (ordering, idempotency, schemaVersion bump)

**Source files to inspect:**
- `lib/data/datasources/local/migrations/**`
- `lib/data/datasources/local/app_database.dart` (schemaVersion)
