---
last_updated: 2026-06-01
applies_to: TTS settings, speech playback, audio settings screen
---

# TTS Settings

> **Status: Current V1 global/front-language settings; Target per-language independence.** Current settings persist as one Drift-backed row in the `tts_settings` table through `TtsSettingsDao` and `TtsSettingsRepositoryImpl`. Independent Korean/English setting sets remain Target/Future and must not be treated as Current. Per-deck TTS gating policy depends on `decks.target_language` from `docs/database/schema-contract.md` §Pending schema changes.

## Source files to inspect

- `lib/domain/services/tts_service.dart` (TtsService, TtsSettings, TtsLanguage, TtsVoice, TtsState, TtsTextSide)
- `lib/domain/services/tts_playback_policy.dart` (TtsPlaybackPolicy)
- `lib/domain/usecases/tts_usecases.dart` (SpeakFlashcardUseCase)
- `lib/domain/repositories/tts_settings_repository.dart`
- `lib/data/repositories/tts_settings_repository_impl.dart`
- `lib/data/datasources/local/daos/tts_settings_dao.dart`
- `lib/data/datasources/local/tables/tts_settings_records_table.dart`
- `lib/data/services/flutter_tts_service.dart` (platform implementation)
- `lib/presentation/features/tts/providers/tts_settings_notifier.dart`
- `lib/presentation/features/tts/providers/tts_controller_notifier.dart`
- `lib/presentation/features/settings/screens/audio_speech_settings_screen.dart`
- `lib/presentation/features/settings/widgets/speech_settings_group.dart`
- `lib/presentation/features/settings/widgets/speech_audio_sliders.dart`
- `lib/app/di/tts_providers.dart`

## Data

Current V1 storage is the Drift `tts_settings` table (Dart table class `TtsSettingsRecords`) through `TtsSettingsDao` and `TtsSettingsRepositoryImpl`.

The table is a single-row pattern with id = `'default'`.

Status: Current for the global/front-language settings row. Target/Future for independent per-language settings; do not add separate per-language storage in a normal parity task without an approved migration/product decision.

Fields:

| Field | Type | Constraint |
| --- | --- | --- |
| `id` | TEXT PK | Always `'default'` (single-row pattern) |
| `auto_play` | BOOL | - |
| `front_language` | TEXT | `'korean'` or `'english'` |
| `rate` | REAL | CHECK between 0.3 and 0.7 |
| `pitch` | REAL | CHECK between 0.7 and 1.5 |
| `volume` | REAL | CHECK between 0.0 and 1.0 |
| `front_voice_name` | TEXT NULL | Voice id from platform |

## Supported languages

| Language | Locale tag | Storage value |
| --- | --- | --- |
| Korean | `ko-KR` | `korean` |
| English | `en-US` | `english` |

Default app TTS language: Korean.

When `front_language` storage value is unknown, fall back to Korean.

## Deck-level language gate

Each deck declares a `target_language` (see `docs/business/deck/deck-management.md`). TTS behavior is gated by this declaration:

| Deck `target_language` | TTS speak action | Auto-play |
| --- | --- | --- |
| `korean` | Enabled, uses `ko-KR` voice from settings | Honors `autoPlay` toggle |
| `english` | Enabled, uses `en-US` voice from settings | Honors `autoPlay` toggle |
| `unsupported` | Speak button disabled / hidden | Suppressed silently (no toast) |

This prevents wrong-accent playback (e.g., Vietnamese front spoken with English voice). The deck-level gate is checked BEFORE the playback policy that restricts side to `front`.

When a deck's `target_language` differs from the app TTS `frontLanguage` setting, the deck's language wins for that deck's playback. The app setting is a default, not an override.

## Setting ranges and defaults

| Setting | Min | Max | Default |
| --- | --- | --- | --- |
| `rate` | 0.3 | 0.7 | 0.5 |
| `pitch` | 0.7 | 1.5 | 1.0 |
| `volume` | 0.0 | 1.0 | 1.0 |
| `autoPlay` | - | - | `false` |
| `frontLanguage` | - | - | `korean` |
| `frontVoiceName` | - | - | `null` |

Source of truth: constants in `TtsSettings` (`minRate`, `maxRate`, `defaultRate`, etc.).

## Normalization rules

- Every write to `rate`, `pitch`, `volume` MUST go through `TtsSettings.normalizeRate`, `normalizePitch`, `normalizeVolume`.
- Normalization clamps to `[min, max]` and returns `double`.
- Normalization applies on both read (repository load) and write (DAO save) so corrupt values self-heal.

## Voice selection

- Available voices come from the platform via `TtsService.availableVoices(language)`.
- Voices are filtered by language tag.
- `frontVoiceName` stores the platform-specific voice identifier.
- Current V1 has one global/front-language `frontVoiceName`, not per-language voice storage.
- Changing `frontLanguage` MUST clear `frontVoiceName` (via `clearFrontVoice: true` in `copyWith`) because the stored voice belongs to the previous front language.
- When the stored voice name is no longer available on the device, the expanded selector falls back to System voice and does not crash. Eager validation/remediation on screen open is Target/Future.
- Target/Future per-language voice storage may persist one voice per supported language after the independent settings migration exists.

## Playback policy

TTS playback is restricted by `TtsPlaybackPolicy`:

| Card side | Can speak? |
| --- | --- |
| `front` | Yes |
| `back` | No |
| `note` | No |

Rationale: TTS today is for prompts (front of card). Back/note are user-revealed content and not spoken.

This restriction is enforced in `SpeakFlashcardUseCase.speakFlashcardSide` via `_playbackPolicy.canSpeakFlashcardSide(side)`. Do not bypass.

## TTS state

`TtsService.state` is a `Stream<TtsState>`:

| State | Meaning |
| --- | --- |
| `idle` | No active playback |
| `speaking` | Currently speaking |
| `paused` | Paused (platform-supported) |
| `error` | Last operation failed |

UI components (e.g., `MxSpeakButton`) react to this stream for play/stop state.

## Rules

- TTS settings is a single global/front-language setting set (no independent Korean/English settings and no per-deck override yet).
- All settings changes persist immediately on user interaction (no save button).
- Blank text (whitespace-only) MUST NOT trigger speech (`StringUtils.isBlank` guard in `SpeakFlashcardUseCase.speakText`).
- Text is trimmed before passing to platform TTS.
- Voice name is trimmed to null on load (empty string → null).
- TTS service is platform-specific (Flutter TTS plugin). Domain layer interacts only via `TtsService` interface.
- Auto-play applies only to study session flashcard reveal. Other surfaces use explicit user tap.

## Screen behavior

`AudioSpeechSettingsScreen` (route: `/settings/audio-speech`) renders `SpeechSettingsGroup` which includes:

- Auto-play toggle.
- Front language picker.
- Voice picker (filtered by current language).
- Rate slider (0.3 → 0.7).
- Pitch slider (0.7 → 1.5).
- Volume slider (0.0 → 1.0).
- Test speak action (sample text).

Loading/error states use shared `Mx*` widgets per UI/UX contract.

## Required UI states

- Loading: while `TtsSettingsNotifier` initial build resolves.
- Error: when repository load fails (rare, since defaults fall back).
- Voice list loading: while `availableVoices` resolves per language.
- Voice list empty: when platform reports zero voices for the language.

## Performance

- Voice list query may be slow on first call per language. Current Settings UI loads voices lazily when voice options are expanded.
- Speak action: do not queue multiple speaks. Stop previous before starting next.

## Agent rule

- Do not introduce a separate TTS settings table. Preserve the current `tts_settings` single-row pattern unless an approved migration/product decision explicitly changes it.
- Do not bypass `TtsPlaybackPolicy` to speak back/note. If a new playable side is needed, update the policy first and document here.
- Do not add per-deck TTS override without updating this doc and schema.
- All slider write paths MUST go through `TtsSettings.normalize*` helpers.
- Changing `frontLanguage` MUST clear `frontVoiceName` (otherwise the stored voice belongs to a different language).

## Related

**Wireframes:**

- `docs/wireframes/21-settings-audio-speech.md` — Current global/front-language TTS settings; Target per-language tabs/settings
- `docs/wireframes/13-study-session-review.md` through `docs/wireframes/17-study-session-fill.md` — TTS button per mode (front only, never back)

**Schema:**

- Current V1 settings table: `tts_settings` via `lib/data/datasources/local/tables/tts_settings_records_table.dart` (`TtsSettingsRecords` Dart class).
- Schema: `decks.target_language` gates TTS when the deck-language migration is active.

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "TTS" (gating, autoplay, range validation, front-only policy)

**Glossary terms:**

- `docs/business/glossary.md` → `target_language`, `korean`, `english`, `unsupported`, "auto-play", "front-only playback"

**Related business specs:**

- `docs/business/deck/deck-management.md` — `target_language` field on deck
- `docs/business/study/study-flow.md` — TTS is invoked per study mode

**Source files to inspect:**

- `lib/domain/services/tts_service.dart`
- `lib/domain/services/tts_playback_policy.dart`
- `lib/presentation/features/settings/screens/audio_speech_settings_screen.dart`
- `lib/presentation/features/settings/widgets/speech_settings_group.dart`
