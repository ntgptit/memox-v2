# Decision Tables: app_navigation_test

Test file: `test/app/app_navigation_test.dart`

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `BuildContext.popRoute` sees `Navigator.canPop == false` and must execute fallback navigation | router starts directly at `/detail` with no previous route in the stack | user taps `Close` and `popRoute(fallback: go('/fallback'))` runs | fallback page text `Fallback` is visible | C0+C1 |
| DT2 | `BuildContext.popRoute` sees `Navigator.canPop == true` and must pop instead of executing fallback | router starts at `/`, user opens `/detail`, and fallback route also exists | user taps `Close` on the detail page | root page text `Open detail` is visible and `Fallback` is absent | C0+C1 |
| DT3 | deck-scoped study entry must preserve the previous deck route for app-bar back navigation | router starts at `/deck/deck-001/flashcards` and a button calls `goStudyEntry(entryType: 'deck', entryRefId: 'deck-001')` | user opens study entry and then taps `Back` on the study page | flashcard-list page text `Deck screen` is visible again instead of falling back to `Library` | C0+C1 |
| DT4 | study session route must preserve the study entry route underneath | router starts at a study entry route and a button calls `goStudySession('session-001')` | user opens the session and then taps `Back` on the session page | study entry text is visible again instead of falling back to `Library` | C0+C1 |
| DT5 | study result route must replace the completed session while preserving the route below the session | router starts at a study entry route, opens a session with `goStudySession`, and then calls `goStudyResult('session-001')` from the session | user taps `Back` on the result page | study entry text is visible and the session page is absent | C0+C1 |
| DT6 | pushed Today study entry must preserve the result/source route underneath | router starts at a study result route with a previous route in stack and a button calls `pushStudyToday()` | user opens Today study and then taps `Back` | result page text is visible again instead of falling back to `Library` | C0+C1 |
| DT7 | deck-scoped study entry may replace the current route when caller opts out of stack preservation | router starts at `/home` and a button calls `goStudyEntry(entryType: 'deck', entryRefId: 'deck-001', preserveStack: false)` | user taps `Study from home` | route path becomes `/study/deck/deck-001` and study entry text is visible | C0+C1 |
