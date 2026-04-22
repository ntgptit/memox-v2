# Folder Rules

## Rule chính
Một folder chỉ được theo một hướng:
- chứa sub-folder
- hoặc chứa deck

Không được chứa cả 2 cùng lúc.

## Rule khóa cấu trúc
- Nếu đã có sub-folder:
  - không được tạo deck
- Nếu đã có deck:
  - không được tạo sub-folder

## Rule tạo và sửa folder
- Có thể tạo folder ở root
- Có thể tạo sub-folder trong folder chưa bị khóa theo hướng deck
- Sửa folder chỉ thay đổi metadata của chính folder
- Đổi tên folder không được làm thay đổi cấu trúc cây con

## Rule xóa folder
- Xóa folder là xóa toàn bộ subtree bên dưới
- Subtree bị xóa gồm sub-folder, deck và flashcard thuộc cây đó
- Đây là thao tác hủy dữ liệu nên phải có xác nhận rõ ràng trước khi thực hiện
- Nếu sau khi xóa hoặc move-out child mà folder trở thành rỗng hoàn toàn:
  - reset khóa cấu trúc của folder về trạng thái chưa chọn hướng

## Rule move folder
- Không được move folder vào chính nó
- Không được move folder vào bất kỳ folder con nào của chính nó
- Folder đích phải là root hoặc folder có thể chứa sub-folder
- Không được move vào folder đã khóa theo hướng chứa deck
- Move folder không làm thay đổi SRS, due date, lịch sử học của flashcard trong cây được move
- Nếu folder nguồn hoặc folder đích trở thành rỗng hoàn toàn sau thao tác:
  - folder đó được mở khóa về trạng thái chưa chọn hướng

## Rule reorder folder
- Hỗ trợ reorder thủ công các sub-folder cùng cha
- Reorder chỉ thay đổi thứ tự hiển thị mặc định giữa các sibling
- Reorder không thay đổi cha của folder và không thay đổi dữ liệu học
- Reorder là thao tác khác với sort theo tên, mới nhất hoặc học gần nhất

## Rule search folder
- Search folder theo tên
- Kết quả cần hiển thị đường dẫn cha để phân biệt các folder cùng tên

## Rule sort folder
- Hỗ trợ sort theo tên
- Hỗ trợ sort theo mới nhất
- Hỗ trợ sort theo học gần nhất
- Mới nhất được hiểu là createdAt giảm dần
- Học gần nhất của folder là thời điểm học gần nhất của bất kỳ flashcard nào trong toàn bộ subtree
- Folder chưa từng có lịch sử học nằm cuối khi sort theo học gần nhất

## Phạm vi áp dụng
- Áp dụng cho folder gốc
- Áp dụng cho mọi sub-folder

## Rule UI
- Nếu đã khóa theo hướng sub-folder:
  - ẩn hoặc disable tạo deck
- Nếu đã khóa theo hướng deck:
  - ẩn hoặc disable tạo sub-folder
- Chặn từ UI, không chờ save

## Tài liệu liên quan
- [Folder Overview](./folder-overview.md)
- [Deck Rules](../deck/deck-rules.md)
- [Core Rules](../shared/core-rules.md)
