# Flashcard Rules

## Rule cấu trúc
- Flashcard luôn thuộc 1 deck
- Không tạo flashcard trực tiếp trong folder
- Không tồn tại flashcard độc lập ngoài deck

## Rule tạo và sửa flashcard
- Chỉ tạo flashcard trong context của 1 deck cụ thể
- Sửa flashcard chỉ thay đổi nội dung hoặc metadata của chính flashcard
- Sau khi sửa, flashcard vẫn phải thuộc đúng 1 deck

## Rule tạo flashcard thủ công
- User có thể tạo thủ công từng flashcard trong 1 deck cụ thể
- Mỗi lần tạo thủ công sinh ra đúng 1 flashcard mới
- Flashcard tạo thủ công bắt đầu như flashcard mới, không có box SRS, due date hay lịch sử học sẵn

## Rule tạo nhiều flashcard liên tiếp
- Luồng tạo liên tiếp luôn giữ nguyên deck hiện tại cho đến khi user chủ động đổi context
- Sau khi lưu 1 flashcard thành công, user có thể tiếp tục tạo flashcard kế tiếp mà không phải rời màn hình tạo
- Mỗi flashcard được lưu là một bản ghi độc lập
- Nếu user dừng luồng tạo liên tiếp, các flashcard đã lưu trước đó vẫn giữ nguyên

## Rule xóa flashcard
- Hỗ trợ xóa đơn lẻ flashcard
- Hỗ trợ bulk delete nhiều flashcard
- Đây là thao tác hủy dữ liệu nên phải có xác nhận rõ ràng trước khi thực hiện

## Rule move flashcard
- Hỗ trợ move 1 flashcard sang deck khác
- Hỗ trợ bulk move nhiều flashcard sang cùng 1 deck đích
- Sau khi move, mỗi flashcard vẫn chỉ thuộc đúng 1 deck
- Move flashcard không làm thay đổi SRS, due date và lịch sử học của flashcard

## Rule reorder flashcard
- Hỗ trợ reorder thủ công flashcard trong cùng 1 deck
- Reorder chỉ thay đổi thứ tự hiển thị mặc định trong deck
- Reorder không thay đổi deck cha và không thay đổi dữ liệu học
- Reorder là thao tác khác với sort theo tên, mới nhất hoặc học gần nhất

## Rule bulk action cho flashcard
- Bulk action chỉ áp dụng trên tập flashcard được user chọn
- Bulk move yêu cầu đúng 1 deck đích cho toàn bộ tập được chọn
- Bulk delete xóa toàn bộ tập flashcard đã chọn

## Rule export flashcard
- Hỗ trợ export 1 flashcard hoặc nhiều flashcard được chọn
- Export flashcard chỉ bao gồm tập flashcard được user chọn
- Dữ liệu export phải đủ để tái tạo lại nội dung flashcard trong lần import sau nếu cùng format được hỗ trợ
- Export flashcard mặc định là export nội dung học, không bao gồm box SRS, due date và lịch sử học trừ khi có rule riêng khác sau này

## Rule search flashcard
- Search flashcard theo nội dung hiển thị chính
- Nếu mô hình card có front và back thì search áp dụng ít nhất trên front và back
- Kết quả cần hiển thị deck cha để xác định vị trí của flashcard

## Rule sort flashcard
- Hỗ trợ sort theo tên
- Hỗ trợ sort theo mới nhất
- Hỗ trợ sort theo học gần nhất
- Với flashcard, tên là nhãn hiển thị chính của flashcard
- Nếu flashcard không có title riêng thì dùng front làm khóa sort theo tên
- Mới nhất được hiểu là createdAt giảm dần
- Học gần nhất được hiểu là lastStudiedAt giảm dần
- Flashcard chưa từng có lịch sử học nằm cuối khi sort theo học gần nhất

## Rule học tập
- Flashcard là đơn vị cuối cùng được đưa vào session học
- Flashcard là đơn vị được chấm kết quả
- Flashcard là đơn vị được cập nhật box và due date

## Tài liệu liên quan
- [Deck Overview](../deck/deck-overview.md)
- [Study Session](../study/study-session.md)
- [SRS Rules](../srs/srs-rules.md)
