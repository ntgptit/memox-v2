---
last_updated: 2026-05-26
route: /settings/audio-speech
source_specs:
  - docs/business/tts/tts-settings.md
  - docs/business/deck/deck-management.md
---

# 21 — Settings: Audio & Speech

## Purpose

Configure Text-to-Speech (TTS) per supported language. TTS is gated by `deck.target_language` at the deck level; this screen sets per-language defaults that decks use.

## V1 verification status

Prompt 21 (2026-05-31) treats this screen as route-safe sub-screen coverage only. Current code implements global/front-language TTS settings, not independent per-language tabs.

| Aspect | V1 status | Notes |
| --- | --- | --- |
| Route `/settings/audio-speech` | Current | Reachable from Settings Hub; hides shell navigation; back returns to hub when pushed from the hub. |
| Auto-play | Current | Global auto-play preference. |
| Front language | Current | One selected front language (`korean` or `english`). |
| Voice/rate/pitch/volume | Current | One front voice/rate/pitch/volume setting set, normalized by `TtsSettings`. |
| Preview | Current | Uses the same `TtsService` path as study speech. |
| Per-language independent tabs/settings | Future/Target | Original tab layout remains target behavior; current V1 does not persist separate Korean and English setting sets. |
| Play-after-grading toggle / reset / unsupported-language explainer | Future/Target | Not implemented in current V1. |

## Layout

```
┌───────────────────────────────────────┐
│ ←   Audio & Speech                    │
├───────────────────────────────────────┤
│                                       │
│ GENERAL                               │
│ ┌───────────────────────────────────┐ │
│ │ Auto-play on card open     [●━━]  │ │  ← Default off
│ ├───────────────────────────────────┤ │
│ │ Play after grading         [○━━]  │ │  ← Always off in v1 (spec)
│ └───────────────────────────────────┘ │
│ ⓘ MemoX plays only the front. Backs   │
│   are not spoken to avoid leaks.      │
│                                       │
│ LANGUAGES                             │
│ ┌─[ Korean ]─[ English ]──────────────┐
│ └───────────────────────────────────┘ │  ← Tabs per supported language
│                                       │
│ ┌─── Korean ───────────────────────┐  │  ← Tab content
│ │ Voice                            │  │
│ │ ◉ System default (ko-KR)         │  │
│ │ ○ Yuna (female)                  │  │
│ │ ○ Joon (male)                    │  │
│ │ ○ Sora (female)                  │  │
│ │                                  │  │
│ │ Speech rate                      │  │
│ │ ◀── ━━━━━●━━━ ──▶  0.50          │  │  ← 0.3–0.7, step 0.05
│ │                                  │  │
│ │ Pitch                            │  │
│ │ ◀── ━━━━●━━━━ ──▶  1.00          │  │  ← 0.7–1.5, step 0.05
│ │                                  │  │
│ │ Volume                           │  │
│ │ ◀── ━━━━━━━●━ ──▶  0.85          │  │  ← 0.0–1.0, step 0.05
│ │                                  │  │
│ │ ┌────────────────────────────┐   │  │
│ │ │ 🔊 Preview: 안녕하세요       │   │  │  ← Speak with current settings
│ │ └────────────────────────────┘   │  │
│ │ [ Reset to defaults ]            │  │
│ └──────────────────────────────────┘  │
│                                       │
│ UNSUPPORTED LANGUAGES                 │
│ ┌───────────────────────────────────┐ │
│ │ Decks set to "Unsupported" do not │ │
│ │ play audio. To enable TTS for a   │ │
│ │ deck, edit the deck and choose a  │ │
│ │ supported language.               │ │
│ └───────────────────────────────────┘ │
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| (none) | route | |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| `tts.autoPlay` | SharedPreferences | watch |
| Per-language settings (`tts.{lang}.voice/rate/pitch/volume`) | SharedPreferences | watch |
| Available voices for current language | platform TTS engine via `voice_lister.dart` | on tab open, cached for screen lifecycle |
| Engine availability | platform TTS engine status | once on screen |

## Forbidden

- ❌ Implement "Play after grading" as functional in v1. Reserved.
- ❌ Speak `back` anywhere in the app.
- ❌ Couple Korean and English settings (they MUST be independent).
- ❌ Use a different TTS engine in preview vs study mode.
- ❌ Hide "System default" voice. It is always first and always available.
- ❌ Allow rate outside 0.3-0.7, pitch outside 0.7-1.5, volume outside 0.0-1.0.
- ❌ Persist a deleted/uninstalled voice. Validate on screen open; fall back to System default.

## Components

| Component | Spec |
| --- | --- |
| Auto-play toggle | Global default. Decks inherit. Default off. |
| Play after grading toggle | Reserved for future; always off in v1. Renders disabled with hint. |
| Language tabs | Top-level tabs per supported language: Korean, English. New supported languages add new tabs. |
| Voice radio group | List of available voices from the platform TTS engine for that language. "System default" always first. |
| Speech rate slider | 0.3–0.7, step 0.05. Default 0.5. |
| Pitch slider | 0.7–1.5, step 0.05. Default 1.0. |
| Volume slider | 0.0–1.0, step 0.05. Default 0.85. |
| Preview button | Speaks a fixed phrase in the current language using current settings. |
| Reset to defaults | Reverts the current tab's settings only. |
| Unsupported languages explainer | Static section explaining why some decks don't speak. |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Loading voices | First open / tab switch | Show "Loading voices..." in the voice list. |
| No voices available | Platform reports zero voices for the language | Show "No voices installed for {language}. Open device settings to install." with deep-link. |
| TTS engine error | Preview fails | Toast "Preview failed. Check device TTS settings." |
| Saving | Slider release or radio change | Debounced auto-save 300ms. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Toggle Auto-play | Tap | Persist preference. |
| Tap language tab | Tap | Load voices for that language; render tab content. |
| Tap voice radio | Tap | Persist voice choice for that language. |
| Drag rate / pitch / volume slider | Drag | Live value; persist on release. |
| Tap Preview | Tap | Speak fixed phrase with current settings. |
| Tap Reset to defaults | Tap | Reset that tab's settings to defaults. Confirm via dialog. |

## Dialogs and bottom-sheets used

- Reset to defaults confirm — generic confirm dialog.

## Validation

| Rule | Behavior |
| --- | --- |
| Rate 0.3–0.7 | Slider clamped. |
| Pitch 0.7–1.5 | Slider clamped. |
| Volume 0.0–1.0 | Slider clamped. |

## Navigation in

- Settings hub → Audio & Speech row.
- Study session overflow → Settings → audio (deep link).

## Navigation out

- Back → Settings hub (or back to study session if deep-linked).

## Responsive

- ≥600dp: tab content side-by-side with sliders/preview.

## Performance

- Voice list fetched on tab open; cached per-tab for the screen lifecycle.
- Slider auto-save debounced 300ms.

## Accessibility

- Sliders announce numeric value on every step.
- Voice radios announce voice name and gender if available.
- Preview button labeled "Preview Korean speech" etc.

## Rules

- Backs are NEVER spoken. (Playback policy from spec.)
- Auto-play default off.
- Only `target_language ∈ {korean, english}` deck shows TTS UI in study modes.
- Per-language settings are independent.

## Agent rule

- Do NOT add "Play after grading" toggle as functional in v1; reserved.
- Do NOT speak backs anywhere in the app.
- Per-language settings MUST be independent (changing Korean rate does not affect English rate).
- Preview MUST use the same TTS engine and settings the study modes use.
- "System default" voice MUST always be the first option and always available (fallback).

## Implementation refs

**Business specs:**

- `docs/business/tts/tts-settings.md`
- `docs/business/deck/deck-management.md` (target_language gate)

**Decision rows:**

- TTS section: per-language settings, autoplay default off, front-only policy

**Schema / storage:**

- SharedPreferences per language: `tts.{lang}.voice`, `tts.{lang}.rate`, `tts.{lang}.pitch`, `tts.{lang}.volume`, plus global `tts.autoPlay`

**Contracts:** `docs/contracts/usecase-contracts/tts.md`

**Code paths:**

- `lib/presentation/features/settings/screens/audio_speech_settings_screen.dart`
- `lib/presentation/features/settings/widgets/speech_settings_group.dart`
- `lib/presentation/features/settings/widgets/speech_audio_sliders.dart`
- `lib/presentation/features/tts/providers/tts_settings_notifier.dart`
- `lib/domain/services/tts_service.dart`
- `lib/data/repositories/tts_settings_repository_impl.dart`
- `lib/app/router/route_names.dart` → `RouteNames.settingsAudioSpeech`

**Related wireframes:**

- `docs/wireframes/04-settings-hub.md` (entry), `13-17` (consumers)
