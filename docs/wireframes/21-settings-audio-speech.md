---
last_updated: 2026-06-01
route: /settings/audio-speech
source_specs:
  - docs/business/tts/tts-settings.md
  - docs/business/deck/deck-management.md
---

# 21 — Settings: Audio & Speech

## Purpose

Current V1 configures global/front-language Text-to-Speech (TTS) settings. TTS is gated by `deck.target_language` at the deck level, but independent per-language defaults are target behavior only and are not implemented in the current V1 screen.

## V1 verification status

Prompt 21 (2026-05-31) treats this screen as route-safe sub-screen coverage only. Current code implements global/front-language TTS settings, not independent per-language tabs.

| Aspect | V1 status | Notes |
| --- | --- | --- |
| Route `/settings/audio-speech` | Current | Reachable from Settings Hub; hides shell navigation; back returns to hub when pushed from the hub. |
| Auto-play | Current | Global auto-play preference. |
| Front language | Current | One selected front language (`korean` or `english`). |
| Voice/rate/pitch/volume | Current | One front voice/rate/pitch/volume setting set, normalized by `TtsSettings`. The primary row uses safe localized voice summary copy; platform voice ids are only storage values. |
| Preview | Current | Uses the same `TtsService` path as study speech and maps failures to generic localized feedback. |
| Per-language independent tabs/settings | Future/Target | Original tab layout remains target behavior; current V1 does not persist separate Korean and English setting sets. |
| Play-after-grading toggle / reset / unsupported-language explainer | Future/Target | Not implemented in current V1. |

The layout/data/components/states sections below describe the target per-language TTS design unless a row is explicitly marked Current in the V1 verification table.

## Layout

Target/reference layout. Current V1 is a single global/front-language TTS settings surface; the per-language tabs, reset action, and unsupported-language explainer shown below are not shipped Current controls.

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
│ │ ◀── ━━━━━━━━● ─▶  1.00          │  │  ← 0.0–1.0, step 0.05
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
| Current: global auto-play | Current TTS settings repository/store | watch |
| Current: front language | Current TTS settings repository/store | watch |
| Current: voice/rate/pitch/volume setting set | Current TTS settings repository/store | watch |
| Current: available voices for selected/front language | Platform TTS service path | lazily when Voice options is expanded |
| Target/Future: engine availability explainer | Platform TTS engine status | once on screen when unsupported-language/engine guidance is expanded |
| Target/Future: per-language settings (`tts.{lang}.voice/rate/pitch/volume`) | Target storage | watch when independent tabs are implemented |

## Forbidden

- ❌ Implement "Play after grading" as functional in current V1. Reserved.
- ❌ Speak `back` anywhere in the app.
- ❌ Target/Future: when per-language tabs are implemented, Korean and English settings MUST be independent. Current V1 uses global/front-language settings.
- ❌ Use a different TTS engine in preview vs study mode.
- ❌ Hide "System default" voice. It is always first and always available.
- ❌ Allow rate outside 0.3-0.7, pitch outside 0.7-1.5, volume outside 0.0-1.0.
- ❌ Target/Future: persist a deleted/uninstalled voice after full voice validation exists. Current V1 falls back safely in the expanded selector but does not perform an eager screen-open remediation write.

## Components

| Component | Spec |
| --- | --- |
| Current: Auto-play toggle | Global default. Default off. |
| Current: Front language selector | Chooses the single front language used by current V1 settings. |
| Current: Voice selector | Opens a detail sheet. Voice options are collapsed until requested; expanding loads voices for the current front language. "System default" remains available. |
| Current: Speech rate slider | 0.3-0.7, step 0.05. Default 0.5. |
| Current: Pitch slider | 0.7-1.5, step 0.05. Default 1.0. |
| Current: Volume slider | 0.0-1.0, step 0.05. Default 1.0. |
| Current: Preview button | Speaks a fixed phrase using the current settings and the same TTS path as study mode. |
| Target/Future: Play after grading toggle | Reserved for future; always off in V1 if rendered. |
| Target/Future: Language tabs | Top-level tabs per supported language: Korean, English. New supported languages add new tabs. |
| Target/Future: Per-language voice radio group | List of available voices from the platform TTS engine for that language. "System default" always first. |
| Target/Future: Reset to defaults | Reverts the current tab's settings only after per-language tabs exist. |
| Target/Future: Unsupported languages explainer | Static section explaining why some decks do not speak. |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Current: Loading voices | Voice options expanded / voice refresh | Show loading in the voice selector/list. |
| Current: No voices available | Platform reports zero voices for selected/front language | Show empty/error guidance for installing device voices. |
| Current: TTS engine error | Preview fails | Surface preview failure without changing settings. |
| Current: Saving | Slider release, selector change, or auto-play change | Persist through the current settings repository/store. |
| Current: Stored voice unavailable | Saved platform voice id no longer appears in the lazy-loaded voice list | Render System default as the selected option and keep the UI safe; full install/uninstall remediation remains Target/Future. |
| Target/Future: Per-language tab switch | Tab switch | Load/cache voices for that language and render tab content. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Toggle Auto-play | Tap | Persist preference. |
| Change front language | Tap/select | Persist current V1 front language and update available voices/settings view. |
| Select voice | Tap | Persist voice choice for the current global/front-language setting set. |
| Drag rate / pitch / volume slider | Drag | Live value; persist on release. |
| Tap Preview | Tap | Speak fixed phrase with current settings; on failure, show generic localized feedback and never render raw platform exceptions. |
| Target/Future: Tap language tab | Tap | Load voices for that language; render tab content. |
| Target/Future: Tap per-language voice radio | Tap | Persist voice choice for that language. |
| Target/Future: Tap Reset to defaults | Tap | Reset that tab's settings to defaults. Confirm via dialog. |

## Dialogs and bottom-sheets used

- Current V1: no reset dialog required.
- Target/Future: Reset to defaults confirm — generic confirm dialog.

## Validation

| Rule | Behavior |
| --- | --- |
| Rate 0.3–0.7 | Slider clamped. |
| Pitch 0.7–1.5 | Slider clamped. |
| Volume 0.0–1.0 | Slider clamped. |

## Navigation in

- Settings hub → Audio & Speech row.
- Target/Future: Study session overflow → Settings → audio (deep link).

## Navigation out

- Back → Settings hub (or back to study session if deep-linked).

## Responsive

- Current V1: keep controls readable and linear across narrow and wide layouts.
- Target/Future ≥600dp: tab content side-by-side with sliders/preview.

## Performance

- Current V1: voice list fetch and preview must use the same TTS service path as study mode.
- Target/Future: voice list fetched on tab open and cached per-tab for the screen lifecycle.
- Target/Future: slider auto-save debounced 300ms.

## Accessibility

- Sliders announce numeric value on every step.
- Voice radios announce voice name and gender if available.
- Current V1 preview button label reflects the selected/front language where available.
- Target/Future preview button labeled "Preview Korean speech" etc. per tab.

## Rules

- Backs are NEVER spoken. (Playback policy from spec.)
- Auto-play default off.
- Only `target_language ∈ {korean, english}` deck shows TTS UI in study modes.
- Current V1 uses one global/front-language setting set.
- Target/Future: per-language settings are independent.

## Agent rule

- Do NOT add "Play after grading" toggle as functional in current V1; reserved.
- Do NOT speak backs anywhere in the app.
- Do NOT promote independent Korean/English tabs, reset-current-tab, or unsupported-language explainer to Current in a Settings route/parity task.
- Target/Future: per-language settings MUST be independent (changing Korean rate does not affect English rate).
- Preview MUST use the same TTS engine and settings the study modes use.
- "System default" voice MUST always be the first option and always available (fallback).

## Implementation refs

**Business specs:**

- `docs/business/tts/tts-settings.md`
- `docs/business/deck/deck-management.md` (target_language gate)

**Decision rows:**

- Current V1: global/front-language settings, autoplay default off, front-only policy.
- Target/Future: per-language independent settings.

**Schema / storage:**

- Current V1: current TTS settings repository/store (`tts_settings` table per `docs/business/tts/tts-settings.md`).
- Target/Future: per-language settings such as `tts.{lang}.voice`, `tts.{lang}.rate`, `tts.{lang}.pitch`, `tts.{lang}.volume`, plus global `tts.autoPlay`.

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
