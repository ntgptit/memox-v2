# Decision Tables: flashcard_import_support_test

Test file: `test/data/repositories/flashcard_import_support_test.dart`

## Decision table: parseRows

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | auto separator detection sees slash vocabulary format before colon text | raw structured text uses `front / back` lines and answer text may contain colons | import support parses rows with auto separator | preview contains parsed front/back pairs from slash separation | C0+C1 |
| DT2 | explicit separator is tab and each row contains one tab-delimited card | raw structured text contains tab-separated front and back values | import support parses rows with explicit tab separator | each line becomes one preview item | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | explicit separator is colon and answer contains additional colons | raw structured text contains `front: answer: with: colons` | import support parses rows with explicit colon separator | first colon splits the row and later colons remain in the answer | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | auto mode receives legacy `Front Back` block format | raw text uses existing front/back block markers instead of delimiter rows | import support parses rows in auto mode | legacy block content remains compatible and produces preview items | C0+C1 |
