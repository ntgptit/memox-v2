# Deck Rules

## Rule tạo deck
Deck chỉ được tạo trong:
- folder rỗng chưa chọn hướng
- folder đã là loại chứa deck

## Rule sửa deck
- Sửa deck chỉ thay đổi metadata của deck
- Đổi tên deck không làm thay đổi flashcard đang thuộc deck đó

## Rule xóa deck
- Xóa deck là xóa toàn bộ flashcard trong deck
- Đây là thao tác hủy dữ liệu nên phải có xác nhận rõ ràng trước khi thực hiện
- Nếu folder cha trở thành rỗng hoàn toàn sau khi xóa deck:
  - folder cha được mở khóa về trạng thái chưa chọn hướng

## Rule move deck
- Chỉ được move deck vào folder rỗng chưa chọn hướng
- Hoặc move vào folder đã là loại chứa deck
- Không được move deck vào deck khác
- Move deck không làm thay đổi flashcard, SRS, due date và lịch sử học của các flashcard trong deck
- Nếu folder nguồn hoặc folder đích trở thành rỗng hoàn toàn sau thao tác:
  - folder đó được mở khóa về trạng thái chưa chọn hướng

## Rule reorder deck
- Hỗ trợ reorder thủ công các deck cùng folder
- Reorder chỉ thay đổi thứ tự hiển thị mặc định giữa các deck sibling
- Reorder không thay đổi folder cha và không thay đổi dữ liệu học
- Reorder là thao tác khác với sort theo tên, mới nhất hoặc học gần nhất

## Rule duplicate deck
- Duplicate tạo ra 1 deck mới từ 1 deck hiện có
- Deck mới mặc định nằm cùng folder cha với deck gốc nếu user không chọn folder đích khác
- Folder đích phải là folder hợp lệ để chứa deck
- Duplicate sao chép nội dung flashcard sang deck mới
- Duplicate không sao chép box SRS, due date, last studied và lịch sử học
- Flashcard trong deck duplicate bắt đầu như flashcard mới

## Rule import vào deck
- Import luôn phải có đúng 1 deck đích
- Import chỉ tạo flashcard mới trong deck đích
- Hỗ trợ import từ CSV
- Hỗ trợ import từ text theo format được hệ thống hỗ trợ
- Không import trực tiếp vào folder
- Flashcard được import bắt đầu như flashcard mới, không có box SRS, due date hay lịch sử học sẵn
- Import phải expose chính sách xử lý duplicate ở màn import
- MVP dùng policy `Skip exact duplicates`: nếu `front + back` trùng trong chính file import hoặc trùng với flashcard đã có trong deck đích thì bỏ qua dòng/block đó
- Nếu chỉ trùng `front` nhưng `back` khác thì vẫn import như một flashcard mới
- Các policy `Import anyway` và `Update existing cards` là hướng mở rộng sau MVP, có thể được hiển thị như lựa chọn chưa khả dụng nhưng chưa phải hành vi mặc định

## Rule preview trước khi import
- Dữ liệu import phải được parse và preview trước khi ghi thật vào hệ thống
- Preview phải cho user thấy dữ liệu sẽ được tạo thành flashcard như thế nào trong deck đích
- Preview phải giữ mapping với nguồn import để user biết từng dòng hoặc từng block sẽ tạo ra dữ liệu gì
- Nếu còn lỗi validation thì không được xác nhận import
- Preview phải cho user thấy số duplicate exact bị skip theo policy hiện tại

## Rule validate import
- Validate chạy trên toàn bộ dữ liệu import trước khi ghi
- Phải chỉ ra chính xác dòng nào hoặc block nào bị lỗi
- Phải kèm lý do lỗi để user sửa dữ liệu nguồn
- Với CSV, số dòng lỗi phải bám theo số dòng trong file nguồn
- Với text theo format nhiều dòng cho 1 flashcard, lỗi phải trỏ tới dòng bắt đầu của block lỗi
- Dòng lỗi không được ghi vào hệ thống

## Rule export deck
- Export deck là export toàn bộ flashcard đang thuộc deck đó
- Export deck không bao gồm folder cha hoặc deck khác
- Dữ liệu export phải đủ để tái tạo lại nội dung deck trong lần import sau nếu cùng format được hỗ trợ
- Export deck mặc định là export nội dung học, không bao gồm box SRS, due date và lịch sử học trừ khi có rule riêng khác sau này

## Rule search deck
- Search deck theo tên
- Kết quả cần hiển thị folder cha để phân biệt các deck cùng tên

## Rule sort deck
- Hỗ trợ sort theo tên
- Hỗ trợ sort theo mới nhất
- Hỗ trợ sort theo học gần nhất
- Mới nhất được hiểu là createdAt giảm dần
- Học gần nhất của deck là thời điểm học gần nhất của bất kỳ flashcard nào trong deck
- Deck chưa từng có lịch sử học nằm cuối khi sort theo học gần nhất

## Rule cấu trúc
- Deck không chứa sub-folder
- Deck không chứa deck con

## Rule học tập
- User có thể bắt đầu học từ deck
- Khi học từ deck, chỉ lấy flashcard trong deck đó

## Tài liệu liên quan
- [Deck Overview](./deck-overview.md)
- [Folder Rules](../folder/folder-rules.md)
- [Study Entry](../study/study-entry.md)
