# Decision Tables: study_entry_screen_test

Test file: `test/presentation/study_entry_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | direct-start entry state is unresolved | deck study entry opens with a pending `Completer<StudyEntryState>` | the first frame is pumped before the future completes | `MxLoadingState` is rendered exactly once while no mode-selection screen is shown | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | mix mode is requested by omitting the mode query | loaded deck state has no resume candidate and New Study defaults | study entry route opens at `/study/deck/deck-001` | route replaces itself with the study session, starts `new_full_cycle`, and queues modes `review`, `match`, `guess`, `recall`, `fill` | C0+C1 |
| DT2 | a single mode is requested by query parameter | loaded deck state has no resume candidate and the route query is `mode=match` | study entry route opens | route replaces itself with the study session, starts `new_match_only`, and queues only `match` | C0+C1 |
| DT3 | resume candidate exists for the entry | loaded deck state contains `resume-session-001` | study entry route opens | route replaces itself with `resume-session-001` and does not start a new session | C0+C1 |
| DT4 | start is rejected because no eligible flashcards are available | loaded deck state has no resume candidate and repository returns an empty eligible batch | study entry route opens | `MxErrorState` shows the no-eligible-flashcards message with retry instead of navigating | C0+C1 |
