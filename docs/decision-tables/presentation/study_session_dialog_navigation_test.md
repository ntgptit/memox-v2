# Decision Tables: study_session_dialog_navigation_test

Test file: `test/presentation/study_session_dialog_navigation_test.dart`

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | user confirms the study-session cancel dialog after opening session from a previous route | active Fill session was pushed from a previous route and cancel confirmation is visible | user taps the dialog's primary `Cancel` action, then taps back on the result route | result back action replaced the session, previous route text is visible after back, and Library fallback is not shown | C0+C1 |
