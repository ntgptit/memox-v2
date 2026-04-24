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
- user vẫn phải tự chấm `remembered` hoặc `forgot` để xác định pass mode

### Match
- ghép cặp đúng
- đáp án nhiễu được sinh runtime từ các flashcard khác trong cùng scope học
- không cần persist distractor riêng trong database

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
