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
  - chưa có lượt học nào
- `đang học`:
  - đã có lượt học
  - nhưng chưa đến due trong hôm nay
- `đến hạn`:
  - `due_at` rơi trong hôm nay
- `quá hạn`:
  - `due_at` trước hôm nay

## Tài liệu liên quan
- [SRS Rules](./srs-rules.md)
- [Flashcard Overview](../flashcard/flashcard-overview.md)
