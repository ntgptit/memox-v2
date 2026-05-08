# Decision Tables: tts_playback_policy_test

Test file: `test/domain/tts_playback_policy_test.dart`

## Decision table: canSpeakTextSide

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | raw text request has no card side | side is `null` | TTS text side policy is evaluated | raw text playback is allowed | C0+C1 |
| DT2 | card side is explicit | side is `front` and then `back` | TTS text side policy is evaluated | front playback is allowed and back playback is rejected | C0+C1 |

## Decision table: canSpeakFlashcardSide

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | flashcard side is explicit | side is `front` and then `note` | TTS flashcard side policy is evaluated | front playback is allowed and note playback is rejected | C0+C1 |
