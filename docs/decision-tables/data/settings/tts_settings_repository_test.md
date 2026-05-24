# Decision Tables: tts_settings_repository_test

Test file: `test/data/settings/tts_settings_repository_test.dart`

## Decision table: load

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | no Drift TTS settings row exists | `tts_settings` is empty | repository loads settings | defaults are `autoPlay=false`, front Korean, rate `0.5`, pitch `1.0`, volume `1.0`, and no front voice | C0+C1 |
| DT2 | persisted row has unknown front language and blank voice | `tts_settings.default` contains unknown language, valid audio values, and whitespace voice name | repository loads settings | language falls back to Korean, audio values are preserved, and front voice becomes null | C0+C1 |

## Decision table: save

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | settings include selected front language, audio controls, and named front voice | settings use English front, rate `0.6`, pitch `1.1`, volume `0.9`, and one front voice name | repository saves settings | `tts_settings.default` stores exact bool/string/double values and voice name | C0+C1 |
| DT2 | settings replace an existing row and audio controls are outside valid ranges | existing default row has a named voice and next settings pass low rate, high pitch, low volume, and null voice | repository saves settings | only one default row remains, rate/pitch/volume are clamped, and front voice is null | C0+C1 |
