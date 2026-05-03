# Decision Tables: drive_sync_snapshot_store_test

Test file: `test/data/sync/drive_sync_snapshot_store_test.dart`

## Decision table: snapshotCodec

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | snapshot archive contains valid manifest, database, and settings entries | codec receives database bytes, syncable settings, schema version, device id, and device label | encode then decode runs | decoded snapshot preserves database/settings and manifest hash/schema metadata | C0+C1 |
| DT2 | database bytes do not match manifest hash | archive contains valid manifest and settings but a changed `memox.sqlite` entry | decode runs | codec returns null and does not expose corrupted snapshot data | C0+C1 |
| DT3 | archive bytes are not a zip | codec receives arbitrary bytes | decode runs | codec catches decode failure and returns null | C0+C1 |
