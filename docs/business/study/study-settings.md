# Study Settings

> Rule học / flow chính không thuộc file này.
> Xem [New Study Flow](./new-study-flow.md), [SRS Review Flow](./srs-review-flow.md), [Retry Loop](./retry-loop.md).

## User cấu hình được

- số flashcard cho batch học mới (`newStudyBatchSize`)
- số flashcard cho batch review (`reviewBatchSize`)
- bật hoặc tắt shuffle flashcard
- bật hoặc tắt shuffle đáp án
- bật hoặc tắt ưu tiên thẻ quá hạn
- bật hoặc tắt auto-play phát âm trong Study UI
- chọn ngôn ngữ TTS cho mặt trước: chỉ `Korean` hoặc `English`
- chỉnh tốc độ phát âm TTS trong khoảng `0.3x` đến `0.7x`
- chọn voice hệ thống nếu platform có voice cho `ko-KR` hoặc `en-US`

## Rule áp dụng cơ bản

- settings chỉ áp dụng khi tạo session mới
- không thay đổi session đang học dở
- batch size áp dụng sau bước filter và random
- nếu số flashcard hợp lệ ít hơn batch size, lấy toàn bộ

## Shuffle

- Shuffle flashcard chỉ áp dụng sau khi đã chốt tập thẻ của session
- Shuffle đáp án chỉ áp dụng trong mode có hỗ trợ đáp án để tráo (Match)
- Shuffle đáp án không làm thay đổi thứ tự flashcard trong session

## Ưu tiên thẻ quá hạn

- Chỉ áp dụng cho SRS Review
- Nếu bật: thẻ quá hạn được chọn trước thẻ vừa đến due khi cần giới hạn batch
- Áp dụng trước bước cắt batch theo `reviewBatchSize`

## Speech / TTS v1

- TTS v1 dùng on-device engine qua platform; không yêu cầu Cloud TTS hoặc API key.
- App chỉ support phát âm tiếng Hàn và tiếng Anh:
  - `Korean` map tới locale `ko-KR`
  - `English` map tới locale `en-US`
- TTS không support tiếng Việt trong v1, kể cả khi app language đang là Vietnamese.
- Chỉ front / term được phép phát âm. Back / meaning không có nút phát và không auto-play.
- Default: `frontLanguage = Korean`, `rate = 0.5`, `autoPlay = false`.
- Cấu hình Speech v1 là global user preference lưu bằng SharedPreferences; không ghi vào DB deck/folder và không cần migration.
- Nếu platform không có voice cho `ko-KR` hoặc `en-US`, voice picker hiển thị empty/disabled state nhưng nút phát vẫn best-effort theo engine mặc định của platform.
- Khi user bấm phát âm nhiều lần, app phải stop audio đang phát trước khi speak lượt mới để tránh overlap.
- Auto-play chỉ phát nội dung đã hiển thị hoặc vừa reveal trong Study UI; không thay đổi grading, retry, session progress hoặc SRS.

## Override bằng lựa chọn tại entry

- Nếu user đổi study flow hoặc session control lúc vào học, lựa chọn tại entry override settings mặc định cho session hiện tại
- Không ghi đè settings mặc định của user
- Xem [Study Entry — Rule ưu tiên](./study-entry.md#rule-ưu-tiên-giữa-settings-và-lựa-chọn-lúc-vào-học)

## Ràng buộc — không được phá flow chính

Settings **không được**:
- tắt rule pass trong mode
- tắt retry round bắt buộc
- bỏ qua mode bắt buộc của New Study (phải đi đủ 5 mode)
- bỏ qua `Fill` trong SRS Review
- thay đổi kết quả SRS trực tiếp

Settings chỉ thay đổi **cách tạo session**, không thay đổi **rule flow**.

## Tài liệu liên quan

- [Study Index](./study-index.md)
- [New Study Flow](./new-study-flow.md)
- [SRS Review Flow](./srs-review-flow.md)
- [Study Entry](./study-entry.md)
- [Study Session](./study-session.md)
- [Study Modes](./study-modes.md)
