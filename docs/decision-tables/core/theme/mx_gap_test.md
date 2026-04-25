# Decision Tables: mx_gap_test

Test file: `test/core/theme/mx_gap_test.dart`

## Decision table: onInsert

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `MxGap` is placed inside a horizontal `Row` | row contains two widgets separated by `MxGap` | widget tree lays out the row | horizontal spacing is applied between the row children | C0+C1 |
| DT2 | `MxGap` is placed inside a vertical `Column` | column contains two widgets separated by `MxGap` | widget tree lays out the column | vertical spacing is applied between the column children | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `MxGap` is placed inside a `ListView` and should follow scroll direction | list view contains children separated by `MxGap` | widget tree lays out the list | gap uses the list scroll axis for spacing | C0+C1 |
| DT2 | `MxSliverGap` is placed inside a `CustomScrollView` | custom scroll view contains a sliver gap between slivers | widget tree lays out the scroll view | sliver spacing renders without layout error | C0+C1 |
