---
last_updated: 2026-06-02
status: post-rc backlog ready
source: docs/checklist/v1-release-readiness-cutline.md
---

# V1 Post-RC Backlog

## A. Current RC baseline

- Tag: `v1.0.0-rc.1`
- Tagged commit: `92fdf6d2f11c809791b54d5c4f92223f6cc417d6`
- Status: `RC_READY_WITH_KNOWN_FUTURE_GAPS`
- GitHub Release draft: intentionally skipped / optional

## B. Do not reopen V1 unless blocker found

V1 RC is closed as a milestone.

Do not keep polishing docs endlessly.

Only reopen V1 RC if a real runtime blocker, data-loss bug, build failure, or serious UX blocker is found.

## C. Known Future gaps retained

- Global Search
- Flashcard History
- tag-scoped study
- onboarding
- root-level decks
- full restore-protection beyond Prompt 41 current hardening (pre-restore snapshot, Upload local first, second destructive confirmation, restore history, cloud comparison/conflict resolution)
- engagement/streak/daily goal/reminders
- independent per-language TTS settings
- strong-confirm account removal
- dedicated SortOptionsSheet
- active-session undo reinsert
- Dashboard-as-landing default boot

## D. Post-RC priority recommendation

### P0 — only if discovered

- crash
- data loss
- broken build
- broken migration
- broken study flow
- broken import flow
- broken restore/upload flow

### P1 — recommended next product work

- full restore-protection follow-up beyond Prompt 41 current hardening
- root-level deck support
- Dashboard-as-landing decision
- Folder Detail Study/Today/Resume banners
- active-session undo reinsert

### P2 — feature expansion

- Flashcard History
- Global Search
- tag-scoped study
- onboarding wizard
- engagement/streak/daily goal/reminders
- independent per-language TTS tabs/settings
- strong-confirm account removal
- dedicated SortOptionsSheet

## E. Recommended Prompt 41

Preferred next path:

Prompt 41 — Account Restore Protection Hardening

Reason:

- It is safer and more important than Global Search/History.
- It reduces data-loss risk.
- It fits post-RC hardening.
- It does not require visual redesign.
- It is closer to release safety than new feature expansion.

Prompt 41 result note:

- Current post-RC restore protection hardening adds destructive restore warning copy, cancel/confirm protection, duplicate-running guard, and visible restore success/failure feedback.
- Still Future: pre-restore snapshot, restore history, cloud version comparison, conflict resolution, Upload local first branch, second destructive confirmation, automatic background sync, and typed strong-confirm account removal.

Alternative prompts:

- Prompt 41A — Root-level Deck Support Planning
- Prompt 41B — Dashboard-as-Landing Decision
- Prompt 41C — Flashcard History Discovery
- Prompt 41D — Global Search Discovery

## F. Guardrails for post-RC work

- Do not mix multiple Future features in one prompt.
- Do not implement Global Search and Flashcard History together.
- Do not change schema unless the prompt explicitly owns migration.
- Do not change SRS algorithm unless the prompt explicitly owns SRS.
- Do not redesign UI during backend/data hardening prompts.
- Always update implementation-ledger.md after each prompt.
- Always run focused tests and guard.
