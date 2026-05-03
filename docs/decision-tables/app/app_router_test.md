# Decision Tables: app_router_test

Test file: `test/app/router/app_router_test.dart`

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | study session path uses reserved `session` segment that overlaps the dynamic study entry route shape | router starts at `/library/study/session/session-001` with a loaded session snapshot | app router resolves the initial location | `StudySessionScreen` is rendered and `StudyEntryScreen` is absent | C0+C1 |
| DT2 | deck import is a focused child flow that must not compete with top-level shell navigation | router starts at `/library/deck/deck-001/import` | app router resolves the initial location | `DeckImportScreen` is rendered and both `NavigationBar` and `NavigationRail` are absent | C0+C1 |
