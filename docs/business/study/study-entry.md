# Study Entry

> File này tập trung vào entry point và ưu tiên settings vs lựa chọn tại entry.
> Flow học cụ thể: [New Study Flow](./new-study-flow.md) / [SRS Review Flow](./srs-review-flow.md).

## Entry point hỗ trợ

- deck
- folder hoặc sub-folder
- danh sách hôm nay
- nhóm deck (nếu sau này hỗ trợ)

## Study flow chọn tại entry

Khi user bấm học từ deck, folder hoặc danh sách hôm nay, hệ thống cho chọn:
- New Study
- SRS Review

Rule của mỗi flow: xem [New Study Flow](./new-study-flow.md) và [SRS Review Flow](./srs-review-flow.md).

## Rule ưu tiên giữa settings và lựa chọn lúc vào học

- Study settings chỉ cung cấp giá trị mặc định
- Nếu user chọn lại study flow hoặc session control lúc vào học:
  - lựa chọn tại entry point được ưu tiên cho session hiện tại
  - không ghi đè settings mặc định của user

## Rule học từ danh sách hôm nay

Danh sách hôm nay dùng daily pool toàn cục của app.

Daily pool gồm:
- thẻ mới
- thẻ due trong hôm nay
- thẻ quá hạn

Khi học từ danh sách hôm nay:
- SRS Review chỉ lấy thẻ due và quá hạn trong daily pool

Giới hạn v1:
- New Study từ danh sách hôm nay chưa hỗ trợ
- mixed flow chưa hỗ trợ

Sau khi lọc theo daily pool, flow tạo batch vẫn đi qua đúng rule của [SRS Review Flow — Rule tạo batch](./srs-review-flow.md#rule-tạo-batch).

## Tài liệu liên quan

- [Study Index](./study-index.md)
- [Study Concepts](./study-concepts.md)
- [New Study Flow](./new-study-flow.md)
- [SRS Review Flow](./srs-review-flow.md)
- [Study Session](./study-session.md)
- [Study Modes](./study-modes.md)
- [Study Settings](./study-settings.md)
- [SRS Rules](../srs/srs-rules.md)
