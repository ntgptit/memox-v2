# Study Clean Architecture

> Layer boundary và flow tổng quát của tầng học. Code skeleton cụ thể: [Study Engine Architecture](../../architecture/study-engine.md).

## Layer

### UI Layer

- chỉ gọi use case
- không chọn strategy trực tiếp
- không import `StudyFlowStrategy` hoặc `StudyFlowStrategyFactory`

### Application Layer (Use Case)

Use case chịu trách nhiệm:

- nhận request từ UI
- gọi factory để lấy strategy
- gọi strategy
- điều phối transaction boundary
- trả result cho UI

Use case là nơi transaction boundary nằm — finalize commit SRS được điều phối ở đây, không ở strategy.

### Domain Layer

Domain chứa:

- entity
- enum
- invariant
- rule thuần nghiệp vụ
- strategy interface nếu không phụ thuộc data source
- port interface (`StudyRepo`, `ModePresenter`)

Domain **không** import Flutter, Drift, data.

### Data Layer

Data layer chứa:

- repository implementation
- local database access
- transaction implementation
- mapper giữa database model và domain model

---

## Flow tổng quát

### Start session

```txt
UI
→ StartStudySessionUseCase
→ StudyFlowStrategyFactory
→ StudyFlowStrategy
→ Repository
```

### Trả lời

```txt
UI
→ AnswerFlashcardUseCase
→ StudyFlowStrategyFactory
→ StudyFlowStrategy
→ AttemptRecorder
→ SessionProgressUpdater
```

### Hoàn thành / Finalize

```txt
UI
→ FinalizeStudySessionUseCase
→ StudyFlowStrategyFactory
→ StudyFlowStrategy
→ Transaction
→ Repository
```

---

## Rule boundary

- **UI không gọi trực tiếp `StudyFlowStrategy` hoặc `StudyFlowStrategyFactory`** — luôn đi qua use case.
- **Use case là transaction boundary**: finalize commit SRS được điều phối ở đây, không ở strategy.
- **Strategy thuần domain**: không biết gì về Drift, Flutter, widget. Chỉ nhận `StudyRepo` (port) và `ModePresenter` (port).
- **Factory không chứa logic nghiệp vụ**: chỉ dispatch `StudyFlowType → StudyFlowStrategy`.
- **Không có `switch (flowType)` ở UI hoặc use case** — factory là nơi duy nhất biết type mapping.

---

## Tài liệu liên quan

- [Study Strategy](./study-strategy.md)
- [Study Engine Architecture (code contract)](../../architecture/study-engine.md)
- [New Study Flow](./new-study-flow.md)
- [SRS Review Flow](./srs-review-flow.md)
