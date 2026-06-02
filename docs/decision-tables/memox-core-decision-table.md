---
last_updated: 2026-05-26
applies_to: behavior branches across folder, deck, flashcard, study, SRS, navigation, UI
---

# MemoX Core Decision Table

This file captures high-value behavior branches.

Agents may split into feature-specific decision tables when a feature grows beyond ~50 rows.

## Convention

- `ID` is stable. Tests reference it.
- `Coverage`: C0 = happy path, C1 = branch coverage.
- `Test` points to the test that asserts the row. Empty means "not yet covered, add when implementing".

## Folder

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| F1 | Create root | Valid name | Create unlocked root folder | C0+C1 | `test/features/folders/create_folder_test.dart::F1` |
| F2 | Create root | Empty name | Reject | C1 | `test/features/folders/create_folder_test.dart::F2` |
| F3 | Create subfolder | Parent unlocked/subfolders | Create child, parent becomes/stays subfolders | C0+C1 | `test/features/folders/create_folder_test.dart::F3` |
| F4 | Create subfolder | Parent decks | Reject with typed `folder_contains_decks`; Folder Detail stale path shows localized snackbar and creates no subfolder | C1 | `test/domain/usecases/folder_usecases_test.dart::F4`, `test/data/repositories/content_repository_test.dart::DT5`, `test/presentation/folder_detail_screen_test.dart::F4` |
| F5 | Create deck | Parent unlocked/decks | Create deck, parent becomes/stays decks | C0+C1 | `test/data/repositories/content_repository_test.dart::DT2`, `test/presentation/folder_detail_screen_test.dart::F5` |
| F6 | Create deck | Parent subfolders | Reject with typed `folder_contains_subfolders`; Folder Detail stale path shows localized snackbar and creates no deck | C1 | `test/domain/usecases/folder_usecases_test.dart::F6`, `test/data/repositories/content_repository_test.dart::DT4`, `test/presentation/folder_detail_screen_test.dart::F6` |
| F7 | Move folder | Target self/descendant | Reject | C1 | `test/features/folders/move_folder_test.dart::F7` |
| F8 | Delete folder | Confirmed | Delete nested content safely | C0+C1 | `test/features/folders/delete_folder_test.dart::F8` |
| F9 | Delete last child | Folder becomes unlocked | Mode returns to unlocked | C1 | `test/features/folders/delete_folder_test.dart::F9` |

## Deck

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| D1 | Create deck | Valid folder/name | Persist deck | C0+C1 | `test/features/decks/create_deck_test.dart::D1` |
| D2 | Create deck | Empty name | Reject | C1 | `test/features/decks/create_deck_test.dart::D2` |
| D3 | Delete deck | Confirmed | Delete deck and dependent data | C0+C1 | `test/features/decks/delete_deck_test.dart::D3` |
| D4 | Reorder | Manual sort active | Update sort order only | C0+C1 | `test/features/decks/reorder_deck_test.dart::D4` |
| D5 | Start study | Empty deck | Do not create session | C1 | `test/features/study/start_session_test.dart::D5` |

## Flashcard

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| C1 | Create card | Valid front/back | Persist card through shared Flashcard Editor create mode | C0+C1 | `test/data/repositories/content_repository_test.dart::DT6 onInsert`, `test/presentation/flashcard_editor_screen_test.dart::DT1 onOpen` |
| C2 | Create card | Empty front | Reject / keep Save disabled | C1 | `test/presentation/flashcard_editor_screen_test.dart::DT2 onInsert` |
| C3 | Create card | Empty back | Reject / keep Save disabled | C1 | `test/presentation/flashcard_editor_screen_test.dart::DT3 onInsert` |
| C4 | Edit card | Existing card opens through shared editor | Load existing content and update same card | C0+C1 | `test/presentation/flashcard_editor_screen_test.dart::DT1 onOpen`, `test/data/repositories/content_repository_test.dart::DT1 onUpdate` |
| C5 | Edit card | Learned front/back changed on a progressed card | Ask explicit Keep / Reset progress policy before save | C1 | `test/presentation/flashcard_editor_screen_test.dart::DT1 onUpdate`, `test/presentation/flashcard_editor_screen_test.dart::DT2 onUpdate` |
| C6 | Delete card | Confirmed from flashcard list row/bulk action | Delete card and dependent data | C0+C1 | `test/data/repositories/content_repository_test.dart::DT4 onDelete`, `test/presentation/flashcard_list_screen_test.dart::DT1 onDelete` |
| C7 | Import | Mixed rows | Save valid, report invalid | C1 | `test/features/flashcards/import_flashcards_test.dart::C7` |
| C8 | Create card | Whitespace-only front | Reject (trim then validate) | C1 | `test/features/flashcards/create_flashcard_test.dart::C8` |
| C9 | Create editor close | Blank draft | Leave without discard dialog | C1 | `test/presentation/flashcard_editor_screen_test.dart::C9 onNavigate` |
| C10 | Create editor close | Front typed but unsaved | Show discard dialog | C1 | `test/presentation/flashcard_editor_screen_test.dart::C10 onNavigate` |
| C11 | Create editor discard | User cancels discard | Stay on editor and keep typed input | C1 | `test/presentation/flashcard_editor_screen_test.dart::C11 onNavigate` |
| C12 | Create editor discard | User confirms discard | Leave editor for deck flashcard list | C1 | `test/presentation/flashcard_editor_screen_test.dart::C12 onNavigate` |
| C13 | Edit editor close | Loaded draft unchanged | Leave without discard dialog | C1 | `test/presentation/flashcard_editor_screen_test.dart::C13 onNavigate` |
| C14 | Edit editor close | Front changed | Show discard dialog | C1 | `test/presentation/flashcard_editor_screen_test.dart::C14 onNavigate` |
| C15 | Edit editor close | Optional note changed | Show discard dialog | C1 | `test/presentation/flashcard_editor_screen_test.dart::C15 onNavigate` |
| C16 | Edit editor close | Tag list changed | Show discard dialog | C1 | `test/presentation/flashcard_editor_screen_test.dart::C16 onNavigate` |
| C17 | Edit editor close | Existing optional note/tags loaded but unchanged | Leave without discard dialog | C1 | `test/presentation/flashcard_editor_screen_test.dart::C17 onNavigate` |
| C18 | Create card save | Destination deck changed before normal Save | Create in selected deck and open selected deck's flashcard list | C0+C1 | `test/presentation/flashcard_editor_screen_test.dart::C18 onInsert` |
| C19 | Create card save-and-add | Destination deck changed before Save and add another | Stay in editor with clean blank draft and selected deck retained | C0+C1 | `test/presentation/flashcard_editor_screen_test.dart::C19 onInsert` |

## Study/SRS

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| S1 | Create session | Deck with cards | Persist session/items | C0+C1 | `test/features/study/create_session_test.dart::S1` |
| S2 | Create session | Folder with recursive cards | Persist session/items | C0+C1 | `test/features/study/create_session_test.dart::S2` |
| S3 | Create session | Today with due cards | Persist SRS session | C0+C1 | `test/features/study/create_session_test.dart::S3` |
| S4 | Create session | Deck with zero cards | `EmptyScopeException(deckNoCards)` → render `EmptyScopeScreen` (`studyEmpty_deck_noCards_title`) with "Add flashcards" CTA pushing `flashcardCreate`; no session persisted | C1 | `test/features/study/empty_scope_test.dart::S4` + `test/presentation/study_entry_screen_test.dart::S4 onTap` |
| S4b | Create session | Folder subtree with zero descendant cards | `EmptyScopeException(folderNoCards)` → `studyEmpty_folder_noCards_title` with "Add a deck" CTA returning to folder detail; no session | C1 | `test/features/study/empty_scope_test.dart::S4b` + `test/presentation/empty_scope_screen_test.dart` (folderNoCards) |
| S4c | Create session | Today (srs_review) has cards but zero due | `EmptyScopeException(todayAllDone)` → `studyEmpty_today_allDone_title` + motivational message with "Back to dashboard" CTA; no session | C1 | `test/features/study/empty_scope_test.dart::S4c` + `test/presentation/empty_scope_screen_test.dart` (todayAllDone) |
| S4d | Create session | Today (srs_review) with zero cards in DB | `EmptyScopeException(todayNoContent)` → `studyEmpty_today_noContent_title` with "Create your first deck" CTA opening library | C1 | `test/features/study/empty_scope_test.dart::S4d` + `test/presentation/empty_scope_screen_test.dart` (todayNoContent) |
| S4e | Create session | Deck (srs_review) has cards but none due | `EmptyScopeException(deckNoDueCards, nextDueAt)` → `studyEmpty_deck_noDueCards_title` (+ "Next due in {relativeTime}" when a future due exists) with "Study new instead" CTA re-entering New Study | C1 | `test/features/study/empty_scope_test.dart::S4e` + `test/data/repositories/study_repo_next_due_test.dart` (nextDueAt) |
| S4j | Create session | Folder (srs_review) subtree has cards but none due | `EmptyScopeException(folderNoDueCards, nextDueAt)` → `studyEmpty_folder_noDueCards_title` (+ next-due hint) with "Study new instead" CTA re-entering New Study | C1 | `test/features/study/empty_scope_test.dart::S4j` + `test/presentation/empty_scope_screen_test.dart` (folderNoDueCards) |
| S4f | Create session | All cards buried for today | Empty state `studyEmpty_allBuried` | C1 | `test/features/study/empty_scope_test.dart::S4f` |
| S4g | Create session | All cards suspended | Empty state `studyEmpty_allSuspended` | C1 | `test/features/study/empty_scope_test.dart::S4g` |
| S4h | Create session | `entry_type=tag` with zero matching cards | Empty state `studyEmpty_tag_noCards`, no session | C1 | `test/features/study/empty_scope_test.dart::S4h` |
| S4i | Create session | `entry_type=tag` matches cards but none due (srs_review) | Empty state `studyEmpty_tag_noDueCards` with "Study new instead" CTA | C1 | `test/features/study/empty_scope_test.dart::S4i` |
| S5 | Validate flow | Invalid type/flow pair | Reject | C1 | `test/domain/study/flow_validator_test.dart::S5` |
| S6 | Answer | Correct | Persist attempt and advance | C0+C1 | `test/features/study/answer_test.dart::S6` |
| S7 | Answer | Incorrect | Persist attempt and retry when required | C0+C1 | `test/features/study/answer_test.dart::S7` |
| S8 | Exit | In progress | Confirm and persist resumable state | C0+C1 | `test/features/study/exit_session_test.dart::S8` |
| S9 | Finalize | Success | Update progress and complete | C0+C1 | `test/features/study/finalize_session_test.dart::S9` |
| S10 | Finalize | Failure | Preserve data and mark recoverable failure | C1 | `test/features/study/finalize_session_test.dart::S10` |
| S11 | Box transition | result=perfect, box<8 | Next box = current+1 | C0+C1 | `test/domain/srs/box_transition_test.dart::S11` |
| S12 | Box transition | result=forgot | Next box = 1 | C0+C1 | `test/domain/srs/box_transition_test.dart::S12` |
| S13 | Box transition | result=recovered | Next box = current (stay) | C0+C1 | `test/domain/srs/box_transition_test.dart::S13` |
| S14 | Box transition | result=perfect, box=8 | Next box = 8 (stay) | C1 | `test/domain/srs/box_transition_test.dart::S14` |
| S15 | Lapse counter | result=forgot | Increment lapse_count | C1 | `test/domain/srs/progress_update_test.dart::S15` |
| S16 | Due query | Filter due_at <= now AND not suspended/buried | Return only due active cards | C0+C1 | `test/data/repositories/progress_repository_test.dart::S16` |
| S17 | Interval table | Box 1..5 | Linear 1..5 day intervals | C0 | `test/domain/srs/box_intervals_test.dart::S17` |
| S18 | Interval table | Box 6, 7, 8 | 12, 30, 60 days | C0 | `test/domain/srs/box_intervals_test.dart::S18` |
| S19 | Attempt grade codec | result=`recovered` | Codec accepts `recovered`; grade is passing but not perfect-eligible | C0+C1 | `test/domain/study/attempt_grade_codec_test.dart::DT15` |
| S20 | SRS Review finalize | All persisted attempts pass, at least one `recovered` | `ReviewResult.recovered`, current box unchanged, no lapse, no retry | C0+C1 | `test/data/repositories/study_repository_test.dart::DT15` |
| S21 | Schema migration | Existing DB reports `user_version=12` but `study_attempts.result` CHECK still allows only `correct`/`incorrect` | Schema v13 rebuilds `study_attempts`; inserting `recovered` succeeds | C1 | `test/data/datasources/local/app_database_migration_test.dart::DT6` |
| S22 | Start study | Start use case or Study Entry provider throws an unexpected error | Preserve the original error as the rejected result when available, set action `AsyncError`, log the error with stack trace, and expose local-only details while production keeps the generic message | C1 | `test/presentation/study_entry_notifier_test.dart::DT3` + `test/presentation/study_entry_screen_test.dart::DT7` + `test/presentation/study_entry_screen_test.dart::S22` |
| S23 | Start study | Flashcards exist in scope but some `flashcard_progress` rows are missing | Treat missing-progress cards as new active cards for New Study and create a session instead of failing Study Entry with an empty eligible batch | C1 | `test/data/repositories/study_repository_test.dart::S23` |
| S24 | Start study | Study Entry action controller is disposed after the repository creates a session but before provider state is updated | Return the created session id to the caller and skip provider invalidation/state writes instead of converting the successful start into `Study session was not started.` | C1 | `test/presentation/study_entry_notifier_test.dart::S24` |
| S25 | Start study | Start use case throws an unexpected error after the action begins | Resolve `StudyEntryStartResult.rejected` with the original error and a non-empty stack trace; never return null | C1 | `test/presentation/study_entry_notifier_test.dart::S25` |
| S26 | Start study | Repository/session creation throws the real root error during direct Study Entry navigation | Log and show the original root error details, and do not create or display `Study session was not started.` | C1 | `test/presentation/study_entry_screen_test.dart::S26` |

## Bury / Suspend

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| BS1 | Bury card | During study session | Set `buried_until` to tomorrow midnight local; skip in session | C0+C1 | `test/data/repositories/study_repo_next_due_test.dart::BS1` (persistence + midnight) + `test/presentation/card_actions_sheet_test.dart` (action) |
| BS2 | Bury card | Action | Do NOT record attempt; SRS state unchanged | C1 | `test/data/repositories/study_repo_next_due_test.dart::BS1` (currentBox/dueAt unchanged) |
| BS3 | Auto-unbury | `buried_until <= now` | Card returns to due queue | C0+C1 | `test/data/repositories/study_repo_next_due_test.dart` (expired bury is eligible again) |
| BS4 | Suspend card | Any time | Set `is_suspended=true`; hide from study queues | C0+C1 | `test/data/repositories/study_repo_next_due_test.dart::BS2` + (excluded from due/new batch) |
| BS5 | Suspend card | Action | Preserve SRS state | C1 | `test/data/repositories/study_repo_next_due_test.dart::BS2` (currentBox/dueAt unchanged) |
| BS6 | Unsuspend | Past `due_at` | Card immediately due | C0+C1 | `test/features/flashcards/suspend_test.dart::BS6` |
| BS7 | Toast undo | Within 5s | Revert state | C1 | `test/features/flashcards/suspend_test.dart::BS7` |
| BS8 | Filter | "Suspended" | Show only suspended cards | C0+C1 | `test/features/flashcards/filter_test.dart::BS8` |
| BS9 | Filter | "Active" | Hide suspended and buried | C0+C1 | `test/features/flashcards/filter_test.dart::BS9` |

## Resume session

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| R1 | Dashboard load | One in_progress session exists | Show "Continue studying" card | C0+C1 | `test/features/dashboard/resume_card_test.dart::R1` |
| R2 | Dashboard load | Multiple in_progress sessions | Show most recent + "{n-1} more" link | C1 | `test/features/dashboard/resume_card_test.dart::R2` |
| R3 | Dashboard load | No in_progress sessions | Hide resume card | C0 | `test/features/dashboard/resume_card_test.dart::R3` |
| R4 | Open deck/folder | Has resumable session for scope | Show banner | C0+C1 | `test/features/decks/resume_banner_test.dart::R4` |
| R5 | Start study | Scope has resumable session, regardless of study flow | Show "Resume or Start over" dialog; do not silently create a second active session | C0+C1 | `test/presentation/study_entry_screen_test.dart::DT3/DT5` |
| R6 | Start over | Confirmed twice | Start requested flow with `restartedFromSessionId`; repository `startSession` atomically cancels previous and creates new session | C1 | `test/presentation/study_entry_screen_test.dart::DT3/DT5` + `test/domain/study/restart_study_session_usecase_test.dart::R6` |
| R7 | Resume | Tap continue | Open session at correct item; bump updated_at | C0+C1 | `test/features/study/resume_test.dart::R7` |
| R8 | Auto-expiry | Session updated_at > 30 days old | Auto-cancel on app open with notice | C1 | `test/features/study/resume_expiry_test.dart::R8` |
| R9 | Resume race | Entity (deck) deleted | Cancel session, show notice | C1 | `test/features/study/resume_expiry_test.dart::R9` |
| R10 | Restart session | Previous session belongs to a different entry scope | Reject before loading a new batch; do not cancel or create | C1 | `test/domain/study/restart_study_session_usecase_test.dart::R10` |
| R11 | Restart session | Previous session is not restartable | Reject before loading a new batch; do not cancel or create | C1 | `test/domain/study/restart_study_session_usecase_test.dart::R11` |
| R12 | Restart session | Eligible batch is empty | Reject; do not cancel previous session or create a new session | C1 | `test/domain/study/restart_study_session_usecase_test.dart::R12` |
| R13 | Resume candidate lookup | Most recent active scope candidate references missing flashcard data | Log candidate snapshot failure, ignore the corrupt candidate, and allow start-new to create a valid session | C1 | `test/data/repositories/study_repository_test.dart::DT4 onUpdate` |
| R14 | Explicit resume/load | Caller opens the corrupt session by id | Surface the load failure; do not hide corruption outside candidate discovery | C1 | `test/data/repositories/study_repository_test.dart::DT5 onUpdate` |

## Progress Overview

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| P1 | Open progress route | Direct `/progress` route | Render `ProgressScreen` inside the shell; do not open Study Session, History, Search, Settings, or sync surfaces | C0+C1 | `test/app/router/app_router_test.dart::DT7 onNavigate` |
| P2 | Load overview | Provider pending on initial open | Show shared loading state; do not show stale or fake summary content | C0 | `test/presentation/progress_screen_test.dart::DT6 onDisplay` |
| P3 | Load overview | Provider fails before data exists | Show shared retryable error state; do not show raw exception/stack text | C1 | `test/presentation/progress_screen_test.dart::DT7 onDisplay` |
| P4 | Display overview | No active sessions | Show learning summary metrics plus active-session empty state with Library CTA; do not invent analytics history | C0+C1 | `test/presentation/progress_screen_test.dart::DT1 onDisplay` |
| P5 | Display overview | Active/ready/failed sessions exist | Show session recovery overview, status labels, Continue/Finalize/Retry/Cancel actions | C0+C1 | `test/presentation/progress_screen_test.dart::DT2 onDisplay`, `test/presentation/progress_session_notifier_test.dart::DT2 onDisplay` |
| P6 | Display overview | New-study session spans multiple modes | Compute per-session progress from total study steps, not only card count | C1 | `test/presentation/progress_screen_test.dart::DT4 onDisplay` |
| P7 | Cancel session | User taps Cancel on Progress card | Require confirmation before mutating; successful cancel refreshes study-session data | C1 | `test/presentation/progress_screen_test.dart::DT1 onSelect`, `test/presentation/progress_session_notifier_test.dart::DT1 onUpdate` |

## Tags

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| TG1 | Tag input | Leading `#` typed | Strip before store | C1 | `test/features/flashcards/tag_input_test.dart::TG1` |
| TG2 | Tag dedup | Same tag different case | Keep one (case-insensitive) | C0+C1 | `test/features/flashcards/tag_input_test.dart::TG2` |
| TG3 | Tag filter | Multi-select chips | Apply AND filter | C0+C1 | `test/features/flashcards/tag_filter_test.dart::TG3` |
| TG4 | Study by tag | `entry_type=tag` | Resolve cards across decks | C0+C1 | `test/features/study/study_by_tag_test.dart::TG4` |
| TG5 | Tag rename | Collides with existing tag | Prompt to merge | C1 | `test/features/tags/tag_management_test.dart::TG5` |
| TG6 | Tag merge | Source has cards target also has | Dedup tag rows on merge | C1 | `test/features/tags/tag_management_test.dart::TG6` |
| TG7 | Tag delete | Confirmation | Remove from all cards in transaction | C0+C1 | `test/features/tags/tag_management_test.dart::TG7` |
| TG8 | Bulk add tag | 1000 cards | Single transaction, dedup per card | C1 | `test/features/flashcards/bulk_tag_test.dart::TG8` |
| TG9 | Tag input | Contains comma `,` | Reject with inline error; do not strip silently | C0+C1 | `test/features/flashcards/tag_input_test.dart::TG9` |
| TG10 | Tag input | Exceeds 50 chars after trim | Reject with inline error | C1 | `test/features/flashcards/tag_input_test.dart::TG10` |
| TG11 | Study-by-tag entry_ref_id | Constructed from selected tags | Lowercased, comma-joined, sorted alphabetically | C0+C1 | `test/features/study/study_by_tag_test.dart::TG11` |

## Bulk operations

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| BK1 | Long-press card | Normal mode | Enter selection mode | C0 | `test/features/flashcards/bulk_select_test.dart::BK1` |
| BK2 | Bulk delete | Confirm | Atomic delete in one transaction | C0+C1 | `test/features/flashcards/bulk_delete_test.dart::BK2` |
| BK3 | Bulk move | Target deck valid | Cards moved; SRS + tags preserved | C0+C1 | `test/features/flashcards/bulk_move_test.dart::BK3` |
| BK4 | Bulk move | Target folder mode = subfolders | Reject | C1 | `test/features/flashcards/bulk_move_test.dart::BK4` |
| BK5 | Bulk suspend | Toast appears | Undo within 5s reverts | C1 | `test/features/flashcards/bulk_suspend_test.dart::BK5` |
| BK6 | Bulk reset progress | Confirm | Reset progress but retain attempts | C0+C1 | `test/features/flashcards/bulk_reset_test.dart::BK6` |
| BK7 | Filter then select-all | Filter = "Suspended" | Selects only filtered cards (snapshot IDs) | C1 | `test/features/flashcards/bulk_select_test.dart::BK7` |
| BK8 | Bulk with >999 rows | SQLite param limit | Chunk IN clauses, still atomic | C1 | `test/features/flashcards/bulk_chunk_test.dart::BK8` |

## Search

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| SR1 | Query < 2 chars | Below min | Show hint, no query fired | C1 | `test/features/search/global_search_test.dart::SR1` |
| SR2 | Query | Multi-token | AND across tokens | C0+C1 | `test/features/search/global_search_test.dart::SR2` |
| SR3 | Query | Case + diacritic insensitive | Match both | C1 | `test/features/search/global_search_test.dart::SR3` |
| SR4 | Query with `%` or `_` | Special chars | Escape before LIKE | C1 | `test/features/search/global_search_test.dart::SR4` |
| SR5 | Result tap | Folder | Navigate to folder detail | C0 | `test/features/search/global_search_test.dart::SR5` |
| SR6 | Result tap | Flashcard | Navigate to deck list, scroll to card | C0 | `test/features/search/global_search_test.dart::SR6` |
| SR7 | Result tap | Tag | Open filtered flashcard list globally | C0 | `test/features/search/global_search_test.dart::SR7` |
| SR8 | Recent searches | Empty query | Show last 5 recent | C1 | `test/features/search/recent_searches_test.dart::SR8` |
| SR9 | Folder-detail search | Inside folder Korean | Recursive: returns matches in Korean/Grammar too | C0+C1 | `test/features/search/folder_search_test.dart::SR9` |
| SR10 | Result row | Any | Breadcrumb path shown so user understands location | C1 | `test/features/search/global_search_test.dart::SR10` |

## Card history

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| H1 | Open history | Card with attempts | Show timeline newest-first | C0+C1 | `test/features/history/card_history_test.dart::H1` |
| H2 | Open history | Card with zero attempts | Show empty state with "Start study" CTA | C1 | `test/features/history/card_history_test.dart::H2` |
| H3 | Reset progress | From future history screen | Reset SRS, set `last_reset_at=now`, retain attempts | Future | Future Proposal; do not implement in V1 |
| H4 | Lifetime stats | Accuracy calculation | (reviewCount - lapseCount) / reviewCount | C0 | `test/domain/services/lifetime_stats_test.dart::H4` |
| H5 | Timeline | Card with `last_reset_at` set | Show divider row at the correct timestamp position | C0+C1 | `test/features/history/card_history_test.dart::H5` |
| H6 | Timeline | `box_before=0` (pre-migration row) | Render "—" for box transition, not "Box 0" | C1 | `test/features/history/card_history_test.dart::H6` |
| H7 | Header sub-label | `last_reset_at != null` | Show "Includes attempts before last reset on {date}." | C1 | `test/features/history/card_history_test.dart::H7` |
| H8 | New attempt insert | Any | `box_before` and `box_after` MUST be populated | C0+C1 | `test/data/repositories/attempt_repository_test.dart::H8` |

## Daily engagement

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| EN1 | Daily progress | Attempt recorded today | Increment progress, computed from `study_attempts` aggregate | C0+C1 | `test/features/engagement/daily_progress_test.dart::EN1` |
| EN2 | Daily progress | Goal disabled | Hide progress on Dashboard | C1 | `test/features/engagement/daily_progress_test.dart::EN2` |
| EN3 | Streak | Goal met today, yesterday was goal-met | `currentStreak++` | C0+C1 | `test/features/engagement/streak_test.dart::EN3` |
| EN4 | Streak | Yesterday was NOT goal-met | Streak broken, reset to 0 + show notice once | C0+C1 | `test/features/engagement/streak_test.dart::EN4` |
| EN5 | Streak | Goal changed mid-day from 20 to 10, progress=12 | Already met; streak advances if not yet | C1 | `test/features/engagement/streak_test.dart::EN5` |
| EN6 | Reminder fires | Goal met today | Suppress notification | C1 | `test/features/engagement/reminder_test.dart::EN6` |
| EN7 | Reminder fires | Has resumable session | Body promotes resume + deep link to session | C0+C1 | `test/features/engagement/reminder_test.dart::EN7` |
| EN8 | Reminder | Permission denied | Toggle shows inline help; no fire | C1 | `test/features/engagement/reminder_test.dart::EN8` |
| EN9 | Landing screen | App launch | Dashboard, not Library | C0 | `test/features/app_shell/landing_test.dart::EN9` |
| EN10 | Onboarding | Zero content | Show onboarding state on Dashboard | C0+C1 | `test/features/dashboard/onboarding_test.dart::EN10` |
| EN11 | Day boundary | Local timezone midnight | Day rollover at local midnight | C1 | `test/features/engagement/day_boundary_test.dart::EN11` |
| EN12 | Dashboard V1 placeholder | Static streak stat is rendered before full engagement is implemented | Show simple `0 days` stat only; expose no daily-goal, reminder, streak-history, or global-search action | C1 | `test/presentation/dashboard_screen_test.dart::DT8 onDisplay` |

## Navigation/UI

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| N1 | Open route | Valid params | Show screen | C0+C1 | `test/app/router/router_test.dart::N1` |
| N2 | Open route | Missing/deleted entity | Show shared error state | C1 | `test/app/router/router_test.dart::N2` |
| N3 | Navigate | From widget | Use route constants | C0 | `test/app/router/router_test.dart::N3` |
| N4 | Push vs Go | Form → list | Use push, return on pop | C1 | `test/features/flashcards/navigation_test.dart::N4` |
| N5 | Push vs Go | Session → result | Use pushReplacement | C1 | `test/features/study/navigation_test.dart::N5` |
| N6 | Deep link | Private route | Redirect to safe ancestor | C1 | `test/app/router/deep_link_test.dart::N6` |
| N7 | Settings hub → sub-screen | Tap row | Push to sub-screen, back returns to hub | C0+C1 | `test/presentation/settings_screen_test.dart::DT1-DT7 onNavigate`, `test/app/router/app_router_test.dart::DT8-DT9 onNavigate` |
| N8 | Future route smoke lock | Direct Future/Blocked paths requested (`/search`, `/global-search`, `/library/search`, `/onboarding`, flashcard history, reminder/daily-goal settings paths) | Resolve to router error state, not to a live V1 screen/action | C1 | `test/app/router/app_router_test.dart::DT11 onNavigate` |
| N9 | Future route registry lock | Route constants/navigation helpers inspected | No Global Search, onboarding, flashcard history, daily-goal, reminder, or similar Future route constant/action is promoted | C1 | `test/app/router/app_router_test.dart::DT12 onNavigate` |
| N10 | Onboarding feature lock | Feature folder inspected | No standalone onboarding presentation feature folder exists in V1 | C1 | `test/app/router/app_router_test.dart::DT13 onNavigate` |
| U1 | Load | Loading | Show shared loading/retained state | C0 | `test/presentation/shared/loading_state_test.dart::U1` |
| U2 | Load | Empty | Show shared empty state | C0+C1 | `test/presentation/shared/empty_state_test.dart::U2` |
| U3 | Load | Error | Show shared error state | C0+C1 | `test/presentation/shared/error_state_test.dart::U3` |
| U4 | Submit | Saving | Prevent double submit | C1 | `test/features/flashcards/save_test.dart::U4` |
| U5 | Delete | Destructive | Require confirmation | C1 | `test/features/flashcards/delete_confirm_test.dart::U5` |

## Export

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| EX1 | Pick format | User dismisses sheet | No-op, no error | C1 | `test/features/flashcards/export_picker_test.dart::EX1` |
| EX2 | Export deck | Format=csv | CSV bytes + `.csv` filename = sanitized deck name | C0+C1 | `test/data/repositories/deck_export_test.dart::EX2` |
| EX3 | Export deck | Format=excel | XLSX bytes + `.xlsx` filename = sanitized deck name | C0+C1 | `test/data/repositories/deck_export_test.dart::EX3` |
| EX4 | Export selection | Non-empty IDs | Bytes + filename `flashcards_export.{csv\|xlsx}` | C0+C1 | `test/data/repositories/flashcard_export_test.dart::EX4` |
| EX5 | Export | Always | Columns are `front,back,note` only (header row first) | C0+C1 | `test/data/repositories/flashcard_export_writer_test.dart::EX5` |
| EX6 | Export delivery | Build success | Hand off via `shareFlashcardExport` → platform share sheet | C0 | `test/features/flashcards/export_share_test.dart::EX6` |
| EX7 | Export filename | Deck has unsafe chars | Filename sanitized via `sanitizeFileName` | C1 | `test/data/repositories/sanitize_filename_test.dart::EX7` |

## TTS

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| T1 | Save settings | Slider change | Persist immediately, no save button | C0+C1 | `test/features/tts/tts_settings_notifier_test.dart::T1` |
| T2 | Set rate | Value outside `[0.3, 0.7]` | Clamp via `normalizeRate` | C1 | `test/domain/services/tts_settings_normalization_test.dart::T2` |
| T3 | Set pitch | Value outside `[0.7, 1.5]` | Clamp via `normalizePitch` | C1 | `test/domain/services/tts_settings_normalization_test.dart::T3` |
| T4 | Set volume | Value outside `[0.0, 1.0]` | Clamp via `normalizeVolume` | C1 | `test/domain/services/tts_settings_normalization_test.dart::T4` |
| T5 | Change language | New language picked | Persist + clear `frontVoiceName` | C0+C1 | `test/features/tts/tts_settings_notifier_test.dart::T5` |
| T6 | Speak side | side=`front` | Speak via `TtsService` | C0+C1 | `test/domain/usecases/speak_flashcard_test.dart::T6` |
| T7 | Speak side | side=`back` or `note` | No-op (policy blocks) | C1 | `test/domain/usecases/speak_flashcard_test.dart::T7` |
| T8 | Speak text | Blank text | No-op | C1 | `test/domain/usecases/speak_flashcard_test.dart::T8` |
| T9 | Load voices | Unknown stored voice | Fall back to platform default | C1 | `test/data/services/flutter_tts_service_test.dart::T9` |
| T10 | Persist load | Corrupt row | Return defaults via normalization | C1 | `test/data/repositories/tts_settings_repository_test.dart::T10` |
| T11 | Speak action | Deck `target_language = unsupported` | Speak button disabled; auto-play suppressed silently | C0+C1 | `test/features/study/tts_deck_gate_test.dart::T11` |
| T12 | Speak action | Deck `target_language = korean` | Use ko-KR voice from settings | C0+C1 | `test/features/study/tts_deck_gate_test.dart::T12` |
| T13 | Deck create form | New deck | `target_language` field required, defaults to `korean` | C0+C1 | `test/features/decks/create_deck_target_language_test.dart::T13` |
| T14 | Fill feedback TTS | Fill wrong feedback with `autoPlay=true` | No automatic speech; manual speak button remains available and speaks front on tap | C0+C1 | `test/presentation/fill_mode_session_view_test.dart::DT14` |
| T15 | Fill hint-taint grading | Exact match after Hint, Try again after Hint, or Mark correct override | Persist `AttemptGrade.recovered`; exact match without Hint remains `AttemptGrade.correct`; new card resets taint | C0+C1 | `test/presentation/fill_mode_session_view_test.dart::DT15` |

## Account / Drive sync

| ID | Event | Condition | Expected | Coverage | Test |
| --- | --- | --- | --- | --- | --- |
| AC1 | Load link | No record in SharedPreferences | Return null (signedOut) | C0+C1 | `test/data/settings/cloud_account_store_test.dart::AC1` |
| AC2 | Load link | Schema version mismatch | Return null (require re-link) | C1 | `test/data/settings/cloud_account_store_test.dart::AC2` |
| AC3 | Load link | Corrupt JSON | Return null, no crash | C1 | `test/data/settings/cloud_account_store_test.dart::AC3` |
| AC4 | Sign in | Success + Drive scope granted | Status=`signedIn`, link saved, `driveAuthorizationState=authorized` | C0+C1 | `test/domain/usecases/sign_in_test.dart::AC4` |
| AC5 | Sign in | Success but Drive scope denied | Status=`needsDriveAuthorization`, link saved with denied state | C0+C1 | `test/domain/usecases/sign_in_test.dart::AC5` |
| AC6 | Sign in | OAuth not configured for platform | Status=`unconfigured`, no link saved | C1 | `test/domain/usecases/sign_in_test.dart::AC6` |
| AC7 | Sign out | Linked account | Clear local session, keep DB file | C0+C1 | `test/domain/usecases/sign_out_test.dart::AC7` |
| AC8 | Disconnect | Linked account | Revoke server-side, clear link | C0+C1 | `test/domain/usecases/disconnect_test.dart::AC8` |
| AC9 | DB context | No link | Resolve to guest DB | C0+C1 | `test/domain/entities/account_database_context_test.dart::AC9` |
| AC10 | DB context | Google account link | Resolve to `{db}_{subjectId}` | C0+C1 | `test/domain/entities/account_database_context_test.dart::AC10` |
| AC11 | Guest → signed-in | choice=`attachGuestData` | Transition flags merge needed | C0+C1 | `test/domain/entities/account_database_context_test.dart::AC11` |
| AC12 | Guest → signed-in | choice=`createFreshAccountDatabase` | Transition flags fresh DB | C0+C1 | `test/domain/entities/account_database_context_test.dart::AC12` |
| SY1 | Load sync status | No account | Return `signedOut` | C0+C1 | `test/data/repositories/google_drive_sync_test.dart::SY1` |
| SY2 | Load sync status | No remote snapshot | Return `noRemoteSnapshot` | C0+C1 | `test/data/repositories/google_drive_sync_test.dart::SY2` |
| SY3 | Load sync status | Remote fingerprint == metadata fingerprint | Return `synced` | C0+C1 | `test/data/repositories/google_drive_sync_test.dart::SY3` |
| SY4 | Load sync status | Remote fingerprint != metadata fingerprint | Return `ready` | C0+C1 | `test/data/repositories/google_drive_sync_test.dart::SY4` |
| SY5 | Upload | Local fingerprint == remote fingerprint | Return `noChanges` | C0+C1 | `test/data/repositories/google_drive_sync_test.dart::SY5` |
| SY6 | Upload | Differs from remote | Upload + update metadata + return `uploadedLocal` | C0+C1 | `test/data/repositories/google_drive_sync_test.dart::SY6` |
| SY7 | Restore | Schema version too new | Return `unsupportedSchema`, do not replace | C1 | `test/data/repositories/google_drive_sync_test.dart::SY7` |
| SY8 | Restore | Success | Replace DB + settings, return `restoredRemote` with `refreshDatabaseProvider` effect | C0+C1 | `test/data/repositories/google_drive_sync_test.dart::SY8` |
| SY9 | Restore | Failure mid-flow | Return `failed` with message, local data unchanged | C1 | `test/data/repositories/google_drive_sync_test.dart::SY9` |
| SY10 | Metadata | Loaded for different account | Return null (account mismatch) | C1 | `test/data/sync/drive_sync_metadata_store_test.dart::SY10` |
| SY11 | Device id | First call | Generate + persist via `IdGenerator` | C0+C1 | `test/data/sync/drive_sync_metadata_store_test.dart::SY11` |
| SY12 | Cross-device | Remote `deviceId` differs from local | `remoteIsFromOtherDevice` = true | C1 | `test/domain/entities/drive_sync_status_test.dart::SY12` |
| SY13 | Current restore protection | Restore selected from Account Settings | Show destructive warning before restore; restore has not executed yet | C0+C1 | `test/presentation/settings_screen_test.dart::DT14` |
| SY14 | Current restore protection | Restore warning canceled | Do not call restore | C1 | `test/presentation/settings_screen_test.dart::DT15b` |
| SY15 | Current restore protection | Restore warning confirmed | Call restore once and show success feedback on success | C0+C1 | `test/presentation/settings_screen_test.dart::DT14` |
| SY16 | Current restore protection | Duplicate restore call while first restore is running | Ignore the duplicate call; restore repository runs once | C1 | `test/presentation/drive_sync_viewmodel_test.dart::restoreDriveToLocal: duplicate call while busy is ignored` |
| SY17 | Current restore protection | Restore returns failed result | Show safe failure feedback and keep retry available | C1 | `test/presentation/settings_screen_test.dart::DT14b` |
| SY18 | Full restore protection target | Local fingerprint != last-synced fingerprint | Show strong warning dialog with "Upload local first" primary | C0+C1 | Future |
| SY19 | Full restore protection target | Pre-restore snapshot save fails | Abort restore; do not proceed | C1 | Future |
| SY20 | Full restore protection target | Pre-restore snapshot saved | Surface path notice after restore | C0+C1 | Future |
| SY21 | Full restore protection target | "Restore anyway" path after fingerprint mismatch | Requires second confirmation tap | C1 | Future |

## Update rule

When implementing a new behavior:

1. Add the row here with ID and expected behavior.
2. Add the test referenced.
3. Implement.
4. Verify the test passes.

When changing existing behavior:

1. Update the row (do not delete, mark deprecated if needed).
2. Update the test.
3. Update related business doc in the same commit.

## Related

This table cross-references every behavior branch. When a row is added or modified, the corresponding business doc and test MUST be updated in the same commit (per `CLAUDE.md` §Doc-code parity rule).

**Business specs (rows reference these for "Source of truth"):**

- All of `../business/**`

**Wireframes (rows reference for UI verification):**

- All of `../wireframes/**`

**Schema:**

- `docs/database/schema-contract.md` — column-level rows under "Schema"

**Checklists:**

- `docs/checklist/implementation-checklist.md` — "Tests" section requires a test per touched decision row
- `docs/checklist/recursive-agent-review.md` — verifies row coverage

**Maintenance rule:**

- Every C0 row MUST have at least one test referenced by ID.
- Every new branch logic in code MUST add a row before merge.
