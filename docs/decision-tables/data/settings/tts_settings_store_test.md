# Decision Tables: tts_settings_store_test

Test file: `test/data/settings/tts_settings_store_test.dart`

## Decision table: load

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | no persisted speech settings exist | SharedPreferences has no TTS keys | store loads settings | defaults are `autoPlay=false`, front Korean, rate `0.5`, and no front voice | C0+C1 |
| DT2 | persisted values contain invalid front language, legacy back keys, blank voice, and out-of-range rate | front language is unknown, legacy back language is blank, rate is `9.0`, and voice strings are blank | store loads settings | front falls back to Korean, rate clamps to `0.7`, and front voice becomes null | C0+C1 |

## Decision table: save

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | settings include selected front language, clamped rate, and named front voice | settings use English front, rate `0.6`, and one front voice name | store saves settings | front SharedPreferences keys store exact expected bool/string/double values and legacy back keys are removed | C0+C1 |
| DT2 | settings clear optional front voice and clamp low rate | existing front/back voice keys are present and settings pass null front voice with rate `0.1` | store saves settings | voice keys are removed and stored rate is clamped to `0.3` | C0+C1 |
