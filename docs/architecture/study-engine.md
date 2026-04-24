# Study Engine Architecture

Tài liệu này chốt contract kỹ thuật cho tầng chạy session học (`New Study`, `SRS Review`, và các study type mở rộng trong tương lai như game). Đọc cùng:

- [Study Index](../business/study/study-index.md)
- [Study Concepts](../business/study/study-concepts.md)
- [Study Strategy](../business/study/study-strategy.md)
- [Study Clean Architecture](../business/study/study-clean-architecture.md)
- [SRS Rules](../business/srs/srs-rules.md)

---

## 1. Mục tiêu

`New Study` và `SRS Review` dùng chung rất nhiều logic:

- chạy theo một hàng đợi flashcard batch
- retry loop until `retryBatch.isEmpty`
- ghi nhận attempt (đúng / sai, timestamp)
- stage kết quả trong lúc chạy, commit SRS 1 lần khi session `completed`

Phần khác nhau chỉ ở:

- cách lấy batch (new vs due vs pool của game)
- mode queue (5 mode theo thứ tự / chỉ `Fill` / tuỳ game)
- rule commit SRS cuối session (hay không commit nếu là game luyện tập)

Để tránh `if (type == newStudy) ... else if (type == srsReview) ...` rải khắp codebase, và để mở đường cho study type thứ 3+ (game, quiz, blast...), dùng **Strategy + Factory Registry** — mỗi study type là 1 instance strategy, factory dispatch qua enum `handleType`.

---

## 2. Nguyên tắc thiết kế

- **Engine dùng chung** nắm: batch queue, retry loop, attempt log, stage/commit orchestrator.
- **Strategy per study type** chỉ override những điểm thật sự khác biệt (load batch, mode queue, commit rule).
- **Factory** lookup strategy qua enum `StudyType`; không có `switch` trên type rải rác.
- **Mở rộng**: thêm study type mới = thêm 1 class extends `StudyStrategy` + đăng ký vào provider factory, **không** sửa engine, không sửa factory.
- **Không dùng `sealed class`** cho `StudyStrategy` — cần mở để module/plugin ngoài cũng thêm được strategy.

---

## 3. Mapping pattern Java → Dart/Flutter

User quen pattern Java:

> interface có `getHandleType()` trả enum → abstract class implement interface → concrete `extends` abstract class → factory dispatch theo enum.

Dart tương đương:

| Java | Dart/Flutter |
|---|---|
| `interface StudyStrategy` | Gộp vào `abstract class StudyStrategy` (mọi class Dart là implicit interface). Nếu muốn tách contract thuần: `abstract interface class StudyContract`. |
| `abstract class BaseStudyStrategy implements StudyStrategy` | `abstract class StudyStrategy` vừa là contract vừa chứa common logic. |
| `@Component` auto-collect `List<StudyStrategy>` | Riverpod provider khai báo tay danh sách strategy. Không có classpath scanning — đổi lại là explicit và dễ test. |
| `StudyType getHandleType()` | `StudyType get handleType;` (getter abstract). |
| `Map<StudyType, StudyStrategy>` factory lookup | Giống hệt — `Map<StudyType, StudyStrategy>` dựng 1 lần trong constructor của factory. |
| `@Override` optional | `@override` bắt buộc (analyzer warning). |

---

## 4. Contract

### 4.1. Enum định danh

```dart
// lib/domain/study/strategy/study_type.dart
enum StudyType {
  newStudy,
  srsReview,
  // tương lai: matchGame, blastGame, quizGame...
}
```

Enum là **contract định danh**. Mọi strategy trả về đúng 1 giá trị ở `handleType`. Không có strategy nào được phép trả về 2 enum.

### 4.2. Abstract class — 3 nhóm method

Abstract class có 3 nhóm method, phân biệt rõ vai trò:

1. **Abstract (bắt buộc override)** — contract cốt lõi, concrete phải tự định nghĩa.
2. **Template (không override)** — skeleton điều phối, gọi các abstract + hook theo đúng thứ tự.
3. **Hook (có default, có thể override)** — điểm mở rộng. Default là no-op hoặc hành vi phổ biến. Concrete chỉ override khi cần đổi.

```dart
// lib/domain/study/strategy/study_strategy.dart
abstract class StudyStrategy {
  StudyType get handleType;

  // ═══════════════════════════════════════════════════════
  // (1) Abstract — concrete BẮT BUỘC override
  // ═══════════════════════════════════════════════════════
  Future<List<Flashcard>> loadBatch(StudyContext ctx);
  List<StudyMode> buildModeQueue(StudyContext ctx);
  Future<void> commitResult(StudySession session);

  // ═══════════════════════════════════════════════════════
  // (2) Template — skeleton cố định, KHÔNG override
  // ═══════════════════════════════════════════════════════
  Future<StudySession> run(StudyContext ctx) async {
    await onBeforeSession(ctx);                        // hook
    final batch = await loadBatch(ctx);
    final modes = buildModeQueue(ctx);
    final session = StudySession.start(
      type: handleType,
      batch: batch,
      modes: modes,
    );

    for (final mode in modes) {
      await onBeforeMode(session, mode);               // hook
      await _runModeWithRetryLoop(session, mode);
      await onAfterMode(session, mode);                // hook
      if (!session.isModePassed(mode)) {
        await onSessionPaused(session);                // hook
        return session.paused();
      }
    }

    await commitResult(session);
    await onAfterSession(session);                     // hook
    return session.completed();
  }

  /// Retry loop until `retryBatch.isEmpty`. Điều kiện dừng duy nhất.
  Future<void> _runModeWithRetryLoop(StudySession s, StudyMode m) async {
    var queue = List<Flashcard>.from(s.batch);
    var round = 0;
    while (queue.isNotEmpty) {
      round++;
      await onBeforeRound(s, m, round, queue);         // hook
      final retry = <Flashcard>[];
      for (final card in queue) {
        final attempt = await presentAndGrade(s, m, card);
        s.recordAttempt(attempt);
        await onAttempt(s, m, attempt);                // hook
        if (!attempt.passed) retry.add(card);
      }
      await onAfterRound(s, m, round, retry);          // hook
      queue = retry;
    }
    s.markModePassed(m);
  }

  // ═══════════════════════════════════════════════════════
  // (3) Hook — default no-op, concrete override KHI CẦN
  // ═══════════════════════════════════════════════════════

  /// Trước khi load batch. Dùng để warm cache, log analytics, v.v.
  Future<void> onBeforeSession(StudyContext ctx) async {}

  /// Sau khi commit thành công. Dùng để celebrate UI, push notification...
  Future<void> onAfterSession(StudySession s) async {}

  /// User thoát giữa chừng. Default: không làm gì (engine đã trả session.paused()).
  /// Override để flush progress đặc biệt, ví dụ SRS Review muốn persist retry batch.
  Future<void> onSessionPaused(StudySession s) async {}

  /// Trước mỗi mode. Dùng để reset UI state, phát âm hint, v.v.
  Future<void> onBeforeMode(StudySession s, StudyMode m) async {}

  /// Sau mỗi mode. Dùng để animate transition, ghi milestone.
  Future<void> onAfterMode(StudySession s, StudyMode m) async {}

  /// Trước mỗi round retry. `round` 1-indexed, `queue` là danh sách thẻ sẽ học.
  /// Override để hiển thị banner "Round 3: còn 2 thẻ" chẳng hạn.
  Future<void> onBeforeRound(
    StudySession s,
    StudyMode m,
    int round,
    List<Flashcard> queue,
  ) async {}

  /// Sau mỗi round, `retry` là danh sách sẽ học ở round sau (rỗng = mode pass).
  Future<void> onAfterRound(
    StudySession s,
    StudyMode m,
    int round,
    List<Flashcard> retry,
  ) async {}

  /// Sau mỗi attempt (trước khi thêm vào retry). Dùng để log analytics,
  /// play sound, haptic feedback. Không dùng để thay đổi kết quả attempt.
  Future<void> onAttempt(StudySession s, StudyMode m, Attempt a) async {}

  /// Hook UI: hiển thị flashcard và chờ user trả lời. Bắt buộc phải có implementation
  /// nhưng thường được inject qua ModePresenter (xem §6) thay vì override ở strategy.
  Future<Attempt> presentAndGrade(
    StudySession s,
    StudyMode m,
    Flashcard card,
  );
}
```

**Quy ước đặt tên hook** (theo Java convention, áp dụng luôn cho Dart):

- `onBeforeX` / `onAfterX` cho trước/sau một giai đoạn.
- `onX` cho event xảy ra (attempt, tap, error).
- Hook default luôn là `async {}` (no-op) — concrete chỉ cần override khi có việc thực sự.

**Ví dụ concrete override hook** — `SrsReviewStrategy` muốn ghi retry batch xuống disk mỗi khi user thoát:

```dart
class SrsReviewStrategy extends StudyStrategy {
  // ... abstract overrides ...

  @override
  Future<void> onSessionPaused(StudySession s) async {
    await _repo.persistPausedReview(s); // override hook khi cần
  }

  @override
  Future<void> onAfterRound(
    StudySession s,
    StudyMode m,
    int round,
    List<Flashcard> retry,
  ) async {
    // log để Grafana theo dõi số round trung bình
    await _analytics.logRetryRound(handleType, round, retry.length);
  }
}
```

`NewStudyStrategy` không override gì thêm → default no-op chạy, không phải viết boilerplate.

Lưu ý:

- **Không đặt business rule core vào hook.** Ví dụ "commit SRS" phải ở `commitResult` (abstract), KHÔNG ở `onAfterSession` (hook) — nếu concrete quên override hook thì rule core sẽ chạy sai.
- Hook chỉ dành cho **side effect mở rộng**: logging, UI polish, telemetry, cache warm-up, notification.
- Khi thêm hook mới vào abstract class, **luôn cung cấp default** — không làm vỡ concrete cũ.
- Tránh hook trả giá trị có ý nghĩa điều khiển flow (`bool shouldStop()`) — sẽ thành "hook điều khiển" khó trace. Nếu cần dừng flow, dùng abstract method.

### 4.3. Concrete — chỉ `extends` và khai báo `handleType`

```dart
// lib/domain/study/strategy/new_study_strategy.dart
class NewStudyStrategy extends StudyStrategy {
  NewStudyStrategy(this._repo);
  final StudyRepo _repo;

  @override
  StudyType get handleType => StudyType.newStudy;

  @override
  Future<List<Flashcard>> loadBatch(StudyContext ctx) =>
      _repo.loadNewCards(scope: ctx.source, size: ctx.settings.newBatchSize);

  @override
  List<StudyMode> buildModeQueue(StudyContext ctx) => const [
        StudyMode.review,
        StudyMode.match,
        StudyMode.guess,
        StudyMode.recall,
        StudyMode.fill,
      ];

  @override
  Future<void> commitResult(StudySession s) =>
      _repo.commitNewStudySrs(s); // stage → box ban đầu + due tiếp theo
}
```

```dart
// lib/domain/study/strategy/srs_review_strategy.dart
class SrsReviewStrategy extends StudyStrategy {
  SrsReviewStrategy(this._repo);
  final StudyRepo _repo;

  @override
  StudyType get handleType => StudyType.srsReview;

  @override
  Future<List<Flashcard>> loadBatch(StudyContext ctx) =>
      _repo.loadDueCards(scope: ctx.source, size: ctx.settings.reviewBatchSize);

  @override
  List<StudyMode> buildModeQueue(StudyContext ctx) => const [StudyMode.fill];

  @override
  Future<void> commitResult(StudySession s) =>
      _repo.commitSrsReview(s); // box tăng/giảm + due mới, 1 transaction
}
```

### 4.4. Factory — lookup qua `handleType`

```dart
// lib/domain/study/strategy/study_strategy_factory.dart
class StudyStrategyFactory {
  StudyStrategyFactory(Iterable<StudyStrategy> strategies)
      : _byType = {
          for (final s in strategies)
            if (_byType.putIfAbsent(s.handleType, () => s) != s)
              throw StateError('Duplicate strategy for ${s.handleType}'),
        };

  final Map<StudyType, StudyStrategy> _byType;

  StudyStrategy of(StudyType type) =>
      _byType[type] ??
      (throw StateError('No StudyStrategy registered for $type'));
}
```

Factory chỉ làm 1 việc: `StudyType` → `StudyStrategy`. Không biết gì về nội dung strategy.

### 4.5. DI qua Riverpod (thay Spring auto-wire)

```dart
// lib/app/di/study_providers.dart
@riverpod
StudyStrategyFactory studyStrategyFactory(Ref ref) {
  final repo = ref.watch(studyRepoProvider);
  return StudyStrategyFactory([
    NewStudyStrategy(repo),
    SrsReviewStrategy(repo),
    // thêm game strategy tại đây — không sửa factory, không sửa engine
  ]);
}

@riverpod
Future<StudySession> startStudySession(
  Ref ref,
  StudyType type,
  StudyContext ctx,
) async {
  final strategy = ref.watch(studyStrategyFactoryProvider).of(type);
  return strategy.run(ctx);
}
```

---

## 5. Rule mở rộng — thêm study type thứ N

Quy trình **cố định** để thêm 1 study type mới:

1. Thêm 1 giá trị vào enum `StudyType` (ví dụ `matchGame`).
2. Tạo class `MatchGameStrategy extends StudyStrategy`:
   - override `handleType` trả về `StudyType.matchGame`
   - override `loadBatch`, `buildModeQueue`, `commitResult` theo rule riêng
3. Đăng ký vào `studyStrategyFactoryProvider`.
4. **Không** sửa `StudyStrategy` base class.
5. **Không** sửa `StudyStrategyFactory`.
6. **Không** thêm `switch` trên `StudyType` ở presentation / service layer — luôn đi qua factory.

Rule này cho phép "100 instance 100 logic khác nhau" mà vẫn giữ engine sạch.

---

## 6. Tách hook UI khỏi strategy (khuyến nghị)

`presentAndGrade(session, mode, card)` phụ thuộc UI. Nếu giữ trong `StudyStrategy`, strategy sẽ bị kéo vào presentation layer, vi phạm Clean Architecture.

Khuyến nghị tách ra collaborator:

```dart
abstract class ModePresenter {
  Future<Attempt> present(StudySession s, StudyMode m, Flashcard card);
}
```

- `StudyStrategy.run()` nhận `ModePresenter` qua `StudyContext` hoặc constructor injection.
- Domain layer chỉ định nghĩa `ModePresenter` interface.
- Presentation layer implement `ModePresenter` (widget, provider, animation, input...).
- Strategy hoàn toàn thuần domain — test không cần Flutter.

---

## 7. Layer / folder

```
lib/
├── domain/study/
│   ├── strategy/
│   │   ├── study_type.dart              # enum
│   │   ├── study_strategy.dart          # abstract class
│   │   ├── new_study_strategy.dart      # concrete (có thể ở data/ nếu cần repo impl)
│   │   ├── srs_review_strategy.dart
│   │   └── study_strategy_factory.dart
│   ├── entities/
│   │   ├── study_session.dart
│   │   ├── study_session_status.dart    # Draft/InProgress/ReadyToFinalize/Completed/FailedToFinalize/Cancelled
│   │   ├── study_mode.dart
│   │   ├── study_context.dart
│   │   ├── flashcard.dart
│   │   └── attempt.dart
│   ├── usecases/
│   │   ├── start_study_session_usecase.dart
│   │   ├── answer_flashcard_usecase.dart
│   │   └── finalize_study_session_usecase.dart
│   └── ports/
│       ├── study_repo.dart              # interface
│       └── mode_presenter.dart          # interface UI hook
├── data/study/
│   ├── study_repo_impl.dart
│   └── mappers/
└── presentation/features/study/
    ├── mode_presenter_impl.dart         # implement ModePresenter bằng widget
    └── ...
```

Rule layer (theo `CLAUDE.md`):

- `domain/study/strategy/` **không** import Flutter, Drift, data.
- Concrete strategy phụ thuộc `StudyRepo` interface (`domain/study/ports/`), không phụ thuộc Drift.
- Factory + provider nằm ở `app/di/` hoặc `domain/study/strategy/` tuỳ test boundary.

---

## 7b. Clean Architecture Boundary

Áp dụng [Study Clean Architecture](../business/study/study-clean-architecture.md) vào phần code:

```
UI widget / ViewModel
   │  (chỉ gọi use case)
   ▼
Application — Use Case
   - StartStudySessionUseCase
   - AnswerFlashcardUseCase
   - FinalizeStudySessionUseCase
   │  (chọn strategy qua factory, điều phối transaction)
   ▼
Domain — StudyStrategy + StudyStrategyFactory
   │  (rule nghiệp vụ thuần)
   ▼
Domain ports — StudyRepo / ModePresenter
   │
   ▼
Data — StudyRepoImpl (Drift)
Presentation — ModePresenterImpl (widget)
```

Rule:

- **UI không gọi trực tiếp `StudyStrategy` hoặc `StudyStrategyFactory`** — luôn đi qua use case.
- **Use case là transaction boundary**: finalize commit SRS được điều phối ở đây, không ở strategy.
- **Strategy thuần domain**: không biết gì về Drift, Flutter, widget. Chỉ nhận `StudyRepo` (port) và `ModePresenter` (port).
- **Factory không chứa logic nghiệp vụ**: chỉ làm dispatch `StudyType → StudyStrategy`.

### Flow tổng quát

```txt
UI
→ StartStudySessionUseCase
→ StudyStrategyFactory
→ StudyStrategy.run()
→ StudyRepo
```

```txt
UI (user answer)
→ AnswerFlashcardUseCase
→ StudyStrategy (xử lý attempt, retry batch)
→ AttemptRecorder + SessionProgressUpdater
```

```txt
UI (hoàn thành)
→ FinalizeStudySessionUseCase
→ StudyStrategy.commitResult()
→ Transaction boundary
→ StudyRepo
```

---

## 8. Test strategy

- **Unit test strategy**: mock `StudyRepo` + `ModePresenter` → test `run()` end-to-end cho từng strategy. Retry loop, mode queue, commit được verify ở đây.
- **Unit test engine**: test `_runModeWithRetryLoop` qua 1 `FakeStudyStrategy` có `buildModeQueue` đơn giản. Verify điều kiện dừng là `retryBatch.isEmpty`, không phải số lượt cố định.
- **Unit test factory**: verify lookup đúng enum, throw khi thiếu, throw khi trùng.
- **Widget/integration test**: chạy `MemoxApp` thật với `ModePresenter` thật, fake repo — đảm bảo full flow pass 5 mode của `NewStudyStrategy`.

---

## 9. Checklist khi code

Trước khi mở PR cho một strategy mới:

- [ ] `handleType` return đúng 1 enum, không trùng với strategy khác.
- [ ] `loadBatch` không lọt flashcard không hợp lệ (ví dụ SRS Review không nhận thẻ chưa due).
- [ ] `buildModeQueue` không rỗng — engine không chạy được nếu rỗng.
- [ ] `commitResult` là 1 transaction; rollback toàn bộ nếu 1 thẻ fail.
- [ ] Không có `if (type == ...)` / `switch (type)` ngoài factory.
- [ ] Unit test phủ: happy path, retry loop nhiều vòng, user thoát giữa chừng (resume), commit rollback.
- [ ] `python tools/guard/run.py --policy memox` clean.
- [ ] `flutter analyze` clean.
