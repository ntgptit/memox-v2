# SRS Overview

## Mục tiêu
Ôn đúng lúc, dễ hiểu, ổn định.

## Mô hình
- Dùng SRS 8 box
- Box được đánh số từ 1 đến 8
- Flashcard mới được khởi tạo ở box 1
- Mỗi flashcard chỉ thuộc 1 box tại một thời điểm
- Box cao thì ôn thưa hơn
- Box thấp cho thẻ mới hoặc thẻ quên
- New Study chỉ commit SRS chính thức khi New Study session hoàn thành
- SRS Review chỉ commit SRS chính thức khi SRS Review session hoàn thành
- Trong lúc session đang chạy, kết quả SRS chỉ được stage để chờ commit cuối session

## Dữ liệu chính
- box hiện tại
- ngày học gần nhất
- ngày ôn tiếp theo
- số lần ôn
- lịch sử gần nhất
- trạng thái:
  - mới
  - đang học
  - đến hạn
  - quá hạn

## Trạng thái là dữ liệu suy ra
- `mới`:
  - chưa pass New Study đủ 5 mode
- `đang học`:
  - đã pass New Study đủ 5 mode
  - nhưng chưa đến due trong hôm nay
- `đến hạn`:
  - `due_at` rơi trong hôm nay
- `quá hạn`:
  - `due_at` trước hôm nay

## Tài liệu liên quan
- [Study Index](../study/study-index.md)
- [SRS Review Flow](../study/srs-review-flow.md)
- [SRS Rules](./srs-rules.md)
- [Flashcard Overview](../flashcard/flashcard-overview.md)
