# Decision Tables: app_navigation_test

Test file: `test/app/app_navigation_test.dart`

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `BuildContext.popRoute` sees `Navigator.canPop == false` and must execute fallback navigation | router starts directly at `/detail` with no previous route in the stack | user taps `Close` and `popRoute(fallback: go('/fallback'))` runs | fallback page text `Fallback` is visible | C0+C1 |
| DT2 | `BuildContext.popRoute` sees `Navigator.canPop == true` and must pop instead of executing fallback | router starts at `/`, user opens `/detail`, and fallback route also exists | user taps `Close` on the detail page | root page text `Open detail` is visible and `Fallback` is absent | C0+C1 |
