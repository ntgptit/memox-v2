# Decision Tables: settings_screen_test

Test file: `test/presentation/settings_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | settings opens with default theme and locale providers | fresh `ProviderContainer` has default `themeModeProvider` and `localeProvider` values | settings screen settles | `Settings`, `Light`, `System`, and `English` are visible | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | normal width and text scale use sectioned settings layout | settings screen renders without compact fallback constraints | page content is displayed | `Appearance` and `Language` sections are visible | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | segmented controls update the selected theme and locale providers | settings screen is rendered at normal size | user taps `Dark`, then taps `Vietnamese` | `themeModeProvider` becomes `ThemeMode.dark`, success snackbar appears, and `localeProvider` becomes `Locale('vi')` | C0+C1 |
| DT2 | compact width or large text scale falls back to radio list controls and still updates providers | screen is constrained to 320 by 640 with text scale 1.4 | user taps `Dark`, scrolls to `Vietnamese`, and taps it | three `RadioListTile<ThemeMode>` controls are rendered, `themeModeProvider` becomes dark, and `localeProvider` becomes Vietnamese | C0+C1 |
