---
last_updated: 2026-06-02
status: rc tag target ready
source: docs/checklist/implementation-ledger.md
---

# V1 RC Release Notes

## A. Release

- RC tag candidate: `v1.0.0-rc.1`
- Date: 2026-06-02
- Commit to tag: Prompt 37 docs-only tag-target commit containing this release-note update. Preflight release-prep commit: `ce60f64068ee9cac06e9694a16fedcfe48743c88`.
- Status: `RC_READY_WITH_KNOWN_FUTURE_GAPS`

## B. What is included

MemoX V1 includes the scoped release-candidate surface confirmed by Prompt 35:

- folder/deck/flashcard management
- import
- study entry/session/result
- SRS review
- dashboard V1
- progress overview
- settings
- account sync basics
- TTS settings
- tag management
- shared dialogs/bottom sheets

## C. Known Future gaps

- Global Search
- Flashcard History
- tag-scoped study
- onboarding
- root-level decks
- full restore-protection
- engagement/streak/daily goal/reminders
- independent per-language TTS settings
- strong-confirm account removal
- dedicated SortOptionsSheet
- active-session undo reinsert
- Dashboard-as-landing default boot

## D. User-facing caveats

- Search is local to current screen.
- App opens Library by default; Dashboard is available from Home tab.
- Dashboard `0 days` streak is a placeholder, not full engagement.
- Tags can be managed, but study-by-tag is not included.
- Drive sync is basic/manual; advanced restore protection is not complete.

## E. Verification evidence

Prompt 35 confirmed the final V1 RC regression gate:

- `dart run build_runner build --delete-conflicting-outputs` passed.
- Generated-file drift: none.
- `flutter analyze` passed.
- Focused regression suite passed 312 tests.
- Full `flutter test` passed 1033 tests.
- `python code-verification-guard/guard/run.py check --project . --ruleset memox` passed.
- Scope leak scan passed.

## F. Tag command

No existing `v1.0.0-rc.*` or `v1.0.0*` tag was found during preflight, so the selected tag remains `v1.0.0-rc.1`.

Run these commands after confirming the Prompt 37 tag-target commit is current and the working tree is clean:

```text
git tag -a v1.0.0-rc.1 -m "MemoX V1.0.0 RC1"
git push origin v1.0.0-rc.1
```
