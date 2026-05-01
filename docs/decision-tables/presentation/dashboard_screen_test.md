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
| DT1 | loaded overview has overdue reviews, due-today reviews, new cards, one active session, and library progress metrics | `DashboardOverviewState` has `overdueCount=3`, `dueTodayCount=2`, `newCardCount=7`, `activeSessionCount=1`, `folderCount=2`, `deckCount=3`, `cardCount=20`, and `masteryPercent=30` | dashboard renders the loaded data branch | `PieChart`, Library progress, `30%`, compact Today Review, New Study, Resume rows, and their labeled counts are visible | C0+C1 |
| DT2 | loaded overview has no review cards, no new cards, and no active sessions | `DashboardOverviewState` has zero counts for review, new study, and resume actions | dashboard renders the loaded data branch | Review, Start, and Resume actions are disabled while the Library progress chart remains visible | C0+C1 |
| DT3 | dashboard study action labels must stay concise while mixed enabled states preserve equal CTA geometry | `DashboardOverviewState` has no review cards, new cards available, and no active sessions so Review and Resume are disabled while Start is enabled | dashboard renders the loaded data branch | action labels are `Review`, `Start`, and `Resume`, old long labels are absent, and all three action containers resolve to the same compact visual width | C0+C1 |
| DT4 | library progress uses separate mastery and structural metadata with singular plurals | `DashboardOverviewState` has one folder, one deck, one card, and one percent mastery | dashboard renders the loaded data branch | `1% mastery` and `1 folder · 1 deck · 1 card` are visible while duplicated old metadata and `1 folders` are absent | C0+C1 |
| DT5 | recent deck highlights have more than three items and include due counts | dashboard state contains four deck highlights with at least one `lastStudiedAt` and the first deck has due cards | dashboard renders deck highlight section | `Recent decks` appears, only the first three deck rows render, metadata shows card count only, and the first deck study action badge shows due count | C0+C1 |
| DT6 | deck highlights are all fallback decks with no `lastStudiedAt` | dashboard state contains suggested decks but none has been studied | dashboard renders deck highlight section | `Start a deck` appears instead of `Recent decks`, with deck metadata shown as card count only | C0+C1 |
| DT7 | no deck has cards to suggest | dashboard state has an empty `deckHighlights` list | dashboard renders loaded data branch | both `Recent decks` and `Start a deck` sections are absent | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | Today Review has overdue or due-today cards, so Review is enabled | dashboard data has `overdueCount=3` and `dueTodayCount=2` and the router exposes the study-today route nested under Library | user taps `dashboard_review_now_action` | route path becomes `/library/study/today` | C0+C1 |
| DT2 | New Study has cards available, so Start opens Library selection | dashboard data has `newCardCount=7` and the router exposes the library route | user taps `dashboard_start_new_study_action` | route path becomes `/library` | C0+C1 |
| DT3 | Resume has exactly one active session, so Resume opens that session directly | dashboard data has `activeSessionCount=1`, `resumeSessionId=session-001`, and the router exposes the study-session route nested under Library | user taps `dashboard_continue_session_action` | route path becomes `/library/study/session/session-001` | C0+C1 |
| DT4 | Resume has multiple active sessions, so Resume opens Progress for selection | dashboard data has `activeSessionCount=2` and no single resume session id | user taps `dashboard_continue_session_action` | route path becomes `/progress` | C0+C1 |
| DT5 | recent deck row body opens flashcard management | dashboard data contains recent deck `deck-grammar` and the router exposes the flashcard-list route | user taps the `dashboard_deck_deck-grammar` row | route path becomes `/library/deck/deck-grammar/flashcards` | C0+C1 |
| DT6 | recent deck study action opens deck Study Entry | dashboard data contains recent deck `deck-grammar` and the router exposes the study-entry route | user taps `dashboard_deck_study_deck-grammar` | route path becomes `/library/study/deck/deck-grammar` | C0+C1 |
