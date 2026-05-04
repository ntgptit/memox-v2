# Decision Tables: drive_sync_viewmodel_test

Test file: `test/presentation/drive_sync_viewmodel_test.dart`

## Decision table: loading

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | repository reports signed out | fake sync repository returns `DriveSyncStatus.signedOut` | `DriveSyncSettingsController` builds | state kind is `signedOut` and `canSync` is false | C0+C1 |
| DT7 | repository reports failure with a diagnostic message | fake sync repository returns `DriveSyncStatus.failure` with a Drive configuration message | `DriveSyncSettingsController` builds | state kind is `failure`, `canSync` is true for retry, and `technicalMessage` carries the repository message for display | C0+C1 |

## Decision table: onSync

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT2 | sync succeeds by uploading local snapshot | initial status is `noRemoteSnapshot` and sync use case returns `uploadedLocal` | controller runs `syncNow` | repository is called once, state becomes `synced`, and uploaded message is exposed | C0+C1 |
| DT3 | sync detects local/Drive conflict | initial status is ready and sync use case returns `needsConflictResolution` with a conflict object | controller runs `syncNow` | state becomes `conflict`, `pendingConflict` is retained for the sheet, and no success/error message is shown | C0+C1 |
| DT5 | sync is disabled by missing Drive authorization | initial status is `needsDriveAuthorization` | controller runs `syncNow` | repository sync is not called because `canSync` is false | C0+C1 |
| DT8 | previous load failed but user retries | initial status is `failure` with a Drive API configuration message and sync use case returns `uploadedLocal` | controller runs `syncNow` | repository sync is called once and state becomes `synced` with uploaded message | C0+C1 |

## Decision table: onRefreshRetry

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT6 | reconnect completed and status reload finds no remote snapshot | first repository status is `needsDriveAuthorization` and the next status is `noRemoteSnapshot` | controller refreshes after account reconnect | state becomes `noRemoteSnapshot` and `canSync` is true | C0+C1 |

## Decision table: onResolve

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT4 | user chooses Drive copy and restore requires runtime effect | controller first receives a conflict from `syncNow`, then resolve use case returns `restoredRemote` with `refreshDatabaseProvider` | controller resolves with `useDriveCopy` | runtime effect is applied once, state becomes `synced`, and restored message is exposed | C0+C1 |
