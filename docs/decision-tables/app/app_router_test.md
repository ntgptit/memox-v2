# Decision Tables: app_router_test

Test file: `test/app/router/app_router_test.dart`

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | study session path uses reserved `session` segment that overlaps the dynamic study entry route shape | router starts at `/library/study/session/session-001` with a loaded session snapshot | app router resolves the initial location | `StudySessionScreen` is rendered and `StudyEntryScreen` is absent | C0+C1 |
| DT2 | deck import is a focused child flow that must not compete with top-level shell navigation | router starts at `/library/deck/deck-001/import` | app router resolves the initial location | `DeckImportScreen` is rendered and both `NavigationBar` and `NavigationRail` are absent | C0+C1 |
| DT3 | settings root remains a top-level destination | router starts at `/settings` | app router resolves the initial location | `SettingsScreen` is rendered and the shell navigation rail remains visible at the test viewport | C0+C1 |
| DT4 | settings account detail is the focused Google and Drive Sync flow | router starts at `/settings/account` | app router resolves the initial location | `AccountSettingsScreen` renders the Drive Sync section and both shell navigation surfaces are absent | C0+C1 |
| DT5 | settings learning detail is a focused child flow | router starts at `/settings/learning` | app router resolves the initial location | `LearningSettingsScreen` is rendered and both shell navigation surfaces are absent | C0+C1 |
| DT6 | settings audio detail is a focused child flow | router starts at `/settings/audio-speech` | app router resolves the initial location | `AudioSpeechSettingsScreen` is rendered and both shell navigation surfaces are absent | C0+C1 |
