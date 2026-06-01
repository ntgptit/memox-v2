---
last_updated: 2026-05-26
status: contract
---

# Sync Repository Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

Drive App Folder backup/restore. NOT a Drift repository — operates on file system, Drive REST API, and `flutter_secure_storage`.

## Methods

```dart
abstract class SyncRepository {
  Future<Either<Failure, DriveManifest?>> fetchManifest();
  Future<Either<Failure, DriveManifest>> uploadDatabase({
    required DeviceLabel deviceLabel,
    required Fingerprint localFingerprint,
  });
  Future<Either<Failure, File>> downloadDatabase();  // returns local temp file path
  Future<Either<Failure, SnapshotInfo>> createLocalSnapshot();  // pre-restore safety
  Future<Either<Failure, Unit>> replaceLocalDatabase(File downloadedDb);
  Future<Either<Failure, Fingerprint>> computeLocalFingerprint();
}
```

## Operational rules

### Upload

1. Compute fingerprint of current local DB.
2. Build manifest with `device_label`, `fingerprint`, `uploaded_at`, `size_bytes`, `schema_version`.
3. Upload DB file to Drive App Folder (overwrite previous).
4. Upload manifest as separate JSON file.
5. Update `account.lastSyncAt`, `account.lastSyncFingerprint` in SharedPreferences.

### Restore (with snapshot)

1. `createLocalSnapshot()` — copy DB to safe local path, verify (re-open + integrity check).
2. If snapshot fails → return `StorageFailure`. Caller MUST abort restore. Original DB UNCHANGED.
3. `downloadDatabase()` — download to temp file, NOT replacing yet.
4. Validate downloaded manifest schema_version matches app expectation. Else `IntegrityFailure`.
5. `replaceLocalDatabase()` — atomic rename: temp → main DB path. Old DB discarded (snapshot still in safe path).
6. Invalidate all Riverpod providers (caller responsibility, signaled via return).

Target retention note: exact pre-restore snapshot cleanup policy is not Current V1. Keep this contract aligned with `docs/business/account-sync/account-sync.md` before implementing the full restore-protection target.

### Restore (Future empty-DB restore handoff, skip snapshot)

Target-only handoff for a future full onboarding / empty-DB restore prompt. Allowed only when DB is verifiably empty (no decks, no flashcards). Current V1 restore remains Account Settings ownership and does not expose a standalone onboarding restore wizard. Skip step 1-2 above only in that future empty-DB path.

## Token storage

OAuth access/refresh tokens stored ONLY in `flutter_secure_storage`. Never SharedPreferences. Never logged.

## Constraints

- Drive App Folder ONLY (other apps cannot see).
- Manifest is canonical source of remote state. If manifest absent, no backup exists.
- Fingerprint = SHA-256 over canonical DB content (deterministic ordering of tables, rows).
- Target snapshot path: `{appSupportDir}/snapshots/snapshot-{timestamp}.db`. Cleanup/retention policy must be finalized with the business restore-protection section before implementation.

## Forbidden

- ❌ Backup outside Drive App Folder.
- ❌ Store tokens in SharedPreferences or DB.
- ❌ Log tokens, manifest content, or DB content.
- ❌ Skip snapshot when local DB has data.
- ❌ Continue restore if snapshot creation fails.
- ❌ Non-atomic DB replace (write directly over active DB without temp file).
- ❌ Auto-upload on every data change (manual only in v1).

## Test contract

- Fetch manifest (present / absent).
- Upload → verify manifest written + DB written.
- Snapshot creation success/failure.
- Restore with snapshot success.
- Restore with snapshot failure → abort, DB unchanged.
- Restore with skipSnapshot (Future empty-DB restore handoff only).
- Schema version mismatch → `IntegrityFailure`.
- Token refresh failure → `AuthFailure`.

Use `FakeDriveService` in tests.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`

**Business spec:** `docs/business/account-sync/account-sync.md`
**Use cases:** `docs/contracts/usecase-contracts/account-sync.md`
**Storage boundaries:** `docs/database/storage-boundaries.md`
**Wireframes:** `docs/wireframes/19-settings-account.md`
**Code paths:**

- `lib/domain/repositories/sync_repository.dart`
- `lib/data/sync/sync_repository_impl.dart`
- `lib/data/sync/drive_upload_service.dart`
- `lib/data/sync/drive_restore_service.dart`
- `lib/data/sync/local_snapshot_service.dart`
- `lib/data/sync/manifest.dart`
- `lib/core/auth/google_auth.dart`
