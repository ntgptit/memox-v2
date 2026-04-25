# Decision Tables: mx_name_dialog_test

Test file: `test/presentation/shared/mx_name_dialog_test.dart`

## Decision table: onBehavior

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | name input is blank or whitespace only | create-folder dialog is open and result variable is null | user leaves field blank, then enters only spaces, then enters `Grammar` | confirm button is disabled for blank and spaces, enabled for `Grammar`, and no result is returned before confirmation | C0+C1 |
| DT2 | name input has leading and trailing spaces and confirm is pressed | create-folder dialog is open | user enters `  Grammar  ` and taps `Create` | dialog closes and returned result is trimmed to `Grammar` | C0+C1 |
| DT3 | name input has leading and trailing spaces and keyboard done is submitted | rename-deck dialog is open | user enters `  Biology  ` and sends `TextInputAction.done` | dialog closes and returned result is trimmed to `Biology` | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | rename dialog receives an initial value | `MxNameDialog.show` is called with `initialValue='Existing folder'` | dialog opens | field controller text is `Existing folder` and selection offsets are at the end | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | barrier tap outside the dialog should not dismiss the name dialog | create-folder dialog is open | user taps outside the dialog at screen corner | dialog remains visible and title `Create folder` is still present | C0+C1 |
