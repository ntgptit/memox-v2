---
last_updated: 2026-05-26
status: contract
---

# Account & Sync Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

Google sign-in, account-scoped DB, Drive App Folder backup/restore with mandatory pre-restore snapshot.

## SignInWithGoogleUseCase

```dart
Future<Either<Failure, Account>> call();
```

**Rules:**

- Launch OAuth flow via `google_auth.dart`.
- Persist account tokens to `flutter_secure_storage` (NEVER SharedPreferences).
- Switch active DB file to account-scoped path (e.g., `memox-{accountId}.db`).
- If switching account, the active DB changes; trigger Riverpod invalidation of all data providers.

**Errors:** `AuthFailure`, `NetworkFailure`, `CancelledFailure`, `StorageFailure`.

## SignOutUseCase

```dart
Future<Either<Failure, Unit>> call();
```

**Rules:**

- Clear tokens.
- DO NOT delete account-scoped DB. User can sign in again and resume.

**Errors:** `StorageFailure`.

## SwitchOrRemoveAccountUseCase

```dart
Future<Either<Failure, Unit>> call({required AccountId id});
```

**Rules:**

- Strong destructive (user typed ERASE confirmation upstream).
- DELETE account-scoped DB file.
- Clear tokens.
- Reset Riverpod state.

**Caution:** Destructive.

**Errors:** `StorageFailure`.

## ComputeLocalFingerprintUseCase

```dart
Future<Either<Failure, Fingerprint>> call();
```

**Rules:**

- Compute SHA-256 over canonical content of DB (deterministic ordering).
- Cached for 30s; recompute on data change.

**Errors:** `StorageFailure`.

## FetchDriveManifestUseCase

```dart
Future<Either<Failure, DriveManifest?>> call();
```

Returns latest manifest from Drive App Folder, or null if none exists.

**Errors:** `NetworkFailure`, `AuthFailure`, `StorageFailure` (parse error).

## UploadToDriveUseCase

```dart
Future<Either<Failure, DriveManifest>> call();
```

**Rules:**

- Compute fingerprint.
- Build manifest: `{ device_label, fingerprint, uploaded_at, size_bytes, schema_version }`.
- Upload DB file + manifest to Drive App Folder. Replace previous.
- Persist `account.lastSyncAt`, `account.lastSyncFingerprint` to SharedPreferences.

**Errors:** `NetworkFailure`, `AuthFailure`, `StorageFailure`.

## CreatePreRestoreSnapshotUseCase

```dart
Future<Either<Failure, SnapshotInfo>> call();
```

**Rules:**

- Copy current DB file to safe local snapshot path.
- VERIFY snapshot integrity (file size, can re-open).
- If verification fails → `StorageFailure`. Caller MUST abort restore.

**Errors:** `StorageFailure`.

## RestoreFromDriveUseCase

```dart
Future<Either<Failure, RestoreResult>> call({
  required DriveManifest manifest,
  required bool skipSnapshot,  // Future empty-DB restore handoff only
});
```

**Rules:**

- `skipSnapshot` is not exposed by current V1 Account Settings restore. It is reserved for a future full onboarding / empty-DB restore prompt and is valid only when the local DB is verifiably empty.
- If `!skipSnapshot`:
  - Call `CreatePreRestoreSnapshotUseCase`. If fails → return `StorageFailure`, abort, original DB UNCHANGED.
- Download DB from Drive.
- Validate downloaded manifest matches schema version.
- Replace local DB atomically (write to temp file, then rename).
- Trigger Riverpod invalidation across all providers.

**Errors:** `NetworkFailure`, `StorageFailure`, schema mismatch → `IntegrityFailure`.

## UpdateDeviceLabelUseCase

```dart
Future<Either<Failure, Unit>> call({required String label});
```

**Rules:**

- Trim. Reject empty. Reject > 50 chars.
- Persist to SharedPreferences `account.deviceLabel`.

**Errors:** `ValidationFailure`, `StorageFailure`.

## Forbidden patterns

- ❌ Auto-restore on sign-in. Manual only.
- ❌ Skip pre-restore snapshot when local DB has data.
- ❌ Continue restore if snapshot fails.
- ❌ Store OAuth tokens in SharedPreferences. Use `flutter_secure_storage`.
- ❌ Log tokens, fingerprints, or DB content to logs.
- ❌ Wipe DB on sign-out. Only `SwitchOrRemoveAccountUseCase` wipes.
- ❌ Backup outside Drive App Folder (other apps must not see data).

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Business spec:** `docs/business/account-sync/account-sync.md`
**Repository:** `docs/contracts/repository-contracts/sync-repository.md`
**Wireframes:** `docs/wireframes/19-settings-account.md`, `docs/wireframes/24-shared-dialogs.md` §restore-warning
**Decision table:** rows under "Account / Sync"
**Code paths:** `lib/domain/usecases/account_sync/**`, `lib/data/sync/**`, `lib/core/auth/**`
