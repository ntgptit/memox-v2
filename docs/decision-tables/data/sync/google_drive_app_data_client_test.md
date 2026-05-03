# Decision Tables: google_drive_app_data_client_test

Test file: `test/data/sync/google_drive_app_data_client_test.dart`

## Decision table: request

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | Drive list response contains a matching file | fake HTTP client returns one file from `/drive/v3/files` | `findFileByName` searches a sync artifact | request targets `appDataFolder` with bearer auth and decoded file metadata includes id, version, size, and app properties | C0+C1 |
| DT2 | Drive list response is empty | fake HTTP client returns an empty `files` array | `findFileByName` searches a missing artifact | method returns null without throwing | C0+C1 |
| DT3 | create uploads multipart file data | fake HTTP client returns file metadata from upload endpoint | `createFile` uploads snapshot bytes | multipart request includes `appDataFolder` parent, appProperties, MIME type, and decoded file id/version are returned | C0+C1 |
| DT4 | Drive returns unsuccessful status | fake HTTP client returns HTTP 401 for media download | `downloadFile` runs | typed `GoogleDriveAppDataException` includes status code 401 | C0+C1 |
