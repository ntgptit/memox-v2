# Decision Tables: drive_sync_usecases_test

Test file: `test/domain/drive_sync_usecases_test.dart`

## Decision table: if

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | load status use case delegates to repository boundary | fake repository returns `noRemoteSnapshot` | `LoadDriveSyncStatusUseCase.execute` runs | returned status matches repository status and load is called once | C0 |
| DT2 | sync use case delegates to repository boundary | fake repository returns `uploadedLocal` | `SyncGoogleDriveSnapshotUseCase.execute` runs | returned result matches repository result and sync is called once | C0 |
| DT3 | resolve conflict use case forwards selected choice | fake repository returns `canceled` | `ResolveDriveSyncConflictUseCase.execute` receives conflict and `cancel` | repository receives the same conflict and choice, and returned result is `canceled` | C0+C1 |
