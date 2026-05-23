# Decision Tables: mx_dialog_test

Test file: `test/presentation/shared/mx_dialog_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | compact viewport should keep dialog inside the visible inset width without double inset | host viewport is `412x915` and dialog content requests an oversized width | `MxDialog` renders | dialog width equals the viewport width minus theme dialog horizontal inset and does not apply a second internal inset | C0+C1 |
| DT2 | wide viewport should cap dialog width through `AppLayout.dialogMaxWidth` | host viewport is expanded and dialog content requests an oversized width | `MxDialog` renders | dialog width is no wider than the context dialog max width | C0+C1 |

## Decision table: onBehavior

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | existing `MxDialog.show` entrypoint should keep opening a dialog | a button calls `MxDialog.show` with title and body | user taps the button | dialog title and body render through the existing show API | C0+C1 |
