---
last_updated: 2026-05-28
owner: technical-lead
status: reference
applies_to:
  - docs/system-design/MemoX Design System/ui_kits/mobile/index.html
  - docs/system-design/MemoX Design System/preview/*.html
  - docs/wireframes/*.md
  - docs/business/**/*.md
  - docs/contracts/**/*.md
  - docs/state/state-management-contract.md
---

# Mock Design to Documentation Mapping

This document maps the MemoX mock design files to the Markdown documentation set.

It is intentionally created as a new bridge document. It does not replace the existing wireframes, business specs, contracts, or design system documents.

## 1. Technical leadership decision

Yes, the mock design can and should be mapped to the documentation.

However, the mapping must be treated as a coordination layer, not as a new source of truth.

The correct priority is:

1. Business behavior source of truth: `docs/business/**`
2. Flow, route, and visual-structure source of truth: `docs/wireframes/**`
3. Architecture, state, use case, repository, and database contracts: `docs/architecture/**`, `docs/state/**`, `docs/contracts/**`, `docs/database/**`
4. Visual design source of truth: `docs/system-design/MemoX Design System/README.md` and `docs/system-design/MemoX Design System/colors_and_type.css`
5. Mock implementation reference: `docs/system-design/MemoX Design System/ui_kits/mobile/index.html`
6. Component preview reference: `docs/system-design/MemoX Design System/preview/*.html`
7. Uploaded screenshots: `docs/system-design/MemoX Design System/uploads/*`

The mock HTML must be used as a visual reference only. Do not copy inline styles, raw colors, hardcoded spacing, JSX structure, or temporary demo data into Flutter production code.

## 2. Source files covered by this mapping

| Area | File / folder | Role |
| --- | --- | --- |
| Mobile mock gallery | `docs/system-design/MemoX Design System/ui_kits/mobile/index.html` | Main visual mock file. Contains 129 rendered screen variants in the gallery. |
| Mobile mock notes | `docs/system-design/MemoX Design System/ui_kits/mobile/README.md` | Current README for the mobile kit. It appears stale because it still describes only the older 5-screen kit. |
| Design foundation | `docs/system-design/MemoX Design System/README.md` | Brand, theme, component, and implementation guidance. |
| Token CSS | `docs/system-design/MemoX Design System/colors_and_type.css` | Color, typography, spacing, radius, elevation, opacity, and motion tokens used by the HTML mock. |
| Component previews | `docs/system-design/MemoX Design System/preview/*.html` | Visual references for reusable components and token groups. |
| Uploaded references | `docs/system-design/MemoX Design System/uploads/*` | Raw screenshots/images used as source visual references. |
| Wireframes | `docs/wireframes/*.md` | Main screen-level behavior and layout contracts. |
| Business specs | `docs/business/**/*.md` | Domain behavior and edge cases. |
| Contracts | `docs/contracts/**/*.md` | Use case, repository, type, error, and code-style contracts. |
| State | `docs/state/state-management-contract.md` | Provider/notifier ownership and UI state rules. |

## 3. Conflict resolution rule

When implementation agents find a conflict, resolve it in this order:

| Conflict type | Winner | Reason |
| --- | --- | --- |
| Business rule conflict | `docs/business/**` | Business docs define product behavior. |
| Route/navigation conflict | `docs/business/navigation/navigation-flow.md` and matching wireframe | Routes must remain stable and testable. |
| State/loading/error conflict | Matching wireframe + `docs/state/state-management-contract.md` | Screen states must be driven by app state, not mock-only JSX flags. |
| DB/schema conflict | `docs/database/**` | Schema and migration contracts control what can be persisted. |
| Use case/repository conflict | `docs/contracts/**` | Domain and data boundaries must not be bypassed. |
| Visual token conflict | `docs/system-design/MemoX Design System/colors_and_type.css` and Flutter theme tokens | Production UI must use tokens, not raw mock values. |
| Layout shape conflict | Matching wireframe first, mock HTML second | Wireframe is the structural contract; mock refines visual feel. |
| Copy/text conflict | `docs/ui-ux/l10n-copy-contract.md` | UI text must be localizable and not copied blindly from mock. |

## 4. Agent implementation rule

For any screen implementation task, the agent must read these in order:

1. This mapping document.
2. The matching wireframe from `docs/wireframes/**`.
3. The wireframe's `Implementation refs` section.
4. The linked business specs.
5. The linked use case and repository contracts.
6. `docs/state/state-management-contract.md`.
7. `docs/ui-ux/ui-ux-contract.md` and `docs/ui-ux/l10n-copy-contract.md`.
8. `docs/system-design/MemoX Design System/README.md`.
9. `docs/system-design/MemoX Design System/colors_and_type.css`.
10. The matching screen variant in `docs/system-design/MemoX Design System/ui_kits/mobile/index.html`.

The agent must not start from the HTML mock alone.

## 5. Top-level mapping summary

| Mock group | Mock source | Primary wireframe | Primary business docs | Primary contract/state docs | Implementation status note |
| --- | --- | --- | --- | --- | --- |
| Dashboard | `25a`-`25h` in `ui_kits/mobile/index.html` | `docs/wireframes/01-dashboard.md` | `docs/business/engagement/dashboard-engagement.md`, `docs/business/resume/resume-session.md`, `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md` | `docs/contracts/usecase-contracts/engagement.md`, `docs/state/state-management-contract.md` | Current target. Prefer this over legacy `HomeScreen`. |
| Library overview | `17a`-`17f` | `docs/wireframes/02-library.md` | `docs/business/folder/folder-management.md`, `docs/business/deck/deck-management.md`, `docs/business/flashcard/flashcard-management.md` | `docs/contracts/usecase-contracts/folder.md`, `docs/contracts/repository-contracts/folder-repository.md` | Current target. |
| Progress | `26a`-`26g` | `docs/wireframes/03-progress.md` | `docs/business/engagement/dashboard-engagement.md`, `docs/business/srs/srs-review.md`, `docs/business/history/card-history.md` | `docs/contracts/usecase-contracts/engagement.md`, `docs/contracts/repository-contracts/progress-repository.md` | Current target. Prefer this over legacy `StatsScreen`. |
| Settings hub | `12a`-`12e` | `docs/wireframes/04-settings-hub.md` | `docs/business/account-sync/account-sync.md`, `docs/business/tts/tts-settings.md`, `docs/business/tags/tag-system.md` | `docs/state/state-management-contract.md`, `docs/contracts/usecase-contracts/account-sync.md` | Current target. |
| Folder detail | `18a`-`18h` | `docs/wireframes/05-folder-detail.md` | `docs/business/folder/folder-management.md`, `docs/business/deck/deck-management.md` | `docs/contracts/usecase-contracts/folder.md`, `docs/contracts/repository-contracts/folder-repository.md` | Current target. |
| Flashcard list | `19a`-`19h` | `docs/wireframes/06-flashcard-list.md` | `docs/business/flashcard/flashcard-management.md`, `docs/business/deck/deck-management.md`, `docs/business/study-actions/bury-suspend.md` | `docs/contracts/usecase-contracts/flashcard.md`, `docs/contracts/repository-contracts/flashcard-repository.md` | Current target. |
| Flashcard create | `20a`-`20f` | `docs/wireframes/07-flashcard-create.md` | `docs/business/flashcard/flashcard-management.md`, `docs/business/tags/tag-system.md`, `docs/business/tts/tts-settings.md` | `docs/contracts/usecase-contracts/flashcard.md`, `docs/contracts/repository-contracts/flashcard-repository.md` | Current target. |
| Flashcard edit | `21a`-`21g` | `docs/wireframes/08-flashcard-edit.md` | `docs/business/flashcard/flashcard-management.md`, `docs/business/tags/tag-system.md`, `docs/business/study-actions/bury-suspend.md` | `docs/contracts/usecase-contracts/flashcard.md`, `docs/contracts/repository-contracts/flashcard-repository.md` | Current target. |
| Flashcard history | `22a`-`22e` | `docs/wireframes/09-flashcard-history.md` | `docs/business/history/card-history.md`, `docs/business/srs/srs-review.md` | `docs/contracts/usecase-contracts/history.md`, `docs/contracts/repository-contracts/progress-repository.md` | Future Proposal for V1; visual reference only until promoted. Requires schema migration. |
| Deck import | `23a`-`23i` | `docs/wireframes/10-deck-import.md` | `docs/business/flashcard/flashcard-management.md`, `docs/business/bulk/bulk-operations.md`, `docs/business/deck/deck-management.md` | `docs/contracts/usecase-contracts/bulk.md`, `docs/contracts/usecase-contracts/flashcard.md` | Current target. Import must be transactional/chunked as required by docs. |
| Library search | `24a`-`24e` | `docs/wireframes/11-library-search.md` | `docs/business/search/global-search.md` | `docs/contracts/usecase-contracts/search.md`, `docs/contracts/repository-contracts/*` | Full global screen is Future Proposal; V1 uses inline/scope-local search guidelines. |
| Study entry gate | Not directly rendered as a named gallery group | `docs/wireframes/12-study-entry-gate.md` | `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md`, `docs/business/resume/resume-session.md` | `docs/contracts/usecase-contracts/study.md`, `docs/contracts/repository-contracts/study-repository.md` | Missing explicit mock variant. Use wireframe as source of truth. |
| Study review | `06` | `docs/wireframes/13-study-session-review.md` | `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md` | `docs/contracts/usecase-contracts/study.md`, `docs/state/state-management-contract.md` | Confirm final SRS review behavior before implementation. |
| Study match | `07` | `docs/wireframes/14-study-session-match.md` | `docs/business/study/study-flow.md` | `docs/contracts/usecase-contracts/study.md` | Current target. |
| Study guess | `08` | `docs/wireframes/15-study-session-guess.md` | `docs/business/study/study-flow.md` | `docs/contracts/usecase-contracts/study.md` | Current target. |
| Study recall | `09a`-`09b` | `docs/wireframes/16-study-session-recall.md` | `docs/business/study/study-flow.md` | `docs/contracts/usecase-contracts/study.md` | Current target. |
| Study fill | `10a`-`10b` | `docs/wireframes/17-study-session-fill.md` | `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md` | `docs/contracts/usecase-contracts/study.md`, `docs/contracts/usecase-contracts/srs.md` | Current target. |
| Study result | `27a`-`27f` | `docs/wireframes/18-study-result.md` | `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md`, `docs/business/engagement/dashboard-engagement.md` | `docs/contracts/usecase-contracts/study.md`, `docs/contracts/usecase-contracts/engagement.md` | Current target. |
| Account sync | `13a`-`13i` | `docs/wireframes/19-settings-account.md` | `docs/business/account-sync/account-sync.md` | `docs/contracts/usecase-contracts/account-sync.md`, `docs/contracts/repository-contracts/sync-repository.md` | Current target. |
| Learning settings | `14a`-`14e` | `docs/wireframes/20-settings-learning.md` | `docs/business/engagement/dashboard-engagement.md`, `docs/business/resume/resume-session.md` | `docs/contracts/usecase-contracts/engagement.md`, `docs/state/state-management-contract.md` | Current target. |
| Audio/Speech settings | `15a`-`15g` | `docs/wireframes/21-settings-audio-speech.md` | `docs/business/tts/tts-settings.md` | `docs/contracts/usecase-contracts/tts.md` | Current target. Some behavior may depend on `decks.target_language` migration. |
| Tag management | `16a`-`16k` | `docs/wireframes/22-settings-tag-management.md` | `docs/business/tags/tag-system.md`, `docs/business/search/global-search.md` | `docs/contracts/usecase-contracts/tag.md`, `docs/contracts/repository-contracts/tag-repository.md` | Current target. |
| Onboarding | `28a`-`28i` | `docs/wireframes/23-onboarding.md` | `docs/business/system/overview.md`, `docs/business/account-sync/account-sync.md`, `docs/business/deck/deck-management.md`, `docs/business/flashcard/flashcard-management.md` | `docs/contracts/usecase-contracts/account-sync.md`, `docs/state/state-management-contract.md` | Full onboarding mock set is Future Proposal; V1 implements only zero-content empty-state CTAs. |
| Shared dialogs | Several overlay states across groups | `docs/wireframes/24-shared-dialogs.md` | Feature-specific docs | `docs/contracts/error-contract.md`, `docs/ui-ux/l10n-copy-contract.md` | Reuse shared dialog widgets. Do not recreate per screen. |
| Shared bottom sheets | Several sheet states across groups | `docs/wireframes/25-shared-bottom-sheets.md` | Feature-specific docs | `docs/contracts/code-style.md`, `docs/ui-ux/ui-ux-contract.md` | Reuse shared bottom-sheet widgets. Do not recreate per screen. |

## 6. Full mobile mock variant mapping

### 6.1 Study variants

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `06 · Study · Review` | Review session card/rating state | `docs/wireframes/13-study-session-review.md` | `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md`, `docs/contracts/usecase-contracts/study.md`, `docs/contracts/usecase-contracts/srs.md` |
| `07 · Study · Match` | Match mode active state | `docs/wireframes/14-study-session-match.md` | `docs/business/study/study-flow.md`, `docs/contracts/usecase-contracts/study.md` |
| `08 · Study · Guess` | Guess mode active state | `docs/wireframes/15-study-session-guess.md` | `docs/business/study/study-flow.md`, `docs/contracts/usecase-contracts/study.md` |
| `09a · Study · Recall (hidden)` | Recall prompt before answer reveal | `docs/wireframes/16-study-session-recall.md` | `docs/business/study/study-flow.md`, `docs/contracts/usecase-contracts/study.md` |
| `09b · Study · Recall (revealed)` | Recall answer revealed | `docs/wireframes/16-study-session-recall.md` | `docs/business/study/study-flow.md`, `docs/contracts/usecase-contracts/study.md` |
| `10a · Study · Fill (input)` | Fill mode input state | `docs/wireframes/17-study-session-fill.md` | `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md`, `docs/contracts/usecase-contracts/study.md` |
| `10b · Study · Fill (wrong)` | Fill mode incorrect-answer feedback | `docs/wireframes/17-study-session-fill.md` | `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md`, `docs/contracts/usecase-contracts/study.md` |

### 6.2 Legacy stats variant

| Mock variant | Visual state | Mapping | Decision |
| --- | --- | --- | --- |
| `11 · Stats` | Older stats/progress view | `docs/wireframes/03-progress.md` | Treat as legacy visual reference. Production target should use `Progress`, not `Stats`, unless product leadership explicitly restores the old naming. |

### 6.3 Settings hub variants

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `12a · Settings (populated)` | Normal settings hub with account/status rows | `docs/wireframes/04-settings-hub.md` | `docs/business/account-sync/account-sync.md`, `docs/business/tts/tts-settings.md`, `docs/business/tags/tag-system.md` |
| `12b · Settings (loading)` | Settings hub loading state | `docs/wireframes/04-settings-hub.md` | `docs/state/state-management-contract.md` |
| `12c · Settings (signed out)` | Settings hub when no Google account is linked | `docs/wireframes/04-settings-hub.md` | `docs/business/account-sync/account-sync.md` |
| `12d · Settings (signing in)` | Settings hub while sign-in is in progress | `docs/wireframes/04-settings-hub.md` | `docs/business/account-sync/account-sync.md`, `docs/contracts/usecase-contracts/account-sync.md` |
| `12e · Settings (sync error)` | Settings hub with sync/account error | `docs/wireframes/04-settings-hub.md` | `docs/business/account-sync/account-sync.md`, `docs/contracts/error-contract.md` |

### 6.4 Account sync variants

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `13a · Account sync (signed out)` | Account sync page before sign-in | `docs/wireframes/19-settings-account.md` | `docs/business/account-sync/account-sync.md` |
| `13b · Account sync (signing in)` | Google sign-in in progress | `docs/wireframes/19-settings-account.md` | `docs/business/account-sync/account-sync.md`, `docs/contracts/usecase-contracts/account-sync.md` |
| `13c · Account sync (sign-in failed)` | Sign-in failure | `docs/wireframes/19-settings-account.md` | `docs/business/account-sync/account-sync.md`, `docs/contracts/error-contract.md` |
| `13d · Account sync (no backup yet)` | Signed in with no backup available | `docs/wireframes/19-settings-account.md` | `docs/business/account-sync/account-sync.md` |
| `13e · Account sync (ready)` | Signed in and sync-ready | `docs/wireframes/19-settings-account.md` | `docs/business/account-sync/account-sync.md`, `docs/contracts/repository-contracts/sync-repository.md` |
| `13f · Account sync (uploading)` | Backup/upload in progress | `docs/wireframes/19-settings-account.md` | `docs/business/account-sync/account-sync.md`, `docs/contracts/usecase-contracts/account-sync.md` |
| `13g · Account sync (restore warn)` | Restore confirmation warning | `docs/wireframes/19-settings-account.md`, `docs/wireframes/24-shared-dialogs.md` | `docs/business/account-sync/account-sync.md`, `docs/contracts/error-contract.md` |
| `13h · Account sync (restoring)` | Restore in progress | `docs/wireframes/19-settings-account.md` | `docs/business/account-sync/account-sync.md`, `docs/database/storage-boundaries.md` |
| `13i · Account sync (token expired)` | Expired token / re-auth required | `docs/wireframes/19-settings-account.md` | `docs/business/account-sync/account-sync.md`, `docs/contracts/error-contract.md` |

### 6.5 Learning settings variants

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `14a · Learning (goal on)` | Daily goal enabled | `docs/wireframes/20-settings-learning.md` | `docs/business/engagement/dashboard-engagement.md` |
| `14b · Learning (goal off)` | Daily goal disabled | `docs/wireframes/20-settings-learning.md` | `docs/business/engagement/dashboard-engagement.md` |
| `14c · Learning (reminder on)` | Reminder enabled | `docs/wireframes/20-settings-learning.md` | `docs/business/engagement/dashboard-engagement.md`, `docs/business/resume/resume-session.md` |
| `14d · Learning (perm denied)` | Notification permission denied | `docs/wireframes/20-settings-learning.md` | `docs/contracts/error-contract.md`, `docs/ui-ux/l10n-copy-contract.md` |
| `14e · Learning (saving)` | Saving settings | `docs/wireframes/20-settings-learning.md` | `docs/state/state-management-contract.md` |

### 6.6 Audio/Speech variants

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `15a · Audio (Korean loaded)` | Korean voice list loaded | `docs/wireframes/21-settings-audio-speech.md` | `docs/business/tts/tts-settings.md` |
| `15b · Audio (English tab)` | English voice tab active | `docs/wireframes/21-settings-audio-speech.md` | `docs/business/tts/tts-settings.md` |
| `15c · Audio (loading voices)` | Voice loading state | `docs/wireframes/21-settings-audio-speech.md` | `docs/state/state-management-contract.md` |
| `15d · Audio (no voices)` | Empty voices state | `docs/wireframes/21-settings-audio-speech.md` | `docs/business/tts/tts-settings.md`, `docs/contracts/error-contract.md` |
| `15e · Audio (engine error)` | TTS engine error | `docs/wireframes/21-settings-audio-speech.md` | `docs/business/tts/tts-settings.md`, `docs/contracts/error-contract.md` |
| `15f · Audio (preview playing)` | Voice preview playing | `docs/wireframes/21-settings-audio-speech.md` | `docs/business/tts/tts-settings.md` |
| `15g · Audio (saving)` | Saving audio settings | `docs/wireframes/21-settings-audio-speech.md` | `docs/state/state-management-contract.md` |

### 6.7 Tag management variants

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `16a · Tags (loaded)` | Loaded tag list | `docs/wireframes/22-settings-tag-management.md` | `docs/business/tags/tag-system.md`, `docs/contracts/usecase-contracts/tag.md` |
| `16b · Tags (loading)` | Loading tag list | `docs/wireframes/22-settings-tag-management.md` | `docs/state/state-management-contract.md` |
| `16c · Tags (empty)` | No tags yet | `docs/wireframes/22-settings-tag-management.md` | `docs/business/tags/tag-system.md` |
| `16d · Tags (search empty)` | No search results | `docs/wireframes/22-settings-tag-management.md` | `docs/business/search/global-search.md`, `docs/business/tags/tag-system.md` |
| `16e · Tags (action sheet)` | Tag action bottom sheet | `docs/wireframes/22-settings-tag-management.md`, `docs/wireframes/25-shared-bottom-sheets.md` | `docs/business/tags/tag-system.md` |
| `16f · Tags (rename)` | Rename dialog | `docs/wireframes/22-settings-tag-management.md`, `docs/wireframes/24-shared-dialogs.md` | `docs/business/tags/tag-system.md` |
| `16g · Tags (rename → merge)` | Rename conflict leading to merge | `docs/wireframes/22-settings-tag-management.md`, `docs/wireframes/24-shared-dialogs.md` | `docs/business/tags/tag-system.md`, `docs/contracts/error-contract.md` |
| `16h · Tags (merge sheet)` | Merge sheet | `docs/wireframes/22-settings-tag-management.md`, `docs/wireframes/25-shared-bottom-sheets.md` | `docs/business/tags/tag-system.md` |
| `16i · Tags (delete confirm)` | Delete confirmation | `docs/wireframes/22-settings-tag-management.md`, `docs/wireframes/24-shared-dialogs.md` | `docs/business/tags/tag-system.md` |
| `16j · Tags (busy row)` | Row-level busy state | `docs/wireframes/22-settings-tag-management.md` | `docs/state/state-management-contract.md` |
| `16k · Tags (op error)` | Operation error | `docs/wireframes/22-settings-tag-management.md` | `docs/contracts/error-contract.md`, `docs/business/tags/tag-system.md` |

### 6.8 Library overview variants

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `17a · Library overview (loaded)` | Loaded root/library overview | `docs/wireframes/02-library.md` | `docs/business/folder/folder-management.md`, `docs/business/deck/deck-management.md` |
| `17b · Library overview (loading)` | Loading library | `docs/wireframes/02-library.md` | `docs/state/state-management-contract.md` |
| `17c · Library overview (empty)` | Empty library | `docs/wireframes/02-library.md`, `docs/wireframes/23-onboarding.md` | `docs/business/system/overview.md`, `docs/business/folder/folder-management.md` |
| `17d · Library overview (error)` | Library load error | `docs/wireframes/02-library.md` | `docs/contracts/error-contract.md` |
| `17e · Library overview (search)` | Inline library search state | `docs/wireframes/02-library.md`, `docs/wireframes/11-library-search.md` | `docs/business/search/global-search.md` |
| `17f · Library overview (overflow)` | Overflow menu/action state | `docs/wireframes/02-library.md`, `docs/wireframes/25-shared-bottom-sheets.md` | `docs/business/folder/folder-management.md`, `docs/business/deck/deck-management.md` |

### 6.9 Folder detail variants

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `18a · Folder detail (decks)` | Folder contains decks | `docs/wireframes/05-folder-detail.md` | `docs/business/folder/folder-management.md`, `docs/business/deck/deck-management.md` |
| `18b · Folder detail (subfolders)` | Folder contains subfolders | `docs/wireframes/05-folder-detail.md` | `docs/business/folder/folder-management.md` |
| `18c · Folder detail (unlocked)` | Empty/unlocked folder state | `docs/wireframes/05-folder-detail.md` | `docs/business/folder/folder-management.md` |
| `18d · Folder detail (search empty)` | Folder search empty | `docs/wireframes/05-folder-detail.md` | `docs/business/search/global-search.md` |
| `18e · Folder detail (loading)` | Folder loading state | `docs/wireframes/05-folder-detail.md` | `docs/state/state-management-contract.md` |
| `18f · Folder detail (error)` | Folder load error | `docs/wireframes/05-folder-detail.md` | `docs/contracts/error-contract.md` |
| `18g · Folder detail (delete)` | Delete folder confirmation | `docs/wireframes/05-folder-detail.md`, `docs/wireframes/24-shared-dialogs.md` | `docs/business/folder/folder-management.md` |
| `18h · Folder detail (move sheet)` | Move folder/deck sheet | `docs/wireframes/05-folder-detail.md`, `docs/wireframes/25-shared-bottom-sheets.md` | `docs/business/folder/folder-management.md`, `docs/business/deck/deck-management.md` |

### 6.10 Flashcard list variants

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `19a · Flashcard list (loaded)` | Deck flashcard list loaded | `docs/wireframes/06-flashcard-list.md` | `docs/business/flashcard/flashcard-management.md`, `docs/business/deck/deck-management.md` |
| `19b · Flashcard list (empty)` | Empty deck state | `docs/wireframes/06-flashcard-list.md` | `docs/business/flashcard/flashcard-management.md` |
| `19c · Flashcard list (search empty)` | Search empty in deck | `docs/wireframes/06-flashcard-list.md` | `docs/business/search/global-search.md`, `docs/business/flashcard/flashcard-management.md` |
| `19d · Flashcard list (loading)` | Loading cards | `docs/wireframes/06-flashcard-list.md` | `docs/state/state-management-contract.md` |
| `19e · Flashcard list (error)` | Load cards error | `docs/wireframes/06-flashcard-list.md` | `docs/contracts/error-contract.md` |
| `19f · Flashcard list (delete card)` | Delete card confirmation | `docs/wireframes/06-flashcard-list.md`, `docs/wireframes/24-shared-dialogs.md` | `docs/business/flashcard/flashcard-management.md` |
| `19g · Flashcard list (delete deck)` | Delete deck confirmation | `docs/wireframes/06-flashcard-list.md`, `docs/wireframes/24-shared-dialogs.md` | `docs/business/deck/deck-management.md` |
| `19h · Flashcard list (reorder)` | Reorder cards visual state | `docs/wireframes/06-flashcard-list.md` | `docs/business/flashcard/flashcard-management.md` |

### 6.11 Flashcard create variants

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `20a · Flashcard create (empty)` | Empty form | `docs/wireframes/07-flashcard-create.md` | `docs/business/flashcard/flashcard-management.md` |
| `20b · Flashcard create (valid)` | Valid form | `docs/wireframes/07-flashcard-create.md` | `docs/business/flashcard/flashcard-management.md`, `docs/contracts/usecase-contracts/flashcard.md` |
| `20c · Flashcard create (details open)` | Optional details expanded | `docs/wireframes/07-flashcard-create.md`, `docs/wireframes/25-shared-bottom-sheets.md` | `docs/business/tags/tag-system.md`, `docs/business/tts/tts-settings.md` |
| `20d · Flashcard create (validation)` | Validation errors | `docs/wireframes/07-flashcard-create.md` | `docs/business/flashcard/flashcard-management.md`, `docs/contracts/error-contract.md` |
| `20e · Flashcard create (saving)` | Saving state | `docs/wireframes/07-flashcard-create.md` | `docs/state/state-management-contract.md` |
| `20f · Flashcard create (save failed)` | Save failure | `docs/wireframes/07-flashcard-create.md` | `docs/contracts/error-contract.md` |

### 6.12 Flashcard edit variants

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `21a · Flashcard edit (loaded)` | Edit form loaded | `docs/wireframes/08-flashcard-edit.md` | `docs/business/flashcard/flashcard-management.md` |
| `21b · Flashcard edit (loading)` | Loading existing card | `docs/wireframes/08-flashcard-edit.md` | `docs/state/state-management-contract.md` |
| `21c · Flashcard edit (load error)` | Load error | `docs/wireframes/08-flashcard-edit.md` | `docs/contracts/error-contract.md` |
| `21d · Flashcard edit (validation)` | Validation error | `docs/wireframes/08-flashcard-edit.md` | `docs/business/flashcard/flashcard-management.md`, `docs/contracts/error-contract.md` |
| `21e · Flashcard edit (saving)` | Dirty form saving | `docs/wireframes/08-flashcard-edit.md` | `docs/state/state-management-contract.md` |
| `21f · Flashcard edit (save failed)` | Save failed | `docs/wireframes/08-flashcard-edit.md` | `docs/contracts/error-contract.md` |
| `21g · Flashcard edit (delete)` | Delete card confirmation | `docs/wireframes/08-flashcard-edit.md`, `docs/wireframes/24-shared-dialogs.md` | `docs/business/flashcard/flashcard-management.md` |

### 6.13 Flashcard history variants

V1 status: Future Proposal. These variants are visual references only until Card History is promoted and its migration is approved.

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `22a · Flashcard history (loaded)` | History loaded | `docs/wireframes/09-flashcard-history.md` | `docs/business/history/card-history.md`, `docs/business/srs/srs-review.md` |
| `22b · Flashcard history (empty)` | No attempts yet | `docs/wireframes/09-flashcard-history.md` | `docs/business/history/card-history.md` |
| `22c · Flashcard history (loading)` | Loading history | `docs/wireframes/09-flashcard-history.md` | `docs/state/state-management-contract.md` |
| `22d · Flashcard history (error)` | History load error | `docs/wireframes/09-flashcard-history.md` | `docs/contracts/error-contract.md` |
| `22e · Flashcard history (partial)` | Partial history data | `docs/wireframes/09-flashcard-history.md` | `docs/business/history/card-history.md`, `docs/database/migration-contract.md` |

### 6.14 Deck import variants

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `23a · Deck import (empty)` | No file/text selected | `docs/wireframes/10-deck-import.md` | `docs/business/bulk/bulk-operations.md`, `docs/business/flashcard/flashcard-management.md` |
| `23b · Deck import (file selected)` | File selected before parse | `docs/wireframes/10-deck-import.md` | `docs/business/bulk/bulk-operations.md` |
| `23c · Deck import (parsing)` | Parse in progress | `docs/wireframes/10-deck-import.md` | `docs/business/bulk/bulk-operations.md`, `docs/state/state-management-contract.md` |
| `23d · Deck import (preview all)` | All rows valid preview | `docs/wireframes/10-deck-import.md` | `docs/business/bulk/bulk-operations.md`, `docs/contracts/usecase-contracts/bulk.md` |
| `23e · Deck import (preview mixed)` | Mixed valid/invalid preview | `docs/wireframes/10-deck-import.md` | `docs/business/bulk/bulk-operations.md`, `docs/contracts/error-contract.md` |
| `23f · Deck import (importing)` | Import in progress | `docs/wireframes/10-deck-import.md` | `docs/business/bulk/bulk-operations.md`, `docs/database/storage-boundaries.md` |
| `23g · Deck import (success)` | Import success | `docs/wireframes/10-deck-import.md` | `docs/business/bulk/bulk-operations.md`, `docs/business/flashcard/flashcard-management.md` |
| `23h · Deck import (partial)` | Partial import success/failure | `docs/wireframes/10-deck-import.md` | `docs/business/bulk/bulk-operations.md`, `docs/contracts/error-contract.md` |
| `23i · Deck import (failed)` | Import failed | `docs/wireframes/10-deck-import.md` | `docs/business/bulk/bulk-operations.md`, `docs/contracts/error-contract.md` |

### 6.15 Library search variants

V1 status: full global search is Future Proposal. V1 may reuse visual patterns for inline/scope-local search only.

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `24a · Library search (empty)` | Empty query | `docs/wireframes/11-library-search.md` | `docs/business/search/global-search.md` |
| `24b · Library search (loading)` | Searching | `docs/wireframes/11-library-search.md` | `docs/state/state-management-contract.md` |
| `24c · Library search (results)` | Search results | `docs/wireframes/11-library-search.md` | `docs/business/search/global-search.md` |
| `24d · Library search (no results)` | No matching result | `docs/wireframes/11-library-search.md` | `docs/business/search/global-search.md`, `docs/ui-ux/l10n-copy-contract.md` |
| `24e · Library search (error)` | Search error | `docs/wireframes/11-library-search.md` | `docs/contracts/error-contract.md` |

### 6.16 Dashboard variants

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `25a · Dashboard (loaded)` | Normal dashboard | `docs/wireframes/01-dashboard.md` | `docs/business/engagement/dashboard-engagement.md`, `docs/business/srs/srs-review.md` |
| `25b · Dashboard (loading)` | Dashboard loading state | `docs/wireframes/01-dashboard.md` | `docs/state/state-management-contract.md` |
| `25c · Dashboard (onboarding)` | First-use dashboard handoff | `docs/wireframes/01-dashboard.md`, `docs/wireframes/23-onboarding.md` | `docs/business/system/overview.md` |
| `25d · Dashboard (goal off)` | Daily goal disabled | `docs/wireframes/01-dashboard.md` | `docs/business/engagement/dashboard-engagement.md` |
| `25e · Dashboard (resume only)` | Resume session is the main CTA | `docs/wireframes/01-dashboard.md` | `docs/business/resume/resume-session.md`, `docs/business/study/study-flow.md` |
| `25f · Dashboard (streak broken)` | Broken streak feedback | `docs/wireframes/01-dashboard.md` | `docs/business/engagement/dashboard-engagement.md`, `docs/ui-ux/l10n-copy-contract.md` |
| `25g · Dashboard (error)` | Dashboard error | `docs/wireframes/01-dashboard.md` | `docs/contracts/error-contract.md` |
| `25h · Dashboard (multi resume)` | Multiple resumable sessions | `docs/wireframes/01-dashboard.md`, `docs/wireframes/24-shared-dialogs.md` | `docs/business/resume/resume-session.md` |

### 6.17 Progress variants

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `26a · Progress (week)` | Weekly progress view | `docs/wireframes/03-progress.md` | `docs/business/engagement/dashboard-engagement.md`, `docs/business/history/card-history.md` |
| `26b · Progress (month)` | Monthly progress view | `docs/wireframes/03-progress.md` | `docs/business/engagement/dashboard-engagement.md`, `docs/business/history/card-history.md` |
| `26c · Progress (loading)` | Progress loading state | `docs/wireframes/03-progress.md` | `docs/state/state-management-contract.md` |
| `26d · Progress (empty)` | No progress data | `docs/wireframes/03-progress.md` | `docs/business/engagement/dashboard-engagement.md` |
| `26e · Progress (insufficient)` | Not enough data for trend/chart | `docs/wireframes/03-progress.md` | `docs/business/engagement/dashboard-engagement.md`, `docs/ui-ux/l10n-copy-contract.md` |
| `26f · Progress (partial)` | Partial data available | `docs/wireframes/03-progress.md` | `docs/business/history/card-history.md`, `docs/contracts/error-contract.md` |
| `26g · Progress (error)` | Progress load error | `docs/wireframes/03-progress.md` | `docs/contracts/error-contract.md` |

### 6.18 Study result variants

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `27a · Study result (loaded)` | Normal completed session result | `docs/wireframes/18-study-result.md` | `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md` |
| `27b · Study result (loading)` | Result loading/finalizing | `docs/wireframes/18-study-result.md` | `docs/state/state-management-contract.md` |
| `27c · Study result (goal off)` | Result with goal disabled | `docs/wireframes/18-study-result.md` | `docs/business/engagement/dashboard-engagement.md` |
| `27d · Study result (save failed)` | Finalization/save failed | `docs/wireframes/18-study-result.md` | `docs/contracts/error-contract.md`, `docs/contracts/usecase-contracts/study.md` |
| `27e · Study result (defensive)` | Defensive fallback state | `docs/wireframes/18-study-result.md` | `docs/contracts/error-contract.md` |
| `27f · Study result (tough empty)` | Empty/tough cards fallback | `docs/wireframes/18-study-result.md` | `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md` |

### 6.19 Onboarding variants

V1 status: full onboarding is Future Proposal. V1 implements only zero-content empty-state CTAs; do not create an onboarding route or feature folder from these variants.

| Mock variant | Visual state | Wireframe | Required docs |
| --- | --- | --- | --- |
| `28a · Onboarding (welcome)` | Welcome state | `docs/wireframes/23-onboarding.md` | `docs/business/system/overview.md` |
| `28b · Onboarding (zero state)` | Empty app zero state | `docs/wireframes/23-onboarding.md` | `docs/business/system/overview.md`, `docs/business/deck/deck-management.md` |
| `28c · Onboarding (create deck)` | Create deck handoff | `docs/wireframes/23-onboarding.md`, `docs/wireframes/02-library.md` | `docs/business/deck/deck-management.md` |
| `28d · Onboarding (deck for import)` | Create deck before import | `docs/wireframes/23-onboarding.md`, `docs/wireframes/10-deck-import.md` | `docs/business/deck/deck-management.md`, `docs/business/bulk/bulk-operations.md` |
| `28e · Onboarding (signing in)` | Sign-in in progress | `docs/wireframes/23-onboarding.md`, `docs/wireframes/19-settings-account.md` | `docs/business/account-sync/account-sync.md` |
| `28f · Onboarding (restore prompt)` | Restore prompt | `docs/wireframes/23-onboarding.md`, `docs/wireframes/24-shared-dialogs.md` | `docs/business/account-sync/account-sync.md` |
| `28g · Onboarding (restoring)` | Restoring backup | `docs/wireframes/23-onboarding.md`, `docs/wireframes/19-settings-account.md` | `docs/business/account-sync/account-sync.md`, `docs/database/storage-boundaries.md` |
| `28h · Onboarding (restore failed)` | Restore failed | `docs/wireframes/23-onboarding.md` | `docs/business/account-sync/account-sync.md`, `docs/contracts/error-contract.md` |
| `28i · Onboarding (import handoff)` | Import flow handoff | `docs/wireframes/23-onboarding.md`, `docs/wireframes/10-deck-import.md` | `docs/business/bulk/bulk-operations.md`, `docs/business/flashcard/flashcard-management.md` |

## 7. Legacy and stale mock references

The mobile mock file contains legacy component functions and the mobile README still documents an older 5-screen kit.

| Legacy mock name | Current production mapping | Decision |
| --- | --- | --- |
| `HomeScreen` | `DashboardScreen` + `docs/wireframes/01-dashboard.md` | Treat `HomeScreen` as old visual reference only. Use Dashboard naming in production. |
| `LibraryScreen` | `LibraryOverviewScreen` + `docs/wireframes/02-library.md` | Use current `Library overview` variants. |
| `DeckScreen` | `FolderDetailScreen` / `FlashcardListScreen` depending route | Do not implement a generic DeckScreen unless docs explicitly require it. |
| `CardsScreen` | `FlashcardListScreen` + `docs/wireframes/06-flashcard-list.md` | Use current flashcard list naming. |
| `CreateCardScreen` | `FlashcardCreateScreen` + `docs/wireframes/07-flashcard-create.md` | Use current flashcard create naming. |
| `BulkAddScreen` | `DeckImportScreen` + `docs/wireframes/10-deck-import.md` | Use deck import naming and bulk operation docs. |
| `StatsScreen` | `ProgressScreen` + `docs/wireframes/03-progress.md` | Treat Stats as legacy. Production route is `/progress`. |

Technical decision: do not delete legacy functions from the mock without a separate design cleanup task. For implementation, ignore them unless they are explicitly selected as visual references by the technical lead.

## 8. Component preview mapping

| Preview file | Design area | Primary implementation docs | Usage note |
| --- | --- | --- | --- |
| `preview/theme-overview.html` | Theme overview | `docs/ui-ux/ui-ux-contract.md`, `docs/system-design/MemoX Design System/README.md` | Use as high-level theme validation reference. |
| `preview/theme-system.html` | Theme system | `docs/ui-ux/ui-ux-contract.md`, `colors_and_type.css` | Use to map light/dark surfaces and semantic roles. |
| `preview/colors-seeds.html` | Seed colors | `colors_and_type.css` | Resolve seed conflicts before final Flutter theme implementation. |
| `preview/colors-surfaces.html` | Surface colors | `docs/ui-ux/ui-ux-contract.md`, `colors_and_type.css` | Use for scaffold/card/surface mapping. |
| `preview/colors-dark-surfaces.html` | Dark surfaces | `docs/ui-ux/ui-ux-contract.md`, `colors_and_type.css` | Use for dark theme validation. |
| `preview/colors-on-surface.html` | Text/icon colors | `docs/ui-ux/l10n-copy-contract.md`, `colors_and_type.css` | Use for contrast and hierarchy. |
| `preview/colors-semantic.html` | Semantic colors | `docs/contracts/error-contract.md`, `colors_and_type.css` | Use for error/success/warning/info states. |
| `preview/colors-status.html` | Status colors | `docs/contracts/error-contract.md`, `docs/business/**/*.md` | Use for state badges and alerts. |
| `preview/colors-ratings.html` | Study ratings | `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md` | Use for Again/Hard/Good/Easy visual states only after business behavior is confirmed. |
| `preview/colors-mastery-gradient.html` | Mastery/progress colors | `docs/business/srs/srs-review.md`, `docs/business/engagement/dashboard-engagement.md` | Use for progress rings/bars. |
| `preview/type-scale.html` | Typography scale | `docs/ui-ux/ui-ux-contract.md` | Flutter implementation must map to theme typography tokens. |
| `preview/type-display.html` | Display text | `docs/ui-ux/l10n-copy-contract.md` | Use visual style only; text must remain localizable. |
| `preview/type-in-use.html` | Type hierarchy in layouts | `docs/wireframes/*.md`, `docs/ui-ux/ui-ux-contract.md` | Use to validate hierarchy, not exact strings. |
| `preview/spacing-grid.html` | Spacing grid | `docs/ui-ux/ui-ux-contract.md` | Map to Flutter spacing tokens. |
| `preview/spacing-radii.html` | Radius tokens | `docs/ui-ux/ui-ux-contract.md` | Do not hardcode `BorderRadius`. |
| `preview/spacing-elevation.html` | Elevation/shadow | `docs/ui-ux/ui-ux-contract.md` | Use theme/elevation tokens. |
| `preview/spacing-motion.html` | Motion/duration | `docs/ui-ux/ui-ux-contract.md` | Do not hardcode durations. |
| `preview/spacing-opacity.html` | Opacity tokens | `docs/ui-ux/ui-ux-contract.md` | Use named opacity tokens. |
| `preview/component-buttons.html` | Buttons | `docs/ui-ux/ui-ux-contract.md`, `docs/contracts/code-style.md` | Map to shared button components, not raw Flutter buttons when shared widget exists. |
| `preview/component-bottom-nav.html` | Bottom navigation | `docs/wireframes/01-dashboard.md` to `04-settings-hub.md`, `docs/business/navigation/navigation-flow.md` | Main tabs must match route docs. |
| `preview/component-chips.html` | Chips/filters | `docs/wireframes/02-library.md`, `docs/wireframes/11-library-search.md`, `docs/wireframes/22-settings-tag-management.md` | Use shared chip components. |
| `preview/component-deck-card.html` | Deck cards | `docs/wireframes/02-library.md`, `docs/wireframes/05-folder-detail.md`, `docs/business/deck/deck-management.md` | Use for deck card visual hierarchy. |
| `preview/component-inputs.html` | Inputs | `docs/wireframes/07-flashcard-create.md`, `08-flashcard-edit.md`, `10-deck-import.md`, `docs/contracts/error-contract.md` | Do not use raw `TextField` if shared input exists. |
| `preview/component-mastery-progress.html` | Mastery progress | `docs/wireframes/01-dashboard.md`, `03-progress.md`, `18-study-result.md`, `docs/business/srs/srs-review.md` | Use to validate visual progress states. |
| `preview/component-toast.html` | Toast/snackbar | `docs/wireframes/24-shared-dialogs.md`, `docs/contracts/error-contract.md` | Use shared feedback component. |
| `preview/brand-logo.html` | Logo | `docs/system-design/MemoX Design System/README.md` | Use asset references, not recreated logo paths. |
| `preview/brand-icons.html` | Brand icon usage | `docs/system-design/MemoX Design System/README.md` | Use icon components/assets as defined by app implementation. |
| `preview/brand-voice.html` | Brand copy | `docs/ui-ux/l10n-copy-contract.md` | Copy must remain localizable. |

## 9. Uploaded image mapping

The files in `docs/system-design/MemoX Design System/uploads/*` are source visual references.

Rules:

1. Do not implement directly from uploaded screenshots unless the matching wireframe and mock variant are identified.
2. If a screenshot conflicts with a wireframe, update the wireframe through a separate documentation task before coding.
3. Treat screenshots as visual evidence, not behavior contracts.
4. If a screenshot represents a new state not covered by `ui_kits/mobile/index.html`, add a new mapping row here before implementation.

## 10. Missing or weak mock coverage

| Area | Current issue | Leadership decision |
| --- | --- | --- |
| Study entry gate | No explicit rendered gallery group is mapped to `docs/wireframes/12-study-entry-gate.md`. | Implement from wireframe/business docs first. Add visual mock later if needed. |
| Shared dialogs catalog | Dialogs exist as embedded states, but not as a standalone complete gallery. | Use `docs/wireframes/24-shared-dialogs.md` as source of truth. Mock embedded dialogs are visual references only. |
| Shared bottom sheets catalog | Sheets exist as embedded states, but not as a standalone complete gallery. | Use `docs/wireframes/25-shared-bottom-sheets.md` as source of truth. |
| Mobile kit README | It describes older 5-screen setup while `index.html` contains 129 variants. | Create a separate cleanup task to update README. This mapping intentionally does not overwrite it. |
| Legacy naming | `Stats`, `Home`, `Deck`, `Cards`, `BulkAdd` appear in old mock code. | Use current docs naming: Dashboard, Progress, Folder detail, Flashcard list, Deck import. |
| Token drift | Some design docs may use old theme/color names. | Resolve token conflicts in a separate design-system cleanup task before large-scale UI implementation. |

## 11. Recommended implementation checklist per screen

For each screen or screen group:

1. Identify the mock variant IDs from this mapping.
2. Open the matching wireframe.
3. Read the wireframe `Implementation refs` section.
4. Read the linked business docs.
5. Read the linked contracts.
6. Inspect `colors_and_type.css` only to understand visual token intent.
7. Map mock visuals to existing Flutter theme/shared widgets.
8. Implement states in the notifier/view model, not with local mock flags.
9. Add or update tests using the decision table IDs where available.
10. Run recursive review against:
    - business docs,
    - wireframe,
    - mock visual state,
    - design system token rules,
    - architecture contracts.

## 12. Hard implementation bans

Do not do the following:

1. Do not copy raw CSS values from `index.html` into Flutter widgets.
2. Do not copy JSX component structure as Flutter architecture.
3. Do not create feature folders based only on legacy mock component names.
4. Do not introduce `stats` as a production feature if docs say `progress`.
5. Do not implement mock-only states that are not backed by business/state docs.
6. Do not bypass use cases/repositories just because mock data is local in HTML.
7. Do not put emoji strings into production UI. Emoji in visual drafts means icon intent only.
8. Do not use mock text as final UI copy without checking l10n contract.

## 13. Final leadership position

This mapping makes the mock design usable by AI agents without letting the mock override the product specification.

The correct workflow is:

```text
Markdown docs define behavior and architecture.
Design system defines visual rules and tokens.
Mock HTML shows the intended visual result.
Implementation maps all three into Flutter code through shared widgets and clean architecture boundaries.
```

With this mapping in place, future implementation prompts can safely say:

```text
Use docs/system-design/mock-design-doc-mapping.md to identify the correct mock variants and required Markdown specs before implementing any MemoX screen.
```
