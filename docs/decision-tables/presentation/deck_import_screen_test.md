# Decision Tables: deck_import_screen_test

Test file: `test/presentation/deck_import_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | import draft starts in Excel source mode with no selected file and compact first action | import route opens for `deck-001` and repository is available | first frame settles | title, `Import from`, `CSV`, `Excel`, `Text`, medium-height `Select Excel file`, Excel column guidance, and header option are visible; paste editor, `Preview import`, and `Clear` are absent | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | source format is switched to structured text, so separator and duplicate settings share one compact options group | import screen is open in default Excel mode | user taps `Text` | compact textarea is visible, `Load file` sits below it before Options, `Separator` with default `Auto` and `Duplicate handling` appear inside the same options card | C0+C1 |
| DT2 | preview preparation contains many valid rows and preview rendering must stay lazy | repository returns eighty preview rows and a mobile viewport is active | user selects CSV, enters raw content, taps `Preview import`, then scrolls to the final preview row | `CustomScrollView` and `deck_import_preview_lazy_items` are used, initially built `MxTermRow` count is lower than total preview rows, `Front 79` is absent before scrolling, then `Front 79` and `Back 79` appear after scroll | C0+C1 |
| DT3 | only the active duplicate policy is visible from the high-level import screen | import screen opens in default Excel mode | first frame settles, then user opens the duplicate policy picker | `Duplicate handling` and `Skip exact duplicates` are visible, policy explanation appears in the sheet, and future disabled choices `Import anyway` and `Update existing cards` are absent | C0+C1 |
| DT4 | preview contains skipped exact duplicates | repository returns one valid row and two skipped exact duplicates | user selects CSV, enters raw content, taps `Preview import`, and scrolls to duplicate section | preview summary shows `1 valid · 0 issues · 2 skipped`, and skipped rows are listed with `Exact duplicate in this file` and `Exact duplicate in this deck` | C0+C1 |
| DT5 | Excel source is file-only before file load and header shares the compact options group | import screen opens in default Excel mode | first frame settles | the text editor is hidden, `Select Excel file` and fixed A/B/C guidance are visible, `First row is header` and `Duplicate handling` appear inside the same options card, and `Preview import` is absent until a `.xlsx` file is loaded | C0+C1 |
| DT6 | loaded Excel file row receives preview metadata after preview succeeds | Excel source has `cards.xlsx` loaded into draft state and repository returns one valid row | user taps `Preview import` | file row shows `Ready to preview` before preview, then `1 row detected`, and the CTA becomes `Import 1 card` | C0+C1 |

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `readDeckImportFileContent` receives in-memory UTF-8 bytes | `PlatformFile.bytes` contains Vietnamese CSV text with diacritics | helper reads the file content | decoded string equals the original UTF-8 CSV content | C0+C1 |
| DT2 | `readDeckImportFileContent` has neither bytes nor path source | `PlatformFile` is created with only name and size | helper reads the file content | result completes with `null` and no fallback content is fabricated | C0+C1 |
| DT6 | `readDeckImportFileBytes` receives in-memory `.xlsx` bytes | `PlatformFile.bytes` contains binary workbook data | helper reads the file bytes | returned bytes equal the original workbook bytes and are not decoded as text | C0+C1 |
| DT3 | preview preparation is in flight, so the focused import action is locked | raw CSV text is entered and repository `prepareHandler` returns a pending future | user taps `Preview import` and then taps another source segment | progress indicator appears, the primary action is disabled, `Clear` remains absent, and source format cannot switch while preview is running | C0+C1 |
| DT4 | commit import is in flight after a valid preview | preview succeeds and repository `commitHandler` returns a pending future | user taps `Import 1 card` | progress indicator appears and the visible Import action is disabled while commit is running | C0+C1 |
| DT5 | preview result contains one valid item and one issue | raw CSV contains one complete row and one row with missing back text | user taps `Preview import` and scrolls to preview summary | `1 valid · 1 issues`, `Line 3`, and `Back is required.` are visible | C0+C1 |

## Decision table: onSelect

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | structured text separator sheet returns Slash and preview uses that separator | source format is Text and separator starts as Auto | user opens separator sheet, selects `Slash`, enters `개다 / Clear up`, and taps `Preview import` | repository receives `ImportSourceFormat.structuredText`, `ImportStructuredTextSeparator.slash`, and the entered raw content | C0+C1 |
| DT2 | Excel header option changes parser input for preview | source format is Excel, a `.xlsx` file is loaded into draft state, and `First row is header` starts enabled | user turns the header option off and taps `Preview import` | repository receives the loaded workbook bytes and `excelHasHeader: false` | C0+C1 |
