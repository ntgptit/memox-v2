# Study Session

## Phiên học
Một phiên học gồm:
- xác định entry point
- xác định study type
- gom flashcard
- lọc flashcard hợp lệ
- áp dụng session control
- chọn mode học
- học từng thẻ
- ghi nhận kết quả
- cập nhật SRS

## Trạng thái session
- Session có thể ở trạng thái dang dở
- Session dang dở là session đã tạo nhưng chưa hoàn thành và chưa kết thúc sớm
- Session hoàn thành khi không còn thẻ nào cần học trong session hiện tại
- Session có thể kết thúc sớm theo chủ động của user
- Session cũ có thể ở trạng thái đã restart nếu user tạo session mới từ thao tác restart

## Thứ tự xử lý
- Xác định phạm vi học
- Gom flashcard
- Lọc theo study type
- Ưu tiên thẻ quá hạn nếu session bật rule này
- Cắt batch theo settings
- Shuffle flashcard nếu session bật rule này
- Tạo session

## Rule resume session dang dở
- User có thể resume session dang dở gần nhất
- Resume phải giữ nguyên:
  - tập thẻ còn lại
  - kết quả đã ghi trước đó
  - mode học đã chọn
  - session control đã dùng khi tạo session
- Resume không gom lại pool mới từ đầu

## Rule restart session
- Restart session tạo ra 1 session mới từ cùng entry point
- Session mới được tạo lại từ dữ liệu hiện tại tại thời điểm restart
- Session cũ chuyển sang trạng thái đã restart và không tiếp tục dùng để resume
- Restart không rollback kết quả đã ghi và không rollback cập nhật SRS đã phát sinh trước đó

## Rule bỏ qua thẻ
- User có thể bỏ qua thẻ hiện tại mà không chấm điểm
- Thẻ bị bỏ qua không được cập nhật SRS ở lần bỏ qua đó
- Thẻ bị bỏ qua được đưa về cuối queue của session hiện tại

## Rule học lại thẻ sai
- Session có thể mở vòng học lại cho các thẻ bị chấm sai hoặc quên trong session hiện tại
- Tập thẻ học lại chỉ gồm các thẻ đã bị chấm sai hoặc quên trong chính session đó
- Học lại thẻ sai là phần tiếp theo của cùng session, không phải 1 deck hay 1 pool mới
- Mỗi lượt trả lời trong vòng học lại vẫn được ghi vào session history
- Sau khi hoàn thành queue hiện tại, nếu có thẻ sai hoặc quên:
  - hệ thống hiển thị lựa chọn học lại
- Chỉ mở retry round khi user xác nhận học lại

## Rule kết thúc sớm session
- User có thể kết thúc sớm session trước khi học hết queue
- Khi kết thúc sớm, session được lưu với trạng thái kết thúc sớm
- Các kết quả đã ghi trước thời điểm kết thúc sớm vẫn được giữ nguyên
- Các thẻ chưa học trong session đó không được tự động chấm hay tự động cập nhật SRS
- Các item còn `pending` trong session đó chuyển sang trạng thái bỏ dở

## Sau mỗi thẻ cần ghi nhận
- trạng thái hoàn thành
- mức độ đúng / sai / nhớ / quên
- thời điểm hoàn thành
- box cũ
- box mới
- ngày ôn tiếp theo

## Cuối phiên học
Hiển thị:
- số thẻ đã học
- số đúng / sai
- số tăng box / giảm box
- số còn lại

## Rule lưu session history
- Mỗi session phải lưu history của chính session đó
- Session history phải lưu tối thiểu:
  - entry point
  - study type
  - mode học
  - session control đã áp dụng
  - thời điểm bắt đầu
  - thời điểm kết thúc
  - trạng thái session
  - tổng kết kết quả
  - log kết quả theo từng lượt trả lời
- Resume tiếp tục ghi thêm vào cùng session history
- Restart tạo session history mới, không ghi đè history của session cũ

## Tài liệu liên quan
- [Study Entry](./study-entry.md)
- [Study Modes](./study-modes.md)
- [Study Settings](./study-settings.md)
- [SRS Rules](../srs/srs-rules.md)
