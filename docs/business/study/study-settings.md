# Study Settings

> Rule học / flow chính không thuộc file này.
> Xem [New Study Flow](./new-study-flow.md), [SRS Review Flow](./srs-review-flow.md), [Retry Loop](./retry-loop.md).

## User cấu hình được

- số flashcard cho batch học mới (`newStudyBatchSize`)
- số flashcard cho batch review (`reviewBatchSize`)
- bật hoặc tắt shuffle flashcard
- bật hoặc tắt shuffle đáp án
- bật hoặc tắt ưu tiên thẻ quá hạn

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
