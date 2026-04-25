# Decision Tables: dashboard_screen_test

Test file: `test/presentation/dashboard_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `libraryOverviewQueryProvider` is unresolved and DashboardScreen enters the loading branch | dashboard route is opened with a pending `Completer<LibraryOverviewState>` | the first frame is pumped before the future completes | `MxLoadingState` is rendered exactly once | C0+C1 |

## Decision table: onSearchFilterSort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `libraryOverviewQueryProvider` completes with an error and DashboardScreen enters the error branch | dashboard query future throws `Exception('dashboard failed')` | the widget settles after provider completion | `MxErrorState` is rendered for retryable dashboard failure | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | loaded library state contains greeting metrics, one folder, twelve cards, and thirty percent mastery | `LibraryOverviewState` has `dueToday=2`, one folder, `itemCount=12`, and `masteryPercent=30` | dashboard renders the loaded data branch | study focus, `1 folders · 12 cards`, and `30%` are visible | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `hasDueCards` is true, so the primary CTA is Study today | dashboard data has `dueToday=2` and the router exposes the study-today route | user taps `dashboard_study_today_action` | route path becomes `/study/today` | C0+C1 |
| DT2 | `hasDueCards` is false, so the primary CTA is Open library and Study today is hidden | dashboard data has `dueToday=0` and the router exposes the library route | user taps `dashboard_open_library_action` | Study today action is absent, Open library button is enabled, and route path becomes `/library` | C0+C1 |
