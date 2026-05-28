---
last_updated: 2026-05-29
author: technical lead
audience: product owner
status: awaiting decisions
related_audit: docs/checklist/wireframe-code-parity-assessment.md (Rev 3)
purpose: 3 product decisions block engineering planning. Mỗi decision có option + recommendation + impact.
---

# Pending Product Decisions — 2026-05-29

> **Bối cảnh ngắn**: parity audit Rev 3 chỉ ra 3 wireframes đang ở trạng thái 🔴 MISSING — spec hoàn chỉnh nhưng code zero presence. Tiếp tục plan sprint trước khi product owner chốt sẽ rủi ro: nếu build mà sau quyết định downgrade là waste; nếu downgrade mà sau quyết định build là rework lớn hơn.
>
> Mỗi decision dưới đây cần một câu trả lời: **Build v1** hoặc **Downgrade Future Proposal**. Default "build" nếu không trả lời → engineering sẽ assume default trong 1 tuần.

---

## Decision 1: Flashcard history (wireframe 09)

**Câu hỏi**: User có nên xem được lịch sử attempts của 1 flashcard (bảng box transitions / result / time / mode) trong v1?

**Hiện trạng**:
- Doc: spec đầy đủ (`docs/wireframes/09-flashcard-history.md` + business + contracts).
- Code: **0%**. Không có screen, không có use case, không có query method. `study_attempts` table có data nhưng chưa expose.
- Reference từ wireframe 08 (`View history` link) hiện sẽ dead-end.

**Options**:

| Option | Effort | Pros | Cons |
| --- | --- | --- | --- |
| **A. Build v1** | M (~1 sprint: domain UC + screen + wire link từ #08) | User insight về SRS journey; debug "tại sao card này khó với tôi"; differentiator vs Anki basic | Sprint cost; chưa chắc retention impact đáng kể nếu user không power user |
| **B. Downgrade Future Proposal** | XS (đổi header wireframe 09 + disable link ở #08) | Tránh waste effort cho feature chưa biết có giá trị; engineering focus vào streak/onboarding | "View history" link biến mất → giảm perceived depth của app |

**Tech-lead recommendation**: **Option B (downgrade)** cho v1.

Lý do: schema raw đã có (`study_attempts` table), nên future-proof — khi product có signal user thực sự muốn, build lại nhanh hơn từ scratch nhiều. Hiện không có signal nào user request feature này. Streak (Decision 4 ngầm — link với #01 dashboard) và empty-scope correctness có user impact rõ ràng hơn.

---

## Decision 2: Global search (wireframe 11)

**Câu hỏi**: User có cần search cross deck/folder/tag với recent searches persistence, hay search inline trong từng scope (như hiện tại) là đủ?

**Hiện trạng**:
- Doc: spec global search + recent searches + filter chips + grouped results.
- Code: chỉ `MxSearchField` shared widget được dùng inline trong library / folder / flashcard-list ở **scope-local**. Không có `/library/search` route. Không có `GlobalSearchUseCase`. Không có SharedPreferences key cho recent searches.

**Options**:

| Option | Effort | Pros | Cons |
| --- | --- | --- | --- |
| **A. Build v1** | M (~1 sprint: search UC + screen + recent searches persistence + route + indexing strategy) | Power-user feature; xử lý case user nhớ từ nhưng không nhớ deck nào; chuẩn cho app library lớn | Sprint cost; user mới (deck < 5) không thấy giá trị; complexity tăng |
| **B. Downgrade thành "Inline search UX guidelines"** | XS (rewrite wireframe 11 thành UX patterns cho inline search ở các scope) | Phù hợp với UX hiện tại — scope-local đã hoạt động; tài liệu hoá patterns đã có | Mất feature cross-scope; user power không phục vụ được |

**Tech-lead recommendation**: **Option B (downgrade thành guidelines)** cho v1.

Lý do: user mới install (target audience đầu) có 1-3 deck, scope-local search overkill. Power-user feature có thể add sau khi có user > 50 cards và signal. Inline search đã work tốt; document patterns sẽ giúp consistency các scope khác (settings, tag management).

---

## Decision 3: Onboarding (wireframe 23)

**Câu hỏi**: First-time install user nên thấy 4-step onboarding với restore-from-Drive prompt, hay vào thẳng Library / Dashboard?

**Hiện trạng**:
- Doc: spec 4-step welcome + restore-prompt branch + 9 variants (`28a-28i` ở mock-mapping).
- Code: **0%**. `grep "onboarding"` trong `lib/` rỗng tuyệt đối. `RouteDefaults.initialLocation = RoutePaths.library` → user mới install thấy library trống không hướng dẫn.
- Phụ thuộc Decision này: cũng cần chốt **landing route** = `dashboard` (`home`) hay `library`?

**Options**:

| Option | Effort | Pros | Cons |
| --- | --- | --- | --- |
| **A. Build full onboarding v1** | M (~1 sprint: 4-step screen + restore prompt + sign-in handoff + gating logic) | Cao impact: first impression; restore Drive backup từ install lần thứ 2 (key cho user reinstall) | Sprint cost; complex flow nhiều state |
| **B. Skip onboarding, build "empty state" mạnh hơn ở dashboard/library** | S (improve empty state copy + 1 CTA "Restore from Drive" nếu detected) | Lower risk; tận dụng wireframe 17c "Library overview (empty)" đã spec; restore flow vẫn đi qua `19-settings-account.md` | User mới có thể không discover restore feature; less "wow" first impression |
| **C. Downgrade Future Proposal** | XS (đổi header wireframe 23) | Zero cost ngắn hạn | Reinstall user mất data nếu không biết tự đi tới Settings → Account → Restore |

**Tech-lead recommendation**: **Option B (empty state mạnh + restore CTA)** cho v1.

Lý do: 80% giá trị onboarding nằm ở 2 thứ — (1) user mới biết phải tạo deck đầu tiên, (2) reinstall user phục hồi data. Empty state đã spec sẵn ở wireframe 17c; chỉ cần add explicit "Restore from Drive" CTA nếu Google sign-in detected hoặc skipped. Sprint cost = 1/3 Option A.

**Đồng thời**: chốt landing route. Nếu chọn Option B → landing = `library` (giữ default hiện tại) vì onboarding gating ở library empty state. Nếu Option A → landing = `home` (dashboard) sau khi onboarding done, hoặc `library` nếu skip.

---

## Tổng hợp decisions & impact

| Decision | Recommendation | Engineering unblock | Doc cleanup downstream |
| --- | --- | --- | --- |
| 1. Flashcard history | Downgrade Future Proposal | Free up M effort; cleanup link ở #08 | Update wireframe 09 header + remove from mock-mapping "Current target" |
| 2. Global search | Downgrade to UX guidelines | Free up M effort; clarify inline patterns | Rewrite wireframe 11; cleanup search refs ở #02, #06 |
| 3. Onboarding | Option B (empty state + restore CTA) | S effort thay vì M; reuse existing empty states | Update wireframe 23 to Future Proposal full version; document restore CTA path |

**Tổng saving nếu accept all recommendations**: ~2.5 sprints effort. Engineering có thể tập trung **P0 (Empty-scope matrix + Bury/Suspend)** và **P1-1 streak** thay vì xa-xa.

---

## Yêu cầu phản hồi

Mỗi decision cần một trong:
- ✅ `Accept recommendation`
- 🔄 `Build` (Option A) — cần thêm acceptance criteria
- ⏸️ `Defer` (chờ thêm user research / signal) — cần thời hạn revisit

**Deadline phản hồi đề nghị**: 2026-06-05 (1 tuần). Sau deadline, engineering assume default = **Accept recommendation** để tránh block thêm.

---

## Side decision: CLAUDE.md trigger map (§3.12 audit)

Không phải product decision nhưng cần user (tech lead) chốt — meta-doc drift:

CLAUDE.md (root + `docs/CLAUDE.md`) trigger map hiện ref 2 file không tồn tại:
```
| `lib/domain/srs/box_intervals.dart` | docs/business/srs/srs-review.md (interval table) |
| `lib/domain/srs/box_transition.dart` | docs/business/srs/srs-review.md (transition table) |
```

| Option | Action |
| --- | --- |
| **a. Xoá 2 dòng**, thay bằng 1 row pointing `lib/domain/study/usecases/study_usecases.dart` → `docs/business/srs/srs-review.md` | Phản ánh code hiện tại; mất "target" intent của 2 file riêng |
| **b. Giữ + mark target** + thêm 1 row mới mapping current location | Giữ intent target file; trigger map cồng kềnh hơn |

Recommend **Option (a)** + đồng thời tạo backlog task "Extract SRS intervals/transitions to dedicated files" để track intent.
