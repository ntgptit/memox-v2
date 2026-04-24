# Study — Index

Tài liệu Study của MemoX được tách theo nhóm đối tượng + flow dev. Dùng file này làm bản đồ điều hướng.

## Khái niệm nền

- [Study Concepts](./study-concepts.md) — Session, Flow, Mode, Retry Batch, Attempt, Progress, Status.
- [Study Entry](./study-entry.md) — user bắt đầu học từ đâu (deck / folder / hôm nay) + rule ưu tiên settings vs lựa chọn entry.

## Flow học

- [New Study Flow](./new-study-flow.md) — học flashcard mới, bắt buộc 5 mode, retry loop trong mode.
- [SRS Review Flow](./srs-review-flow.md) — ôn đến hạn, chỉ Fill mode, merge retry + commit SRS cuối session.
- [Retry Loop](./retry-loop.md) — rule chung của vòng retry, điều kiện dừng `retryBatch.isEmpty`.

## Mode tương tác

- [Study Modes](./study-modes.md) — Review / Match / Guess / Recall / Fill, rule tương tác và shuffle.

## Session

- [Study Session](./study-session.md) — resume, restart, bỏ qua, huỷ sớm, session status, commit boundary, history.
- [Study Settings](./study-settings.md) — batch size, shuffle, ưu tiên quá hạn + ràng buộc không phá flow.

## Kỹ thuật / Mở rộng

- [Study Strategy](./study-strategy.md) — Strategy + Factory + Template Method + Hook, khung mở rộng flow mới.
- [Study Clean Architecture](./study-clean-architecture.md) — layer boundary, use case, transaction boundary, flow tổng quát.

## Tài liệu liên quan

- [SRS Overview](../srs/srs-overview.md)
- [SRS Rules](../srs/srs-rules.md)
- [Study Engine Architecture (code contract)](../../architecture/study-engine.md)
