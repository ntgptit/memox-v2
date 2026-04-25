# Study Modes

> Rule flow thuộc về [New Study Flow](./new-study-flow.md) / [SRS Review Flow](./srs-review-flow.md). Rule retry chung: [Retry Loop](./retry-loop.md).
> File này chỉ bổ sung chi tiết tương tác và rule phụ của từng mode.

## Danh sách mode hỗ trợ ở v1

- Review
- Match
- Guess
- Recall
- Fill

Mode nào dùng ở flow nào: xem [New Study Flow — Mode bắt buộc](./new-study-flow.md#mode-bắt-buộc) và [SRS Review Flow — Mode bắt buộc](./srs-review-flow.md#mode-bắt-buộc).

## Vai trò và chi tiết tương tác

### Review
- xem term và meaning trực tiếp
- có thể vuốt để đổi thẻ
- không hiển thị nút tự chấm `remembered` / `forgot`
- mỗi flashcard đã xem trong Review được stage là `remembered`
- khi user tới thẻ cuối, app tự ghi một batch attempt `remembered` cho toàn bộ item pending của Review mode sau delay 2 giây
- nếu màn hình bị dispose trước khi batch submit, không ghi attempt và session resume lại Review mode chưa đổi

### Match
- ghép toàn bộ cặp trong current Match round trên một board hai cột
- cột trái hiển thị `back` / definition dài; cột phải hiển thị `front` / label ngắn
- thứ tự cột phải tuân theo setting `shuffleAnswers`; nếu tắt thì giữ source order của round hiện tại
- mismatch chỉ tạo trạng thái UI tạm thời: flash lỗi, rung thẻ, reset selection, không ghi database tại thời điểm sai
- nếu một flashcard từng mismatch trong board, flashcard đó được stage là `incorrect` cho lần flush cuối board
- flashcard không từng mismatch và được ghép đúng được stage là `correct`
- khi toàn bộ board được ghép xong, app ghi một batch attempt cho toàn bộ pending item của Match round trong một transaction
- nếu batch có item `incorrect`, app tạo retry Match round kế tiếp chỉ gồm các flashcard sai
- nếu toàn bộ item `correct`, Match mode pass và chuyển sang mode tiếp theo
- không persist distractor riêng trong database

### Guess
- nhìn một phía, đoán phía còn lại

### Recall
- tự nhớ trước khi xem đáp án

### Fill
- là mode bắt buộc trong New Study (mode cuối cùng trong chuỗi 5 mode)
- là mode duy nhất của SRS Review
- user nhập đáp án cho mặt còn lại của flashcard
- Fill v1 dùng dữ liệu `front` và `back` hiện có của flashcard
- cloze nâng cao là phạm vi sau v1 và cần data contract riêng nếu được bổ sung

## Rule chung cho mode

- mode chỉ quyết định cách tương tác
- mode không tự cập nhật SRS
- mode không tự quyết định finalize session
- kết quả mode được ghi nhận qua attempt và session progress
- riêng Review mode ghi attempt theo batch ở cuối mode, không ghi từng lần vuốt thẻ
- riêng Match mode ghi attempt theo batch ở cuối board, không ghi tại thời điểm mismatch
- SRS chỉ cập nhật tại finalize boundary của session
- `Review` ở đây là tên mode tương tác, khác với study flow `SRS Review`
- Shuffle đáp án chỉ áp dụng cho mode có danh sách đáp án hoặc vị trí đáp án cần tráo
- Shuffle đáp án không làm thay đổi thứ tự flashcard trong session

## Tài liệu liên quan

- [Study Index](./study-index.md)
- [New Study Flow](./new-study-flow.md)
- [SRS Review Flow](./srs-review-flow.md)
- [Retry Loop](./retry-loop.md)
- [Study Session](./study-session.md)
- [Study Settings](./study-settings.md)
- [SRS Rules](../srs/srs-rules.md)
