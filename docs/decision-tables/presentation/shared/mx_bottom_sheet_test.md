# Decision Tables: mx_bottom_sheet_test

Test file: `test/presentation/shared/mx_bottom_sheet_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | bottom sheet has a title, so title typography should be component-owned | `MxBottomSheet` is built with title `Import cards` | sheet renders | title is rendered through `MxTextRole.sheetTitle` instead of a raw Material text-theme role | C0+C1 |

## Decision table: onBehavior

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | bottom sheet is rendered while keyboard bottom inset is non-zero | `MediaQuery.viewInsets.bottom` is 160 and sheet content has height 80 | `MxBottomSheet` is laid out | inner `AnimatedPadding` resolves bottom padding to 160 and sheet content remains visible | C0+C1 |
