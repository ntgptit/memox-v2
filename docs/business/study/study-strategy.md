# Study Strategy

> Khung mở rộng flow học bằng Strategy + Factory + Template Method + Hook.
> Code contract chi tiết: [Study Engine Architecture](../../architecture/study-engine.md).

## Mục tiêu

Tách logic học theo flow để dễ mở rộng.

[New Study](./new-study-flow.md) và [SRS Review](./srs-review-flow.md) có nhiều bước giống nhau nhưng khác rule. Sau này Game Study, Challenge Study, Test Study có thể thêm logic riêng mà không phá flow hiện tại.

---

## Strategy Pattern

### StudyFlowStrategy

Mỗi strategy chịu trách nhiệm:

- xác định flow type
- xác định mode bắt buộc
- tạo batch
- xử lý answer
- xử lý retry
- kiểm tra điều kiện pass
- finalize session

### Strategy ban đầu

- `NewStudyFlowStrategy`
- `SrsReviewFlowStrategy`

### Strategy mở rộng sau này

- `GameStudyFlowStrategy`
- `ChallengeStudyFlowStrategy`
- `TestStudyFlowStrategy`

---

## Factory Pattern

### Mục tiêu

Factory chọn strategy theo `StudyFlowType`.

UI và use case không tự viết if/else cho từng flow.

### Rule

Factory nhận:

- `StudyFlowType`

Factory trả về:

- `StudyFlowStrategy` tương ứng

Nếu không có strategy phù hợp:

- throw error rõ ràng
- fail fast

---

## Template Method + Hook Method

### Mục tiêu

Base strategy giữ skeleton flow chung.

Concrete strategy chỉ override phần khác biệt.

Hook method dùng để mở extension point có kiểm soát.

### BaseStudyFlowStrategy

Base class nên giữ:

- skeleton start session
- skeleton answer
- skeleton retry loop
- skeleton finalize
- common validation
- common attempt recording
- common session progress update

### Required method

Class con bắt buộc implement các method khác biệt như:

- get flow type
- get required modes
- filter eligible flashcards
- build finalize result
- apply finalize result

### Hook method

Class con có thể override khi cần:

- `beforeStart`
- `afterStart`
- `beforeAnswer`
- `afterAnswer`
- `beforeFinalize`
- `afterFinalize`

Hook mặc định là no-op.

### Rule giới hạn hook

- không mở hook bừa bãi
- không cho subclass phá invariant
- bước transaction/finalize quan trọng phải được kiểm soát ở use case hoặc base flow
- hook chỉ dùng cho biến thể hợp lệ
- **business rule core không được đặt ở hook** — phải ở required method

---

## Rule mở rộng — thêm flow thứ N

Quy trình cố định để thêm một study flow mới:

1. thêm giá trị vào `StudyFlowType` enum
2. tạo class `XxxFlowStrategy extends BaseStudyFlowStrategy`
3. override các required method
4. đăng ký strategy vào factory (qua provider/DI)
5. **không** sửa base strategy
6. **không** sửa factory core
7. **không** thêm `switch (flowType)` ở UI / use case

---

## Rule tổng kết

```txt
Study flow phải mở rộng bằng Strategy + Factory.
Base class giữ template flow.
Hook method chỉ dùng cho extension point hợp lệ.
Không để BaseStudyFlowStrategy phình thành God class.
```

## Tài liệu liên quan

- [Study Clean Architecture](./study-clean-architecture.md)
- [Study Engine Architecture (code contract)](../../architecture/study-engine.md)
- [New Study Flow](./new-study-flow.md)
- [SRS Review Flow](./srs-review-flow.md)
