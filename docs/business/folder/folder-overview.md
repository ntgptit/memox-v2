# Folder Overview

## Vai trò
Folder là đơn vị tổ chức nội dung theo cây.

## Đặc điểm
- Có thể nhiều cấp
- Không chứa flashcard trực tiếp
- Có thể là điểm bắt đầu học
- Hỗ trợ tạo, sửa, xóa, di chuyển folder
- Hỗ trợ tìm kiếm và sắp xếp danh sách folder
- Có thể chứa:
  - sub-folder
  - hoặc deck

## Khi học từ folder
- Hệ thống duyệt toàn bộ cây con
- Thu thập tất cả deck bên dưới
- Gom flashcard từ các deck đó
- Metadata của tile folder chỉ mô tả cấu trúc subtree:
  - số sub-folder bên dưới
  - số deck bên dưới
  - tổng số thẻ trong subtree
- Trạng thái học không nằm trong metadata folder:
  - số thẻ đã đến hạn ôn SRS, bao gồm cả quá hạn, hiển thị bằng badge trên nút học
  - số thẻ mới được xử lý ở Study Entry theo flow user chọn
- Tile folder vẫn hiển thị mức mastery của subtree như trạng thái tiến độ riêng
- Nút học trên tile chỉ đưa user vào Study Entry; Study Entry vẫn là nơi chọn New Study hoặc SRS Review
- Với folder còn `unlocked`, màn Folder Detail vẫn hiển thị FAB tạo mới; FAB mở lựa chọn tạo subfolder hoặc deck trước khi chạy form tạo tương ứng
- Import từ bottom sheet của folder chỉ là shortcut để tạo deck mới hoặc chọn deck có sẵn làm deck đích; dữ liệu import vẫn luôn ghi vào một deck, không ghi trực tiếp vào folder

## Tài liệu liên quan
- [Folder Rules](./folder-rules.md)
- [Study Entry](../study/study-entry.md)
- [Core Rules](../shared/core-rules.md)
