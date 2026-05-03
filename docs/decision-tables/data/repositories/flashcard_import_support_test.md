# Decision Tables: flashcard_import_support_test

Test file: `test/data/repositories/flashcard_import_support_test.dart`

## Decision table: parseRows

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | auto separator detection sees slash vocabulary format before colon text | raw structured text uses `front / back` lines and answer text may contain colons | import support parses rows with auto separator | preview contains parsed front/back pairs from slash separation | C0+C1 |
| DT2 | explicit separator is tab and each row contains one tab-delimited card | raw structured text contains tab-separated front and back values | import support parses rows with explicit tab separator | each line becomes one preview item | C0+C1 |
| DT3 | CSV content is empty | raw CSV contains no non-empty lines | import support parses CSV rows | preview is empty and validation issue points to line 1 | C0+C1 |
| DT4 | CSV header omits required front/back columns | raw CSV header lacks one required column | import support parses CSV rows | preview is empty and validation issue points to line 1 with header reason | C0+C1 |
| DT5 | CSV row is missing a required side | CSV header is valid and one data row has blank back value | import support parses CSV rows | valid rows remain in preview and issue points to the invalid source line | C0+C1 |
| DT6 | structured block is missing `Back:` | raw structured block starts at line 1 and has only front text | import support parses block format | preview is empty and issue points to the block starting line | C0+C1 |
| DT7 | `.xlsx` source has a header row and fixed A/B/C columns | OpenXML workbook bytes contain row 1 labels with arbitrary text, row 2 valid A/B/C values, and row 3 missing column B | import support parses Excel rows with `excelHasHeader` enabled | row 1 is skipped without text validation, row 2 becomes a preview card, note comes from column C, and row 3 reports the Excel row number | C0+C1 |
| DT8 | `.xlsx` source has no header row and data starts at A1 | OpenXML workbook bytes contain valid A1/B1/C1 values and row 2 is missing column B | import support parses Excel rows with `excelHasHeader` disabled | row 1 becomes the first preview card, note comes from C1, and row 2 reports the Excel row number | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | explicit separator is colon and answer contains additional colons | raw structured text contains `front: answer: with: colons` | import support parses rows with explicit colon separator | first colon splits the row and later colons remain in the answer | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | auto mode receives legacy `Front Back` block format | raw text uses existing front/back block markers instead of delimiter rows | import support parses rows in auto mode | legacy block content remains compatible and produces preview items | C0+C1 |
| DT2 | auto mode sees pipe-delimited rows without block labels | raw structured text uses pipe-delimited front/back lines | import support parses rows in auto mode | each line becomes a preview item with source line labels | C0+C1 |
