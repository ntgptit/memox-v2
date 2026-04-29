# Decision Tables: progress_screen_test

Test file: `test/presentation/progress_screen_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | active session list is empty but progress analytics are available | progress provider returns library overview metrics and an empty active session list | Progress screen renders | `Learning overview` analytics remain visible, `Active sessions` renders an empty state, and Library navigation is offered | C0+C1 |
| DT2 | active session list has in-progress, ready, and failed-finalize sessions | progress provider returns library overview metrics plus three active sessions across the supported active statuses | Progress screen renders | learning overview metrics, active-session counters, status badges, session cards, and management actions are visible | C0+C1 |
| DT3 | medium-width learning overview has enough horizontal space for metric cards | progress provider returns overview metrics and the viewport resolves to a non-compact layout | Progress screen renders the learning overview | review, new-card, mastery, and active-session metrics share one horizontal row instead of narrowing into a vertical stack | C0+C1 |
| DT4 | New Study active session has multiple required modes per card | progress provider returns one New Study session with 10 cards, 5 total modes, 10 completed attempts, and 40 pending mode items | Progress screen renders the active session card | progress text says `10 of 50 study steps · 40 remaining`, and the progress bar value is 20% instead of treating 40 pending items as remaining cards | C0+C1 |

## Decision table: onSelect

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | cancel is requested from a session card | progress screen shows one cancellable active session and repository fake records cancel calls | user taps cancel and then confirms the dialog | confirmation is shown before mutation, then the repository receives one cancel call | C0+C1 |
