# Core Rules

## Rule cấu trúc
- Folder chỉ chứa sub-folder hoặc deck
- Không trộn cả 2 trong cùng 1 folder
- Flashcard luôn thuộc deck
- Không tạo flashcard trực tiếp trong folder

## Rule quản lý nội dung
- Folder, deck, flashcard đều hỗ trợ tạo và sửa
- Xóa folder là xóa cascade toàn bộ subtree của folder đó
- Xóa deck là xóa cascade toàn bộ flashcard trong deck đó
- Move là thay đổi vị trí trong cây nội dung nhưng giữ nguyên identity của đối tượng được move
- Move không làm thay đổi SRS, due date và lịch sử học của dữ liệu đang tồn tại
- Nếu folder trở thành rỗng hoàn toàn sau delete hoặc move-out:
  - khóa cấu trúc của folder được reset về trạng thái chưa chọn hướng
- Duplicate chỉ áp dụng cho deck
- Duplicate deck sao chép nội dung nhưng không sao chép tiến độ học
- Flashcard hỗ trợ tạo thủ công từng cái hoặc tạo nhiều cái liên tiếp trong cùng deck
- Import chỉ áp dụng để tạo flashcard mới vào 1 deck đích cụ thể
- Export hỗ trợ ở cấp deck hoặc cấp flashcard
- Bulk action chỉ áp dụng cho flashcard
- Bulk action được hỗ trợ gồm bulk move và bulk delete
- Reorder thủ công được hỗ trợ cho sibling folder, deck và flashcard
- Reorder là thao tác khác với sort

## Rule import export
- Hệ thống hỗ trợ import flashcard từ CSV và text theo format được hỗ trợ
- Import phải có bước preview trước khi xác nhận ghi dữ liệu
- Validate import phải chỉ ra đúng dòng hoặc block bị lỗi và lý do lỗi
- Nếu còn lỗi validation thì không được thực hiện import
- Dữ liệu import hợp lệ mới được ghi vào hệ thống
- Export mặc định phục vụ trao đổi nội dung học, không mặc định mang theo box SRS, due date và lịch sử học

## Rule tìm kiếm
- Hệ thống hỗ trợ search riêng cho folder, deck, flashcard
- Folder và deck search theo tên hiển thị
- Flashcard search theo `title` nếu có, cùng với `front` và `back`
- Kết quả search cần giữ ngữ cảnh cha để user biết đối tượng đang nằm ở đâu

## Rule sắp xếp
- Hệ thống hỗ trợ sort theo tên, mới nhất, học gần nhất
- Tên là tên hiển thị của folder hoặc deck
- Với flashcard, tên là nhãn hiển thị chính; nếu không có title riêng thì dùng front
- Mới nhất được hiểu là createdAt giảm dần
- Học gần nhất được hiểu là lastStudiedAt giảm dần
- Với deck, học gần nhất là giá trị lớn nhất của các flashcard trong deck
- Với folder, học gần nhất là giá trị lớn nhất của các flashcard trong toàn bộ subtree
- Đối tượng chưa từng có lịch sử học nằm cuối khi sort theo học gần nhất

## Rule học tập
- User có thể học từ deck hoặc folder
- Nếu học từ folder:
  - duyệt đệ quy toàn bộ cây con
  - gom tất cả flashcard trong các deck bên dưới
- User có thể học từ danh sách hôm nay dùng daily pool toàn cục
- User có thể tạo New Study hoặc SRS Review session
- New Study phải pass đủ 5 mode học theo thứ tự `Review`, `Match`, `Guess`, `Recall`, `Fill`
- SRS Review chỉ dùng Fill mode và bắt retry cho tới khi retry batch rỗng
- Không hỗ trợ học hỗn hợp mới và due như một study type chính
- Không hỗ trợ Single Mode Study làm luồng học chính
- `Fill` là mode bắt buộc trong New Study và là mode duy nhất của SRS Review
- Study settings chỉ là default; lựa chọn tại entry point sẽ override cho session hiện tại
- Session có thể resume nếu còn dang dở
- Restart session tạo session mới và không rollback SRS chính thức đã cập nhật trước đó
- User có thể bỏ qua thẻ, học lại thẻ sai trong mode hiện tại hoặc kết thúc sớm session
- Session luôn chạy trên tập flashcard đã gom

## Rule session control
- Session hỗ trợ giới hạn batch size
- Session hỗ trợ shuffle flashcard
- Session hỗ trợ shuffle đáp án nếu mode học có đáp án để tráo
- Mỗi session áp dụng đúng 1 study type: New Study hoặc SRS Review
- Session có thể ưu tiên thẻ quá hạn khi chọn pool due
- Session phải lưu history để theo dõi quá trình và kết quả học

## Rule SRS
- SRS chạy ở cấp flashcard
- Mỗi flashcard chỉ có 1 box hiện tại
- New Study chỉ commit box và due date chính thức khi New Study session hoàn thành
- SRS Review chỉ commit box và due date chính thức khi SRS Review session hoàn thành
- Không được tăng box, giảm box hoặc cập nhật due date chính thức khi session còn đang chạy

## Rule thiết kế hệ thống
- Folder là đơn vị tổ chức
- Deck là đơn vị chứa nội dung học
- Flashcard là đơn vị kiến thức nhỏ nhất
- Không bỏ deck chỉ để hỗ trợ học từ folder
