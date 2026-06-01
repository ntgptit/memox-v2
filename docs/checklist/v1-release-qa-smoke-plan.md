---
last_updated: 2026-06-02
status: current release qa smoke plan
source: docs/checklist/v1-release-readiness-cutline.md
---

# V1 Release QA Smoke Plan

This is a release-candidate smoke plan for the scoped MemoX V1 cutline. It is
not a Future feature checklist.

## A. Route Safety Smoke

Verify manually or via tests that these current routes open safely:

- `/` redirects to the current V1 Library boot surface
- `/library`
- `/progress`
- `/settings`
- `/settings/account`
- `/settings/learning`
- `/settings/audio-speech`
- `/settings/learning/tags`
- `/library/study/today`
- `/library/study/session/:sessionId` with a valid fixture if available

Verify invalid Future paths show a safe error and do not expose live V1 screens:

- `/search`
- `/global-search`
- `/library/search`
- `/onboarding`
- `/settings/reminders`
- `/settings/learning/daily-goal`

## B. Core Content Flow Smoke

- Create folder.
- Create subfolder.
- Create deck.
- Create flashcard.
- Edit flashcard.
- Search card locally.
- Sort/reorder if the current UI supports it.
- Delete/move/export row or bulk action if available.
- Import deck content.

## C. Study Flow Smoke

- Start today review.
- Start deck study.
- Start folder study.
- Complete at least one study mode.
- Verify result screen.
- Resume paused session.
- Discard paused session.

## D. Settings Smoke

- Account screen opens safely.
- Manual sync actions behave according to current state.
- Learning settings read/write current defaults.
- Audio/speech settings preview handles errors safely.
- Tag management rename/merge/delete current flows.

## E. Future Feature Absence Smoke

Confirm no visible entry for:

- Global Search
- Flashcard History
- tag-scoped study
- onboarding wizard
- daily goal settings
- reminder settings
- account removal strong-confirm
- TTS per-language tabs
- root-level deck creation
- Dashboard-as-landing default boot behavior

## F. Regression Command Gate

Run before final RC sign-off:

```text
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
python code-verification-guard/guard/run.py check --project . --ruleset memox
```
