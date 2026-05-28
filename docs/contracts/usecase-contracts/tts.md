---
last_updated: 2026-05-26
status: contract
---

# TTS Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.


Per-language settings, gating by `deck.target_language`, front-only playback.

## SpeakFrontUseCase

```dart
Future<Either<Failure, Unit>> call({required Flashcard card, required Deck deck});
```

**Rules:**
- If `deck.target_language == TargetLanguage.unsupported` → silently return `Right(unit)`. No error.
- Map `target_language` to `TtsLanguageCode`.
- Apply per-language settings (voice, rate, pitch, volume).
- Speak `card.front`. NEVER speak `card.back`.
- If TTS engine fails to initialize or speak → return `StorageFailure` (general kind, no user error popup needed; just log).

**Errors:** `StorageFailure` (engine).

## StopSpeechUseCase

```dart
Future<Either<Failure, Unit>> call();
```

Stops in-flight playback.

## ListVoicesUseCase

```dart
Future<Either<Failure, List<TtsVoice>>> call({required TtsLanguageCode lang});
```

Returns available voices on device for given language. Always prepends "System default".

**Errors:** `StorageFailure` (engine).

## GetTtsSettingsUseCase / UpdateTtsSettingsUseCase

```dart
Future<TtsSettings> getAll();
Future<Either<Failure, Unit>> updateAutoPlay(bool value);
Future<Either<Failure, Unit>> updateLanguageSettings(TtsLanguageCode lang, TtsLanguageSettings settings);
```

**Rules:**
- Validate rate ∈ [0.3, 0.7], pitch ∈ [0.7, 1.5], volume ∈ [0.0, 1.0]. Else `ValidationFailure(code: outOfRange)`.
- Per-language settings stored independently.
- Persist to SharedPreferences.

**Errors:** `ValidationFailure`, `StorageFailure`.

## Forbidden patterns

- ❌ Speak `back` anywhere.
- ❌ Auto-play when `deck.target_language == unsupported`. Silently skip.
- ❌ Couple Korean and English settings.
- ❌ Use different engine instance in preview vs study session.
- ❌ Show error popup on TTS engine failure during study. Log + silently skip.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Repositories used:** None (uses platform TTS engine via `lib/core/tts/` + SharedPreferences via `lib/data/datasources/local/preferences/`). TTS does NOT touch Drift.

**Business spec:** `docs/business/tts/tts-settings.md`
**Wireframes:** `docs/wireframes/21-settings-audio-speech.md`, `docs/wireframes/13-study-session-review.md` through `docs/wireframes/17-study-session-fill.md`
**Decision table:** rows under "TTS"
**Code paths:** `lib/domain/usecases/tts/**`, `lib/core/tts/**`
