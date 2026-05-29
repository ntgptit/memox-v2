---
last_updated: 2026-05-26
status: contract
---

# Test Strategy

How MemoX tests are organized, what each layer's tests must cover, and what tooling to use.

## Layer mapping

| Test layer | What it tests | What it mocks | Real dependencies |
| --- | --- | --- | --- |
| **Domain test** | Use case logic, value object invariants, pure functions (SRS box transition, strict matcher, board composer, swipe gesture commit) | Repositories (via mocktail) | None |
| **Repository test** | Drift queries, transactions, joins, migration steps | None | Real Drift in-memory DB (NativeDatabase.memory()) |
| **Notifier test** | Notifier state transitions, action handling, async cancellation | Use cases (via mocktail) | None |
| **Widget test** | One screen / widget rendering, user input, golden image where visual | Notifier (via overrideWith) | flutter_test framework |
| **Integration test** | Full user flow through real router + real notifiers + real repositories + in-memory DB | None | Real Drift in-memory, fake TTS engine, fake Drive |
| **Golden test** | Visual regression of theme-sensitive widgets | Notifier | flutter_test goldens |

## Folder layout

```
test/
├── domain/
│   ├── srs/
│   │   ├── box_transition_test.dart
│   │   └── box_intervals_test.dart
│   ├── usecases/
│   │   ├── folder/
│   │   ├── deck/
│   │   ├── flashcard/
│   │   ├── study/
│   │   ├── tag/
│   │   └── ...
│   └── study/
│       ├── strict_matcher_test.dart        # fill mode: trim + exact char-equality
│       ├── distractor_sampler_test.dart    # guess mode only (option pool from scope)
│       ├── match_board_composer_test.dart  # match mode: seeded shuffle, deterministic per session+board
│       ├── flow_validator_test.dart        # mode skip rules (fill on trivial fronts, match on < 5 cards)
│       └── swipe_to_grade_test.dart        # review mode: threshold + gesture commit
├── data/
│   ├── repositories/
│   │   ├── folder_repository_test.dart
│   │   ├── deck_repository_test.dart
│   │   └── ...
│   ├── datasources/
│   │   └── local/
│   │       └── migrations/
│   │           └── migration_v{N}_test.dart
│   └── sync/
│       └── drive_sync_test.dart
├── presentation/
│   ├── features/
│   │   ├── dashboard/
│   │   │   ├── dashboard_notifier_test.dart
│   │   │   └── dashboard_screen_test.dart
│   │   ├── library/
│   │   ├── flashcard_list/
│   │   ├── study/
│   │   └── settings/
│   └── widgets/
│       └── dialogs/
│           └── mx_dialog_resume_or_start_over_test.dart
├── integration/
│   ├── study_session_full_flow_test.dart
│   ├── import_csv_full_flow_test.dart
│   ├── restore_with_snapshot_test.dart
│   └── resume_session_test.dart
├── golden/
│   ├── dashboard_states_test.dart
│   ├── study_modes_test.dart
│   └── empty_states_test.dart
└── fixtures/
    ├── folder_tree_fixture.dart
    ├── library_basic_fixture.dart
    ├── srs_due_cards_fixture.dart
    ├── study_session_fixture.dart
    └── import_csv_fixture.dart
```

Test file naming: `{subject_under_test}_test.dart`. Subject = file being tested OR feature flow name for integration.

## Required tests by change type

| Code change | Mandatory tests |
| --- | --- |
| New use case | Domain test covering: happy path, every `Failure` returned, every `ValidationCode` checked. Reference at least one decision row ID in test name. |
| New repository method | Repository test covering: success, NotFound, transaction rollback on error, returned data shape. |
| Schema migration | Migration test: open DB at vN-1 with seeded data, run migration, assert vN schema + data preserved. |
| New notifier | Notifier test covering: initial state, each action, each AsyncValue transition (loading/data/error), cancellation. |
| New screen | Widget test covering: each documented state from wireframe (loading / populated / empty / error / selection / etc.). |
| New dialog or bottom-sheet | Widget test covering: open, primary action, secondary action, dismiss, default focus. |
| New decision table row | One test referencing the row ID. C0 rows MUST be tested; C1 rows SHOULD be tested. |
| SRS change | Domain test for transition table + integration test for end-to-end study flow. |
| Validation rule | Use case test for the rule + widget test for inline error display. |
| New route | Widget test for navigation in + integration test for back stack behavior. |
| User-facing string | l10n key present in ARB; widget test asserts key resolution, not literal string. |

## Tooling

- **Test framework:** `flutter_test` (built-in).
- **Mocking:** `mocktail` (not mockito). Reason: null-safety friendly, no codegen.
- **Golden image:** `flutter_test` goldens with `golden_toolkit` for device variants. Tolerance: pixel-perfect on platforms specified; cross-platform diffs allowed up to 0.01.
- **Coverage:** `coverage` package. Targets: domain ≥ 90%, data ≥ 80%, presentation ≥ 60%, integration ≥ critical-paths only.
- **In-memory DB:** `drift/native.dart` `NativeDatabase.memory()`.
- **Fake clock:** `clock` package with `withClock(...)` for time-dependent tests (SRS due, bury until, streak, session expiry).
- **Fake TTS:** `FakeTtsEngine` test double in `test/test_doubles/fake_tts_engine.dart` (no audio output, records calls).
- **Fake Drive:** `FakeDriveService` in `test/test_doubles/fake_drive_service.dart` (in-memory manifest + content map).

## Mock framework rule (mocktail)

```dart
// Good
class MockFolderRepository extends Mock implements FolderRepository {}

// Setup
when(() => folderRepo.findById(any())).thenAnswer((_) async => Right(folder));

// Verify
verify(() => folderRepo.findById('folder-1')).called(1);
```

NEVER mix `mockito` with `mocktail`. Repo standardizes on mocktail. If you find mockito in a test, migrate it in the same commit.

## Time and randomness

- Time: use `package:clock` everywhere. Production: `clock.now()`. Tests: `withClock(Clock.fixed(...))`.
- Random: inject a `Random` instance via constructor or provider. Tests use `Random(seed)` for deterministic distractor sampling (guess) and board shuffle (match). Production code seeds these from `sessionId` + index so resume produces the same layout.

## Naming convention

Test names follow `{decision_id_or_what}_{when_or_input}_{expected}`:

```dart
group('GradeAttemptUseCase', () {
  test('GA1: perfect on box 3 → box 4, due_at advances per interval table', () { ... });
  test('GA2: forgot on box 5 → box 1, lapse_count increments', () { ... });
  test('GA3: returns SessionNotFoundFailure when session deleted mid-attempt', () { ... });
});
```

Decision row IDs (e.g., `GA1`, `H5`, `TG9`) appear in test name AND in code comment if helpful.

## Forbidden patterns

- ❌ Network calls in tests (use fake).
- ❌ `Future.delayed` for "wait for something" — use `pumpAndSettle` or explicit completer.
- ❌ Real `DateTime.now()` in tests (use `clock`).
- ❌ Shared mutable test state across `group()` blocks without explicit `setUp`/`tearDown`.
- ❌ `expect(actual, isNotNull)` without checking content. Be specific.
- ❌ Skipped tests without GitHub issue link in `skip:` reason.
- ❌ Tests that pass when implementation is removed (no-op tests).
- ❌ Golden tests for purely textual UI (use widget assertions; goldens are for visual structure).

## Required patterns

- ✅ `setUp()` constructs fresh mocks per test.
- ✅ Failure-path tests assert specific `Failure` subtype, not "any error".
- ✅ Integration tests use real DB + faked external services (TTS, Drive, OAuth).
- ✅ Widget tests use `tester.pumpWidget(MaterialApp(home: ...))` shell that mirrors actual app theme.
- ✅ Golden tests pin device pixel ratio and theme.
- ✅ Long async test bodies broken into helper methods for readability.

## Integration test scope

Each integration test exercises a **single critical user flow** end-to-end:

| Test file | Flow |
| --- | --- |
| `study_session_full_flow_test.dart` | Dashboard → Today CTA → entry gate → 3 cards in mixed modes → result → Done returns to Dashboard |
| `import_csv_full_flow_test.dart` | Library FAB → new deck → import CSV with mix of valid/duplicate/invalid → preview → commit → flashcard list shows new cards |
| `restore_with_snapshot_test.dart` | Signed-in user with data → Restore from Drive (fingerprint mismatch) → warning dialog with 5s second-tap → snapshot succeeds → restore replaces data |
| `restore_snapshot_fails_test.dart` | Same as above but snapshot fails → restore aborts, local data unchanged |
| `resume_session_test.dart` | Start session, answer 5 of 20 → exit → Dashboard shows Resume → tap → continue from card 6 |
| `bulk_operations_test.dart` | Select 10 cards → bulk add tag → undo within 5s → tag removed |
| `folder_mode_lock_test.dart` | Create empty folder → add subfolder → attempt to add deck → blocked |

Integration tests do NOT mock notifiers or repositories. They use real implementations with `NativeDatabase.memory()` and fake external services.

## Test data via fixtures

Test data lives in `test/fixtures/*.dart` as code (NOT markdown). Examples:

```dart
// test/fixtures/folder_tree_fixture.dart
Future<void> seedFolderTreeFixture(AppDatabase db) async {
  await db.into(db.folders).insert(...); // Korean root
  await db.into(db.folders).insert(...); // TOPIK subfolder
  await db.into(db.decks).insert(...);   // Vocabulary deck
  // ...
}
```

Fixtures index will live at `docs/testing/fixtures-overview.md`. **Status: planned (Sprint 2)** — to be created when actual `test/fixtures/*.dart` files exist. Until then, refer to inline fixture functions in test files directly.

## Verification commands

```bash
# All tests
flutter test

# Single file
flutter test test/domain/usecases/study/grade_attempt_test.dart

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Goldens (update)
flutter test --update-goldens

# Integration only
flutter test test/integration
```

## Agent rule

- When implementing a behavior change: write the failing test FIRST referencing the decision row, then implement.
- When fixing a bug: add a regression test referencing the bug description, then fix.
- Coverage drop on a PR is a flag. If unavoidable, explain in report.
- A use case without at least one failure-path test is incomplete.

## Related

**Repo-level:**

- `CLAUDE.md` §Mandatory workflow step 9 (verification)
- `AGENTS.md` self-audit Q1
- `docs/checklist/implementation-checklist.md` test requirements

**Contracts:**

- `docs/contracts/error-contract.md` — every failure type has a corresponding failure-path test
- `docs/contracts/types-catalog.md` — enums under test
- `docs/contracts/code-style.md` — test file naming
- `docs/decision-tables/memox-core-decision-table.md` — row IDs referenced in test names

**Code paths:**

- `test/**`
- `test/test_doubles/**` (FakeTtsEngine, FakeDriveService)
- `test/fixtures/**`
