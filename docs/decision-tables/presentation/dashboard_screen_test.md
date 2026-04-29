# Decision Tables: dashboard_screen_test

Test file: `test/presentation/dashboard_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `dashboardOverviewProvider` is unresolved and DashboardScreen enters the loading branch | dashboard route is opened with a pending `Completer<DashboardOverviewState>` | the first frame is pumped before the future completes | `MxLoadingState` is rendered exactly once | C0+C1 |

## Decision table: onSearchFilterSort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `dashboardOverviewProvider` completes with an error and DashboardScreen enters the error branch | dashboard overview future throws `Exception('dashboard failed')` | the widget settles after provider completion | `MxErrorState` is rendered for retryable dashboard failure | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | loaded overview has overdue reviews, due-today reviews, new cards, one active session, and library health metrics | `DashboardOverviewState` has `overdueCount=3`, `dueTodayCount=2`, `newCardCount=7`, `activeSessionCount=1`, `folderCount=2`, `deckCount=3`, `cardCount=20`, and `masteryPercent=30` | dashboard renders the loaded data branch | Today Review, New Study, Resume, Library health, separated counts, and `30%` are visible | C0+C1 |
| DT2 | loaded overview has no review cards, no new cards, and no active sessions | `DashboardOverviewState` has zero counts for review, new study, and resume actions | dashboard renders the loaded data branch | Review now, Start new study, and Continue session actions are disabled while Library health remains visible | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | Today Review has overdue or due-today cards, so Review now is enabled | dashboard data has `overdueCount=3` and `dueTodayCount=2` and the router exposes the study-today route nested under Library | user taps `dashboard_review_now_action` | route path becomes `/library/study/today` | C0+C1 |
| DT2 | New Study has cards available, so Start new study opens Library selection | dashboard data has `newCardCount=7` and the router exposes the library route | user taps `dashboard_start_new_study_action` | route path becomes `/library` | C0+C1 |
| DT3 | Resume has exactly one active session, so Continue session opens that session directly | dashboard data has `activeSessionCount=1`, `resumeSessionId=session-001`, and the router exposes the study-session route nested under Library | user taps `dashboard_continue_session_action` | route path becomes `/library/study/session/session-001` | C0+C1 |
| DT4 | Resume has multiple active sessions, so Continue session opens Progress for selection | dashboard data has `activeSessionCount=2` and no single resume session id | user taps `dashboard_continue_session_action` | route path becomes `/progress` | C0+C1 |
