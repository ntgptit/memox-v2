# Decision Tables: settings_screen_test

Test file: `test/presentation/settings_screen_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | settings opens with default account, theme, locale, study defaults, and collapsed speech voice options | fresh `ProviderContainer` has no linked account, default `themeModeProvider`, `localeProvider`, study settings in SharedPreferences, and collapsed speech voice options | settings screen settles and the user scrolls down from the Account group | `Settings`, `Account`, Google account signed-out or unconfigured copy, `Light`, `System`, `English`, and `Study defaults` are available, and no TTS voice lookup runs before voice options are opened | C0+C1 |
| DT2 | study defaults provider is still loading on first render | `studySettingsStoreProvider` is held by a pending future while other settings dependencies are available | settings screen pumps the first frame and scrolls to study defaults | `Study defaults`, `Loading study defaults`, and one shared loading state are visible | C0+C1 |
| DT3 | speech settings provider is still loading on first render | `ttsSettingsStoreProvider` is held by a pending future while other settings dependencies are available | settings screen pumps the first frame and scrolls to the speech section | `Speech`, `Loading speech settings`, and one shared loading state are visible | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | normal width and text scale use sectioned settings layout | settings screen renders without compact fallback constraints | page content is displayed | `Appearance` and `Language` sections are visible | C0+C1 |
| DT2 | speech settings are loaded with supported front-side TTS languages and advanced voice controls collapsed | fake TTS service exposes Korean and English voices | page content is displayed | `Speech`, auto-play, front language, and `Voice options` are visible; back language and all voice selectors are hidden; the single speech language control contains only Korean and English | C0+C1 |
| DT3 | study defaults are loaded from SharedPreferences-backed store | settings store has default New Study batch `10`, Review batch `20`, and shared study toggles enabled | page content is displayed and scrolled to study defaults | `Study defaults`, New Study batch, Review batch, valid ranges `5-20 cards` and `5-50 cards`, shuffle flashcards, shuffle answers, and prioritize overdue controls are visible before Speech | C0+C1 |
| DT4 | persisted study batch defaults are outside the current valid ranges | SharedPreferences contains New Study batch `100` and Review batch `1` from an older app version | settings screen loads study defaults | provider state, settings store reads, and rendered stepper values clamp to New Study `20` and Review `5` before user interaction | C0+C1 |
| DT5 | Google OAuth config is missing | account provider has no Google client IDs for the current platform | settings screen loads Account section | missing-config copy is visible and `Sign in with Google` is disabled | C0+C1 |
| DT6 | linked account has Drive appdata scope | account store contains a Google account with `drive.appdata` granted | settings screen loads Account section | avatar identity, email, `Google Drive ready`, and `Sign out` are visible | C0+C1 |
| DT7 | linked account is missing Drive appdata scope | account store contains a Google account without Drive appdata authorization | settings screen loads Account section | account identity is visible with `Google Drive reconnect required` and `Reconnect Google Drive` | C0+C1 |
| DT8 | web account reconnect requires Google-rendered platform button | account store contains a Google account without Drive appdata authorization and auth service requires the platform sign-in button | settings screen loads Account section | account identity stays visible, custom `Reconnect Google Drive` button is hidden, and `Sign out` remains available | C0+C1 |
| DT9 | Drive sync cannot run while signed out | sync repository reports signed-out status and account group is available | settings screen loads Drive Sync section below Account | `Drive sync` shows only the `Sync now` action and the button is disabled | C0+C1 |
| DT10 | Drive sync can run when Drive access is ready | sync repository reports no remote snapshot for a Drive-authorized account | settings screen loads Drive Sync section below Account | `Drive sync` shows only the `Sync now` action and the button is enabled | C0+C1 |
| DT11 | compact settings density fits account, sync, appearance, and language in the first phone viewport | settings screen renders on a 390 by 844 phone viewport with a Drive-ready account and Drive sync ready for first backup | page content is displayed without scrolling | Account, Drive sync, Appearance, and Language section titles all fit inside the initial viewport | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | segmented controls update the selected theme and locale providers | settings screen is rendered at normal size with Account group above Appearance | user scrolls controls into view, taps `Dark`, then taps `Vietnamese` | `themeModeProvider` becomes `ThemeMode.dark`, success snackbar appears, and `localeProvider` becomes `Locale('vi')` | C0+C1 |
| DT2 | compact width or large text scale falls back to radio list controls and still updates providers | screen is constrained to 320 by 640 with text scale 1.4 and Account group above Appearance | user scrolls controls into view, taps `Dark`, scrolls to `Vietnamese`, and taps it | three `RadioListTile<ThemeMode>` controls are rendered, `themeModeProvider` becomes dark, and `localeProvider` becomes Vietnamese | C0+C1 |
| DT3 | front-only speech controls update persisted settings and preview uses selected language | settings screen is rendered with fake TTS service | user enables auto-play, sets front language English, rate `0.7`, then taps `Preview audio` | `ttsSettingsProvider` stores the front language and rate, and fake service receives one English speak call with rate `0.7` | C0+C1 |
| DT4 | front voice picker is a progressive disclosure section | speech settings are rendered with voice options collapsed and default front language Korean | user taps `Voice options` | `Hide voice options` and front voice control appear, back voice remains hidden, and the fake TTS service receives one Korean voice lookup request | C0+C1 |
| DT5 | study default controls save batch sizes and shared toggles | settings screen is rendered with default study settings | user increases New Study batch, decreases Review batch, and disables shuffle flashcards, shuffle answers, and prioritize overdue | provider state and SharedPreferences store persist New Study batch `11`, Review batch `19`, and all three shared study toggles as disabled | C0+C1 |
| DT6 | Google sign-in succeeds and grants Drive appdata scope | Settings uses configured OAuth and fake Google auth service returning a Drive-ready account | user taps `Sign in with Google` | account store persists subject/email/scope metadata and Account section shows `Google Drive ready` | C0+C1 |
| DT7 | Google sign-in is canceled | Settings uses configured OAuth and fake Google auth service returning canceled | user taps `Sign in with Google` | account remains signed out and no account metadata is stored | C0+C1 |
| DT8 | Google Drive scope is denied after sign-in | fake Google auth returns account identity but no Drive appdata authorization | user taps `Sign in with Google` | account metadata is stored, Account section shows `Google Drive reconnect required`, and no token is stored | C0+C1 |
| DT9 | user signs out locally | account store contains a Drive-ready Google account and study data exists in SharedPreferences | user taps `Sign out` | account store is cleared while study default settings remain unchanged | C0+C1 |
