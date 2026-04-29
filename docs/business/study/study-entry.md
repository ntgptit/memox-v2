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

## Rule resume và bắt đầu phiên mới

- Nếu entry point đang có session dang dở có thể resume, Study Entry phải tách rõ 2 CTA:
  - `Continue session`: mở đúng session đang dang dở, không tạo batch mới và không thay đổi session history
  - `Start new session`: tạo session mới từ entry point hiện tại
- Khi user chọn `Start new session` trong lúc còn session dang dở, app phải confirm trước:
  - `Starting a new session will cancel the current unfinished session.`
- Nếu user confirm, session cũ đi theo rule restart/supersede trong [Study Session](./study-session.md#rule-restart-session):
  - session cũ không còn dùng để resume
  - session mới lấy lại dữ liệu hiện tại tại thời điểm tạo
  - kết quả/SRS đã ghi trước đó không rollback

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

## Rule Dashboard học hôm nay

Dashboard là entry point chính để trả lời câu hỏi user nên học gì trong ngày.
Dashboard không được ưu tiên Library summary hơn hành động học.

Dashboard phải tách rõ bốn khối nghiệp vụ:
- Today Review:
  - số thẻ quá hạn
  - số thẻ due trong hôm nay
  - CTA Review now mở entry point danh sách hôm nay
- New Study:
  - số thẻ mới đang có trong thư viện
  - CTA Start new study đưa user tới Library để chọn deck hoặc folder vì New Study từ danh sách hôm nay chưa hỗ trợ trong v1
- Resume:
  - số session đang mở hoặc có thể tiếp tục
  - CTA Continue session mở session duy nhất nếu chỉ có một session, hoặc mở Progress nếu có nhiều session
- Library health:
  - tổng số folder
  - tổng số deck
  - tổng số thẻ
  - mastery toàn thư viện

Today Review chỉ tính thẻ đã học có `due_at` nằm trong hôm nay hoặc trước hôm nay.
New Study chỉ tính thẻ chưa có tiến độ học hoàn chỉnh theo rule New Study hiện hành.
Resume chỉ tính session có trạng thái đang học, sẵn sàng finalize hoặc finalize lỗi.

## Tài liệu liên quan

- [Study Index](./study-index.md)
- [Study Concepts](./study-concepts.md)
- [New Study Flow](./new-study-flow.md)
- [SRS Review Flow](./srs-review-flow.md)
- [Study Session](./study-session.md)
- [Study Modes](./study-modes.md)
- [Study Settings](./study-settings.md)
- [SRS Rules](../srs/srs-rules.md)
