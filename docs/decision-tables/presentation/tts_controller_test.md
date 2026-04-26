# Decision Tables: tts_controller_test

Test file: `test/presentation/tts_controller_test.dart`

## Decision table: build

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | service state stream emits a new state | controller is built with fake `TtsService` | fake service emits `speaking` | controller state becomes `speaking` | C0+C1 |

## Decision table: speakText

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | text is blank | TTS settings are default and fake service records calls | `speakText` receives only whitespace | result is `false` and service `speak` is not called | C0+C1 |
| DT2 | text is present and service succeeds | persisted settings contain rate `0.6` and front voice `Korean Voice` | `speakText` receives Korean text for front side | result is `true` and service receives the exact text, Korean language, rate, and voice name | C0+C1 |
| DT3 | service throws while speaking | fake service is configured to throw on speak | `speakText` receives nonblank text | result is `false` and controller state becomes `error` | C0+C1 |
| DT4 | non-front card side is requested | TTS settings are default and fake service records calls | `speakText` receives side `back` | result is `false` and service `speak` is not called | C0+C1 |

## Decision table: stop

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | stop succeeds | fake service has an active controller | controller `stop` is called | service stop count increments and controller state becomes `idle` | C0+C1 |
