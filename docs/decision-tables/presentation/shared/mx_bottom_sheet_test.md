# Decision Tables: mx_bottom_sheet_test

Test file: `test/presentation/shared/mx_bottom_sheet_test.dart`

## Decision table: onBehavior

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | bottom sheet is rendered while keyboard bottom inset is non-zero | `MediaQuery.viewInsets.bottom` is 160 and sheet content has height 80 | `MxBottomSheet` is laid out | inner `AnimatedPadding` resolves bottom padding to 160 and sheet content remains visible | C0+C1 |
