# Decision Tables: google_drive_sync_repository_test

Test file: `test/data/sync/google_drive_sync_repository_test.dart`

## Decision table: loadStatus

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT11 | Drive rejects the existing access token | account is Drive-authorized, auth service returns an access token, and fake Drive throws HTTP 401 while loading remote metadata | repository loads status | status becomes `needsDriveAuthorization` with no technical failure message | C0+C1 |

## Decision table: syncNow

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | no remote snapshot exists | account is Drive-authorized, access token is available, and fake Drive has no manifest or snapshot files | repository runs `syncNow` | local DB/settings snapshot is uploaded as snapshot and manifest files, status becomes `synced`, and sync metadata is saved | C0+C1 |
| DT2 | local fingerprint equals remote fingerprint | first sync already uploaded current local snapshot and local bytes/settings are unchanged | repository runs `syncNow` again | result is `noChanges` and Drive files are not updated | C0+C1 |
| DT3 | local changed and remote unchanged since baseline | first sync saved metadata, then local DB bytes change while remote files remain unchanged | repository runs `syncNow` | local snapshot overwrites Drive snapshot and manifest | C0+C1 |
| DT4 | remote changed and local unchanged since baseline | first sync saved metadata, then remote snapshot changes while local DB bytes remain unchanged | repository runs `syncNow` | result requests conflict resolution with remote-changed reason | C0+C1 |
| DT5 | both local and remote changed since baseline | first sync saved metadata, then local DB bytes and remote snapshot both change | repository runs `syncNow` | result requests conflict resolution with diverged reason | C0+C1 |
| DT10 | access token provider fails | account is linked and Drive-authorized but auth service returns token failure | repository loads status | status is `failure` with the token error message | C0+C1 |
| DT12 | Drive rejects token during sync request | account is Drive-authorized, auth service returns an access token, and fake Drive throws HTTP 401 while sync loads remote metadata | repository runs `syncNow` | result is `failed` with status `needsDriveAuthorization` instead of a technical `failure` status | C0+C1 |

## Decision table: resolveConflict

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT6 | user keeps local copy | pending conflict references current Drive files and local DB differs | repository resolves conflict with `keepLocal` | local snapshot overwrites Drive files and result is `uploadedLocal` | C0+C1 |
| DT7 | user uses Drive copy | pending conflict references a valid remote snapshot containing DB bytes and settings | repository resolves conflict with `useDriveCopy` | settings are restored, DB bytes are staged through snapshot gateway, and restore effect is returned | C0+C1 |
| DT8 | remote schema is newer than local app schema | pending conflict references remote manifest with schema version above local gateway schema | repository resolves conflict with `useDriveCopy` | result fails with `unsupportedSchema` and DB restore is not called | C0+C1 |
| DT9 | remote zip is corrupted or hash validation fails | pending conflict references a remote snapshot file whose bytes cannot decode as a validated snapshot | repository resolves conflict with `useDriveCopy` | result fails with `Drive snapshot is invalid.` and DB restore is not called | C0+C1 |
| DT13 | Drive rejects token while restoring remote copy | pending conflict references a remote snapshot and fake Drive throws HTTP 403 when the snapshot file is requested | repository resolves conflict with `useDriveCopy` | result is `failed` with status `needsDriveAuthorization` and DB restore is not called | C0+C1 |
