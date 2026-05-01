# Decision Tables: study_entry_screen_test

Test file: `test/presentation/study_entry_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `studyEntryStateProvider(entryType, entryRefId)` is unresolved and the shared async state enters first-load loading | deck study entry opens with a pending `Completer<StudyEntryState>` | the first frame is pumped before the future completes | `MxLoadingState` is rendered exactly once | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | deck entry type supports both New Study and SRS Review flows | loaded state has `entryType=deck`, `entryRefId=deck-001`, no resume candidate, and both default settings snapshots | study entry renders flow choices | `Start a study session`, `New Study`, `SRS Review`, and `Session settings` are visible | C0+C1 |
| DT2 | today entry type is review-only and hides New Study | loaded state has `entryType=today`, `entryRefId=null`, and review defaults | study entry renders flow choices | `SRS Review` is visible, `New Study` is hidden, and today-only copy is visible | C0+C1 |
| DT3 | resume candidate exists and restart must not be hidden behind the primary CTA label | loaded state has `entryType=deck`, one active resume candidate, and default settings | study entry renders the resume branch | `Continue` and `Start` are visible, while `Restart` is hidden | C0+C1 |
| DT4 | New Study batch size is already at its maximum | loaded deck state uses New Study defaults with batch size 20 | user taps the increase control | batch size remains `20`, the range `5-20 cards` is visible, and no value above the New Study max is rendered | C0+C1 |
| DT5 | SRS Review batch size is already at its maximum | loaded today state uses review defaults with batch size 50 | user taps the increase control | batch size remains `50`, the range `5-50 cards` is visible, and no value above the review max is rendered | C0+C1 |

## Decision table: onSelect

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `Start` is selected while an unfinished resume candidate exists | loaded deck state has one resume candidate | user taps `Start` | confirmation dialog states `Starting a new session will cancel the current unfinished session.` before restart can proceed | C0+C1 |
