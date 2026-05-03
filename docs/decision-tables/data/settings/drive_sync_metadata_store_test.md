# Decision Tables: drive_sync_metadata_store_test

Test file: `test/data/settings/drive_sync_metadata_store_test.dart`

## Decision table: metadataStore

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | no metadata key exists | SharedPreferences has no sync metadata key | `loadForAccount` runs | store returns null | C0+C1 |
| DT2 | metadata belongs to requested account | store saves complete metadata for `google-user` | load, load for another account, then clear run | requested account loads metadata, other account returns null, and clear removes metadata | C0+C1 |
| DT3 | metadata JSON is malformed | SharedPreferences contains invalid JSON at sync metadata key | `loadForAccount` runs | store catches parse failure and returns null | C0+C1 |
| DT4 | metadata JSON is old or incomplete | SharedPreferences contains JSON missing required metadata fields | `loadForAccount` runs | store rejects it and returns null | C0+C1 |
| DT5 | device id is absent then present | SharedPreferences has no device id on first read and generated id is stored | `loadOrCreateDeviceId` runs twice with different generators | first call stores generated id and second call reuses the stored id | C0+C1 |
