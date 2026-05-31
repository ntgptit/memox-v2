---
last_updated: 2026-05-29
revision: 4 (scope-resolution update after product decisions)
author: technical leader recursive audit
scope: docs/wireframes/** ↔ lib/{presentation,domain,data}/**
purpose: Đối chiếu wireframe ↔ code ở mức aspect-by-aspect, với evidence cụ thể (file:line + symbol). Rev 4 cập nhật scope sau khi 3 product decisions ngày 2026-05-29 được chốt.
companion_docs:
  - docs/checklist/c-greater-than-d-cleanup-2026-05-28.md (log của đợt cleanup trước đó)
  - docs/checklist/product-decisions-pending-2026-05-29.md (resolved V1 decisions)
  - docs/checklist/v1-implementation-scope-2026-05-29.md (current V1 scope guard)
---

# Wireframe ↔ Code Parity Assessment (Revision 4)

> **Lifecycle**:
>
> - Rev 1 (junior, deprecated) — đánh giá theo "file tồn tại" bề mặt; sai chiều drift ở Match/Guess; sai MATCH cho Dashboard/Tag/Recall/Import/Study-entry.
> - Rev 2 (senior, replaced) — đào sâu 3 layer, evidence file:line, phát hiện streak orphan, schema thiếu bury/suspend, code paths stale; nhưng còn vài chỗ over-broad (xem §5.1).
> - Rev 3 — refresh sau C>D cleanup pass đã commit; 4 cross-cutting items resolved, 3 cross-cutting items mới phát hiện qua recursive review.
> - Rev 4 (CURRENT) — scope-resolution update: #09 Card History, #11 Global Search, and full #23 Onboarding are no longer V1 blockers; they are Future Proposal except V1 thin zero-content guidance.

> **Core Learning Loop freeze (2026-05-31, Prompt 13)**: the Core Learning Loop
> source-of-truth (rows #12–#18 + §2 study routes + SRS §3.10/finalize) is **frozen for V1 /
> current behavior**. The authoritative Core Freeze Summary table, frozen-status per area,
> manual Chrome preflight confirmation, retained automated coverage, the Review/Match/Recall
> dedicated-mode-view test gap (P3), and the two still-open product decisions (terminal
> `forgot` path; canonical interval ladder) live in
> `docs/checklist/implementation-ledger.md` §"Prompt 13 — Core Learning Loop Source-of-Truth
> Freeze". No code/schema/route/SRS-interval behavior changed in Prompt 13.

---

## §0. Methodology

### Layer-by-layer audit (giữ từ Rev 2)

Mỗi wireframe được kiểm ở 3 tầng — KHÔNG dừng ở "có screen file":

1. **Presentation** — screen + viewmodel + mọi widget có call-site. Widget tồn tại trong `shared/` mà không có call-site = **orphan**, không tính là implement.
2. **Domain** — use case nào? Repository contract đầy đủ?
3. **Data** — table/column/DAO/migration. Especially cho status-bearing features (bury/suspend, tag, history, engagement).

Mỗi finding cell **§1 Điểm khác biệt** phải có evidence dạng `file.dart:line` hoặc symbol cụ thể, không suy luận từ tên.

### Recursive review (mới ở Rev 3)

Sau mỗi pass edit/cleanup, chạy lại grep cho toàn bộ pattern stale đã fix trong pass đó. Pattern phổ biến: tên file mà code không còn (do consolidation). Nếu grep còn match, chưa được giải thích trong drift-note → fix tiếp hoặc add to backlog với rationale. Mỗi pass phải có "final sweep zero unexplained stale refs".

### Severity bands

| Mức | Định nghĩa | SLA |
| --- | --- | --- |
| **P0 — Blocker** | Spec contract / Hard Rule bị vi phạm. Release sẽ rơi vào trạng thái không thể giải thích cho user. | Trong sprint hiện tại. |
| **P1 — Major** | Doc đã commit tính năng người dùng nhưng code không có. Risk: user trust khi đọc release notes. | Sprint tới. |
| **P2 — Minor** | Drift về thông tin/format/edge case. UI và core flow OK. | Backlog gần. |
| **P3 — Doc lag** | Code > doc. Không ảnh hưởng user, ảnh hưởng dev onboarding. | Sweep định kỳ. |

### Direction of drift

| Ký hiệu | Ý nghĩa |
| --- | --- |
| `D>C` | Doc vượt Code (spec hứa, code chưa có). |
| `C>D` | Code vượt Doc (code đã làm, doc chưa cập nhật). |
| `D≠C` | Hai bên có, nhưng spec lệch (số liệu, mô tả khác). |
| `=` | Khớp aspect-by-aspect ở phạm vi đã verify. |

### Phạm vi "verified" — disclaimer quan trọng

Một row gán `=` (match) ở Rev 3 chỉ có nghĩa **các aspect được liệt kê trong cell "Điểm khác biệt" đã được verify**. Các aspect khác của cùng wireframe (Forbidden, States edge case, Accessibility, Responsive...) **không tự động được verify** trừ khi explicit. Đây là precision discipline để tránh over-claim như Junior Rev 1.

---

## §1. Per-screen assessment

Cột "Điểm khác biệt" trình bày theo format `[Verified 2026-05-28]: ...` cho aspect đã kiểm, `[Pending]: ...` cho aspect còn lại.

| # | Wireframe | Status | Chức năng (theo doc) | Điểm khác biệt (doc ↔ code, evidence) | Đề xuất | Ưu điểm | Nhược điểm |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 01 | `01-dashboard.md` | 🟡 D>C (engagement-only) | Resume card (multi-session), streak chip với daily-progress, due cards summary, mastery, deck highlights. | [Prompt 04, 2026-05-30]: Resume card (Continue/Discard + "+N more"), **multi-resume** paused-sessions sheet, discard dialog, "Start new learning" scope picker, và recent decks đã implement + tested (`test/presentation/dashboard_screen_test.dart`); `DashboardOverviewState.resumeSessions` carries the list. **Còn lại chỉ là engagement**: `MxStreakCard` (`mx_streak_card.dart:14`) vẫn không có call-site; state không có field streak/dailyGoal — streak chip + daily-goal ring stay `Target`/Future (blocked on §3.2). | **P2 (engagement)**: Implement `EngagementUseCase` (streak từ distinct `study_sessions.started_at`); mount `MxStreakCard` vào `dashboard_content.dart` khi product decision được chốt. | Route + viewmodel + widgets + resume/scope/recent đều ổn. | Chỉ streak/daily-goal engagement còn trống; study-entry/resume parity đã đạt. |
| 02 | `02-library.md` | 🟡 D>C | Library: tabs, sort, search inline scope-local, FAB tạo. | [Verified 2026-05-28]: Library overview dùng `MxSearchField` inline trong app bar (`library_app_bar.dart:60`); KHÔNG dùng full toolbar — Rev 2 nhầm với folder-detail. `libraryToolbarStateProvider.query` scope-local đúng spec. [Prompt 14, 2026-05-31]: Recursive folder count verified in `WatchLibraryOverviewUseCase` → `FolderRepositoryImpl.getLibraryOverview` → `FolderDao.count*InSubtree`; sibling root folder trees stay isolated and empty nested folders contribute zero. | Recursive-count P2 resolved; remaining Library rows stay Partial for sort/empty/responsive create-flow parity. | Search + sort clean; recursive counts now tested. | Full Library screen still not globally Current; only recursive-count gap is closed. |
| 03 | `03-progress.md` | 🟠 D>C | Mastery rings, history list, streak chart 7-day, box distribution chart, daily goal donut. | [Verified 2026-05-28]: `MxStatTone.streak` ở `progress_overview_section.dart:26,95` là **color tone** không phải streak count. `mx_weekly_bar_chart.dart` tồn tại nhưng nguồn data thực chưa trace. [Pending]: Box-distribution widget riêng cho box 1-8. | **P1**: Box-distribution widget + streak history data source. | Có shared chart. | Streak history hiện ở mức tone-only. |
| 04 | `04-settings-hub.md` | ✅ = | Hub Account/Learning/Audio-Speech/About. | [Verified 2026-05-28]: 4 sub-routes `settingsAccount/Learning/AudioSpeech/LearningTags` khớp `RouteNames`. | OK. | Routes 1-1. | Tag mgmt nested dưới Learning — doc không show rõ hierarchy. |
| 05 | `05-folder-detail.md` | 🟡 D>C | Breadcrumb, children list, sort, search inline, quick actions, empty state, lock-mode rejection. | [Verified 2026-05-28]: §Components đã document `MxSearchSortToolbar<ContentSortMode>` (verified at `folder_detail_screen.dart:178`). [Prompt 14, 2026-05-31]: lock-mode fallback UX verified and fixed: `FailureCodes.folderContainsDecks` / `folderContainsSubfolders` map to localized snackbar copy in Folder Detail; widget tests cover stale create-subfolder/create-deck paths and assert no generic error appears. | Lock-mode P2 resolved; keep row Partial for remaining broader Folder Detail parity items. | Shared toolbar tái sử dụng; lock-mode message typed + localized. | Full screen still not globally Current; move/cascade/reorder broader parity remains separate. |
| 06 | `06-flashcard-list.md` | ✅ = (§Components scope) | Danh sách: bulk select, reorder, search inline, breadcrumb, deck summary, study modes, progress, bulk action bar, empty/skeleton. | [Verified 2026-05-28]: §Components đã expand thành 13-row bảng mapped 1-1 với `flashcard_*_section.dart` files theo render order screen (lines 130-436). [Pending]: §Rules, §States, §Forbidden chưa re-verify aspect-by-aspect. | **P3**: Subsequent pass verify other sections. | Mapping doc ↔ widget rõ ràng, dễ review PR. | Verify scope hẹp — chỉ §Components. |
| 07 | `07-flashcard-create.md` | 🟡 D≠C | Form tạo flashcard 1 thẻ + bulk paste; route riêng `flashcardCreate`. | [Verified 2026-05-28]: `flashcard_editor_screen.dart` shared cho cả create và edit (`flashcardCreate` và `flashcardEdit` cùng map sang screen này). [Pending]: Doc vẫn tách 07/08 → gây hiểu nhầm. | **P2**: Merge 07+08 thành "Flashcard editor" hoặc add cross-ref note ở header cả hai file. | Một code path, ít drift logic. | Spec dual-file ↔ code single-file. |
| 08 | `08-flashcard-edit.md` | 🟡 D≠C | Form chỉnh + delete (danger zone) + future "View history" action. | [Verified 2026-05-28]: Cùng screen với #07. [Scope 2026-05-29]: `View history` is Future Proposal and must not be exposed as a live V1 action. Bury/Suspend foundation implemented (P0-2, §3.1 resolved); the live trigger is the study-session card-actions sheet (#25), not this editor. | **P2**: Cùng action với #07 + ensure `View history` is hidden/disabled in V1. | Bury/Suspend now functional via card-actions sheet. | History action is intentionally future. |
| 09 | `09-flashcard-history.md` | ⚪ Future | Trang lịch sử attempts của 1 flashcard. | [Verified 2026-05-28]: `find lib -name "*history*"` vẫn rỗng. [Scope 2026-05-29]: downgraded to Future Proposal for V1; also requires `last_reset_at`, `box_before`, `box_after` migration. | No V1 implementation. Hide/disable entry links. Promote only via scope-guard + migration PR. | Schema raw attempts exist. | Not a V1 blocker after decision. |
| 10 | `10-deck-import.md` | ✅ = (§Implementation refs scope) | Import CSV/Excel/structured-text vào deck. | [Verified 2026-05-28]: Doc đã update code paths to `flashcard_import_support.dart` (csv + structuredText) + `flashcard_excel_import_parser.dart` (DIY xlsx parser, không dùng `excel` pkg, single-sheet only). Format enum verified at `value_objects/content_actions.dart:45`. [Pending]: Decision-table rows cho import chưa cross-verify. | **P3**: Decision-table cross-verify. | Import 3-format đầy đủ. | Excel parser scope (single sheet, no formula) là known limitation đã document. |
| 11 | `11-library-search.md` | ⚪ Future / V1 guideline | Full global search cross deck/folder/tag, plus V1 inline search rules. | [Verified 2026-05-28]: Không có screen, không có `GlobalSearchUseCase`; inline `MxSearchField` is scope-local. [Scope 2026-05-29]: full global search downgraded to Future Proposal; V1 keeps inline/scope-local guidelines. | No V1 global route/use case. Use doc only to standardize inline search. | Inline scope-local works. | Full global search not a V1 blocker after decision. |
| 12 | `12-study-entry-gate.md` | 🟡 D>C (Tier 1 done) | Empty scope matrix 10 cases với l10n keys. | [Verified 2026-05-29]: **6 Tier 1 cases implemented**. `StartStudySessionUseCase._rejectEmptyScope` (`study_usecases.dart`) branches per entry/study type, throwing typed `EmptyScopeException(reason, nextDueAt)` for deck_noCards / deck_noDueCards / folder_noCards / folder_noDueCards / today_allDone / today_noContent. Repo probe queries `countFlashcardsInScope` / `countDueCardsInScope` / `nextDueAt` in `study_repo_impl.dart`. `EmptyScopeScreen` renders all 6 arms with CTAs; 16 l10n keys added. Tier 3 (`allBuried`/`allSuspended`) implemented 2026-05-29 (P0-2). [Prompt 05B, 2026-05-30]: **resume conflict semantics now match the scope-only spec** — the gate shows `MxDialogResumeOrStartOver` for any resumable session with the same `(entry_type, entry_ref_id)`, including different requested mode flows; Resume opens the existing session, Start over confirms discard and creates the requested flow through `RestartStudySessionUseCase` with `restartedFromSessionId`, and Cancel pops back without creating a session (`study_entry_screen.dart`). Restart atomicity is preserved by letting `StudyRepoImpl.startSession` perform cancel+create in one transaction. Remaining: Tier 2 (`tag_noCards`/`tag_noDueCards`) needs `StudyEntryType.tag`. | **P0 Tier 1 + Tier 3 + resume dialog resolved.** Remaining: Tier 2 (tag). | Typed failure + dedicated empty states + tests (decision rows S4/S4b–S4g/S4j, R5/R6/R10-R12). | 2 of 10 cases still blocked (tag scope). |
| 13 | `13-study-session-review.md` | 🟡 D>C | Review mode swipe + long-press → card actions. | [Verified 2026-05-28]: Code paths đã refresh tới `review_mode_session_view.dart` + `review_page_scroll_behavior.dart`. Card-actions overflow trigger (`MxCardActionsSheet`) wired into all mode views via shared `MxStudyTopBar`; bury/suspend drop the card from the active session (§3.1 resolved). | **P3**: optional long-press shortcut in addition to the overflow trigger. | Swipe + scroll layers clean; card-actions reachable in-session. | Long-press shortcut optional. |
| 14 | `14-study-session-match.md` | ✅ = | Board 5-pair, 10 cells, ≥5 cards. | [Verified 2026-05-28]: `matchVisiblePairLimit = 5` ở `match_batching.dart`. Seeded shuffle (`match_seed.dart`) deterministic per `sessionId + boardIndex`. Grading via `AnswerCurrentMatchModeBatchUseCase`. Long-press: cùng track #13. | **P3**: Long-press track #13. | Match-mode batch usecase riêng → clean. | Long-press chưa wire. |
| 15 | `15-study-session-guess.md` | ✅ = | 5 options (A-E), up to 4 valid decoys, countdown 0.8s correct / 1.5s wrong. | [Prompt 10B, 2026-05-31]: Option generation lives in domain `lib/domain/study/guess/guess_option_builder.dart` (`GuessOptionBuilder.build`, `kGuessDecoyLimit = 4`). The builder filters the full valid decoy pool first, seeded-shuffles that full pool, then selects up to 4 decoys; final option order is separately seeded when answer shuffle is enabled. Presentation/notifier no longer owns Guess decoy sampling; `guess_mode_session_view.dart` consumes builder output directly, and `study_session_notifier.dart` has no inline `Random`/`shuffle()`/`take()` sampling. Countdown constants unchanged: `AppDurations.guessCorrectAdvanceDelay = 800ms`, `AppDurations.guessWrongFeedbackDelay = 1500ms` (`lib/core/theme/tokens/app_motion.dart`) surfaced as `MxDurations.guess*` and aliased in `guess_motion.dart`. Footer countdown progress + delayed grade staging both consume the per-grade duration. | **P3**: Long-press card actions (shared with #13/#14). | Full-pool decoy selection and option ordering are deterministic per `(sessionId, itemId, mode, cardId, shuffleAnswers)` seed. | Covered by `test/domain/study/guess/guess_option_builder_test.dart` and `test/presentation/guess_mode_session_view_test.dart` (799/800 + 1499/1500 boundary pumps). |
| 16 | `16-study-session-recall.md` | ✅ = | Flip card + 20s timeout auto-reveal + self-grade. | [Verified 2026-05-28]: Doc đã thêm full spec timer 20s (`MxDurations.recallAnswerTimeout = Duration(seconds: 20)` ở `app_motion.dart:29`) + auto-reveal on timeout flow. §Layout, §Components, §States, §Actions, §Rules, §Forbidden tất cả include timer. Long-press track #13. [Mock gap]: Mock variants `09a (hidden)` + `09b (revealed)` không có `09c (timed out)` — tracking through §3.15.2 item 2. | **P3**: Long-press + mock variant gap. | UX timer behavior giờ minh bạch trong wireframe doc. | Mock chưa có variant timed-out (visual same với revealed + caption). |
| 17 | `17-study-session-fill.md` | ✅ = | Type front, strict char match, Mark correct override, Hint button taint to `recovered`. | [Prompt 06, 2026-05-31]: strict matcher and hint reveal policy live in domain (`lib/domain/study/fill/fill_answer_matcher.dart`, `lib/domain/study/fill/fill_hint_policy.dart`). [Prompt 07, 2026-05-31]: Fill wrong feedback is manual-TTS only; no `StudyAutoSpeakEffect`. [Prompt 08/08B, 2026-05-31]: hint-taint grading uses explicit `AttemptGrade.recovered` / schema v13, so exact+hint and Mark-correct override persist recovered without fake `incorrect`; SRS review recovered-only pass finalizes as `ReviewResult.recovered`, keeps current box, and records no lapse. [Prompt 12, 2026-05-31]: **SRS finalize box-transition aligned to the authoritative `srs-review.md` table for ALL recovered paths** — previously `_reviewOutcome` (`study_repo_impl_helpers.dart`) treated any session attempt history containing an `incorrect` grade (e.g. the `incorrect → correct` retry path) as a box-decrement + lapse, which contradicted the `recovered` row (box stays, lapse only on `forgot`). It now classifies per the shared breakdown rule: no-passing → `forgot` (box → 1, lapse +1, currently unreachable because failed cards re-queue until passed), at-least-one-passing-but-not-all-correct → `recovered` (box stays, no lapse), all-correct → `perfect` (box +1). Contract tests `DT3 repositoryFlow` and `DT1 onRefreshRetry` were updated from the old box-3/lapse-1 expectation to box-stable/lapse-0. | — | Clean Architecture boundary now holds for matcher/hint/grading; TTS remains manual-only. | Covered by `test/domain/study/fill_answer_matcher_test.dart`, `test/domain/study/fill_hint_policy_test.dart`, `test/domain/study/attempt_grade_codec_test.dart`, `test/data/datasources/local/app_database_migration_test.dart`, `test/data/repositories/study_repository_test.dart` DT15, and `test/presentation/fill_mode_session_view_test.dart` DT14/DT15. |
| 18 | `18-study-result.md` | 🟡 D>C | Stats summary, streak chip, per-card review list, retry session, finalize retry. | [Verified 2026-05-28]: `FinalizeStudySessionUseCase` + `RetryFinalizeUseCase` tồn tại (`study_usecases.dart:339,363`). [Prompt 09, 2026-05-31]: V1 action contract + breakdown landed — Done uses `context.go(...)` via `AppNavigation.goStudyResultDone` (result never preserved in back stack), failed-finalize banner keeps Done available next to Retry, and `StudyResultBreakdown` + `BoxChangeBreakdown` are computed from `study_attempts` (oldBox/newBox) in `lib/domain/study/result_breakdown.dart`. [Prompt 09B, 2026-05-31]: **Today Done now goes to Dashboard/Home** (not Library); Study more was extracted to `lib/presentation/shared/bottom_sheets/study_scope_picker_sheet.dart` and the Dashboard caller is now a thin wrapper; Study more selection (Today/Deck/Folder) is fully covered by widget tests that assert routes go to StudyToday / StudyEntry-deck / StudyEntry-folder respectively and that Result is NOT preserved underneath. [Prompt 11, 2026-05-31]: **V1 per-card review section ("Cards to review") added** — `computeStudyResultCardReviewItems` shares the per-card classifier with `computeStudyResultBreakdown`, the repository mapping populates `StudySessionSnapshot.resultCardReviewItems` from the same loaded attempts/flashcards, and `_StudyResultCardReviewSection` renders recovered/forgot rows (forgot first, most-recent first within bucket) with optional box transition. Perfect/initialPassed cards are excluded. No History route and no filtered tough-cards route are added. Empty bucket renders "No cards need extra review." Streak chip + external filtered tough-cards list remain **Future/Blocked** (engagement use cases not present, no filtered history route). | **P2**: Streak source-of-truth (link #01). | Finalize/retry + Done/Study more + V1 per-card review section aligned with wireframe; scope picker shared cleanly. Covered by `test/presentation/study_result_screen_test.dart`, `test/domain/study/result_breakdown_test.dart`, `test/domain/study/result_card_review_test.dart`, `test/data/repositories/study_repository_test.dart`. | Streak block still missing (out of Prompt 09/09B/11 scope); external filtered tough-cards screen remains Future/Blocked. |
| 19 | `19-settings-account.md` | ✅ = (§Platform gateways scope) | Sign in Google → link → Drive sync snapshot list / restore. | [Verified 2026-05-28]: Business doc `account-sync.md` đã thêm hẳn §Platform snapshot gateways với bảng so sánh io/web/stub + rules (web cần `sqlite3.wasm` + `drift_worker.dart.js` assets; io dùng `path_provider.getTemporaryDirectory()`; stub throws). [Pending]: Wireframe 19 chính nó (UI flow restore-warning, fingerprint mismatch) chưa re-verify. | **P3**: Wireframe 19 UI aspects pass tiếp. | Sync layer tách clean nhất. | Verify scope hẹp — chỉ data-layer gateways. |
| 20 | `20-settings-learning.md` | 🟡 D>C | Daily goal, autoplay TTS, intervals override, mode prefs, bury/suspend defaults. | [Verified 2026-05-28]: `study_settings_policy.dart` exists. Bury/suspend foundation done (§3.1); exposing bury/suspend default-behavior settings is a separate follow-up. **Daily-goal field** chưa thấy — link #01. | **P1**: Daily-goal setting; optional bury/suspend default settings. | Policy tách object. | 2 sub-features missing. |
| 21 | `21-settings-audio-speech.md` | 🟡 D>C | TTS engine select, voice, rate, pitch, sample, auto-play default. | [Verified 2026-05-28]: `audio_speech_settings_screen.dart` + `tts_usecases.dart` + `tts_settings_records_table.dart` exist. [Pending]: Engine fallback Android/iOS + voice picker UI. | **P2**: Verify engine fallback + voice picker. | Persistence table cho TTS settings. | Edge case engine unavailable chưa rõ. |
| 22 | `22-settings-tag-management.md` | ✅ = (V1 scope) | Tag list, rename, merge, delete; affect flashcards cascade. | [Verified 2026-05-30]: Tag domain layer added — `TagRepository` + `TagRepositoryImpl` + `FlashcardTagDao` + `TagValidator` + use cases (`WatchAllTagsWithCount`/`AddTagToCard`/`RemoveTagFromCard`/`RenameTag`/`MergeTag`/`DeleteTag`). Screen rewritten with rename/merge/delete via shared dialogs; UseCase → Repository → DAO flow (no data access from presentation). Tags lowercased (schema v11). See §3.3. | — (resolved) | `mx_tag_input` shared widget (now with inline validation). | "Study cards with this tag" Blocked (`StudyEntryType.tag`); global "View cards" Future (global search) — not exposed in V1. |
| 23 | `23-onboarding.md` | 🟡 V1 thin / Future full | V1 zero-content guidance; full onboarding flow is future. | [Verified 2026-05-28]: `grep -i "onboarding" lib/` rỗng and initial route is Library. [Scope 2026-05-29]: this is acceptable for V1; implement stronger empty-state CTAs, not standalone onboarding. | **P1**: Add create/import/restore CTAs to empty states. Do not create onboarding route/feature. | Avoids M-size onboarding scope. | Full welcome/restore prompt remains future. |
| 24 | `24-shared-dialogs.md` | 🟠 D>C | Catalog 8+ dialogs. | [Verified 2026-05-28]: Code có 3 typed widgets (`mx_dialog`, `mx_confirmation_dialog`, `mx_name_dialog`). [Prompt 05, 2026-05-30]: **§resume-or-start-over implemented** as `MxDialogResumeOrStartOver` (`mx_dialog_resume_or_start_over.dart`, typed `MxResumeChoice`); §discard-session composed via `MxConfirmationDialog` (danger). Các dialog specific còn lại (exit-session, finalize-retry, restore-prompt, …) chưa có file riêng. | **P2**: Audit từng §dialog → tạo widget hoặc confirm inline. | Base `mx_dialog` foundation. | Dialog ecosystem ~45% typed. |
| 25 | `25-shared-bottom-sheets.md` | 🟠 D>C | Card-actions, undo toast, destination picker, study-mode picker. | [Verified 2026-05-29]: base widgets + **`MxCardActionsSheet`** (Edit/Bury/Suspend, no History) with **undo toast**, reachable from all five mode views + session app bar (P0-2, §3.1 resolved). | **P1**: scope picker / paused-sessions sheets still TBD. | Card-actions + in-session triggers + undo done. | Sheet ecosystem ~65% complete. |

### §1.1 Status distribution (Rev 4 vs Rev 3 — docs-scope update)

| Status | Rev 3 | Rev 4 | Δ | Rows changed |
| --- | --- | --- | --- | --- |
| ✅ = | 7 | 7 | = | No implementation parity change in this docs-only scope update. |
| 🟡 / V1 thin | 9 | 10 | +1 | #23 becomes V1 thin zero-content guidance rather than missing standalone onboarding. |
| 🟠 | 6 | 6 | = | No change. |
| 🔴 (MISSING V1 blocker) | 3 | 0 | -3 | #09, #11, #23 no longer counted as V1 missing blockers after product decision. |
| ⚪ Future | 0 | 2 | +2 | #09 Card History and #11 full Global Search. Full #23 onboarding is also future, while thin empty-state guidance remains V1. |
| **Total** | 25 | 25 | | |

→ Rev 4 is a docs-scope correction. It does not claim code improved; it removes three false V1 blockers by explicitly downgrading them or narrowing their scope.

> **Post-Rev 4 implementation delta (2026-05-29, P0-1 Empty-Scope Tier 1 merge):** row #12 moved 🟠 → 🟡 after the 6 Tier 1 empty-scope cases landed in code (see §1 row #12 + §3.7). Net effect on the distribution: 🟠 6 → 5, 🟡 10 → 11. A full Rev 5 re-audit is the right vehicle to re-tally; this note records the single-row delta in the interim per §9 re-audit trigger #1.

---

## §2. Routes ↔ navigation parity (unchanged from Rev 2 — code chưa đổi)

| Route name | Path | Doc spec | Status |
| --- | --- | --- | --- |
| `home` | `/home` | Dashboard | ✅ |
| `library` | `/library` | Library overview | ✅ (cũng là `initialLocation` — verify với navigation-flow.md) |
| `progress` | `/progress` | Progress | ✅ |
| `settings` (+ 4 sub) | `/settings/*` | Settings hub + 4 sub-screens | ✅ |
| `folderDetail` | `/library/folder/:id` | Folder detail | ✅ |
| `flashcardList` | `/library/deck/:deckId/flashcards` | Flashcard list | ✅ |
| `flashcardCreate` | `/library/deck/:deckId/flashcards/new` | Create | ✅ (shared screen với edit — xem #07) |
| `flashcardEdit` | `/library/deck/:deckId/flashcards/:flashcardId/edit` | Edit | ✅ |
| `deckImport` | `/library/deck/:deckId/import` | Import | ✅ |
| `studyEntry` | `/library/study/:entryType/:entryRefId` | Study entry | ✅ |
| `studyToday` | `/library/study/today` | Today shortcut | ✅ |
| `studySession` | `/library/study/session/:sessionId` | Active session | ✅ |
| `studyResult` | `/library/study/session/:sessionId/result` | Result | ✅ |
| **Missing in code** | — | `/flashcard/:id/history` (wireframe 09) | 🔴 |
| **Missing in code** | — | `/library/search` (wireframe 11) | 🔴 |
| **Missing in code** | — | `/onboarding` (wireframe 23) | 🔴 |

`RouteDefaults.initialLocation = RoutePaths.library` — cần verify với `docs/business/navigation/navigation-flow.md` xem default đúng là library hay dashboard. Vẫn open question từ Rev 2.

---

## §3. Cross-cutting drift

### §3.1 Bury / Suspend — **RESOLVED 2026-05-29 (P0-2)** (in-session removal + mode-view triggers complete)

| Layer | Status | Evidence |
| --- | --- | --- |
| Doc | ✅ | `docs/business/study-actions/bury-suspend.md` + decision rows BS1/BS2/S4f/S4g. |
| Schema | ✅ | `flashcard_progress_table.dart` `buriedUntil` + `isSuspended` (schema v10) + index `idx_flashcard_progress_eligibility`. |
| Domain | ✅ | `Bury/Unbury/Suspend/UnsuspendFlashcardUseCase` in `study_usecases.dart`; `StudyRepo.setBuried/setSuspended/countSuspendedInScope/countActiveBuriedInScope`. |
| Data | ✅ | `study_repo_impl.dart` persistence + `_eligibilityClause` filtering in batch/due/count queries; migration `_addBurySuspendColumnsForSchemaV10` + migration test. |
| Presentation | ✅ | `MxCardActionsSheet` (Edit/Bury/Suspend, no History) reachable via the overflow trigger in the shared `MxStudyTopBar` across all five mode views (review/match/guess/recall/fill) + session app bar, with undo toast. Bury/Suspend drop the current card from the active session (`DropCurrentStudyItemUseCase` → `StudyRepo.dropCurrentItemFromSession`): no requeue, advances or finalizes, no attempt recorded, SRS preserved. |

**Resolved**: study-batch + due-count filtering (excludes suspended + currently-buried; expired bury re-enters), empty-scope `studyEmpty_allBuried`/`studyEmpty_allSuspended`, card-actions sheet + in-session triggers, active-session removal on bury/suspend. Tests: `study_repo_drop_item_test.dart`, `study_session_card_action_dispatch_test.dart`, `study_mode_card_actions_test.dart`.

**Remaining follow-up (not blockers)**: undo re-insert into the active session (undo currently reverts progress only), flashcard-list state badges + status filter chips (06), bulk suspend/unsuspend, bury defaults in settings (20), optional long-press shortcut.

### §3.2 Streak / Engagement — **P1 Major** (unchanged from Rev 2)

| Layer | Status |
| --- | --- |
| Doc | ✅ |
| Schema | 🟡 Implicit (derivable from `study_sessions.started_at`) |
| Domain | 🔴 No `CalculateStreakUseCase` |
| Data | 🔴 No distinct-day query |
| Presentation | 🟠 `mx_streak_card.dart` orphan (verified 2026-05-28, still 0 call-sites) |

**Impact**: blocks streak chip in #01 + #18, daily-goal in #20.

### §3.3 Tag system — ✅ **RESOLVED 2026-05-30** (domain layer + management screen)

- Schema: junction-only (`flashcard_tags`), now case-insensitive with **lowercased storage**; schema v11 backfills existing rows to lowercase (`_lowercaseFlashcardTagsForSchemaV11`).
- Domain: `TagValidator` (`lib/domain/tag/tag_validator.dart`), `TagRepository` interface (`lib/domain/repositories/tag_repository.dart`), value objects (`TagWithCount`, `TagMergeResult`), use cases (`lib/domain/usecases/tag_usecases.dart`): `WatchAllTagsWithCountUseCase`, `AddTagToCardUseCase`, `RemoveTagFromCardUseCase`, `RenameTagUseCase`, `MergeTagUseCase`, `DeleteTagUseCase`. Names follow `docs/contracts/usecase-contracts/tag.md`; the prompt's `ListTags`/`EnsureTag`/`MergeTags` map to `WatchAllTagsWithCount`/(`TagValidator`+`AddTagToCard`)/`MergeTag`.
- Data: `TagRepositoryImpl` + `FlashcardTagDao`; merge/delete/rename are transaction-wrapped; result type is the project's `Result<T>` (not `fpdart`).
- Presentation: `tag_management_screen.dart` rewritten — empty/populated/search states, rename (collision → merge confirm), merge (destination picker), delete (confirm). Flow is UseCase → Repository → DAO; **no presentation→Drift access**. Flashcard editor tag input validates/normalizes through `TagValidator`.
- **Out of V1**: "Study cards with this tag" (Blocked on `StudyEntryType.tag`, §3.7 Tier 2) and global "View cards" (Future global search, §3.5) are not exposed in the context sheet.
- Tests: `test/domain/tag/tag_validator_test.dart`, `test/domain/tag/tag_usecases_test.dart`, `test/data/repositories/tag_repository_impl_test.dart`, `test/data/datasources/local/tag_lowercase_migration_test.dart`, `test/presentation/tag_management_screen_test.dart`, editor tag tests in `test/presentation/flashcard_editor_screen_test.dart`.

### §3.4 Card history — **Future Proposal** (scope resolved 2026-05-29)

Schema attempts có, nhưng domain/screen trống. V1 decision: không build Card History; `View history` must be hidden/disabled. Future promotion requires schema migration for `last_reset_at`, `box_before`, `box_after`.

### §3.5 Global search — **Future Proposal / V1 inline guideline** (scope resolved 2026-05-29)

Full cross-scope global search is Future Proposal. V1 keeps inline/scope-local search only. Do not add `/library/search`, `GlobalSearchUseCase`, grouped results, or `search.recent` persistence.

### §3.6 Onboarding — **P1 Thin V1 / Future full flow** (scope resolved 2026-05-29)

Standalone onboarding remains absent by design. V1 scope is stronger zero-content empty states with Create / Import / Restore CTAs. Full welcome screen, onboarding feature folder, and restore prompt branch are Future Proposal.

### §3.7 Empty-scope matrix — **Tier 1 + Tier 3 RESOLVED; Tier 2 still blocked**

Tier 1 (6 cases: deck_noCards, deck_noDueCards, folder_noCards, folder_noDueCards, today_allDone, today_noContent) implemented — typed `EmptyScopeException` + repo scope-probe queries + `EmptyScopeScreen` arms + l10n + tests (decision rows S4/S4b–S4e/S4j). Evidence: `lib/domain/study/usecases/study_usecases.dart` `_rejectEmptyScope`, `lib/data/repositories/study_repo_impl_helpers.dart` (`_countFlashcardsInScope`/`_countDueCardsInScope`/`_nextDueAt`), `lib/presentation/features/study/widgets/empty_scope_screen.dart`.

Tier 3 (`allBuried`, `allSuspended`) implemented 2026-05-29 (P0-2) — `countSuspendedInScope`/`countActiveBuriedInScope` pre-checks (allSuspended precedes allBuried), screen arms, l10n, tests (decision rows S4f/S4g). See §3.1.

Remaining blocked:

- **Tier 2** `tag_noCards` / `tag_noDueCards` — needs `StudyEntryType.tag` + tag-scope queries.

### §3.8 Excel import — ✅ **RESOLVED 2026-05-28**

Doc đã update với DIY xlsx parser scope + limitations. Xem [docs/wireframes/10-deck-import.md](docs/wireframes/10-deck-import.md) §Code paths + §Excel parser scope. **Đóng item này.**

### §3.9 Recall timer — ✅ **RESOLVED 2026-05-28**

Doc đã thêm full spec timer 20s + auto-reveal. Xem [docs/wireframes/16-study-session-recall.md](docs/wireframes/16-study-session-recall.md) §Layout (timed-out) + §Components + §States + §Rules + §Agent rule. **Đóng item này.**

### §3.10 Strict matcher, hint taint, and Fill TTS — ✅ **RESOLVED for Fill V1** (updated 2026-05-31, Prompt 08)

- ✅ **Strict matcher promoted to domain**: `lib/domain/study/fill/fill_answer_matcher.dart` (trim + strict char equality, no case folding, no diacritic stripping, no whitespace collapsing). `FillModeSessionView` uses it in place of `StringUtils.equalsNormalized`. Tests: `test/domain/study/fill_answer_matcher_test.dart`.
- ✅ **Hint reveal policy promoted to domain**: `lib/domain/study/fill/fill_hint_policy.dart` (`floor(len/2)` cap, per-card reveal count, taint flag). `FillModeSessionView` tracks reveal count per current card; Hint button reveals one char per tap, disables at cap, Try again clears input but retains reveal count, new card resets. Tests: `test/domain/study/fill_hint_policy_test.dart`, `test/presentation/fill_mode_session_view_test.dart`.
- ✅ **Fill TTS auto-play disabled**: `FillIncorrectCard` no longer mounts `StudyAutoSpeakEffect`, so Fill wrong feedback does not call `TtsController.autoPlayTextSide` even when settings `autoPlay=true`. Manual `StudySpeakButton` remains visible post-feedback and speaks `front` on tap. Tests: `test/presentation/fill_mode_session_view_test.dart` DT14.
- ✅ **Hint-taint → SRS downgrade implemented without fake incorrect attempts**: Prompt 08 adds explicit `AttemptGrade.recovered` / `RawStudyResult.recovered`; Prompt 08B makes the CHECK migration version-safe as schema v13 for `study_attempts.result`. SRS review finalization maps recovered-only passes to `ReviewResult.recovered` while keeping the current box and lapse count. `FillModeSessionView` submits `correct` for exact/no-hint, `recovered` for exact/after-hint and Mark-correct override, preserves taint through Try again, and resets taint on new card. Tests: `test/domain/study/attempt_grade_codec_test.dart`, `test/data/datasources/local/app_database_migration_test.dart`, `test/data/repositories/study_repository_test.dart` DT15, and `test/presentation/fill_mode_session_view_test.dart` DT15.

### §3.11 Architecture inconsistency — **P2** (refined evidence 2026-05-28)

Hai vị trí cho domain use cases:

- `lib/domain/usecases/*.dart` — feature-flat (deck, flashcard, folder, content_query, cloud_account, drive_sync, tts).
- `lib/domain/study/usecases/study_usecases.dart` — chỉ study, sub-module style.

→ Reviewer/onboarder phải biết cả hai pattern. Đề xuất chuẩn hoá một trong hai (cleanup doc cho phần này sẽ phụ thuộc refactor code).

### §3.12 CLAUDE.md trigger map references non-existent files — **RESOLVED 2026-05-31 (Prompt 13 docs alignment)**

Earlier project-root `CLAUDE.md` §"Code change → required docs" mapped SRS changes to non-existent target files:

```
| `lib/domain/srs/box_intervals.dart` | `docs/business/srs/srs-review.md` (interval table) |
| `lib/domain/srs/box_transition.dart` | `docs/business/srs/srs-review.md` (transition table) |
```

Cả 2 file đó **không tồn tại** (`find lib/domain -name "box_*"` returns empty). Prompt 13 updated `CLAUDE.md` to point at the real runtime owners:

- `lib/data/repositories/study_repo_impl_mapping_helpers.dart` (`_intervalForBox`) → `docs/business/srs/srs-review.md` interval table.
- `lib/data/repositories/study_repo_impl_helpers.dart` (`_reviewOutcome`) → `docs/business/srs/srs-review.md` transition table.

The canonical interval ladder is still a separate P2 product/docs decision; the trigger-map drift itself is closed.

### §3.13 "Doc target, code inline" anti-pattern — **NEW P2 backlog** (phát hiện 2026-05-28)

Có ít nhất **8 case** doc spec một file riêng nhưng code làm inline trong file lớn / sai layer:

| # | Doc target file | Code thực tế | Layer issue? |
| --- | --- | --- | --- |
| 1 | `lib/domain/srs/box_intervals.dart` | **Resolved as target-only**: runtime owner is `_intervalForBox` in `lib/data/repositories/study_repo_impl_mapping_helpers.dart`; extraction deferred until product/architecture decision | No runtime blocker |
| 2 | `lib/domain/srs/box_transition.dart` | **Resolved as target-only**: runtime owner is `_reviewOutcome` in `lib/data/repositories/study_repo_impl_helpers.dart`; extraction deferred until product/architecture decision | No runtime blocker |
| 3 | `lib/domain/study/flow_validator.dart` | Inline trong `study_strategy.dart` | No |
| 4 | `lib/domain/study/distractor_sampler.dart` | **Resolved 2026-05-31** (Prompt 10B): extracted as `lib/domain/study/guess/guess_option_builder.dart`. `GuessOptionBuilder.build` is the single source for Guess option generation; it samples from the full valid decoy pool before limiting to 4. `guess_mode_session_view.dart` delegates to it directly; the presentation notifier no longer contains Guess sampling helpers. | ✅ Domain (Guess) |
| 5 | `lib/domain/study/option_description_builder.dart` | Inline trong `guess_option_models.dart` (presentation) | **YES — presentation** |
| 6 | `lib/domain/study/strict_matcher.dart` | **Resolved 2026-05-31**: extracted as `lib/domain/study/fill/fill_answer_matcher.dart` (Prompt 06) | ✅ Domain |
| 7 | `lib/domain/study/hint_revealer.dart` | **Resolved 2026-05-31**: extracted as `lib/domain/study/fill/fill_hint_policy.dart` (Prompt 06) | ✅ Domain |
| 8 | `lib/domain/usecases/engagement/record_completion_usecase.dart` | **Missing entirely** | YES (domain layer trống) |

Item 4-7 là Clean Architecture violations (business logic ở presentation). Item 1-3 chỉ là organization (tech debt nhẹ). Item 8 là missing domain.

**Đề xuất backlog**: 1 epic "Extract inline study/SRS logic to domain modules" — chia 8 sub-task.

### §3.14 Target-vs-current file ref convention — **NEW P3** (phát hiện 2026-05-28)

Khi doc đề cập file dự kiến tồn tại (target) vs file đang tồn tại (current), không có convention. Trong cleanup pass đã áp dụng tạm:

```
**Source (target):** future extracted domain helper if approved.
**Source (current):** `_intervalForBox` in `lib/data/repositories/study_repo_impl_mapping_helpers.dart`; canonical ladder still P2 product/docs decision.
```

**Đề xuất**: chuẩn hoá format này vào `docs/contracts/code-style.md` để future docs dùng đồng nhất.

### §3.15 Mock-mapping doc audit — **NEW** (phát hiện 2026-05-28)

`docs/system-design/mock-design-doc-mapping.md` là coordination doc mapping 129 mock variant → wireframe + business spec + contract. Audit dedicated cho doc này:

#### §3.15.1 Findings: internal consistency

| Check | Result | Evidence |
| --- | --- | --- |
| Variant ranges §5 ↔ §6 sub-section match | ✅ | Đếm bằng tay 24 row §5 + cross-ref với 19 sub-section §6.1-6.19 (`25a-25h`=8 = §6.16 8 rows; `17a-17f`=6 = §6.8 6 rows; …). 100% align. |
| Tổng variant count khớp claim "129 rendered screen variants" | ✅ | `grep -c "^\| \`[0-9]"` = 129 đúng claim ở line 42. |
| Tất cả 17 contract docs referenced tồn tại | ✅ | `[ -f ... ]` confirm 17/17. |
| Tất cả 15 business + state + UI-UX docs referenced tồn tại | ✅ | Confirm 15/15. |
| Tất cả 28 preview HTML referenced tồn tại | ✅ | Match `ls preview/` 28 files = 28 §8 rows. |
| Tất cả wireframe paths referenced tồn tại | ✅ | 25 wireframes mapped, all `[ -f ]` confirm. |

→ **No broken refs**. Doc về cấu trúc reference, rất sạch.

#### §3.15.2 Findings: drift / minor issues

| # | Issue | Severity | Recommendation |
| --- | --- | --- | --- |
| 1 | §1 priority list (line 30) ref `docs/architecture/**` (plural) nhưng dir chỉ chứa 1 file `clean-architecture-contract.md`. Globbing pattern hứa nhiều file. | P3 trivial | Đổi sang `docs/architecture/clean-architecture-contract.md` hoặc giữ glob nếu kế hoạch tách thêm files. |
| 2 | §6.1 Recall variants `09a (hidden)` + `09b (revealed)` — **không có variant cho timeout state**. Sau khi Rev 3 documents `Layout — auto-reveal on timeout` ở wireframe 16 với caption "Time's up — grade yourself", mock thiếu variant tương ứng. | P3 | Tuỳ chọn: (a) thêm `09c · Study · Recall (timed out)` variant vào mock + mapping, hoặc (b) note rõ trong mock-mapping §10 rằng timed-out là visual variant của 09b với caption phụ. |
| 3 | ✅ Resolved (Prompt 04, 2026-05-30). Dashboard renders multi-resume: `DashboardResumeSection` shows the primary session + "+N more" link → `showDashboardPausedSessionsSheet` (`dashboard_paused_sessions_sheet.dart`) lists every resumable session. Covered by `test/presentation/dashboard_screen_test.dart` ("multiple paused sessions open the paused-sessions sheet"). | — | Done. |
| 4 | §6.4 Account sync variants `13a-13i` không phân biệt platform (web vs mobile). Sau khi Rev 3 documents `§Platform snapshot gateways` (io / web / stub), mock chưa cover platform-specific UI differences. | P3 (likely intentional) | Nếu UI thực sự identical → note rõ trong mock-mapping. Nếu khác → thêm variants `13a-web`, `13a-mobile` v.v. |
| 5 | §6.18 Study result variant `27f · Study result (tough empty)` — "Empty/tough cards fallback" — "tough" terminology chưa định nghĩa ở glossary hoặc business doc. | P3 | Hoặc rename variant (vd `(no-cards-remaining-fallback)`), hoặc add term vào `docs/business/glossary.md`. |
| 6 | §10 "Missing or weak mock coverage" hiện liệt kê 6 items (study entry gate, shared dialogs catalog, shared bottom sheets catalog, mobile kit README stale, legacy naming, token drift). **KHÔNG bao gồm**: recall timeout variant (#2 above), multi-resume rendering gap (#3), platform-specific sync UI (#4). | P3 | Refresh §10 bổ sung 3 items này. |
| 7 | §7 "Legacy and stale mock references" mentions `HomeScreen`, `LibraryScreen`, `DeckScreen`, `CardsScreen`, `CreateCardScreen`, `BulkAddScreen`, `StatsScreen`. Verify code không còn dùng — `grep` cho thấy code dùng `dashboard_screen`, `library_overview_screen`, `folder_detail_screen`, `flashcard_list_screen`, `flashcard_editor_screen`, `deck_import_screen`, `progress_screen`. → Legacy table CHÍNH XÁC; code naming hiện đại. | ✅ no action | — |
| 8 | Mock variant `28a-28i` Onboarding — 9 variants có nhưng code zero presence (Rev 3 §3.6). Mock-mapping treats là "Current target". OK theo perspective doc-as-truth, nhưng implementer nhìn vào dễ tưởng feature đã có. | P3 | Cross-link với Rev 3 #23 trong mock-mapping §10 — note "Implementation status: missing in code (see Rev 3 §3.6)". |

#### §3.15.3 Findings: chỗ doc xuất sắc (giữ làm reference)

| Item | Giá trị |
| --- | --- |
| §3 "Conflict resolution rule" 8-row priority table | Rõ ràng cho implementer khi mock ↔ wireframe ↔ business ↔ design system mâu thuẫn. Senior BA mẫu mực. |
| §4 "Agent implementation rule" 10-step reading order | Ngăn agent skip context và start từ HTML mock. |
| §12 "Hard implementation bans" 8 rules | Concrete prohibitions (copy raw CSS, JSX structure, etc.). |
| §11 "Recommended implementation checklist per screen" | 10-step process integrated với decision table IDs. |
| §13 "Final leadership position" framing | Cho phép reusing prompt: "Use docs/system-design/mock-design-doc-mapping.md to identify..." → reduce friction cho agent prompts. |

→ Mock-mapping doc về **cấu trúc và process** đã ở mức A+ senior. Drift chỉ ở mức P3 (visual variant gaps cập nhật theo Rev 3 + minor cleanups).

---

## §4. Recommended priority queue (Rev 3)

Items resolved trong cleanup pass đã xoá. Items mới từ §3.12-3.14 thêm.

| Priority | Item | Section | Est. cost |
| --- | --- | --- | --- |
| **P0-1** | Empty-scope matrix branching (10 l10n keys + UI) | §3.7 | M |
| **P0-2** | Bury/Suspend foundation (schema → UC → UI → settings) | §3.1 | XL |
| **P0-3** | Default landing route alignment (`home` vs `library`) | §2 | XS |
| **P1-1** | Streak / Engagement use case + wire `MxStreakCard` + daily-goal | §3.2, #01, #18, #20 | M |
| **P1-2** | ✅ DONE (2026-05-30) Tag domain layer (repo + use cases + validator) + management screen + editor wiring | §3.3, #22 | M |
| **FUT-1** | Card history use case + screen | §3.4, #09 | M |
| **FUT-2** | Full global search screen | §3.5, #11 | M |
| **P1-3** | Thin zero-content onboarding CTAs | §3.6, #23 | S |
| **P1-6** | Long-press wiring sau khi #P0-2 ready | §3.1, #13-17 | S |
| **P1-7** | ✅ DONE (2026-05-31, Prompt 06) Strict matcher + hint reveal policy extracted to domain (`lib/domain/study/fill/`). | §3.10, §3.13 items 6-7, #17 | S |
| **P1-9** | ✅ DONE (2026-05-31, Prompt 08/08B) Fill hint-taint grading channel: `AttemptGrade.recovered` / schema v13 allow hint-tainted exact match and Mark-correct override to finalize as `ReviewResult.recovered` without fake `incorrect` attempts, including migration repair for legacy schema-12 databases. | §3.10, #17 | M |
| **P1-10** | ✅ DONE (2026-05-31, Prompt 07) Fill TTS auto-play disabled enforcement: Fill feedback no longer mounts `StudyAutoSpeakEffect`; wrong feedback does not auto-play with settings `autoPlay=true`; manual `StudySpeakButton` remains post-feedback and speaks `front` on tap. | §3.10, #17 wireframe §TTS, `docs/business/tts/tts-settings.md`, `test/presentation/fill_mode_session_view_test.dart` DT14 | S |
| **P1-8** | Per-card review section in study result | #18 | S |
| **P2-1** | Box-distribution chart on progress | #03 | S |
| **P2-2** | Flashcard create/edit doc merge | #07, #08 | XS |
| **P2-3** | ✅ DONE (2026-05-31, Prompt 14) Lock-mode UI verification on folder: typed `folder_contains_decks` / `folder_contains_subfolders` failures map to localized snackbar copy; stale invalid create paths do not create data and do not show a generic error. | #05 | XS |
| **P2-4** | ✅ DONE (2026-05-31, Prompt 10B) Guess countdown durations verified as named constants (`guessCorrectAdvanceDelay = 800ms`, `guessWrongFeedbackDelay = 1500ms`); option generation promoted to domain `GuessOptionBuilder`; decoys now sample from the full valid pool before limiting; notifier inline sampling removed. | #15, §3.13 item 4 | XS |
| **P2-5** | TTS engine fallback + voice picker verify | #21 | S |
| **P2-6** | **NEW** CLAUDE.md trigger map sửa box_* refs | §3.12 | XS (cần user decision) |
| **P2-7** | **NEW** Extract inline study/SRS logic to domain modules (epic 8 sub-task) | §3.13 | L |
| **P2-8** | Architecture inconsistency (usecase location standardize) | §3.11 | M |
| **P3-1** | Design system widget catalog update (orphan `MxStreakCard` + shared toolbars) | §3.2 | XS |
| **P3-2** | **NEW** Convention doc cho target/current file refs | §3.14 | XS |
| **P3-3** | Wireframe 19 UI flow pass tiếp (sau khi data layer ✅ ở Rev 3) | #19 | S |
| **P3-4** | Wireframe 06 §Rules / §States / §Forbidden pass tiếp | #06 | S |
| **P3-5** | Wireframe 10 decision-table import rows cross-verify | #10 | XS |
| **P3-6** | **NEW** Mock-mapping `docs/architecture/**` glob narrow → `clean-architecture-contract.md` | §3.15.2 #1 | XS |
| **P3-7** | **NEW** Mock-mapping: add recall timed-out variant `09c` hoặc note in §10 | §3.15.2 #2, #16 | XS |
| **P3-8** | **NEW** Mock-mapping: verify multi-resume dashboard UI hoặc mark variant `25h` "specified-not-implemented" | §3.15.2 #3, #01 | S |
| **P3-9** | **NEW** Mock-mapping: confirm/document account-sync UI is platform-agnostic OR split variants | §3.15.2 #4 | XS |
| **P3-10** | **NEW** Mock-mapping: define "tough" in study-result `27f` variant | §3.15.2 #5 | XS |
| **P3-11** | **NEW** Mock-mapping §10 refresh: add 3 missing items from Rev 3 (recall timeout, multi-resume, platform UI) | §3.15.2 #6 | XS |
| **P3-12** | Mock-mapping: mark onboarding mock variants `28a-28i` as Future visual reference, not V1 implementation target | §3.15.2 #8 | XS |

**Removed from Rev 2 priority queue** (đã resolve qua cleanup):

- ~~P2-1 Rev2: Recall timer doc update~~ → §3.9 RESOLVED.
- ~~P2-2 Rev2: Excel import doc update~~ → §3.8 RESOLVED.
- ~~P3-1 Rev2: Wireframe 06 component list catch-up~~ → §1 #06 ✅ (§Components scope).
- ~~P3-2 Rev2: Account-sync platform variants doc~~ → §1 #19 ✅ (gateway scope).
- ~~P3-4 Rev2: Design system widget catalog update (general)~~ → narrowed to orphan-widget cleanup (P3-1 mới).

---

## §5. Lessons learned

### §5.1 What Revision 1 (junior) got wrong (kept from Rev 2)

| Rev 1 claim | Sự thật | Vì sao sai |
| --- | --- | --- |
| "Match mode DRIFT: code 4 pairs → 5" | Code đã 5; doc lag | Không grep code, đoán theo timing doc edit |
| "Guess mode DRIFT: code 4 options → 5" | Code đã 5; doc lag | Cùng lý do |
| "Dashboard MATCH" | Streak missing entirely; widget orphan | Chỉ check screen file, không trace state shape |
| "Tag management MATCH" | Domain layer trống | Dừng ở presentation |
| "Recall MATCH" | Code có timer; doc không spec | Không đọc code bên trong widget |
| "Deck import MATCH" | Code support Excel; doc chỉ CSV/TSV | Chỉ list file names, không inspect parser |
| "Study entry MATCH" | 10 empty cases vs 1 generic exception | Không cross-check decision table |
| "Bury/Suspend MISSING" | ✅ Đúng | Điểm Rev 1 đúng |
| Priority P0 chứa "Match 4→5 code update" | Item không tồn tại | Sai chiều drift → sai ưu tiên |

### §5.2 What Revision 2 (senior, my own previous work) missed

Tôi (senior) cũng có blind-spot. Honest disclosure:

| Rev 2 claim | Sự thật phát hiện sau pass cleanup | Vì sao bỏ sót |
| --- | --- | --- |
| "#02 Library `mx_search_sort_toolbar` not in doc (C>D nhỏ)" | Toolbar thuộc **folder-detail** (#05), không phải library overview (#02). Library overview dùng inline `MxSearchField`. | Tôi grep "MxSearchSortToolbar" rồi assume nó dùng ở library overview vì naming "library_toolbar_state" tương đối trùng. Lesson: bám đúng call-site, đừng infer từ tên provider/widget. |
| "#10 Code support Excel xlsx, doc chỉ mention CSV/TSV" | Doc 10 ĐÃ mention Excel + format radio + header toggle. Drift thực tế là **Implementation refs stale paths**, không phải spec gap. | Tôi đọc lướt §Forbidden + §Implementation refs nhưng skip §Components + §Layout — nơi Excel ĐÃ được liệt kê. Lesson: đừng audit từ "section nóng nhất"; quét toàn bộ wireframe. |
| Chưa phát hiện CLAUDE.md trigger map ref non-existent files | Đây là drift cấp meta, đáng lẽ phải catch khi quét stale refs về `box_*`. | Rev 2 chỉ scope wireframes/business/contracts; chưa quét CLAUDE.md/AGENTS.md cấp meta. Lesson: meta-doc cũng có thể drift; thêm vào scope sweep. |
| "#19 Code có 3 variants (io/web/stub), doc không nhắc" | Business doc account-sync.md DID list 1 dòng `lib/data/sync/local_database_snapshot_gateway*.dart (DB snapshot read/write, io/web/stub)`. Drift thực tế: doc list file paths, không giải thích **behavior** per platform. | Tôi grep "platform" + "Wasm" trong doc, không match. Nhưng dòng "io/web/stub" có ở source-files list. Lesson: search by ALL terms doc có thể dùng, không chỉ canonical term. |
| Không tách bạch giữa "doc edit" vs "code change" trong P-queue Rev 2 | Một số items chỉ cần doc update (giờ đã làm) chen lẫn items cần code work. | Lesson: tag mỗi item bằng `[doc-only]` hoặc `[code]` để planning rõ. |

### §5.3 Bài học methodology cập nhật

1. **"File exists" ≠ "feature works"** (giữ từ Rev 2).
2. **Audit chiều DRIFT trước khi assume direction** — grep code constant trước, đừng nhìn doc timestamp.
3. **Quét cả meta-doc (CLAUDE.md, AGENTS.md, index.md)**, không chỉ feature docs.
4. **Đọc HẾT wireframe sections trước khi claim missing**, không skip nội dung "nguội".
5. **Tag P-queue items với `[doc-only]` vs `[code]`** để planning chuẩn.
6. **Recursive review sau mỗi pass** — chạy lại grep cho tất cả stale pattern đã sửa.
7. **Phạm vi "verified" phải explicit** — `=` (match) cell phải nói rõ aspect nào đã verify.

---

## §6. Quy trình parity định kỳ (refined Rev 3)

1. **Mỗi PR thay đổi `lib/presentation/features/**/screens/*.dart`**: reviewer mở wireframe tương ứng và verify §Components, §States, §Actions, §Forbidden — không chỉ visual diff.
2. **Mỗi PR thay đổi business doc / wireframe**: reviewer mở "Source files to inspect" trong doc và xác nhận code align.
3. **Mỗi PR thêm shared widget**: update `docs/system-design/MemoX Design System/README.md` cùng commit. Áp dụng Hard Rule "doc-code parity" theo cả chiều C>D.
4. **Mỗi PR refactor consolidates files** (kiểu này gây ra §3.13 anti-pattern): chạy `grep -rn "<deleted_filename>" docs/` trước commit; nếu match > 0, fix doc trong cùng commit.
5. **Sprint review**: re-run §1 + §3 cho row không phải `=`; xác nhận status không thoái lui.
6. **Trước release**: P0/P1 phải về 0 hoặc có exception note đã được product owner ký.
7. **Sau cleanup pass**: tạo log doc dạng `docs/checklist/<topic>-cleanup-<date>.md` (mẫu: cleanup ngày hôm nay) để track lineage giữa các revision.

---

## §7. Methodology limitations (refined Rev 3)

- **KHÔNG chạy** `flutter analyze` / `flutter test` để verify runtime behavior. Một số "có vẻ implement" có thể fail runtime.
- **KHÔNG đọc 100%** từng widget file — inspect đủ để confirm/exclude feature. `[Pending]` cells trong §1 cần follow-up khi đụng task.
- **KHÔNG check `*.g.dart`** generated files — assume build_runner output đồng bộ.
- **KHÔNG audit l10n keys** một-một — chỉ check vài key tiêu biểu.
- **KHÔNG audit accessibility** / responsive layouts — track riêng cho specialist.
- **Rev 3 mới**: KHÔNG full re-audit toàn bộ wireframe sections sau khi cleanup; chỉ aspect liên quan trực tiếp tới C>D items đã verify. `[Pending]` markers trong §1 là honest disclosure phạm vi đã làm.

---

## §8. Resolution log Rev 2 → Rev 3

| Rev 2 item | Action | Where |
| --- | --- | --- |
| §3.8 Excel import C>D | RESOLVED — doc updated | [10-deck-import.md](docs/wireframes/10-deck-import.md), [c-greater-than-d-cleanup-2026-05-28.md](docs/checklist/c-greater-than-d-cleanup-2026-05-28.md) §1 row #2 |
| §3.9 Recall timer C>D | RESOLVED — doc updated | [16-study-session-recall.md](docs/wireframes/16-study-session-recall.md) §Layout/Components/States/Rules, [cleanup log](docs/checklist/c-greater-than-d-cleanup-2026-05-28.md) §1 row #1 |
| #02 Library toolbar C>D (small) | RECLASSIFIED — issue actually at #05 | [05-folder-detail.md](docs/wireframes/05-folder-detail.md) §Components |
| #06 Flashcard list C>D (sections) | PARTIALLY RESOLVED — §Components scope | [06-flashcard-list.md](docs/wireframes/06-flashcard-list.md) §Components 13-row table |
| #19 Account sync C>D (platform variants) | PARTIALLY RESOLVED — gateway data-layer scope | [account-sync.md](docs/business/account-sync/account-sync.md) §Platform snapshot gateways |
| §3.11 Architecture inconsistency P2 | REFINED — same severity, better evidence | §3.11 above |
| Stale code paths in 13/14/15/16/17 wireframes (grade_attempt_usecase.dart etc.) | RESOLVED — all 5 wireframes refreshed §Code paths | Cleanup log §1 rows #6-9 |
| Stale code paths in 12/18 wireframes + business/study + resume + srs + contracts/srs + contracts/study | RESOLVED — 7 additional files refreshed | Cleanup log §1 rows #10-16 |
| (NEW) §3.12 CLAUDE.md trigger map drift | DISCOVERED — pending user decision | This doc §3.12 |
| (NEW) §3.13 "Doc target, code inline" anti-pattern 8 items | DISCOVERED — backlog item P2-7 | This doc §3.13 |
| (NEW) §3.14 Target/current ref convention | DISCOVERED — backlog item P3-2 | This doc §3.14 |
| (NEW) §3.15 Mock-mapping doc audit | COMPLETED — 6 P3 findings; 100% file refs verified; structure A+ | This doc §3.15 + P3-6 through P3-12 |

---

## §9. Re-audit triggers

Re-run audit thành Rev 4 khi gặp một trong:

1. **Merge một epic P0/P1** ở §4 → re-audit rows liên quan + cross-cutting section đó.
2. **Sau 4 tuần** kể từ `last_updated` ở header.
3. **Khi phát hiện drift cấp meta-doc mới** (như §3.12) — re-audit immediate.
4. **Khi Future Proposal được promote** (Card History, Global Search, full Onboarding) — re-tag #09/#11/#23 status and update the scope guard.
5. **Sau khi epic P2-7** (extract inline logic) hoàn thành — re-audit §3.13 + #15/#17.

---

## §10. Document lineage

- Rev 1 → deprecated (junior, removed history but referenced in §5.1).
- Rev 2 → replaced (commit `<TBD by VCS>`); 1 file edit history available via `git log`.
- Rev 3 → **CURRENT**; companion: [c-greater-than-d-cleanup-2026-05-28.md](docs/checklist/c-greater-than-d-cleanup-2026-05-28.md).

---

## §11. Self-review checklist (Rev 3 internal QA)

Senior tech-lead audit của chính Rev 3 doc này:

| Tiêu chí | Status | Ghi chú |
| --- | --- | --- |
| Mọi resolved item của Rev 2 cleanup được explicit log ở §8 | ✅ | §8 list 9 mục, ref tới cleanup log + cụ thể file. |
| Mọi new finding (§3.12-3.14) có evidence file:line | ✅ | §3.12 quote chính xác 2 dòng trigger map; §3.13 list 8 items với cặp doc-target ↔ code-actual; §3.14 motivation từ pattern recurring. |
| Status distribution §1.1 đếm khớp số row thực | ✅ | Verified bằng `awk + grep`: 7+9+6+3=25 ✓. Đã sửa sai số ban đầu (8/11/3/3) → đúng (7/9/6/3). |
| Phạm vi "verified" mark được rõ ràng cell-by-cell | ✅ | 28 occurrences của `[Verified 2026-05-28]` hoặc `[Pending]` trong §1. |
| Lessons learned không che giấu sai sót Rev 2 chính tôi | ✅ | §5.2 disclose 5 items Rev 2 missed. |
| P-queue Rev 3 không trùng lặp với items đã resolve | ✅ | §4 "Removed from Rev 2 priority queue" list tường minh; new P2-6/P2-7/P3-2 cross-link §3.12-3.14. |
| Cross-cutting §3.8/§3.9 marked RESOLVED, không pretend còn open | ✅ | Cả hai có "✅ RESOLVED 2026-05-28" + link tới cleanup log. |
| `last_updated` header reflects today | ✅ | `2026-05-28`. |
| Document lineage có thể trace ngược | ✅ | §10 list Rev 1 → 2 → 3 với references. |
| Hard Rule không bị vi phạm (path convention, etc.) | ✅ | Backtick refs đều dạng `docs/...` no leading slash; markdown links dùng đúng format. |
| Bias check: có over-claim "match" không? | ✅ | Mỗi ✅ ở §1 đều kèm `(§X scope)` hoặc `[Verified 2026-05-28]` + `[Pending]` riêng cho aspect chưa kiểm. Không over-claim. |
| Backwards-compat: reader của Rev 2 hiểu Rev 3 không? | ✅ | §0 đầu doc explain lifecycle Rev 1/2/3; §8 resolution log; §5 lessons learned vẫn giữ context Rev 1+2. |
| **Audit mock-mapping doc với same rigor** | ✅ | §3.15 added — 100% file refs verified (17 contracts + 15 docs + 28 preview HTML + 25 wireframes); variant count (129) cross-verified với §5↔§6; 6 P3 findings extracted; structure-quality observations recorded. |

**Self-grade**: **9.4/10**. Trừ điểm:

- §1.1 numerical error caught chỉ bởi recursive sweep (đáng lẽ tôi nên đếm thủ công trước khi viết). Lesson: bất kỳ số count nào trong audit phải có command verify đi kèm.
- §3.13 item 6 ("strict matcher inline trong `fill_actions.dart`") suy luận từ phạm vi review trước, chưa grep file để chắc chắn nội dung. `[Pending verify by file content]` nên thêm vào row đó nếu chặt.
- §10 document lineage còn placeholder `<TBD by VCS>` cho Rev 2 commit hash — sẽ resolve sau khi commit.
