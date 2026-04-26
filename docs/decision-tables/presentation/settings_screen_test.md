# Decision Tables: settings_screen_test

Test file: `test/presentation/settings_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | settings opens with default theme and locale providers | fresh `ProviderContainer` has default `themeModeProvider`, `localeProvider`, and collapsed speech voice options | settings screen settles | `Settings`, `Light`, `System`, and `English` are visible, and no TTS voice lookup runs before voice options are opened | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | normal width and text scale use sectioned settings layout | settings screen renders without compact fallback constraints | page content is displayed | `Appearance` and `Language` sections are visible | C0+C1 |
| DT2 | speech settings are loaded with supported front-side TTS languages and advanced voice controls collapsed | fake TTS service exposes Korean and English voices | page content is displayed | `Speech`, auto-play, front language, and `Voice options` are visible; back language and all voice selectors are hidden; the single speech language control contains only Korean and English | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | segmented controls update the selected theme and locale providers | settings screen is rendered at normal size | user taps `Dark`, then taps `Vietnamese` | `themeModeProvider` becomes `ThemeMode.dark`, success snackbar appears, and `localeProvider` becomes `Locale('vi')` | C0+C1 |
| DT2 | compact width or large text scale falls back to radio list controls and still updates providers | screen is constrained to 320 by 640 with text scale 1.4 | user taps `Dark`, scrolls to `Vietnamese`, and taps it | three `RadioListTile<ThemeMode>` controls are rendered, `themeModeProvider` becomes dark, and `localeProvider` becomes Vietnamese | C0+C1 |
| DT3 | front-only speech controls update persisted settings and preview keeps TTS alive | settings screen is rendered with fake TTS service | user enables auto-play, sets front language English, rate `0.7`, then taps `Preview audio` | `ttsSettingsProvider` stores the front language and rate, fake service receives one English speak call with rate `0.7`, and controller disposal does not immediately stop the preview | C0+C1 |
| DT4 | front voice picker is a progressive disclosure section | speech settings are rendered with voice options collapsed and default front language Korean | user taps `Voice options` | `Hide voice options` and front voice control appear, back voice remains hidden, and the fake TTS service receives one Korean voice lookup request | C0+C1 |
