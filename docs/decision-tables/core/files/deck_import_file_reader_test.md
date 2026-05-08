# Decision Tables: deck_import_file_reader_test

Test file: `test/core/files/deck_import_file_reader_test.dart`

## Decision table: readContent

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | file supplies in-memory UTF-8 bytes | `PlatformFile.bytes` contains CSV text | content reader reads the file | decoded string equals the original UTF-8 CSV content | C0+C1 |
| DT2 | file supplies only a local platform path | `PlatformFile.path` points at a UTF-8 CSV file and `bytes` is absent | content reader reads the file on an IO platform | decoded string equals the file contents | C0+C1 |
| DT3 | file has neither bytes nor path source | `PlatformFile` is created with only name and size | content reader reads the file | result completes with `null` and no fallback content is fabricated | C0+C1 |

## Decision table: readBytes

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | file supplies in-memory `.xlsx` bytes | `PlatformFile.bytes` contains binary workbook data | byte reader reads the file | returned bytes equal the original workbook bytes and are not decoded as text | C0+C1 |
| DT2 | file supplies only a local platform path | `PlatformFile.path` points at an `.xlsx` file and `bytes` is absent | byte reader reads the file on an IO platform | returned bytes equal the file contents | C0+C1 |
| DT3 | file has neither bytes nor path source | `PlatformFile` is created with only name and size | byte reader reads the file | result completes with `null` and no fallback bytes are fabricated | C0+C1 |
