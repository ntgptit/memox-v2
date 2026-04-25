# Decision Tables: dialog_typography_test

Test file: `test/presentation/shared/dialog_typography_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | dialog content text should inherit the active MemoX typography | `MaterialApp` uses `AppTheme.light` and dialog body contains `Dialog body` | user opens `MxDialog` | body `RichText` font family equals `AppTypography.fontFamily` and body text is visible | C0+C1 |

## Decision table: onBehavior

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | dialog has an icon, so title alignment should be centered | `MxDialog.show` is called with title `Delete folder` and delete icon | user opens the dialog | title `Text.textAlign` is `TextAlign.center` and delete icon is visible | C0+C1 |
