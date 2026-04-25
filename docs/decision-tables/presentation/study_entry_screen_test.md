# Decision Tables: study_entry_screen_test

Test file: `test/presentation/study_entry_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `studyEntryStateProvider(entryType, entryRefId)` is unresolved and entry screen enters loading branch | deck study entry opens with a pending `Completer<StudyEntryState>` | the first frame is pumped before the future completes | `MxLoadingState` is rendered exactly once | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | deck entry type supports both New Study and SRS Review flows | loaded state has `entryType=deck`, `entryRefId=deck-001`, no resume candidate, and both default settings snapshots | study entry renders flow choices | `Start a study session`, `New Study`, `SRS Review`, and `Session settings` are visible | C0+C1 |
| DT2 | today entry type is review-only and hides New Study | loaded state has `entryType=today`, `entryRefId=null`, and review defaults | study entry renders flow choices | `SRS Review` is visible, `New Study` is hidden, and today-only copy is visible | C0+C1 |
