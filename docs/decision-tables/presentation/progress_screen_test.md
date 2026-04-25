# Decision Tables: progress_screen_test

Test file: `test/presentation/progress_screen_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | active session list is empty | progress provider returns an empty active session list | Progress screen renders | empty state explains that no active study sessions exist and offers Library navigation | C0+C1 |
| DT2 | active session list has in-progress, ready, and failed-finalize sessions | progress provider returns three active sessions across the supported active statuses | Progress screen renders | overview counters, status badges, session cards, and management actions are visible | C0+C1 |

## Decision table: onSelect

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | cancel is requested from a session card | progress screen shows one cancellable active session and repository fake records cancel calls | user taps cancel and then confirms the dialog | confirmation is shown before mutation, then the repository receives one cancel call | C0+C1 |
