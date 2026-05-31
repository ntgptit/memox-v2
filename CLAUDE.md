# CLAUDE.md - MemoX

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.


Local-first Flutter flashcard app.

`docs/` là **source of truth** cho behavior, schema, routes, UI contract. Khi `docs/` và code mâu thuẫn, KHÔNG tự chọn. Report mismatch hoặc update cả hai trong cùng commit.

## 🔴 Doc-code parity rule (đọc trước tiên, luôn áp dụng)

**Mỗi commit thay đổi code phải giữ docs đồng bộ với code.** Nếu thay đổi code ảnh hưởng đến bất kỳ aspect nào được spec trong `docs/`, bắt buộc update docs **trong CÙNG commit**, không phải "sửa sau".

Lý do: docs đã từng bị drift trong các iteration trước. Drift làm Claude Code các phiên sau làm sai vì đọc spec đã lỗi thời. Quy tắc này tồn tại để chặn drift ngay từ source.

### Pre-commit parity check (bắt buộc, không skip)

Trước khi finish task, tự trả lời theo thứ tự:

1. **Có thay đổi behavior người dùng thấy không?** (UX flow, dialog copy, button order, empty states, validation message, error handling, navigation transition)
   → Nếu CÓ: update file business/wireframe tương ứng.

2. **Có thay đổi schema/persistence không?** (column add/remove/rename, index, migration, SharedPreferences key, file path, encoding)
   → Nếu CÓ: update `docs/database/schema-contract.md` + `docs/database/migration-contract.md` + `docs/database/storage-boundaries.md`.

3. **Có thay đổi route/navigation không?** (new path, new param, push vs go, redirect rule, deep link)
   → Nếu CÓ: update `docs/business/navigation/navigation-flow.md` + `RouteNames`/`RoutePaths` constants.

4. **Có thay đổi SRS algorithm, intervals, box count, result enum, study flow, study mode behavior?**
   → Nếu CÓ: update `docs/business/srs/srs-review.md` + `docs/business/study/study-flow.md` + decision table.

5. **Có thay đổi rule, edge case, validation hoặc agent rule không?**
   → Nếu CÓ: update doc tương ứng. NEVER quietly relax/tighten a documented rule.

6. **Có thêm/sửa branch behavior có thể test được không?**
   → Nếu CÓ: thêm/sửa row trong `docs/decision-tables/memox-core-decision-table.md` và viết test tương ứng.

7. **Có chuyển một aspect từ "Specified" sang implemented (hoặc ngược lại) không?**
   → Update bảng status trong `docs/business/system/overview.md`.

8. **Behavior đã thay đổi nhưng docs cũ vẫn còn ref đến cách cũ?**
   → Phải sửa **TẤT CẢ** ref. Dùng `grep -rn "{old_term}" docs/` để tìm. Không để lại text inconsistent.

Nếu không chắc một mục có cần update không, **mặc định LÀ cần update**. Cost của update thừa < cost của drift.

### Code change → required docs (trigger map)

Bảng này map giữa loại thay đổi code và các file docs BẮT BUỘC kiểm tra (không phải "có thể"):

| Code change | Bắt buộc kiểm tra & update nếu liên quan |
| --- | --- |
| `lib/data/datasources/local/tables/**` | `docs/database/schema-contract.md`, `docs/database/migration-contract.md`, `docs/decision-tables/memox-core-decision-table.md` |
| `lib/domain/entities/**` | Business doc của entity đó + `docs/business/glossary.md` (nếu thêm thuật ngữ) |
| `lib/domain/usecases/**` (new use case hoặc behavior thay đổi) | Business doc liên quan + decision table |
| `lib/domain/study/srs_interval_policy.dart` / `lib/data/repositories/study_repo_impl_mapping_helpers.dart` (`_intervalForBox`) | `docs/business/srs/srs-review.md` (interval table) |
| `lib/data/repositories/study_repo_impl_helpers.dart` (`_reviewOutcome`) | `docs/business/srs/srs-review.md` (transition table) |
| `lib/app/router/route_names.dart` / `route_paths.dart` | `docs/business/navigation/navigation-flow.md` |
| `lib/presentation/features/**/screens/*.dart` | Wireframe tương ứng trong `docs/wireframes/*.md` |
| `lib/presentation/features/**/widgets/dialog_*.dart` hoặc `*_dialog.dart` | `docs/wireframes/24-shared-dialogs.md` (nếu là shared dialog) |
| `lib/presentation/features/**/widgets/*_sheet.dart` hoặc bottom sheet | `docs/wireframes/25-shared-bottom-sheets.md` (nếu là shared sheet) |
| `lib/presentation/features/study/**` (5 mode files) | `docs/wireframes/13-17-study-session-*.md` + `docs/business/study/study-flow.md` |
| `lib/data/repositories/flashcard_import_*.dart` | `docs/business/flashcard/flashcard-management.md` (import section) + `docs/wireframes/10-deck-import.md` |
| `lib/data/repositories/flashcard_export_*.dart` | `docs/business/export/export.md` |
| `lib/data/sync/**` hoặc `drive_sync_*.dart` | `docs/business/account-sync/account-sync.md` + `docs/wireframes/19-settings-account.md` |
| `lib/presentation/features/settings/**` | `docs/wireframes/04-settings-hub.md` + sub-screen wireframes 19-22 |
| `lib/l10n/app_*.arb` (new key) | Đảm bảo key được ref trong wireframe/business doc tương ứng |
| `pubspec.yaml` (new dependency) | Stop and ask. Approval needed. |
| Theme tokens (`lib/core/theme/**`) | `docs/ui-ux/ui-ux-contract.md` + `docs/system-design/MemoX Design System/README.md` + `docs/system-design/MemoX Design System/colors_and_type.css` |

Nếu code change rơi vào nhiều rows, kiểm tra tất cả.

### Drift detection (khi nhận task)

Trước khi code, đọc related docs (theo "Required reading" bên dưới). Nếu phát hiện docs ĐÃ lag so với code hiện tại (ví dụ: code có column mới chưa được doc, hoặc behavior code khác behavior doc):

1. **Dừng lại.** Không continue task.
2. Report drift cho user với format:
   ```
   DRIFT DETECTED:
   - File code: lib/...
   - File doc: docs/...
   - Mismatch: {mô tả cụ thể}
   - Suggested fix: {update doc / update code / cần user quyết định}
   ```
3. Chờ user xác nhận hướng xử lý trước khi continue.

Đây là cách duy nhất để drift không tích lũy.

## Required reading by task

**Universal additions (apply to every task):**
- `docs/contracts/error-contract.md` (Failure taxonomy)
- `docs/contracts/types-catalog.md` (enums, value objects)
- `docs/contracts/code-style.md` (naming, structure)

**Task-specific:**

| Task type | Đọc trước |
| --- | --- |
| Bất kỳ task nào | `docs/business/index.md`, `docs/business/glossary.md`, **3 universal contracts above** |
| Thêm/sửa use case | `docs/contracts/usecase-contracts/{entity}.md` + business spec + decision rows |
| Thêm/sửa repository | `docs/contracts/repository-contracts/{entity}-repository.md` + use case contract |
| Thêm/sửa screen | Wireframe của screen đó + related `docs/business/**` + `docs/ui-ux/ui-ux-contract.md` + `docs/system-design/MemoX Design System/README.md` + Implementation refs trong wireframe (→ tự link đến contracts) |
| Thêm/sửa route | `docs/business/navigation/navigation-flow.md` |
| Schema change | `docs/database/schema-contract.md`, `docs/database/migration-contract.md` |
| State/provider | `docs/state/state-management-contract.md` (đặc biệt §Per-notifier contracts) |
| Study/SRS | `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md`, `docs/contracts/usecase-contracts/study.md`, `docs/contracts/usecase-contracts/srs.md` |
| Bury/Suspend | `docs/business/study-actions/bury-suspend.md`, `docs/contracts/usecase-contracts/study.md` §Bury/Suspend |
| Resume session | `docs/business/resume/resume-session.md`, `docs/contracts/usecase-contracts/study.md` §FindResumableSessionUseCase |
| Folder/Deck/Flashcard | `docs/business/{folder,deck,flashcard}/*.md` + wireframe + `docs/contracts/usecase-contracts/{folder,deck,flashcard}.md` |
| Tag-related | `docs/business/tags/tag-system.md`, `docs/contracts/usecase-contracts/tag.md` |
| Bulk operations | `docs/business/bulk/bulk-operations.md`, `docs/contracts/usecase-contracts/bulk.md` |
| Search | `docs/business/search/global-search.md`, `docs/wireframes/11-library-search.md`, `docs/contracts/usecase-contracts/search.md` |
| Card history | `docs/business/history/card-history.md`, `docs/wireframes/09-flashcard-history.md`, `docs/contracts/usecase-contracts/history.md` |
| Dashboard / engagement | `docs/business/engagement/dashboard-engagement.md`, `docs/wireframes/01-dashboard.md`, `docs/contracts/usecase-contracts/engagement.md` |
| Export | `docs/business/export/export.md` |
| TTS | `docs/business/tts/tts-settings.md`, `docs/contracts/usecase-contracts/tts.md` |
| Account / Drive sync | `docs/business/account-sync/account-sync.md`, `docs/wireframes/19-settings-account.md`, `docs/contracts/usecase-contracts/account-sync.md`, `docs/contracts/repository-contracts/sync-repository.md` |
| Dialog work | `docs/wireframes/24-shared-dialogs.md` |
| Bottom-sheet work | `docs/wireframes/25-shared-bottom-sheets.md` |
| Writing tests | `docs/testing/test-strategy.md` |
| Perf-sensitive feature | `docs/quality/performance-contract.md` |
| Adding log site | `docs/quality/observability-contract.md` |
| Adding user-facing string | `docs/ui-ux/l10n-copy-contract.md` |
| Giving task to agent | `docs/agent/agent-task-template.md` |
| Review code | `docs/checklist/recursive-agent-review.md` |
| Complete task | `docs/checklist/implementation-checklist.md` |

## Path convention for cross-references (canonical)

Whenever a markdown file references another markdown file inside backticks, the path MUST be **repo-root absolute, no leading slash**:

```
✓  `docs/business/folder/folder-management.md`
✓  `docs/wireframes/13-study-session-review.md`
✓  `docs/contracts/usecase-contracts/study.md`
✓  `CLAUDE.md`
✓  `AGENTS.md`

✗  /docs/business/folder/folder-management.md          (leading slash)
✗  ../business/folder/folder-management.md             (relative)
✗  folder-management.md                                (bare filename)
✗  business/folder/folder-management.md                (missing docs/ prefix)
```

Rationale: one path style across the codebase, trivially verifiable by `[ -f path ]` from repo root, no resolution-by-context confusion. Agents finding a non-conforming ref MUST fix it in the same commit (report under "Drift detected").

This convention applies to **backtick references** in markdown body text and tables. Markdown link syntax (`[label](url)`), if used, also follows the same path rule.

## Hard rules (vi phạm = task fail)

- KHÔNG commit code change without parity-checking docs theo "Pre-commit parity check".
- KHÔNG implement từ giả định khi docs đã có contract.
- KHÔNG sửa generated files (`*.g.dart`, `*.freezed.dart`, Drift generated, `lib/l10n/generated/**`).
- KHÔNG hardcode route strings, colors, text styles, durations, user-facing strings.
- KHÔNG bypass MemoX design tokens/theme. UI phải dùng token/shared component hiện có trong MemoX Design System; nếu token thiếu, report gap hoặc update token theo task được duyệt.
- KHÔNG tạo shared widget mới khi widget hiện có giải quyết được. Chỉ tạo shared widget mới khi có nhu cầu lặp lại thật, có naming/contract rõ, và task yêu cầu hoặc user approve.
- KHÔNG dùng raw `Card`, raw `Button`, raw action layout nếu MemoX đã có component tương ứng như `MxCard`, `MxActionButton`, `MxCardActions`, `MxContentShell`. Nếu phải dùng raw Material widget, giải thích lý do trong report.
- KHÔNG sửa schema/persistence nếu không có migration, schema docs, migration docs, và test tương ứng trong cùng commit.
- KHÔNG đánh dấu item trong docs từ `Future`/`Target`/`Specified` sang `Current`/`Implemented` nếu code chưa implement thật và chưa có verification/test tương ứng.
- KHÔNG giữ persistent data chỉ trong provider memory.
- KHÔNG bypass UseCase → Repository → DAO flow.
- KHÔNG import ngược chiều dependency: domain MUST NOT import data or presentation; presentation MUST NOT import data directly. Allowed imports: presentation → domain; data → domain (data implements domain interfaces). Dependencies point inward: domain has no outward imports.
- KHÔNG dùng `ref.watch` trong callback.
- KHÔNG thêm route mới mà không update route constants AND `docs/business/navigation/navigation-flow.md` trong cùng commit.
- KHÔNG để docs reference đến term/route/field cũ sau khi rename.
- KHÔNG đánh dấu task "done" nếu chưa pass Pre-commit parity check.
- KHÔNG báo cáo complete nếu `code-verification-guard` tồn tại trong repo mà chưa chạy pass. Nếu tool không tồn tại, ghi rõ: `guard: skipped (tool not present)`.

## Mandatory workflow

1. Đọc related docs theo bảng "Required reading".
2. Inspect "Source files to inspect" trong related doc.
3. **Drift check**: docs có match với code hiện tại không? Nếu không, dừng lại và report (xem "Drift detection" ở trên).
4. Confirm acceptance criteria khi spec không rõ.
5. Implement theo Clean Architecture: entity → repository contract → use case → notifier/viewmodel → widget.
6. **Pre-commit parity check**: chạy 8-step checklist ở trên trước khi finish.
7. Update related docs nếu behavior thay đổi (mandatory, cùng commit).
8. Update decision table nếu thêm/sửa behavior branch.
9. Check MemoX Design System compliance nếu có thay đổi UI: token usage, shared component usage, no raw component bypass.
10. Chạy verification theo `docs/checklist/implementation-checklist.md`.
11. Báo cáo theo format trong checklist, **bao gồm section "Docs updated"** liệt kê file docs đã sửa và lý do, section `Guard status`, và lý do nếu bỏ qua command nào.

## Stack reference

- Flutter, Dart 3
- Material 3
- Riverpod annotation v3
- Drift SQLite (DAO pattern)
- GoRouter
- fpdart Either (Target; requires approved dependency/API migration before implementation if not adopted)
- freezed
- ARB localization
- MemoX Design System
- code-verification-guard

## Verification commands

```text
dart run build_runner build --delete-conflicting-outputs
python code-verification-guard/guard/run.py check --project . --ruleset memox   # if available
flutter analyze
flutter test <targeted tests>
```

### Analyze / dart fix pairing rule

When `flutter analyze` reports diagnostics that `dart fix` can safely apply, run:

```text
dart fix --apply
flutter analyze
```

Treat these as a pair: do not run `dart fix --apply` without rerunning
`flutter analyze`, and do not leave fixable analyzer diagnostics unresolved
without either applying the fix or explaining why the fix is unsafe/out of
scope. After `dart fix --apply`, inspect the diff and keep only changes that
belong to the current task.

`code-verification-guard` is an optional repo-side tool maintained separately. If it is not present in the working directory (clone), agent SHOULD skip it and note in report: "guard: skipped (tool not present)". The other commands are mandatory.

Doc parity verification (chạy trước khi finish):

```bash
# Tìm refs đến term/file đã rename trong toàn bộ docs
grep -rn "{old_term}" docs/

# Verify cross-refs trong wireframes không bị broken
cd docs/wireframes && for f in *.md; do
  grep -oE "[0-9]{2}-[a-z-]+\.md" "$f" | sort -u | while read r; do
    [ -f "$r" ] || echo "BROKEN in $f: $r"
  done
done
```

## When in doubt

- Ưu tiên minimal structurally correct change hơn broad refactor.
- Ưu tiên update doc thừa hơn skip parity check.
- Nếu task yêu cầu vi phạm bất kỳ hard rule nào, dừng lại và confirm với user trước.
- Nếu phát hiện docs drift nhưng task không yêu cầu sửa, vẫn report drift để user biết.
