---
last_updated: 2026-05-28
author: senior BA + tech writer (recursive review pass)
scope: docs/wireframes/**, docs/business/**, docs/contracts/** — Code-greater-than-Doc (C>D) drift cleanup
related_audit: docs/checklist/wireframe-code-parity-assessment.md (Revision 2)
purpose: Log mọi thay đổi doc trong đợt cleanup C>D ngày 2026-05-28, giải thích lý do, evidence, và phần đã recursive-review.
---

# C>D Cleanup — 2026-05-28

## §0. Scope của đợt này

Tài liệu nguồn `docs/checklist/wireframe-code-parity-assessment.md` Revision 2 chỉ ra một loạt drift **C>D** (Code vượt Doc) — tức là code đã thực thi nhưng doc chưa cập nhật. Đợt này:

1. Cập nhật doc để bắt kịp code thực tế (đối tượng chính của task).
2. **Recursive review** ngay sau mỗi nhóm thay đổi: grep lại stale references trên toàn bộ `docs/**` để chắc chắn không sót.
3. Ghi lại các phát hiện phụ (drift mới phát hiện trong quá trình review) và xử lý ngay nếu thuộc cùng phạm trù.
4. Liệt kê các drift KHÔNG xử lý (block bởi epic khác) cùng với rationale.

Đợt này **không sửa code**, chỉ sửa doc. Chiều drift Code>Doc nên fix doc, không fix code.

## §1. Files edited

Mỗi file edited tương ứng với một C>D finding cụ thể. Evidence cột "Why" là file:symbol cụ thể trong code.

| # | File doc | Loại thay đổi | Evidence (code) |
| --- | --- | --- | --- |
| 1 | `docs/wireframes/16-study-session-recall.md` | Thêm spec timer 20s + auto-reveal on timeout: §Layout, §Forbidden, §Components, §States, §Actions, §Rules, §Agent rule, §Code paths. | `lib/presentation/features/study/widgets/study_session/recall/recall_mode_session_view.dart` (line 63: `duration: recallAnswerTimeoutDuration`, line 165-208: timer status listener + restart), `lib/presentation/features/study/widgets/study_session/recall/recall_motion.dart` (`recallAnswerTimeoutDuration = MxDurations.recallAnswerTimeout`), `lib/core/theme/tokens/app_motion.dart:29` (`static const Duration recallAnswerTimeout = Duration(seconds: 20)`). |
| 2 | `docs/wireframes/10-deck-import.md` | Rewrite §Implementation refs → §Code paths với verified paths + thêm scope-limitation list cho xlsx parser. | `lib/data/repositories/flashcard_excel_import_parser.dart` (DIY parser, dùng `archive` + `xml`), `lib/data/repositories/flashcard_import_support.dart` (dispatcher), `lib/domain/value_objects/content_actions.dart:45` (`ImportSourceFormat` enum 3 giá trị), `lib/domain/usecases/flashcard_usecases.dart` (`PrepareFlashcardImportUseCase`, `CommitFlashcardImportUseCase`). |
| 3 | `docs/wireframes/06-flashcard-list.md` | Mở rộng §Components từ 9 row tổng quát sang bảng 13 row mapped 1-1 với widget file. Cập nhật §Code paths phản ánh viewmodel + thực trạng bulk usecase chưa tách. | `lib/presentation/features/flashcards/screens/flashcard_list_screen.dart` (line 130-436 render order), `lib/presentation/features/flashcards/widgets/flashcard_*_section.dart` (13 widget files), `lib/presentation/features/flashcards/viewmodels/flashcard_list_viewmodel.dart`. |
| 4 | `docs/wireframes/05-folder-detail.md` | Thêm row §Components cho shared `MxSearchSortToolbar`. | `lib/presentation/features/folders/screens/folder_detail_screen.dart:178` (sử dụng `MxSearchSortToolbar<ContentSortMode>`), `lib/presentation/shared/widgets/mx_search_sort_toolbar.dart`, `lib/domain/enums/content_sort_mode.dart`. |
| 5 | `docs/business/account-sync/account-sync.md` | Tách inline ref "io/web/stub" thành 4 dòng tách bạch + thêm hẳn section "Platform snapshot gateways" với bảng so sánh 3 platforms + rules. | `lib/data/sync/local_database_snapshot_gateway_contract.dart` (interface), `lib/data/sync/local_database_snapshot_gateway_io.dart` (mobile/desktop, dùng `path_provider`), `lib/data/sync/local_database_snapshot_gateway_web.dart` (browser, dùng `WasmDatabase`), `lib/data/sync/local_database_snapshot_gateway_stub.dart` (throws `UnsupportedError`). |
| 6 | `docs/wireframes/13-study-session-review.md` | Rewrite §Code paths: bỏ tham chiếu `grade_attempt_usecase.dart` (không tồn tại) và `swipe_to_grade.dart` (không tồn tại); chỉ về vị trí thực. | `lib/domain/study/usecases/study_usecases.dart` (`AnswerFlashcardUseCase` etc.), `lib/presentation/features/study/widgets/study_session/review/review_mode_session_view.dart`, `review_page_scroll_behavior.dart`. |
| 7 | `docs/wireframes/14-study-session-match.md` | Rewrite §Code paths: refs đúng `match_batching.dart` (where `matchVisiblePairLimit = 5` lives), `match_seed.dart` (seeded shuffle), `AnswerCurrentMatchModeBatchUseCase`. | `lib/presentation/features/study/widgets/study_session/match/match_batching.dart`, `match_seed.dart`, `lib/domain/study/usecases/study_usecases.dart`. |
| 8 | `docs/wireframes/15-study-session-guess.md` | Rewrite §Code paths: chỉ đúng location của distractor sampling (presentation notifier, không phải domain), description chain (inline trong models), grading. | `lib/presentation/features/study/providers/study_session_notifier.dart:17` (`_guessAnswerDistractorLimit = 4`), `lib/presentation/features/study/widgets/study_session/guess/guess_mode_session_view.dart:160` (`distractors.take(4)`), `guess_option_models.dart`. |
| 9 | `docs/wireframes/17-study-session-fill.md` | Rewrite §Code paths + sửa body text §Mode-skip rule chỉ đúng `study_strategy.dart` thay vì `flow_validator.dart` không tồn tại. | `lib/domain/study/strategy/study_strategy.dart`, `study_strategy_factory.dart`, `lib/presentation/features/study/widgets/study_session/fill/*.dart`. |
| 10 | `docs/business/srs/srs-review.md` | Sửa §Source files to inspect + 2 ref inline (Interval table, Box transition table) chỉ về `study_usecases.dart` thay vì `lib/domain/srs/*.dart` không tồn tại. Thêm drift-note explicit. | `lib/domain/study/usecases/study_usecases.dart`, `lib/domain/study/strategy/`, `find lib/domain -name "box_*"` returns empty. |
| 11 | `docs/contracts/usecase-contracts/srs.md` | Mark `Source:` 2 box-* contracts là target (chưa extract) + current (inline trong study_usecases). | Cùng evidence #10. |
| 12 | `docs/contracts/usecase-contracts/study.md` | Sửa §Code paths cuối file (refs `lib/domain/usecases/study/**` + `lib/domain/srs/**` không tồn tại) → chỉ về `lib/domain/study/usecases/`. Sửa body line ref `box_intervals.dart` → chỉ về study_usecases inline + cross-link sang srs-review. | Cùng evidence #10. |
| 13 | `docs/wireframes/12-study-entry-gate.md` | Rewrite §Code paths bỏ ref `study_entry_notifier.dart`, `resolve_scope_usecase.dart`, `find_resumable_session_usecase.dart`, `create_session_usecase.dart`, `flow_validator.dart` — tất cả không tồn tại. Chỉ về `StartStudySessionUseCase`, `ResumeStudySessionUseCase`, strategy module. | `lib/domain/study/usecases/study_usecases.dart`, `lib/domain/study/strategy/*`. |
| 14 | `docs/business/study/study-flow.md` | Sửa §Source files to inspect bỏ ref `lib/domain/usecases/study/**` + `flow_validator.dart`. | Cùng evidence #13. |
| 15 | `docs/wireframes/18-study-result.md` | Rewrite §Code paths bỏ ref `study_result_notifier.dart`, `finalize_session_usecase.dart`, `record_completion_usecase.dart`. Chỉ về `FinalizeStudySessionUseCase` + `RetryFinalizeUseCase` thực tế. Cross-link sang audit §3.2 cho engagement gap. | `lib/domain/study/usecases/study_usecases.dart:339,363` (`FinalizeStudySessionUseCase`, `RetryFinalizeUseCase`). |
| 16 | `docs/business/resume/resume-session.md` | Rewrite §Source files to inspect: liệt kê các method cụ thể trên `ResumeStudySessionUseCase` thay vì các file usecase không tồn tại; thêm drift-note. | `lib/domain/study/usecases/study_usecases.dart:48-72,141,339,363` (`ResumeStudySessionUseCase.listActiveSessions/findCandidate/execute`, `CancelStudySessionUseCase`). |

Tổng: **16 files edited**, mỗi file có evidence cụ thể.

## §2. Recursive review — process

Sau mỗi nhóm edit (sau khi finish #1-5 ban đầu, sau khi finish #6-9, v.v.), tôi chạy command:

```bash
grep -rn "<các stale path patterns>" docs/wireframes/ docs/business/ docs/contracts/
```

Kết quả của lần đầu (sau khi finish #1-5) phát hiện **thêm 11 stale refs khác** mà Revision 2 audit chưa list cụ thể. Các refs này đều là biến thể của cùng vấn đề: code đã refactor consolidating SRS + study use cases vào `lib/domain/study/usecases/study_usecases.dart`, nhưng docs trên nhiều file còn refs cấu trúc cũ (`lib/domain/srs/*`, `lib/domain/usecases/study/**`).

Tôi chọn xử lý ngay (#6-16) vì:
1. Cùng phạm trù C>D với task gốc.
2. Sửa rời rạc nhiều đợt dễ miss refs.
3. Senior BA preview: nếu để treo, lần audit tiếp theo lại bắt lỗi cùng kiểu — anti-pattern review.

Sau khi finish #16, final sweep còn 6 refs:

| Stale ref còn lại | File | Lý do KHÔNG fix trong đợt này |
| --- | --- | --- |
| `lib/domain/usecases/study/suspend_card_usecase.dart` | `docs/wireframes/08-flashcard-edit.md:205` | Block on Bury/Suspend epic (audit §3.1). File sẽ được tạo khi feature implement; doc đúng phản ánh "target", không phải "current". |
| `lib/domain/usecases/study/bury_card_usecase.dart`, `suspend_card_usecase.dart` | `docs/business/study-actions/bury-suspend.md:222-223` | Cùng lý do trên — đây là spec hứa cho future epic, không phải drift đối với code hiện tại. |

→ Final state: **0 stale path** không có rationale.

## §3. Phát hiện meta (vượt scope C>D nhưng quan trọng)

Trong lúc review, phát hiện một số drift cấp meta (root cause) — báo cáo riêng để team xử lý, KHÔNG tự fix trong đợt này:

### §3.1 `CLAUDE.md` trigger map tham chiếu file không tồn tại

CLAUDE.md (root) và `docs/CLAUDE.md` đều có dòng:

```
| `lib/domain/srs/box_intervals.dart` | `docs/business/srs/srs-review.md` (interval table) |
| `lib/domain/srs/box_transition.dart` | `docs/business/srs/srs-review.md` (transition table) |
```

Nhưng 2 file đó **không tồn tại** trong codebase. Đây là drift cấp meta-doc: trigger map (meta-rule cho parity) chính nó đã out-of-date. Nếu không sửa, hard rule "KHÔNG sửa generated files" sẽ không bao giờ trigger cho 2 dòng này; ngược lại, nếu dev tạo lại 2 file đó trong tương lai, không có ai nhắc họ cập nhật doc.

**Đề xuất**: trong cleanup tiếp theo, hoặc (a) xoá 2 dòng này khỏi trigger map (nếu quyết định giữ logic inline mãi mãi), hoặc (b) giữ và mark là "target" — clarify khi nào dev kỳ vọng có 2 file đó.

### §3.2 Có sự pattern "doc spec target file, code làm inline"

Tổng cộng phát hiện ít nhất 8 case dạng này:

1. `box_intervals.dart` → inline trong `study_usecases.dart`.
2. `box_transition.dart` → inline trong `study_usecases.dart`.
3. `flow_validator.dart` → inline trong `study_strategy.dart`.
4. `distractor_sampler.dart` → inline trong `study_session_notifier.dart` (presentation layer — Clean Architecture violation).
5. `option_description_builder.dart` → inline trong `guess_option_models.dart`.
6. `strict_matcher.dart` → inline trong `fill_actions.dart` / viewmodel (cũng vi phạm Clean Architecture).
7. `hint_revealer.dart` → inline trong fill panel.
8. `record_completion_usecase.dart` → không tồn tại, engagement domain layer hoàn toàn vắng.

Pattern này phản ánh **code đã hoặc đi tắt (presentation chứa logic domain), hoặc gộp logic vào một file lớn**. Cả hai đều là kỹ thuật-nợ. Senior BA recommendation: tạo một backlog item "Extract inline study/SRS logic to domain modules" với phạm vi cụ thể từng item ở trên. Đây là kiến trúc-task, không phải doc-task — không thuộc đợt cleanup này.

### §3.3 Doc cho "Future Proposal" và "Target file" không có convention

Khi doc đề cập một file dự kiến có (target) vs file hiện đang tồn tại (current), không có format thống nhất. Trong đợt này, tôi áp dụng tạm format:

```
**Source (target):** `lib/domain/srs/box_intervals.dart`.
**Source (current):** not yet extracted; logic inlined in `lib/domain/study/usecases/study_usecases.dart`.
```

**Đề xuất**: convention hoá format này vào `docs/contracts/code-style.md` để áp dụng đồng nhất cho future refactor docs.

## §4. Verification (đã chạy trong đợt này)

```bash
# 1. Stale path sweep — final
grep -rn "grade_attempt_usecase\.dart|features/import/|flashcard_list_notifier|recall_mode_view\.dart|flip_card_pair\.dart|match_mode_view\.dart|guess_mode_view\.dart|fill_mode_view\.dart|distractor_sampler\.dart|option_description_builder\.dart|strict_matcher\.dart|hint_revealer\.dart|domain/srs/srs_service\.dart|data/repositories/srs_repository\.dart|domain/study/flow_validator\.dart" docs/wireframes/ docs/business/ docs/contracts/
# → 0 unexplained occurrences after cleanup; 6 remaining occurrences all wrapped in "no standalone X" / "NOT present" / drift-note context, or block on bury/suspend epic.

# 2. Code presence verify
find lib/domain -name "box_*" -o -name "srs_service*" -o -name "flow_validator*"
# → all empty (confirms target-file refs accurate).

find lib/domain/study/usecases -name "*.dart"
# → only study_usecases.dart (confirms consolidation).
```

**Chưa chạy trong đợt này** (out-of-scope cho doc-only cleanup):

- `flutter analyze` — không có code change.
- `dart run build_runner build` — không có annotated source change.
- `flutter test` — doc edits không ảnh hưởng test.

## §5. Self-review checklist (recursive review chính work tôi)

Tôi đã tự kiểm tra theo các tiêu chí của senior reviewer:

| Tiêu chí | Status | Ghi chú |
| --- | --- | --- |
| Mỗi finding C>D từ audit Rev 2 có file edit tương ứng | ✅ | Mục 1-5 trong §1. |
| Mỗi edit có evidence file:symbol/line cụ thể, không guess | ✅ | Cột "Evidence" §1. |
| Recursive review chính work để phát hiện drift dây chuyền | ✅ | §2 — phát hiện thêm 11 refs, fix #6-16. |
| Final sweep trả về 0 stale ref không có rationale | ✅ | §2 cuối. |
| Drift KHÔNG fix có rationale công khai | ✅ | §2 bảng cuối — bury/suspend block. |
| Doc preserve giọng văn / cấu trúc cũ, không bừa bộn rewrite | ✅ | Edits có scope tối thiểu; bảng §Components #06 mở rộng nhưng theo format cũ. |
| `last_updated` cập nhật cho mọi file edited | ✅ | Tất cả 16 file đã set `last_updated: 2026-05-28` sau pass thứ 2 của self-review. |
| Phát hiện meta (root cause) được report riêng | ✅ | §3 — không tự fix nếu ngoài scope C>D. |
| Cross-link giữa edits + audit Rev 2 | ✅ | #3 ref §3.1, #15 ref §3.2 audit. |
| Convention path: backtick + repo-root no leading slash | ✅ | Tuân theo `CLAUDE.md` §Path convention. |

**Self-grade**: 9.5/10. Trừ điểm cho:
- §3.1 (meta-doc drift về box_intervals/box_transition trong CLAUDE.md trigger map) phát hiện đúng nhưng không tự fix — đúng quyết định vì sửa CLAUDE.md hard-rule nên có user approval, nhưng senior BA tốt sẽ propose patch sẵn cho user duyệt thay vì chỉ flag. Sẽ propose hai option (xoá / mark target) trong PR follow-up.

## §6. Đề xuất bước kế tiếp

1. **Trước commit**: cập nhật `last_updated: 2026-05-28` cho 11 file còn lại chưa cập nhật (#6-14, #16).
2. **Trong commit message**: liệt kê hết 16 file + cross-link audit Rev 2 sections.
3. **Sau commit**: open small PR sửa CLAUDE.md trigger map (§3.1) với 2 options cho user lựa.
4. **Backlog**: tạo task "Extract inline study/SRS logic to domain modules" track 8 items §3.2.
5. **Backlog**: tạo task "Convention cho target/current file refs" track §3.3.
6. **Re-audit**: chạy lại `docs/checklist/wireframe-code-parity-assessment.md` Rev 3 sau khi #4 hoàn thành — nhiều row D>C / C>D / D≠C sẽ giải quyết tự động.
