# Decision Tables: dashboard_screen_test

Test file: `test/presentation/dashboard_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `dashboardOverviewProvider` is unresolved and DashboardScreen enters the loading branch | dashboard route is opened with a pending `Completer<DashboardOverviewState>` | the first frame is pumped before the future completes | `DashboardSkeleton` is rendered exactly once | C0+C1 |

## Decision table: onSearchFilterSort

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `dashboardOverviewProvider` completes with an error and DashboardScreen enters the error branch | dashboard overview future throws `Exception('dashboard failed')` | the widget settles after provider completion | `MxErrorState` is rendered for retryable dashboard failure | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | loaded overview has review cards and Home kit metrics | `DashboardOverviewState` has `overdueCount=3`, `dueTodayCount=2`, `deckCount=3`, `cardCount=20`, and `masteryPercent=30` | dashboard renders the loaded data branch | `Today`, `Good evening, learner`, due-now CTA, review time estimate, full-width `Start review`, Streak and Mastery stat cards with supporting progress text, mastered-card count, and pickup section are visible | C0+C1 |
| DT2 | loaded overview has no review cards | `DashboardOverviewState` has zero review counts and no suggested decks | dashboard renders the loaded data branch | caught-up CTA replaces review CTA, `View library` remains available, and no disabled review button is rendered | C0+C1 |
| DT3 | dashboard review CTA must remain primary and full-width | `DashboardOverviewState` has review cards | dashboard renders the loaded data branch | `Start review` uses the primary button surface and spans the card width | C0+C1 |
| DT4 | Home stats use derived mastery count plus compact design-system support text | `DashboardOverviewState` has one folder, one deck, one card, and one percent mastery | dashboard renders the loaded data branch | Mastery stat renders a derived card count and percent support text, while duplicated old library metadata and `1 folders` are absent | C0+C1 |
| DT5 | recent deck highlights have more than three items and include due counts | dashboard state contains four deck highlights with at least one `lastStudiedAt` and the first deck has due cards | dashboard renders deck highlight section | `Pick up where you left off` appears, only the first three deck rows render, first deck metadata shows due count plus card count, and the first deck study action badge shows due count | C0+C1 |
| DT6 | deck highlights are all fallback decks with no `lastStudiedAt` | dashboard state contains suggested decks but none has been studied | dashboard renders deck highlight section | `Start a deck` appears instead of `Recent decks`, with deck metadata shown as card count only | C0+C1 |
| DT7 | no deck has cards to suggest | dashboard state has an empty `deckHighlights` list | dashboard renders loaded data branch | `Recent decks` is absent; empty-deck card shows `Start a deck` and the new-study empty body string once | C0+C1 |

_Disabled action visuals are driven by `ThemeData` / `ButtonTheme` tokens only — feature code must not wrap dashboard action buttons in `Opacity`._

## Decision table: onResponsive

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | dashboard renders Home kit hierarchy on compact-mobile density target | loaded dashboard state renders at logical size `412x915` with review cards and pickup data | dashboard lays out the first viewport | greeting, due-now CTA, full-width `Start review`, and pickup section remain visible, and the due card stays within the viewport width | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | Today Review has overdue or due-today cards, so Review is enabled | dashboard data has `overdueCount=3` and `dueTodayCount=2` and the router exposes the study-today route nested under Library | user taps `dashboard_review_now_action` | route path becomes `/library/study/today` | C0+C1 |
| DT2 | New Study has cards available, so Start opens Library selection | dashboard data has `newCardCount=7` and the router exposes the library route | user taps `dashboard_start_new_study_action` | route path becomes `/library` | C0+C1 |
| DT5 | recent deck row body opens flashcard management without replacing the dashboard route | dashboard data contains recent deck `deck-grammar` and the router exposes the flashcard-list route | user taps the `dashboard_deck_deck-grammar` row, then the route stack is popped | `flashcard_list_destination` is rendered from an imperative push, `router.canPop()` is true, and popping returns to dashboard content instead of using the flashcard screen fallback | C0+C1 |
| DT6 | recent deck study action opens deck Study Entry | dashboard data contains recent deck `deck-grammar` and the router exposes the study-entry route | user taps `dashboard_deck_study_deck-grammar` | route path becomes `/library/study/deck/deck-grammar` | C0+C1 |
