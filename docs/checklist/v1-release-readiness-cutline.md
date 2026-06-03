---
last_updated: 2026-06-02
status: current release cutline
scope: V1 release readiness after Prompt 30B
---

# V1 Release Readiness Cutline

This file locks the V1 release-readiness boundary after Prompt 30B.

It is a cutline, not a feature wish list. A row marked `Current` is safe enough
for a V1 release candidate because the current code, docs, and tests support
that scope. A row marked `Partial` may still ship only for the explicitly named
V1 subset. Future, Target, and Blocked items must not be reclassified as release
blockers unless they break a current V1 flow.

## A. V1 Current / Release Candidate

| Area | Cutline status | V1-safe scope | Evidence |
| --- | --- | --- | --- |
| Library V1 | Partial | Top-level folders, inline scope-local search, true-empty vs no-results, root folder creation. Root-level decks are Rejected / Out of Scope. | `docs/checklist/implementation-ledger.md` Prompt 18/18B/30B; `docs/wireframes/02-library.md`; `test/presentation/library_overview_screen_test.dart` |
| Folder Detail V1 | Partial | Folder/deck child browsing by content mode, local search, sort chip/menu, create subfolder/deck within lock rules, row actions, invalid-id safety. Study/Today/Resume banners remain Future/Target. | Prompt 19 ledger row; `docs/wireframes/05-folder-detail.md`; `test/presentation/folder_detail_screen_test.dart` |
| Deck management V1 | Current for verified folder-owned deck flows | Create, rename, move, delete, duplicate/export/import entry through Folder Detail / Flashcard List owners. Root-level deck creation is Rejected / Out of Scope. | Prompt 19 ledger row; `docs/business/deck/deck-management.md`; folder/flashcard focused tests |
| Flashcard List V1 | Current for verified V1 scope | Deck flashcard list, invalid deck safety, loading/error/empty/no-results states, local search, sort/reorder, row/bulk Delete-Move-Export, import and study entry ownership. | Prompt 16/16B ledger rows; `docs/wireframes/06-flashcard-list.md`; `test/presentation/flashcard_list_screen_test.dart` |
| Flashcard Create/Edit V1 | Current for shared-editor contract | Create/edit through shared editor, dirty-exit guard, destination save navigation, learned-content Keep/Reset policy dialog. History and standalone progress reset remain Future. | Prompt 15/15B ledger rows; `docs/wireframes/07-flashcard-create.md`; `docs/wireframes/08-flashcard-edit.md` |
| Deck Import V1 | Current for inline bulk-add scope | CSV / structured text / Excel parse, validation preview, transactional commit, default progress init, duplicate handling in the V1 inline flow. Multi-step result flow remains Future. | Prompt 17 ledger row; `docs/wireframes/10-deck-import.md` |
| Study Entry V1 | Partial | Deck/folder/today entry, current empty-scope cases, resume/start-over conflict handling. Tag entry remains Blocked/Future. | Prompt 13 ledger section; `docs/wireframes/12-study-entry-gate.md`; study entry tests |
| Core Learning Loop V1 | Current for frozen current behavior | Study entry, resume/start-over, full cycle, single-mode entries, five study modes, SRS finalize, result navigation. | Prompt 13 ledger freeze; `docs/business/study/study-flow.md`; study/domain/data tests |
| Study Session V1 | Current for verified current behavior | Review, Match, Guess, Recall, Fill, shared card-actions overflow, cancel/exit protection, finalize path. Optional long-press shortcut remains P3 polish. | Prompt 13/28 ledger rows; study session tests |
| Study Result V1 | Current for verified current behavior | Result summary, failed-finalize recovery, Done routing, Study more scope picker for Today/Deck/Folder, per-card review section. Engagement/tough-card expansion remains Future/Target. | Prompt 09B/13/28 ledger rows; `test/presentation/study_result_screen_test.dart` |
| Dashboard V1 | Partial | Due/new/mastery summary, recent decks, resume card, paused-sessions sheet, Start new learning for Today/Deck/Folder. Full engagement and Dashboard onboarding remain Future/Target. | Prompt 04/30B ledger rows; `docs/wireframes/01-dashboard.md`; `test/presentation/dashboard_screen_test.dart` |
| Progress Overview V1 | Current for V1 overview + active-session recovery | Due/new/mastery/card-count summary and active/ready/failed session recovery. Analytics charts, history, and engagement remain Future/Target. | Prompt 20 ledger row; `docs/wireframes/03-progress.md`; `test/presentation/progress_screen_test.dart` |
| Settings Hub V1 | Partial | Route/action-safe settings hub, navigation rows, disabled Appearance/Language rows, About via current `AboutDialog`. Dynamic subtitles/About sheet remain polish/Target. | Prompt 21 ledger row; `docs/wireframes/04-settings-hub.md`; settings/router tests |
| Account Settings V1 | Partial | Google sign-in/sign-out/disconnect, safe auth errors, manual Drive upload/restore with Prompt 41 destructive restore warning, cancel/confirm protection, duplicate-running guard, and visible restore success/failure feedback. Full restore-protection and account-removal strong-confirm remain Target/Future. | Prompt 22/41 ledger rows; `docs/wireframes/19-settings-account.md`; `test/presentation/settings_screen_test.dart`; `test/presentation/drive_sync_viewmodel_test.dart` |
| Learning Settings V1 | Partial | Study defaults, shared study toggles, read-only interval table, Manage tags route. Daily goal/streak/reminder controls remain Future/Target. | Prompt 23 ledger row; `docs/wireframes/20-settings-learning.md`; learning/settings tests |
| Audio/Speech Settings V1 | Current for global/front-language settings | Auto-play, front language, front voice, rate, pitch, volume, preview, safe failure copy. Independent per-language tabs/settings remain Future/Target. | Prompt 24 ledger row; `docs/wireframes/21-settings-audio-speech.md`; `test/presentation/settings_screen_test.dart`; `test/presentation/tts_controller_test.dart` |
| Tag Management V1 | Current for management scope | Tag list/count, search/no-results/sort, rename, merge, delete through UseCase -> Repository -> DAO. Study/View tag actions remain Blocked/Future. | Prompt 25 ledger row; `docs/wireframes/22-settings-tag-management.md`; tag tests |
| Shared Dialogs V1 | Partial catalog / Current primitives | `MxDialog`, `MxConfirmationDialog`, `MxNameDialog`, `MxDialogResumeOrStartOver`, current composed confirms. Strong-confirm and full restore-warning catalog remain Target/Future. | Prompt 27 ledger row; `docs/wireframes/24-shared-dialogs.md`; shared dialog tests |
| Shared Bottom Sheets V1 | Partial catalog / Current primitives | `MxBottomSheet`, `MxActionSheetList`, `MxDestinationPickerSheet`, `MxCardActionsSheet`, current scope picker and paused-sessions usage. Dedicated sort/engagement sheets remain Target/Future. | Prompt 28 ledger row; `docs/wireframes/25-shared-bottom-sheets.md`; bottom-sheet tests |

## B. Known Future / Not in V1

These items are intentionally outside the V1 release candidate:

| Item | V1 classification | Reason |
| --- | --- | --- |
| Global Search | Future Proposal | No live route/use case. V1 uses inline scope-local search only. |
| Flashcard History | Future Proposal / Migration Required | Requires history route/link approval and schema fields such as `last_reset_at`, `box_before`, `box_after`. |
| Tag-scoped study | Blocked/Future | Blocked on `StudyEntryType.tag`, tag scope query, canonical `entry_ref_id`, empty-scope rows, and route tests. |
| Full onboarding wizard | Future Proposal | No `/onboarding` route, feature folder, first-launch gate, or wizard in V1. |
| Root-level decks | Rejected / Out of Scope | Product owner rejected root-level decks. Library root contains folders only; Folder Detail contains decks; every deck belongs to exactly one folder. `decks.folder_id` must stay non-null and nullable deck parent migration is Rejected / Not Applicable. |
| Full restore-protection | Partial / Target | Prompt 41 implements current destructive warning/cancel/confirm/running guard/feedback only. Pre-restore snapshot, Upload local first branch, second destructive confirmation, restore history, cloud comparison/conflict resolution, and abort-on-snapshot-failure remain target scope. |
| Engagement / streak / daily goal / reminders | Future / Target | No engagement use-case/persistence/sheet stack is promoted. Existing visual/stat tokens do not make the feature Current. |
| Independent TTS language tabs/settings | Future / Target | Current V1 has one global/front-language settings set only. |
| Strong-confirm account removal | Target/Future | Shared strong-confirm typed input and account removal flow are not V1. |
| Dedicated `SortOptionsSheet` | NotStarted / Target | Current sort UI is chip/menu based. |
| Active-session undo reinsert | Future polish | Current card-action undo reverts progress only; it does not reinsert dropped cards into the active session. |
| Dashboard-as-landing default boot behavior | Target/Future | Current V1 boot redirects `/` to Library; changing default boot to Dashboard requires a dedicated navigation task. |

## C. True Release Blockers

No true release blockers were found in Prompt 31.

The current V1 release candidate remains safe as a scoped release if the release
notes and QA plan describe the Partial areas above honestly. Future/Target gaps
must not be counted as blockers unless a current V1 route/action breaks.

## D. Low-risk Polish Candidates

| Candidate | Why it is low-risk | Suggested owner |
| --- | --- | --- |
| Dashboard streak placeholder wording/status audit | Completed by Prompt 32: keep the static `0 days` UI unchanged as a simple visual/stat placeholder, with docs clarifying it is not full engagement. | Codex |
| Add or refresh one focused router smoke test for unknown/private route safety if coverage is missing | Completed by Prompt 32: router smoke tests lock Future/Blocked paths to the router error state and check no Future route constants/navigation helpers were promoted. | Codex |
| Metadata refresh for docs touched during release | Several docs are intentionally living trackers. Keeping `last_updated` and lineage current reduces agent confusion. | Codex |
| Settings Hub About polish decision | Current behavior is `AboutDialog`; target bottom sheet remains Future. This can stay as-is or be documented as release polish. | Codex |
| Mock-mapping README cleanup | Mobile kit README is known stale relative to the 129-variant mock file. This is docs-only and should not affect V1 behavior. | Claude Code or Codex |

## E. Prompt 32+ Recommended Order

### Prompt 32

| Field | Recommendation |
| --- | --- |
| Title | Release Polish: Future-route smoke lock + dashboard streak placeholder decision |
| Owner | Codex |
| Scope | Add only small tests/docs if needed: verify no Global Search, Flashcard History, onboarding, or tag-study route exposure; decide whether the Dashboard static streak stat needs docs/copy polish. |
| Files to inspect | `lib/app/router/**`, `lib/presentation/features/dashboard/**`, `test/app/router/**`, `test/presentation/dashboard_screen_test.dart`, `docs/wireframes/01-dashboard.md`, `docs/business/engagement/dashboard-engagement.md` |
| Verification commands | `flutter test test/app/router/app_router_test.dart`; `flutter test test/app/router/route_guards_test.dart`; `flutter test test/presentation/dashboard_screen_test.dart`; `flutter analyze`; `python code-verification-guard/guard/run.py check --project . --ruleset memox` |
| Explicit out-of-scope | Do not implement engagement, streak history, daily goals, reminders, Global Search, History, onboarding, tag-scoped study, schema changes, or route redesign. |

### Prompt 33

| Field | Recommendation |
| --- | --- |
| Title | V1 Docs Honesty Sweep: release notes inputs and metadata |
| Owner | Claude Code |
| Scope | Prepare release-note-ready documentation from the cutline: Current V1, Partial-but-shippable areas, Known Future gaps, and QA notes. Keep statuses honest. |
| Files to inspect | `docs/checklist/v1-release-readiness-cutline.md`, `docs/checklist/screen-function-task-matrix.md`, `docs/checklist/wireframe-code-parity-assessment.md`, `docs/checklist/v1-implementation-scope-2026-05-29.md`, `docs/business/system/overview.md`, `docs/wireframes/index.md` |
| Verification commands | Markdown cross-ref check from `CLAUDE.md`; `flutter analyze`; `python code-verification-guard/guard/run.py check --project . --ruleset memox` |
| Explicit out-of-scope | Do not promote Future/Target rows, add new product promises, or change production code. |

### Prompt 34

| Field | Recommendation |
| --- | --- |
| Title | V1 Low-risk UI/Copy Polish Window |
| Owner | Codex |
| Scope | Only tiny existing-flow polish that does not alter architecture: weak empty-state copy, missing localized string for an existing UI, or a narrowly scoped route/widget smoke gap found by Prompt 32/33. |
| Files to inspect | The exact screen/widget/test files named by Prompt 32/33 findings; relevant wireframe/business doc for each touched area; `lib/l10n/app_en.arb`; `lib/l10n/app_vi.arb` if copy changes |
| Verification commands | Focused tests for each touched screen; `flutter analyze`; `python code-verification-guard/guard/run.py check --project . --ruleset memox`; full `flutter test` only if production/test changes touch shared behavior. |
| Explicit out-of-scope | No new features, no schema, no SRS changes, no design-token changes, no new dependencies, no broad refactors, no Future route exposure. |

### Prompt 35

| Field | Recommendation |
| --- | --- |
| Title | V1 Release Candidate Regression Gate |
| Owner | Codex |
| Scope | Re-run the release candidate gates after all low-risk polish is complete and update the implementation ledger with the final RC status. |
| Files to inspect | `docs/checklist/implementation-ledger.md`, `docs/checklist/v1-release-readiness-cutline.md`, latest git diff, focused touched tests from Prompt 32-34 |
| Verification commands | `dart run build_runner build --delete-conflicting-outputs`; `flutter analyze`; focused smoke tests for touched areas; full `flutter test`; `python code-verification-guard/guard/run.py check --project . --ruleset memox`; scope leak scan |
| Explicit out-of-scope | Do not fix unrelated failures by widening scope; classify any failure as RC blocker or punt to a narrow follow-up. |

## Route Exposure Check

| Area | Prompt 31 result | Classification |
| --- | --- | --- |
| Global Search | No live route name/path/use case found. Inline `LibrarySearchNoResultsSection` is scope-local Library UI, not Global Search. | not present |
| Flashcard History | No live route name/path/screen folder found. Docs keep it Future/Migration Required. | not present |
| Tag-scoped study | Present only as blocked docs/comment references; `study/:entryType/:entryRefId` route exists for current entry types, but UI scope pickers do not expose Tag. | present as blocked type/doc only |
| Onboarding | No live route or feature folder found. `MxActionIntent.onboardingHero` is a reusable button intent name, not an onboarding flow. | not present as feature |
| Engagement / streak / daily goal | Theme tokens/shared `MxStreakCard` and a Dashboard static `0 days` stat exist; no engagement use cases, sheets, reminders, or settings controls are promoted. | present as visual/token/placeholder only |
| Account removal strong-confirm | No strong-confirm account removal flow found. Existing sign-out/disconnect confirmations are normal current account actions. | not present |
| TTS per-language tabs | No independent per-language tabs/settings found. Current V1 is global/front-language settings. | not present |
| Root-level decks | No Library root-deck read-model/channel or route exposure found. Prompt 42 confirmed `decks.folder_id` is non-null and deck APIs require concrete folder ids. Product owner rejected root-level decks after Prompt 42B; nullable deck parent migration is Not Applicable. Folder-owned deck flows remain current. | rejected / out of scope |
| Dashboard-as-landing default boot behavior | Current boot remains Library; Dashboard is a top-level destination only. | not present as default boot |

## Prompt 31 Decision

Prompt 31 status: PASS.

The V1 release candidate can proceed with the scoped cutline above. Prompt 32 is
safe to start as a low-risk route/docs/copy polish task, not a feature expansion.

## Prompt 32 Decision

Prompt 32 status: PASS.

Future-route smoke coverage now locks Global Search, Flashcard History,
onboarding, reminder/daily-goal settings paths, and related Future route
registry/navigation helpers out of the live V1 route surface. Dashboard keeps
the static `0 days` streak stat as Option A: a simple visual/stat placeholder
only. No production code, ARB/l10n, schema, dependency, route, SRS, or visual
redesign change was made.

## Prompt 33 Decision

Prompt 33 status: PASS.

Release-note-ready docs now live in
`docs/checklist/v1-release-notes-input.md`, and the manual QA smoke package now
lives in `docs/checklist/v1-release-qa-smoke-plan.md`. The V1 cutline above is
unchanged: Current and Partial scopes remain shippable as named, while
Future/Target/Blocked items remain excluded from V1.
