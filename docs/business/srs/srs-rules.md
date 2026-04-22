# SRS Rules

## Rule dịch chuyển box
- Làm tốt:
  - tăng box
- Chưa tốt:
  - giữ hoặc giảm box
- Quên:
  - rơi về box thấp hơn, có thể về box đầu

## Rule khoảng ôn cho 8 box
- Box 1:
  - học ngay hoặc trong ngày
- Box 2:
  - 1 ngày
- Box 3:
  - 3 ngày
- Box 4:
  - 7 ngày
- Box 5:
  - 14 ngày
- Box 6:
  - 30 ngày
- Box 7:
  - 60 ngày
- Box 8:
  - 120 ngày

## Rule lập lịch
- Mỗi box có khoảng ôn riêng
- Sau mỗi lần chấm:
  - cập nhật box mới
  - cập nhật ngày ôn tiếp theo

## Rule daily pool
Danh sách hằng ngày gồm:
- thẻ mới
- thẻ due trong hôm nay
- thẻ quá hạn
- Daily pool là nguồn dữ liệu của entry point danh sách hôm nay

## Rule với study type
- Học mới:
  - chỉ lấy thẻ chưa học
- Học due (`Review` trên UI):
  - chỉ lấy thẻ đã đến due
  - gồm cả thẻ quá hạn
- Học hỗn hợp:
  - lấy cả thẻ mới và thẻ đã đến due

## Rule mapping kết quả chấm sang nhánh SRS
- `correct`:
  - map vào nhánh làm tốt
- `remembered`:
  - map vào nhánh làm tốt
- `incorrect`:
  - map vào nhánh chưa tốt
- `forgot`:
  - map vào nhánh quên

## Rule ưu tiên thẻ quá hạn
- Thẻ quá hạn là tập con của thẻ due
- Nếu session bật ưu tiên thẻ quá hạn và số thẻ due vượt giới hạn batch:
  - chọn thẻ quá hạn trước
- Sau khi đã ưu tiên thẻ quá hạn, phần thẻ còn lại mới được xét tiếp theo session control hiện hành

## Rule suy ra trạng thái flashcard
- `mới`:
  - chưa có lượt học nào
- `đang học`:
  - đã có lượt học
  - và `due_at` sau hôm nay
- `đến hạn`:
  - `due_at` nằm trong hôm nay
- `quá hạn`:
  - `due_at` trước hôm nay

## Rule với mode học
- Mode học chỉ khác cách tương tác
- Không mode nào tự xử lý SRS riêng

## Tài liệu liên quan
- [Study Entry](../study/study-entry.md)
- [Study Modes](../study/study-modes.md)
- [Flashcard Rules](../flashcard/flashcard-rules.md)
