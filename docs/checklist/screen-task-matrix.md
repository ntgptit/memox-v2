---
last_updated: 2026-05-29
author: technical lead
status: living tracker (update each PR)
purpose: Master coordination table — one row per (screen × function). Use this to scope work, avoid duplicate effort, and ensure each task touches the right code + doc + wireframe.
---

# MemoX — Screen × Function task matrix

## How to use

- **One row = one shippable task** (usually one PR-sized vertical slice).
- "Function detail" names the use case / notifier method / widget that owns the behavior. If empty, the behavior is not yet decomposed — first task in that row is to design the decomposition.
- "Files to modify" lists the canonical owner files; cross-cutting helpers (theme tokens, l10n, decision-table) are implied by the [Doc-code parity rule](../../CLAUDE.md).
- Always re-read the **doc refs** + **wireframe** before opening the task. They are the source of truth — if code disagrees, report drift before coding.
- Path convention follows `CLAUDE.md` §"Path convention for cross-references": repo-root absolute, no leading slash.

## Legend

- 🟢 = implemented & test-covered  ·  🟡 = partial / placeholder  ·  🔴 = not started  ·  ⏸ = blocked (see notes)

## Cross-screen / foundational

| Screen | Function | Function detail (use case / notifier / widget) | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| _foundation_ | Error / Failure taxonomy | `AppFailure`, `AppException`, `MxActionErrors` | `lib/core/errors/**` | `docs/contracts/error-contract.md` | — |
| _foundation_ | Type catalog (enums, value objects) | `StudyEntryType`, `StudyType`, `AttemptGrade`, `ContentQuery`, … | `lib/domain/enums/**`, `lib/domain/value_objects/**` | `docs/contracts/types-catalog.md` | — |
| _foundation_ | Code style / naming | — | repo-wide | `docs/contracts/code-style.md` | — |
| _foundation_ | Route registry | `RouteNames`, `RoutePaths`, `RouteDefaults`, `AppNavigation` | `lib/app/router/route_names.dart`, `lib/app/router/app_navigation.dart` | `docs/business/navigation/navigation-flow.md` | — |
| _foundation_ | Theme tokens + design system | `AppSpacing`, `AppRadius`, `AppIconSizes`, color scheme | `lib/core/theme/**` | `docs/ui-ux/ui-ux-contract.md`, `docs/system-design/MemoX Design System/README.md` | — |
| _foundation_ | Localization keys | EN/VI ARB sources | `lib/l10n/app_en.arb`, `lib/l10n/app_vi.arb` | `docs/ui-ux/l10n-copy-contract.md` | — |
| _foundation_ | Decision-table rows | `S*`, `D*`, `F*` row IDs | `docs/decision-tables/memox-core-decision-table.md` | self | — |

## 01. Dashboard (`/home`)

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Dashboard | Render landing populated state | `DashboardNotifier`, `DashboardScreen` | `lib/presentation/features/dashboard/screens/dashboard_screen.dart`, `lib/presentation/features/dashboard/providers/*` | `docs/business/engagement/dashboard-engagement.md` | `docs/wireframes/01-dashboard.md` |
| Dashboard | Render onboarding (zero-content) state | `DashboardOnboardingSection` | dashboard widgets | `docs/business/engagement/dashboard-engagement.md`, `docs/business/system/overview.md` | `docs/wireframes/01-dashboard.md`, `docs/wireframes/23-onboarding.md` |
| Dashboard | Resume card | `FindResumableSessionUseCase` + `ResumeCardWidget` | `lib/domain/study/usecases/study_usecases.dart` (`ResumeStudySessionUseCase.findCandidate`), dashboard widget | `docs/business/resume/resume-session.md`, `docs/contracts/usecase-contracts/study.md` §FindResumableSessionUseCase | `docs/wireframes/01-dashboard.md` |
| Dashboard | Today's review CTA | navigates to study entry gate (today) | `app_navigation.dart` push, dashboard widget | `docs/business/study/study-flow.md`, `docs/business/engagement/dashboard-engagement.md` | `docs/wireframes/01-dashboard.md`, `docs/wireframes/12-study-entry-gate.md` |
| Dashboard | Start new learning (scope picker) | scope picker bottom-sheet → entry gate | dashboard widget, `lib/presentation/shared/widgets/sheets/scope_picker_sheet.dart` | `docs/business/study/study-flow.md` | `docs/wireframes/01-dashboard.md`, `docs/wireframes/25-shared-bottom-sheets.md` §scope-picker |
| Dashboard | Streak chip + history | `GetStreakUseCase`, `StreakHistorySheet` | `lib/domain/usecases/engagement_*`, dashboard widget | `docs/business/engagement/dashboard-engagement.md`, `docs/contracts/usecase-contracts/engagement.md` | `docs/wireframes/01-dashboard.md`, `docs/wireframes/25-shared-bottom-sheets.md` §streak-history |
| Dashboard | Daily goal ring | `GetDailyGoalUseCase`, `SetDailyGoalUseCase` | engagement use cases, dashboard widget | `docs/business/engagement/dashboard-engagement.md` | `docs/wireframes/01-dashboard.md`, `docs/wireframes/25-shared-bottom-sheets.md` §daily-goal |
| Dashboard | Recent decks (top 3) | `GetRecentDecksUseCase` | `lib/domain/usecases/deck_*`, dashboard widget | `docs/business/engagement/dashboard-engagement.md`, `docs/contracts/usecase-contracts/deck.md` | `docs/wireframes/01-dashboard.md` |
| Dashboard | Discard paused session dialog | shared confirm dialog | `lib/presentation/shared/widgets/dialogs/discard_session_dialog.dart` | `docs/business/resume/resume-session.md` | `docs/wireframes/24-shared-dialogs.md` §discard-session |
| Dashboard | Paused sessions list sheet | bottom-sheet listing resumables | `lib/presentation/shared/widgets/sheets/paused_sessions_sheet.dart` | `docs/business/resume/resume-session.md` | `docs/wireframes/25-shared-bottom-sheets.md` §paused-sessions |

## 02. Library (`/library`)

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Library | List top-level folders + root decks | `LibraryOverviewNotifier`, `library_overview_screen.dart` | `lib/presentation/features/folders/screens/library_overview_screen.dart` | `docs/business/folder/folder-management.md`, `docs/business/deck/deck-management.md` | `docs/wireframes/02-library.md` |
| Library | Empty state | dedicated section | library widget | `docs/business/folder/folder-management.md` | `docs/wireframes/02-library.md` |
| Library | Sort overflow | `ContentSortMode` switcher | shared sort menu widget | `docs/contracts/types-catalog.md`, `docs/business/folder/folder-management.md` | `docs/wireframes/02-library.md` |
| Library | Create folder | `CreateFolderUseCase` | `lib/domain/usecases/folder_usecases.dart`, create folder dialog | `docs/business/folder/folder-management.md`, `docs/contracts/usecase-contracts/folder.md` | `docs/wireframes/02-library.md`, `docs/wireframes/24-shared-dialogs.md` |
| Library | Create deck | `CreateDeckUseCase` | `lib/domain/usecases/deck_usecases.dart`, create deck dialog | `docs/business/deck/deck-management.md`, `docs/contracts/usecase-contracts/deck.md` | `docs/wireframes/02-library.md`, `docs/wireframes/24-shared-dialogs.md` |
| Library | Search entry | navigates to library search | `app_navigation.dart` | `docs/business/search/global-search.md` | `docs/wireframes/02-library.md`, `docs/wireframes/11-library-search.md` |

## 03. Progress (`/progress`)

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Progress | Active sessions list | `ResumeStudySessionUseCase.listActiveSessions` | `lib/presentation/features/progress/screens/progress_screen.dart` | `docs/business/resume/resume-session.md`, `docs/contracts/usecase-contracts/study.md` | `docs/wireframes/03-progress.md` |
| Progress | Aggregate metrics (cards/day, accuracy) | `GetProgressMetricsUseCase` | `lib/domain/usecases/engagement_*` | `docs/business/engagement/dashboard-engagement.md` | `docs/wireframes/03-progress.md` |
| Progress | Discard session row | shared confirm dialog → cancel session | `CancelStudySessionUseCase` | `docs/business/resume/resume-session.md` | `docs/wireframes/03-progress.md`, `docs/wireframes/24-shared-dialogs.md` |

## 04. Settings hub (`/settings`)

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Settings hub | Navigation list to sub-screens | static rows | `lib/presentation/features/settings/screens/settings_screen.dart` | `docs/business/system/overview.md` | `docs/wireframes/04-settings-hub.md` |
| Settings hub | Account status row | `AccountStateNotifier` | settings widget | `docs/business/account-sync/account-sync.md` | `docs/wireframes/04-settings-hub.md`, `docs/wireframes/19-settings-account.md` |

## 05. Folder detail (`/library/folder/:id`)

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Folder detail | Render `subfolders` / `decks` / `unlocked` mode | `FolderDetailNotifier` mode resolution | `lib/presentation/features/folders/screens/folder_detail_screen.dart` | `docs/business/folder/folder-management.md` | `docs/wireframes/05-folder-detail.md` |
| Folder detail | Create child folder | `CreateFolderUseCase(parentId)` | folder use case, dialog | `docs/business/folder/folder-management.md`, `docs/contracts/usecase-contracts/folder.md` | `docs/wireframes/05-folder-detail.md`, `docs/wireframes/24-shared-dialogs.md` |
| Folder detail | Create deck | `CreateDeckUseCase(folderId)` | deck use case, dialog | `docs/business/deck/deck-management.md`, `docs/contracts/usecase-contracts/deck.md` | `docs/wireframes/05-folder-detail.md`, `docs/wireframes/24-shared-dialogs.md` |
| Folder detail | Rename folder | `RenameFolderUseCase` | folder use case, rename dialog | `docs/contracts/usecase-contracts/folder.md` | `docs/wireframes/24-shared-dialogs.md` |
| Folder detail | Move folder/deck | `MoveFolderUseCase`, `MoveDeckUseCase` | folder/deck use cases, move sheet | `docs/business/bulk/bulk-operations.md`, `docs/contracts/usecase-contracts/bulk.md` | `docs/wireframes/25-shared-bottom-sheets.md` §move-picker |
| Folder detail | Delete folder/deck (cascade) | `DeleteFolderUseCase`, `DeleteDeckUseCase` | folder/deck use cases, confirm dialog | `docs/contracts/usecase-contracts/folder.md`, `docs/contracts/usecase-contracts/deck.md` | `docs/wireframes/24-shared-dialogs.md` |
| Folder detail | Start study (folder scope) | navigate to study entry gate (`entry_type=folder`) | `app_navigation.dart` | `docs/business/study/study-flow.md` | `docs/wireframes/12-study-entry-gate.md` |

## 06. Flashcard list (`/library/deck/:deckId/flashcards`)

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Flashcard list | Normal mode list + filter | `FlashcardListNotifier`, `ContentQuery` | `lib/presentation/features/flashcards/screens/flashcard_list_screen.dart` | `docs/business/flashcard/flashcard-management.md` | `docs/wireframes/06-flashcard-list.md` |
| Flashcard list | Empty state (no flashcards) | dedicated section + Add CTA | list widget | `docs/business/flashcard/flashcard-management.md` | `docs/wireframes/06-flashcard-list.md` |
| Flashcard list | Filtered empty state | dedicated state | list widget | `docs/business/flashcard/flashcard-management.md` | `docs/wireframes/06-flashcard-list.md` |
| Flashcard list | Selection mode + bulk actions | `SelectionController`, `BulkDeleteFlashcardsUseCase`, `BulkMoveFlashcardsUseCase`, `BulkTagFlashcardsUseCase` | list widget, `lib/domain/usecases/bulk_*` | `docs/business/bulk/bulk-operations.md`, `docs/contracts/usecase-contracts/bulk.md` | `docs/wireframes/06-flashcard-list.md` |
| Flashcard list | Add flashcard CTA | push `flashcardCreate` | list widget | `docs/business/flashcard/flashcard-management.md` | `docs/wireframes/07-flashcard-create.md` |
| Flashcard list | Import flashcards | push `deckImport` | list widget | `docs/business/flashcard/flashcard-management.md` (import section) | `docs/wireframes/10-deck-import.md` |
| Flashcard list | Reorder (manual sort) | `ReorderFlashcardsUseCase` | flashcard use case, drag handle | `docs/business/flashcard/flashcard-management.md`, `docs/contracts/usecase-contracts/flashcard.md` | `docs/wireframes/06-flashcard-list.md` |

## 07. Flashcard create (`/library/deck/:deckId/flashcards/new`)

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Flashcard create | Front/back editor | `FlashcardEditorNotifier` create mode | `lib/presentation/features/flashcards/screens/flashcard_editor_screen.dart` | `docs/business/flashcard/flashcard-management.md` | `docs/wireframes/07-flashcard-create.md` |
| Flashcard create | Tag input | `mx_tag_input` + `EnsureTagUseCase` | tag use case, widget | `docs/business/tags/tag-system.md`, `docs/contracts/usecase-contracts/tag.md` | `docs/wireframes/07-flashcard-create.md`, `docs/wireframes/22-settings-tag-management.md` |
| Flashcard create | Starting status picker | `FlashcardStartingStatus` selector | editor widget | `docs/business/flashcard/flashcard-management.md`, `docs/business/srs/srs-review.md` | `docs/wireframes/07-flashcard-create.md` |
| Flashcard create | Validation + submit | `CreateFlashcardUseCase` | `lib/domain/usecases/flashcard_usecases.dart` | `docs/contracts/usecase-contracts/flashcard.md` | `docs/wireframes/07-flashcard-create.md` |
| Flashcard create | TTS preview | `PreviewTtsUseCase` | `lib/domain/usecases/tts_*` | `docs/business/tts/tts-settings.md`, `docs/contracts/usecase-contracts/tts.md` | `docs/wireframes/07-flashcard-create.md`, `docs/wireframes/21-settings-audio-speech.md` |

## 08. Flashcard edit (`/library/deck/:deckId/flashcards/:flashcardId/edit`)

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Flashcard edit | Load existing card | `FlashcardEditorNotifier` edit mode | `flashcard_editor_screen.dart` | `docs/business/flashcard/flashcard-management.md` | `docs/wireframes/08-flashcard-edit.md` |
| Flashcard edit | Update card | `UpdateFlashcardUseCase` | flashcard use case | `docs/contracts/usecase-contracts/flashcard.md` | `docs/wireframes/08-flashcard-edit.md` |
| Flashcard edit | Reset SRS progress | `ResetFlashcardProgressUseCase` | flashcard use case, confirm dialog | `docs/business/srs/srs-review.md`, `docs/contracts/usecase-contracts/flashcard.md` | `docs/wireframes/08-flashcard-edit.md`, `docs/wireframes/24-shared-dialogs.md` |
| Flashcard edit | Bury / Suspend | `BuryFlashcardUseCase`, `SuspendFlashcardUseCase` ⏸ blocked on P0-2 | flashcard use case | `docs/business/study-actions/bury-suspend.md`, `docs/contracts/usecase-contracts/study.md` §Bury/Suspend | `docs/wireframes/08-flashcard-edit.md`, `docs/wireframes/25-shared-bottom-sheets.md` §card-actions |
| Flashcard edit | View history | navigate to history screen | `app_navigation.dart` | `docs/business/history/card-history.md` | `docs/wireframes/09-flashcard-history.md` |
| Flashcard edit | Delete card | `DeleteFlashcardUseCase` | flashcard use case, confirm dialog | `docs/contracts/usecase-contracts/flashcard.md` | `docs/wireframes/24-shared-dialogs.md` |

## 09. Flashcard history

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| History | Timeline of attempts + box transitions | `GetFlashcardHistoryUseCase` | `lib/domain/usecases/history_*`, history screen | `docs/business/history/card-history.md`, `docs/contracts/usecase-contracts/history.md` | `docs/wireframes/09-flashcard-history.md` |
| History | Empty state | dedicated section | history widget | `docs/business/history/card-history.md` | `docs/wireframes/09-flashcard-history.md` |
| History | Filter (mode / outcome) | local filter state | history widget | `docs/business/history/card-history.md` | `docs/wireframes/09-flashcard-history.md` |

## 10. Deck import

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Deck import | Step 1: configure source | `DeckImportNotifier` source step | `lib/presentation/features/flashcards/screens/deck_import_screen.dart` | `docs/business/flashcard/flashcard-management.md` (import section) | `docs/wireframes/10-deck-import.md` |
| Deck import | Step 2: preview parsed rows | parsing pipeline | `lib/data/repositories/flashcard_import_*` | `docs/business/flashcard/flashcard-management.md` (import section) | `docs/wireframes/10-deck-import.md` |
| Deck import | Step 3: commit + result | `ImportFlashcardsUseCase` | flashcard import use case | `docs/contracts/usecase-contracts/flashcard.md` | `docs/wireframes/10-deck-import.md` |
| Deck import | Error handling per row | typed `ImportFailure` | import repository | `docs/contracts/error-contract.md` | `docs/wireframes/10-deck-import.md` |

## 11. Library search

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Search | Initial (no query) state | search screen build | `lib/presentation/features/folders/screens/library_search_screen.dart` 🔴 (not yet present) | `docs/business/search/global-search.md` | `docs/wireframes/11-library-search.md` |
| Search | Query debounce + min length | local state + `ContentQuery` rules | search widget | `docs/business/search/global-search.md` | `docs/wireframes/11-library-search.md` |
| Search | Results render (folders/decks/cards) | `GlobalSearchUseCase` | `lib/domain/usecases/search_*` | `docs/business/search/global-search.md`, `docs/contracts/usecase-contracts/search.md` | `docs/wireframes/11-library-search.md` |
| Search | No-results state | dedicated section | search widget | `docs/business/search/global-search.md` | `docs/wireframes/11-library-search.md` |

## 12. Study entry gate (`/study/:entryType/:entryRefId`)

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Entry gate | Resolve resume vs start | `ResumeStudySessionUseCase.findCandidate` + `StartStudySessionUseCase` | `lib/presentation/features/study/screens/study_entry_screen.dart` | `docs/business/study/study-flow.md`, `docs/business/resume/resume-session.md`, `docs/contracts/usecase-contracts/study.md` | `docs/wireframes/12-study-entry-gate.md` |
| Entry gate | Empty state: deck_noCards 🟢 | `_rejectEmptyScope` + `EmptyScopeScreen` (deckNoCards arm) | `lib/domain/study/usecases/study_usecases.dart`, `lib/presentation/features/study/widgets/empty_scope_screen.dart` | `docs/business/study/study-flow.md` §Empty scope matrix, `docs/checklist/p0-1-empty-scope-matrix-plan-2026-05-29.md` | `docs/wireframes/12-study-entry-gate.md` §Variant — deck has zero cards |
| Entry gate | Empty state: deck_noDueCards 🔴 | `_rejectEmptyScope` next-due branch + `EmptyScopeScreen` arm | same as above | same as above | `docs/wireframes/12-study-entry-gate.md` §Variant — no due cards |
| Entry gate | Empty state: folder_noCards 🔴 | folder count repo method + new arm | study repo + use case + screen | same | `docs/wireframes/12-study-entry-gate.md` §Variant — deck has zero cards (folder analog) |
| Entry gate | Empty state: folder_noDueCards 🔴 | folder next-due + arm | same | same | `docs/wireframes/12-study-entry-gate.md` §Variant — no due cards |
| Entry gate | Empty state: today_allDone 🔴 | today-scope due lookup | same | same + `docs/business/engagement/dashboard-engagement.md` (streak) | `docs/wireframes/12-study-entry-gate.md` §Variant — today, all done |
| Entry gate | Empty state: today_noContent 🔴 | hasAnyFlashcard check | same | same | `docs/wireframes/12-study-entry-gate.md` §Variant — today, no content at all |
| Entry gate | Empty state: tag_noCards / tag_noDueCards ⏸ | blocked on adding `StudyEntryType.tag` | enum + strategy + repo | `docs/business/tags/tag-system.md`, `docs/business/study/study-flow.md` | `docs/wireframes/12-study-entry-gate.md` §Variant — tag scope |
| Entry gate | Empty state: allBuried / allSuspended ⏸ | blocked on P0-2 bury/suspend epic | study repo + use case + screen | `docs/business/study-actions/bury-suspend.md` | `docs/wireframes/12-study-entry-gate.md` §Variant — all buried/suspended |

## 13. Study session — Review mode

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Session/Review | Prompt + answer render | `ReviewModePanel`, `ReviewModeSessionView` | `lib/presentation/features/study/widgets/study_session/review/*` | `docs/business/study/study-flow.md` | `docs/wireframes/13-study-session-review.md` |
| Session/Review | Grade selection | `AnswerFlashcardUseCase` + `AttemptGrade` | study use case | `docs/business/srs/srs-review.md`, `docs/contracts/usecase-contracts/study.md` | `docs/wireframes/13-study-session-review.md` |
| Session/Review | Batch "all correct" | `AnswerCurrentModeBatchUseCase` | study use case | `docs/contracts/usecase-contracts/study.md` | `docs/wireframes/13-study-session-review.md` |
| Session/Review | TTS auto-play | `PlayTtsUseCase` driven by mode | `lib/domain/usecases/tts_*`, study widget | `docs/business/tts/tts-settings.md` | `docs/wireframes/13-study-session-review.md`, `docs/wireframes/21-settings-audio-speech.md` |

## 14. Study session — Match mode

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Session/Match | Pair board | `MatchModePanel`, `MatchBoard` | `lib/presentation/features/study/widgets/study_session/match/*` | `docs/business/study/study-flow.md` | `docs/wireframes/14-study-session-match.md` |
| Session/Match | Submit batch result | `AnswerCurrentMatchModeBatchUseCase` | study use case | `docs/contracts/usecase-contracts/study.md` | `docs/wireframes/14-study-session-match.md` |
| Session/Match | Animations / motion | `match_motion.dart` tokens | match widgets | `docs/ui-ux/ui-ux-contract.md` | `docs/wireframes/14-study-session-match.md` |

## 15. Study session — Guess mode

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Session/Guess | Option tile render | `GuessModePanel`, `GuessOptionTile` | `lib/presentation/features/study/widgets/study_session/guess/*` | `docs/business/study/study-flow.md` | `docs/wireframes/15-study-session-guess.md` |
| Session/Guess | Distractor selection logic | `studyGuessAnswerOptions` | `study_session_notifier.dart` | `docs/business/study/study-flow.md` | `docs/wireframes/15-study-session-guess.md` |
| Session/Guess | Per-item grade batch | `AnswerCurrentModeItemGradesBatchUseCase` | study use case | `docs/contracts/usecase-contracts/study.md` | `docs/wireframes/15-study-session-guess.md` |

## 16. Study session — Recall mode

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Session/Recall | Card flip + self-grade | `RecallModePanel`, `RecallModeSessionView` | `lib/presentation/features/study/widgets/study_session/recall/*` | `docs/business/study/study-flow.md` | `docs/wireframes/16-study-session-recall.md` |
| Session/Recall | Submit per-item grade | `AnswerCurrentModeItemGradesBatchUseCase` | study use case | `docs/contracts/usecase-contracts/study.md` | `docs/wireframes/16-study-session-recall.md` |

## 17. Study session — Fill mode

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Session/Fill | Input + answer check | `FillModePanel`, `FillModeSessionView` | `lib/presentation/features/study/widgets/study_session/fill/*` | `docs/business/study/study-flow.md` | `docs/wireframes/17-study-session-fill.md` |
| Session/Fill | Validation (empty input) | `studyEmptyAnswerMessage` | fill widget | `docs/business/study/study-flow.md` | `docs/wireframes/17-study-session-fill.md` |
| Session/Fill | Submit grade | `AnswerFlashcardUseCase` | study use case | `docs/contracts/usecase-contracts/study.md` | `docs/wireframes/17-study-session-fill.md` |
| Session (shared) | Cancel mid-session | `CancelStudySessionUseCase` + cancel dialog | study use case, `study_session_screen.dart` | `docs/business/study/study-flow.md` | `docs/wireframes/24-shared-dialogs.md` §cancel-session |
| Session (shared) | Skip current item | `SkipFlashcardUseCase` | study use case | `docs/contracts/usecase-contracts/study.md` | n/a (in-session control) |
| Session (shared) | Finalize → result | `FinalizeStudySessionUseCase`, `RetryFinalizeUseCase` | study use cases, `study_session_screen.dart` | `docs/contracts/usecase-contracts/study.md` | `docs/wireframes/18-study-result.md` |

## 18. Study result

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Result | Summary metrics | `StudySummary` derivation | `lib/presentation/features/study/screens/study_result_screen.dart` | `docs/business/study/study-flow.md`, `docs/contracts/usecase-contracts/study.md` | `docs/wireframes/18-study-result.md` |
| Result | Retry / restart | `RestartStudySessionUseCase` | study use case | `docs/contracts/usecase-contracts/study.md` | `docs/wireframes/18-study-result.md` |
| Result | Return to entry / dashboard | `AppNavigation` push/pop | result screen | `docs/business/navigation/navigation-flow.md` | `docs/wireframes/18-study-result.md` |

## 19. Settings — Account

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Settings/Account | Sign in / out (Google) | `SignInUseCase`, `SignOutUseCase` | `lib/domain/usecases/account_*`, `lib/presentation/features/settings/screens/account_settings_screen.dart` | `docs/business/account-sync/account-sync.md`, `docs/contracts/usecase-contracts/account-sync.md` | `docs/wireframes/19-settings-account.md` |
| Settings/Account | Drive sync toggle + push/pull | `EnableSyncUseCase`, `PushSyncUseCase`, `PullSyncUseCase` | `lib/data/sync/**`, `lib/domain/usecases/sync_*` | `docs/business/account-sync/account-sync.md`, `docs/contracts/repository-contracts/sync-repository.md` | `docs/wireframes/19-settings-account.md` |
| Settings/Account | Remove account (strong confirm) | `RemoveAccountUseCase` | account use case + strong dialog | `docs/business/account-sync/account-sync.md`, `docs/contracts/usecase-contracts/account-sync.md` | `docs/wireframes/19-settings-account.md`, `docs/wireframes/24-shared-dialogs.md` §strong-confirm |

## 20. Settings — Learning

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Settings/Learning | New-study defaults editor | `StudySettingsStore.saveNewStudyDefaults` | `lib/presentation/features/settings/screens/learning_settings_screen.dart` | `docs/state/state-management-contract.md` §Per-notifier, `docs/business/study/study-flow.md` | `docs/wireframes/20-settings-learning.md` |
| Settings/Learning | SRS-review defaults editor | `StudySettingsStore.saveReviewDefaults` | same | same | `docs/wireframes/20-settings-learning.md` |
| Settings/Learning | Interval table view (read-only) | `box_intervals.dart` source | `lib/domain/srs/box_intervals.dart` | `docs/business/srs/srs-review.md` | `docs/wireframes/20-settings-learning.md` |
| Settings/Learning | Tags sub-screen entry | navigate to tags | `app_navigation.dart` | `docs/business/tags/tag-system.md` | `docs/wireframes/22-settings-tag-management.md` |

## 21. Settings — Audio / Speech

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Settings/TTS | Voice picker | `TtsSettingsNotifier`, `SelectVoiceUseCase` | `lib/presentation/features/settings/screens/audio_speech_settings_screen.dart` | `docs/business/tts/tts-settings.md`, `docs/contracts/usecase-contracts/tts.md` | `docs/wireframes/21-settings-audio-speech.md` |
| Settings/TTS | Rate / pitch sliders | settings notifier | same | same | `docs/wireframes/21-settings-audio-speech.md` |
| Settings/TTS | Auto-play toggle per mode | settings notifier | same | same | `docs/wireframes/21-settings-audio-speech.md` |
| Settings/TTS | Preview sample | `PreviewTtsUseCase` | TTS use case | `docs/contracts/usecase-contracts/tts.md` | `docs/wireframes/21-settings-audio-speech.md` |

## 22. Settings — Tag management

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Settings/Tags | List tags + usage count | `ListTagsUseCase` | `lib/presentation/features/settings/screens/tag_management_screen.dart` | `docs/business/tags/tag-system.md`, `docs/contracts/usecase-contracts/tag.md` | `docs/wireframes/22-settings-tag-management.md` |
| Settings/Tags | Rename tag | `RenameTagUseCase` | tag use case, dialog | same | `docs/wireframes/22-settings-tag-management.md`, `docs/wireframes/24-shared-dialogs.md` |
| Settings/Tags | Merge tags | `MergeTagsUseCase` | tag use case | same | `docs/wireframes/22-settings-tag-management.md` |
| Settings/Tags | Delete tag | `DeleteTagUseCase` | tag use case, confirm dialog | same | `docs/wireframes/22-settings-tag-management.md`, `docs/wireframes/24-shared-dialogs.md` |

## 23. Onboarding

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Onboarding | Welcome step (dismissible) | `OnboardingNotifier` | onboarding screen 🔴 (TBD) | `docs/business/system/overview.md` | `docs/wireframes/23-onboarding.md` |
| Onboarding | Inline "Create deck for import" | reuses create-deck dialog + import flow | onboarding widget | `docs/business/flashcard/flashcard-management.md` | `docs/wireframes/23-onboarding.md` |
| Onboarding | Restore prompt (Drive backup) | `RestoreFromDriveUseCase` | sync use case | `docs/business/account-sync/account-sync.md` | `docs/wireframes/19-settings-account.md`, `docs/wireframes/23-onboarding.md` |

## 24. Shared dialogs

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Shared | Confirm dialog (standard) | `MxConfirmDialog` | `lib/presentation/shared/widgets/dialogs/mx_confirm_dialog.dart` | `docs/ui-ux/ui-ux-contract.md` | `docs/wireframes/24-shared-dialogs.md` |
| Shared | Strong confirm (typed input) | `MxStrongConfirmDialog` | dialog widget | same | `docs/wireframes/24-shared-dialogs.md` §Strong variant |
| Shared | Input dialog (single-field) | `MxInputDialog` | dialog widget | same | `docs/wireframes/24-shared-dialogs.md` |
| Shared | Cancel-session dialog | composes `MxConfirmDialog` | session screen | `docs/business/study/study-flow.md` | `docs/wireframes/24-shared-dialogs.md` §cancel-session |
| Shared | Discard paused session | composes `MxConfirmDialog` | dashboard/progress widgets | `docs/business/resume/resume-session.md` | `docs/wireframes/24-shared-dialogs.md` §discard-session |

## 25. Shared bottom sheets

| Screen | Function | Function detail | Files to modify | Doc refs | Wireframe |
| --- | --- | --- | --- | --- | --- |
| Shared | Scope picker | `ScopePickerSheet` | `lib/presentation/shared/widgets/sheets/scope_picker_sheet.dart` | `docs/business/study/study-flow.md` | `docs/wireframes/25-shared-bottom-sheets.md` §scope-picker |
| Shared | Move folder/deck picker | `MovePickerSheet` | sheet widget | `docs/business/bulk/bulk-operations.md` | `docs/wireframes/25-shared-bottom-sheets.md` §move-picker |
| Shared | Daily-goal slider | `DailyGoalSheet` | sheet widget, engagement use case | `docs/business/engagement/dashboard-engagement.md` | `docs/wireframes/25-shared-bottom-sheets.md` §daily-goal |
| Shared | Streak history | `StreakHistorySheet` | sheet widget, engagement use case | `docs/business/engagement/dashboard-engagement.md` | `docs/wireframes/25-shared-bottom-sheets.md` §streak-history |
| Shared | Paused sessions list | `PausedSessionsSheet` | sheet widget | `docs/business/resume/resume-session.md` | `docs/wireframes/25-shared-bottom-sheets.md` §paused-sessions |
| Shared | Card actions (bury/suspend/edit) ⏸ | blocked on P0-2 | sheet widget | `docs/business/study-actions/bury-suspend.md` | `docs/wireframes/25-shared-bottom-sheets.md` §card-actions |
| Shared | Sort options | `SortOptionsSheet` | sheet widget | `docs/contracts/types-catalog.md` (`ContentSortMode`) | `docs/wireframes/25-shared-bottom-sheets.md` §sort |

## Maintenance rules

1. **Adding a screen**: append a new H2 section using the same column order. Update `docs/business/navigation/navigation-flow.md` first; this matrix mirrors that doc.
2. **Adding a function row**: confirm the row maps to exactly one feature; if it spans many, split it.
3. **Status emoji change**: do it in the same PR that lands the behavior change. Stale status here will mislead future agents.
4. **Removing a row**: only when the feature is removed from the spec. Otherwise change the status to 🔴 with a note in "Function detail" column.
5. **Doc-code parity**: this file is a navigator, not a source of truth. If a doc cell disagrees with reality, update the underlying doc first, then mirror here.
