# Decision Tables: deck_import_screen_test

Test file: `test/presentation/deck_import_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | import draft starts in CSV source mode with empty raw content | import route opens for `deck-001` and repository is available | first frame settles | title, `CSV`, `Text format`, and `CSV content` editor are visible | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | source format is switched to structured text, so separator choices are displayed before preview | import screen is open in default CSV mode | user taps `Text format` | `Separator` heading and default `Auto` choice are visible | C0+C1 |
| DT2 | preview preparation contains many valid rows and preview rendering must stay lazy | repository returns eighty preview rows and a mobile viewport is active | user taps `Preview`, then scrolls to the final preview row | `CustomScrollView` and `deck_import_preview_lazy_items` are used, initially built `MxTermRow` count is lower than total preview rows, `Front 79` is absent before scrolling, then `Front 79` and `Back 79` appear after scroll | C0+C1 |
| DT3 | MVP duplicate policy choices are visible from the high-level import screen | import screen opens in default CSV mode | first frame settles, then user opens the duplicate policy picker | `Duplicate handling`, `Skip exact duplicates`, `Same front with a different back will still be imported.`, `Import anyway`, and `Update existing cards` are visible | C0+C1 |
| DT4 | preview contains skipped exact duplicates | repository returns one valid row and two skipped exact duplicates | user taps `Preview` and scrolls to duplicate section | preview summary shows `1 valid · 0 issues · 2 skipped`, and skipped rows are listed with `Exact duplicate in this file` and `Exact duplicate in this deck` | C0+C1 |

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `readDeckImportFileContent` receives in-memory UTF-8 bytes | `PlatformFile.bytes` contains Vietnamese CSV text with diacritics | helper reads the file content | decoded string equals the original UTF-8 CSV content | C0+C1 |
| DT2 | `readDeckImportFileContent` has neither bytes nor path source | `PlatformFile` is created with only name and size | helper reads the file content | result completes with `null` and no fallback content is fabricated | C0+C1 |
| DT3 | preview preparation is in flight, so import controls are disabled | raw CSV text is entered and repository `prepareHandler` returns a pending future | user taps `Preview` | progress indicator appears, outlined buttons are disabled, Clear is disabled, Import is disabled, and source format cannot switch | C0+C1 |
| DT4 | commit import is in flight after a valid preview | preview succeeds and repository `commitHandler` returns a pending future | user taps `Import` | progress indicator appears, Import is disabled, and file/source action buttons are disabled | C0+C1 |
| DT5 | preview result contains one valid item and one issue | raw CSV contains one complete row and one row with missing back text | user taps `Preview` and scrolls to preview summary | `1 valid · 1 issues`, `Line 3`, and `Back is required.` are visible | C0+C1 |

## Decision table: onSelect

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | structured text separator sheet returns Slash and preview uses that separator | source format is Text format and separator starts as Auto | user opens separator sheet, selects `Slash`, enters `개다 / Clear up`, and taps `Preview` | repository receives `ImportSourceFormat.structuredText`, `ImportStructuredTextSeparator.slash`, and the entered raw content | C0+C1 |
