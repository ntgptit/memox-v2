---
last_updated: 2026-05-29
author: technical lead
status: implementation plan (pre-sprint)
related_audit: docs/checklist/wireframe-code-parity-assessment.md (Rev 3) §3.7 + #12
parent_priority: P0-1
purpose: Decompose empty-scope matrix (10 cases) thành 3 tier theo dependency, sẵn sàng sprint planning. Surface mới drift "tag entry type missing".
---

# P0-1 Empty-scope matrix — Implementation Plan

## §1. Context

`docs/business/study/study-flow.md` §Empty scope matrix spec **10 cases** với 10 l10n key prefixes. Code hiện chỉ throw **1 generic `ValidationException`** tại `lib/domain/study/usecases/study_usecases.dart:33-37`:

```dart
final batch = await strategy.loadBatch(context, _repository);
if (batch.isEmpty) {
  throw const ValidationException(
    message: 'No eligible flashcards are available for this study session.',
  );
}
```

UI hiển thị message này qua `studyErrorMessage()` (`study_session_notifier.dart:153`) bằng `MxErrorState` widget — user sẽ thấy **cùng 1 message generic** cho mọi empty-scope case, vi phạm doc rule "Rejection MUST NOT be a generic toast or error dialog. Always render dedicated empty state with actionable CTA where possible".

## §2. Drift mới phát hiện trong research

| Drift | Severity | Evidence |
| --- | --- | --- |
| **`StudyEntryType` enum thiếu `tag`** | P0 cascading | `lib/domain/enums/study_enums.dart:10-18` chỉ có `deck/folder/today`. Nhưng `study-flow.md:26` spec `tag` là entry type, và empty-scope matrix có 2 rows cho tag (`studyEmpty_tag_noCards`, `studyEmpty_tag_noDueCards`). |
| **L10n keys 100% MISSING** | P0 | `grep "studyEmpty_" lib/l10n/*.arb` = 0 match cho cả 10 keys spec'd. Chỉ có `studyEmptyAnswerMessage` (unrelated — fill mode empty input). |

→ Engineering effort thực tế lớn hơn ước tính "M" ban đầu. Cần re-scope.

## §3. Decomposition theo dependency tier

| Tier | Cases | Block on | Effort | Có thể start ngay? |
| --- | --- | --- | --- | --- |
| **Tier 1 — Independent** | `deck_noCards` (covers both `new` + `srs_review`), `deck_noDueCards`, `folder_noCards`, `folder_noDueCards`, `today_allDone`, `today_noContent` | None | **S** (~3 days) | ✅ YES |
| **Tier 2 — Tag entry type** | `tag_noCards`, `tag_noDueCards` | Add `tag` to `StudyEntryType` enum + tag-scoped query path + tag picker UI | **M** (~1 sprint) | ⚠ Need domain change first |
| **Tier 3 — Bury/Suspend** | `allBuried`, `allSuspended` | P0-2 Bury/Suspend epic foundation (XL, separate epic) | XS (after epic) | 🔴 Block on P0-2 |

**Tổng effort phân bổ**: S + M + (XS within P0-2) = **~1.5 sprints** (vs ban đầu ước M = ~1-2 sprints monolithic). Tier 1 ship được trong sprint hiện tại; Tier 2 + 3 ship sau khi unblock.

## §4. Tier 1 detailed plan (do được ngay)

### §4.1 Domain layer

Thay 1 generic `ValidationException` bằng **typed Failure** chứa enum identifying empty-scope case:

```dart
// lib/domain/study/entities/empty_scope_reason.dart (NEW FILE)
enum EmptyScopeReason {
  deckNoCards,
  deckNoDueCards,
  folderNoCards,
  folderNoDueCards,
  todayAllDone,
  todayNoContent,
  // Tier 2: tagNoCards, tagNoDueCards (defer)
  // Tier 3: allBuried, allSuspended (defer)
}

class EmptyScopeFailure extends AppFailure {
  final EmptyScopeReason reason;
  final DateTime? nextDueAt; // for *_noDueCards cases
  const EmptyScopeFailure(this.reason, {this.nextDueAt});
}
```

Modify `StartStudySessionUseCase.execute()`:

1. Before calling `strategy.loadBatch`, branch on `context.entryType + context.studyType`.
2. Query repository for each tier-1 case condition.
3. Throw `EmptyScopeFailure(reason: <specific>)` instead of generic `ValidationException`.

Need 2 new repo methods:

- `StudyRepo.queryNextDueAt(StudyContext context)` → `DateTime?` (cho *_noDueCards relative time)
- `StudyRepo.hasAnyFlashcard()` → `bool` (cho `todayNoContent` discrimination)

### §4.2 L10n keys cần add vào `app_en.arb` + `app_vi.arb`

| Key | EN copy | VI copy |
| --- | --- | --- |
| `studyEmpty_deck_noCards_title` | "No flashcards in this deck" | "Bộ này chưa có thẻ nào" |
| `studyEmpty_deck_noCards_cta` | "Add flashcards" | "Thêm thẻ" |
| `studyEmpty_deck_noDueCards_title` | "All caught up" | "Đã ôn hết hôm nay" |
| `studyEmpty_deck_noDueCards_subtitle` | "Next due in {relativeTime}." | "Hạn ôn tiếp theo: {relativeTime}." |
| `studyEmpty_deck_noDueCards_cta` | "Study new instead" | "Học bài mới" |
| `studyEmpty_folder_noCards_title` | "No cards in this folder" | "Thư mục này chưa có thẻ" |
| `studyEmpty_folder_noCards_cta` | "Add a deck" | "Thêm bộ thẻ" |
| `studyEmpty_folder_noDueCards_title` | "All caught up for this folder" | "Thư mục này đã ôn xong" |
| `studyEmpty_folder_noDueCards_subtitle` | "Next due in {relativeTime}." | "Hạn ôn tiếp theo: {relativeTime}." |
| `studyEmpty_folder_noDueCards_cta` | "Study new instead" | "Học bài mới" |
| `studyEmpty_today_allDone_title` | "All done for today!" | "Đã ôn xong hôm nay!" |
| `studyEmpty_today_allDone_message` | "Great work. Check back tomorrow." | "Tuyệt vời. Hẹn gặp lại ngày mai." |
| `studyEmpty_today_noContent_title` | "You haven't created any flashcards yet." | "Bạn chưa tạo thẻ nào." |
| `studyEmpty_today_noContent_cta` | "Create your first deck" | "Tạo bộ thẻ đầu tiên" |

Tổng = **14 keys × 2 locales = 28 string entries**. Copy phải cross-check `docs/ui-ux/l10n-copy-contract.md`.

### §4.3 Presentation layer

Modify `lib/presentation/features/study/screens/study_entry_screen.dart`:

```dart
// Replace generic _error: Object? with typed:
EmptyScopeFailure? _emptyScopeFailure;
Object? _otherError;

// In build():
if (_emptyScopeFailure != null) {
  return EmptyScopeScreen(failure: _emptyScopeFailure!);
}
if (_otherError != null) { ... existing error UI ... }
```

Create `lib/presentation/features/study/widgets/empty_scope_screen.dart` (NEW):

- Switch on `failure.reason` → render matching `MxEmptyState` widget.
- Each case has: icon, title (l10n), subtitle (l10n if applicable), CTA button.
- CTA wiring:
  - `deck_noCards` → push flashcard create screen
  - `deck_noDueCards` / `folder_noDueCards` → re-trigger study with `study_type = new` (switch flow)
  - `folder_noCards` → return to folder detail
  - `today_allDone` → return to dashboard (motivational message)
  - `today_noContent` → push library + open new deck dialog

### §4.4 Decision table rows (test plan)

Add to `docs/decision-tables/memox-core-decision-table.md`:

| ID | Trigger | Condition | Expected | Test file |
| --- | --- | --- | --- | --- |
| S5a | Create session | `entry_type=deck`, deck has 0 cards | EmptyScope reason=deckNoCards; CTA "Add flashcards" → push create | `test/features/study/empty_scope_test.dart::S5a` |
| S5b | Create session | `entry_type=deck`, study_type=srs_review, deck cards > 0 but no due | EmptyScope reason=deckNoDueCards, nextDueAt populated | `::S5b` |
| S5c | Create session | `entry_type=folder`, folder + descendants 0 cards | EmptyScope reason=folderNoCards | `::S5c` |
| S5d | Create session | `entry_type=folder`, srs_review, no due in tree | EmptyScope reason=folderNoDueCards, nextDueAt populated | `::S5d` |
| S5e | Create session | `entry_type=today`, user has cards but 0 due | EmptyScope reason=todayAllDone | `::S5e` |
| S5f | Create session | `entry_type=today`, user has 0 cards total | EmptyScope reason=todayNoContent | `::S5f` |
| S5g | Empty screen tap CTA | reason=deckNoCards | Pushes flashcardCreate route | `::S5g` |
| S5h | Empty screen tap CTA | reason=deckNoDueCards | Re-triggers study with new flow | `::S5h` |
| S5i | Next-due query | scope has only due_at > now items | Returns MIN(due_at) | `test/data/repositories/study_repo_next_due_test.dart::S5i` |

### §4.5 Files touched (Tier 1)

| File | Change | Lines (est) |
| --- | --- | --- |
| `lib/domain/study/entities/empty_scope_reason.dart` | NEW | ~30 |
| `lib/domain/study/usecases/study_usecases.dart` | Modify `StartStudySessionUseCase.execute()` | ~40 |
| `lib/domain/study/ports/study_repo.dart` | Add 2 method signatures | ~10 |
| `lib/data/repositories/study_repo_impl.dart` | Implement 2 methods + queries | ~50 |
| `lib/data/repositories/study_repo_impl_helpers.dart` | SQL helpers | ~30 |
| `lib/l10n/app_en.arb` + `app_vi.arb` | Add 14 keys × 2 = 28 entries | ~60 |
| `lib/presentation/features/study/widgets/empty_scope_screen.dart` | NEW | ~150 |
| `lib/presentation/features/study/screens/study_entry_screen.dart` | Branch on EmptyScopeFailure | ~30 |
| `lib/presentation/features/study/providers/study_session_notifier.dart` | Handle typed failure | ~20 |
| `test/features/study/empty_scope_test.dart` | NEW | ~200 |
| `test/data/repositories/study_repo_next_due_test.dart` | NEW | ~80 |
| `docs/decision-tables/memox-core-decision-table.md` | Add 9 rows | ~12 |

**Tổng**: ~12 file touched, ~700 dòng code/test/doc.

## §5. Tier 2 plan (Tag entry type)

Block on adding `tag` to `StudyEntryType` enum. Triggers cascade:

| Change | Files | Notes |
| --- | --- | --- |
| Add `StudyEntryType.tag('tag')` | `lib/domain/enums/study_enums.dart` | Single line |
| Tag scope resolution | `lib/domain/study/strategy/study_strategy.dart` | New method `loadBatchForTagScope(tags, studyType)` |
| Tag-scoped query | `lib/data/repositories/study_repo_impl.dart` | JOIN `flashcards × flashcard_tags` |
| Route + entry gate | `lib/presentation/features/study/screens/study_entry_screen.dart` | Parse `entryRefId` as comma-joined tag names |
| Tag picker UI | New widget | Per spec `docs/wireframes/22-settings-tag-management.md` reuse `mx_tag_input` |
| EmptyScopeReason enum add | `lib/domain/study/entities/empty_scope_reason.dart` | `tagNoCards`, `tagNoDueCards` |
| L10n keys | `app_*.arb` | 4 more keys × 2 locales |
| Decision rows | Decision table | S5j, S5k |

Plus Tag domain layer cleanup (§3.3 audit P1-2). **Tier 2 implicitly batches with Tag epic** → recommend defer until P1-2 sprint.

## §6. Tier 3 plan (Bury/Suspend dependent)

Block on P0-2 Bury/Suspend epic. After schema migration:

| Change | Files |
| --- | --- |
| EmptyScopeReason add `allBuried`, `allSuspended` | `empty_scope_reason.dart` |
| Bury/suspend filter in batch loader | `study_strategy.dart` |
| Repo helpers count buried/suspended in scope | `study_repo_impl.dart` |
| L10n keys × 2 locales | `app_*.arb` |
| Decision rows S5l, S5m | Decision table |

→ Tier 3 = "wrap-up after bury/suspend foundation" — XS effort but blocks on XL epic.

## §7. Sequencing recommendation

```
Week 1-2 (current sprint):
  ├── Tier 1 (6 cases independent)     [S, ~3 days]
  ├── CLAUDE.md trigger map fix         [XS, 30min]
  └── Forward decision memo to product  [XS, 15min]

Week 3-4 (after product decisions land):
  ├── If onboarding Option B chosen     [S, 1 sprint]
  ├── Tier 2 batched with Tag P1-2      [M, 1 sprint]
  └── Bury/Suspend epic kickoff         [XL, plan only this sprint]

Week 5+ (Bury/Suspend epic):
  ├── Schema migration                  [S]
  ├── Domain UC + repo                   [M]
  ├── Presentation + card-actions sheet  [M]
  └── Tier 3 wrap-up                     [XS]
```

## §8. Risks

| Risk | Mitigation |
| --- | --- |
| L10n copy chưa được product review → ship sai tone | Forward Tier 1 copy table với product owner trong decision memo Decision 4 (suggest) |
| `studyEmpty_today_allDone` muốn show streak (per spec line 127) — phụ thuộc P1-1 streak | Phase 1 implement "All done" message simple; streak inset chip add sau khi P1-1 done. Flag là known-incomplete với pointer Rev 3 #01. |
| `next due in {relativeTime}` calculation phụ thuộc `flashcard_progress.due_at` index | Verify index exists trong `flashcard_progress_table.dart` — nếu missing, add migration trong cùng Tier 1 |
| EmptyScopeFailure typed thay đổi error contract → presentation layer khác (#13-17) cần update | Audit `studyErrorMessage()` call-sites; chuyển sang `MxActionErrors.failureOf()` switch on type |
| Test cases S5a-S5i cần data fixtures (deck với 0 cards, folder rỗng, etc.) | Reuse existing test helpers in `test/data/repositories/study_repo_test_helpers.dart` nếu có, else create |

## §9. Acceptance criteria (Tier 1)

- [ ] Code: `StartStudySessionUseCase` không còn throw `ValidationException` cho empty-scope cases.
- [ ] Code: 6 case path → `EmptyScopeFailure(reason: <specific>)`.
- [ ] UI: Mỗi reason render dedicated `MxEmptyState` widget với title + (subtitle if applicable) + CTA.
- [ ] L10n: 28 entries trong cả `app_en.arb` + `app_vi.arb`; build_runner regen `lib/l10n/generated/**`.
- [ ] Test: 9 rows decision table có test pass.
- [ ] Doc: Rev 4 audit row #12 mark resolved (Tier 1 scope).
- [ ] CTA wiring: tap `Add flashcards` push correct route; tap `Study new instead` re-triggers với `study_type=new`.
- [ ] No regression: existing #04 + study session start flow tests still pass.

## §10. Next action

**Đề xuất bắt đầu**: Đợi product confirm Tier 1 copy table (Decision memo §4.2), rồi engineering kickoff. Trong khi chờ:

1. Tạo branch `feat/p0-1-empty-scope-tier1` (read-only prep).
2. Draft typed failure + reason enum (no behavior change yet).
3. Build skeleton `EmptyScopeScreen` widget với placeholder copy.
4. Surface drift §2 (tag entry type missing) lên audit — ĐÃ làm trong doc này.

User confirm có muốn tôi proceed với (1)-(3) skeleton work song song với decision memo chờ phản hồi không?
