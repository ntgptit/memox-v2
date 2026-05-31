---
last_updated: 2026-05-26
status: contract
---

# Error Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

Single source of truth for: failure type taxonomy, error propagation rules, UI mapping, recovery actions, and user-facing message conventions. Every layer of MemoX uses these failure types — no ad-hoc exception subclasses.

## Principles

1. **Failures are values, not thrown exceptions.** Target architecture uses `Either<Failure, T>` (fpdart) for domain/data results. If the project has not adopted `fpdart` yet, use the existing repository error/result pattern and do not add the dependency in a normal feature task. Throwing is reserved for programmer errors (asserts, contract violations) and is never caught at application level.
2. **No raw exceptions in UI.** Presentation never sees `DriftWrappedException`, `SocketException`, `FormatException`. All low-level exceptions are mapped to a `Failure` at the data layer boundary.
3. **Failures are typed, not stringly.** Every recoverable error case has a named failure with structured fields, never `Failure(message: 'something went wrong')`.
4. **Keep user input on save failure.** A `Failure` from a save use case does NOT reset form state.
5. **Recovery is documented.** Each failure type below has a defined UI behavior; agents do not invent new recovery flows.

## Failure type hierarchy

All failures extend the sealed `Failure` base in `lib/core/error/failure.dart` (freezed sealed class). The taxonomy is **closed**: adding a new top-level failure type requires updating this contract AND every UI mapper.

### Sealed Failure (top-level)

| Failure type | When raised | UI mapping | Recovery |
| --- | --- | --- | --- |
| `ValidationFailure` | Input violates business rule (empty name, tag with comma, length exceeded, etc.) | Inline field error under offending input. Save button remains enabled. | User edits input and retries. |
| `NotFoundFailure` | Entity referenced does not exist (folder/deck/flashcard/session) | Shared empty/error state with back action. | Pop or navigate to safe parent. |
| `StorageFailure` | Database read/write fails (transaction abort, disk error, constraint violation) | Shared error widget OR snackbar (depending on if blocking). | Offer Retry. Preserve user input. |
| `NetworkFailure` | Drive sync, OAuth, or any network IO fails | Snackbar with retry. Non-blocking unless in restore flow. | Retry button. Restore failures abort safely. |
| `AuthFailure` | OAuth token invalid, refresh failed, account scope changed | Banner on Settings/Account: "Sign in expired. Tap to reconnect." | User re-authenticates. |
| `IntegrityFailure` | Data invariant violated (cycle in folder tree, orphan reference, schema mismatch) | Blocking dialog, abort current operation. | Report to user, log severe. No automated recovery. |
| `ConflictFailure` | Concurrent modification or duplicate detected during create/update | Inline message with merge/replace options where applicable. | User chooses resolution. |
| `UnsupportedActionFailure` | Action invoked in invalid state (e.g., create deck inside subfolders-mode folder) | Action MUST be disabled in UI; if reached, surface as toast. | UI should prevent reaching this. Programmer error if surfaced often. |
| `CancelledFailure` | User cancelled mid-operation (rare; for long ops like import) | Silent; revert UI to pre-op state. | No message needed. |
| `FinalizationFailure` | Session completion partially failed (some attempts saved, summary couldn't write) | Banner on result screen with Retry. Session marked `failed_to_finalize`. | Retry finalization; data preserved. |

### ValidationFailure subtypes

Validation is the most-used failure. Fields:

```
ValidationFailure(
  field: String,        // form field name, e.g., 'name', 'tag', 'front'
  code: ValidationCode, // enum
  message: String?,     // optional override; usually use code → l10n
)

enum ValidationCode {
  empty,
  tooLong,
  tooShort,
  invalidCharacter,   // e.g., comma in tag
  duplicate,
  invalidFormat,
  outOfRange,
  parentModeLocked,   // folder/deck mode mismatch
  cycleDetected,      // folder move would create cycle
  insufficientContent, // study match and guess require >= 5 cards
}
```

UI maps `(field, code)` to localized message. Mapping table lives in `lib/core/error/validation_messages.dart` and l10n ARB keys follow pattern `error_validation_{field}_{code}`.

### StorageFailure subtypes

```
StorageFailure(
  operation: StorageOp,  // read | write | transaction | migration
  table: String?,        // affected table name if known
  cause: String,         // technical detail for logs (NEVER shown to user)
)
```

`cause` is for `Logger.severe` only. UI shows generic message based on `operation`.

### NetworkFailure subtypes

```
NetworkFailure(
  kind: NetworkErrorKind, // offline | timeout | http(status) | parse
  retryable: bool,
)
```

`retryable=false` cases (auth required, manifest schema unsupported) hide retry button.

### IntegrityFailure

Reserved for **data corruption** — should never happen in normal operation. When raised:

1. Logger.severe with full stack.
2. Abort current operation.
3. Show user blocking dialog with "Contact support" CTA (file path: bug report).
4. Do NOT attempt automatic recovery.

## Error mapping by layer

### Data layer

- Wraps all `DriftWrappedException`, file IO, network calls in try-catch.
- Returns `Left(StorageFailure(...))` / `Left(NetworkFailure(...))` etc.
- NEVER lets a raw exception escape to domain.
- Exceptions to this rule: `AssertionError` (programmer bug), `OutOfMemoryError` (cannot recover) propagate up.

### Domain layer (use cases)

- Receives `Either<Failure, T>` from repository.
- Maps low-level failures to higher-level if helpful (e.g., `StorageFailure` on a single-row read might map to `NotFoundFailure` if not-found is a normal case for the use case).
- Adds `ValidationFailure` before calling repository.
- Returns `Either<Failure, T>` to caller.

### Presentation layer (notifier)

- Pattern-matches on `Failure` subtype.
- Updates `AsyncValue` state with the failure (or a wrapper type).
- NEVER throws.

### UI widget

- Reads `AsyncValue` or notifier state.
- Renders shared error widget (`MxErrorState`, `MxEmptyState`, `MxValidationField`, etc.) based on failure subtype.
- Never displays raw `Failure.toString()` or technical detail.

## User-facing message convention

| Quality | Rule |
| --- | --- |
| Tone | Calm, direct, never apologetic-spam ("Sorry, sorry, something went wrong!" is forbidden). |
| Length | One sentence preferred. Two max. |
| Actionable | Tell user what to do next, not just what failed. |
| Specific when safe | "Tag cannot contain a comma." > "Invalid input." |
| Generic when not safe | "Couldn't save changes. Please try again." (do NOT expose SQLite error codes). |
| No emoji | Per Design System voice. |
| Sentence case | Per Design System voice. |
| l10n only | All messages live in ARB. No hardcoded strings in switch statements. |

### Standard copy bank

| Scenario | Standard copy (en) |
| --- | --- |
| Empty input | "{Field} is required." |
| Too long | "{Field} is too long (max {N} characters)." |
| Tag has comma | "Tags cannot contain commas." |
| Duplicate name | "A {entity} with this name already exists in this {parent}." |
| Save failed (storage) | "Couldn't save changes. Please try again." |
| Read failed | "Couldn't load. Tap to retry." |
| Entity not found | "This {entity} no longer exists." |
| Network offline | "No connection. Check your network and try again." |
| Sync timeout | "Sync took too long. Try again or check your connection." |
| Auth expired | "Sign in expired. Tap to reconnect." |
| Cycle in folder move | "A folder cannot be moved inside itself or its subfolders." |
| Folder mode locked | "This folder can only hold {subfolders | decks}." |
| Match mode insufficient | "Match mode needs at least 5 cards. Try a different mode." |
| Concurrent modification | "Someone else changed this. Reloading." |
| Finalization partial | "Some session data couldn't be saved. Retry?" |
| Restore snapshot failed | "Backup snapshot failed. Restore cancelled. Your data is unchanged." |
| Generic catch-all | "Something went wrong. Please try again." (use only when no specific case fits) |

l10n keys live in `lib/l10n/app_en.arb` under prefix `error_`. Per-field validation keys: `error_validation_{field}_{code}`. Per-action keys: `error_action_{verb}`.

Current implementation note for folder lock-mode: MemoX's existing `Result<T>`/`AppFailure` path uses validation failure codes `folder_contains_decks` and `folder_contains_subfolders` (constants in `FailureCodes`) rather than the target `ValidationCode.parentModeLocked` enum. Folder Detail maps these codes to `errorFolderContainsDecks` / `errorFolderContainsSubfolders` ARB keys so the user sees typed localized copy instead of a generic error.

## Forbidden patterns

- ❌ Empty catch block (`catch (_) {}`). Must at minimum log.
- ❌ Catch-all `catch (e) { showSnackbar(e.toString()); }`.
- ❌ Throwing `Exception('...')` for business failure.
- ❌ Silent failure (no log, no UI signal).
- ❌ Stack trace in UI.
- ❌ Hardcoded user-facing error string in switch statement.
- ❌ Layer-jumping: presentation catching `DriftWrappedException`.
- ❌ Recovery action invented at call site (e.g., manual retry loop in widget). Use shared retry infrastructure.

## Required patterns

- ✅ `Either<Failure, T>` for all use case and repository signatures.
- ✅ `Failure` is sealed; pattern match exhaustively.
- ✅ `Logger.severe` for `IntegrityFailure`, `Logger.warning` for unexpected `StorageFailure`, `Logger.info` for recoverable `NetworkFailure`.
- ✅ Map at boundaries: data→domain maps raw exception, domain→presentation may refine failure type.
- ✅ Preserve user input on save failure. State is set back to dirty with failure attached.

## Test contract for errors

Every use case test MUST include:

- At least one happy-path test → `Right(T)`.
- At least one failure-path test per failure type the use case can return.
- Validation tests covering every `ValidationCode` the use case checks.
- Repository test for each `StorageFailure` cause (e.g., constraint violation, transaction abort).

See `docs/testing/test-strategy.md`.

## Agent rule

- When implementing a use case, FIRST add the failure types it can return to a comment on the signature, BEFORE writing the body.
- When adding a new failure type, update this contract in the same commit.
- When adding a new validation code, update `ValidationCode` enum AND the l10n key set AND this contract's standard copy bank.
- Do not introduce a new top-level failure subtype without explicit user approval.

## Related

**Repo-level:**

- `CLAUDE.md` §Doc-code parity rule
- `AGENTS.md`

**Contracts:**

- `docs/contracts/types-catalog.md` — enums referenced here (ValidationCode, NetworkErrorKind, StorageOp)
- `docs/contracts/code-style.md` — naming for failure classes
- `docs/testing/test-strategy.md` — error-path test requirements
- `docs/quality/observability-contract.md` — when to log which severity

**Business specs:**

- Every business doc references failure types via inline mentions; this contract is the registry.

**Wireframes:**

- `docs/wireframes/24-shared-dialogs.md` — error confirmation dialogs
- `docs/wireframes/25-shared-bottom-sheets.md` §undo-toast — recovery via undo

**Code paths:**

- `lib/core/error/failure.dart` (sealed Failure base)
- `lib/core/error/validation_messages.dart` (mapping)
- `lib/core/widgets/error/mx_error_state.dart`
- `lib/core/widgets/error/mx_validation_field.dart`
- `lib/l10n/app_en.arb` (error_* keys)
