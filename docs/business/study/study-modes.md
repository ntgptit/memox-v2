# Study Modes

## Danh sách mode hỗ trợ ở v1
- Review
- Match
- Guess
- Recall

## Mode planned sau v1
- Fill

## Vai trò từng mode

### Review
- xem term và meaning trực tiếp
- có thể vuốt để đổi thẻ

### Match
- ghép cặp đúng
- đáp án nhiễu được sinh runtime từ các flashcard khác trong cùng scope học
- không cần persist distractor riêng trong database

### Guess
- nhìn một phía, đoán phía còn lại

### Recall
- tự nhớ trước khi xem đáp án

### Fill
- planned sau v1
- cần data contract cloze riêng
- chưa nằm trong schema database v1

## Rule chung
- `Review` ở đây là tên mode tương tác
- `Review` mode khác với study type due
- User chọn 1 mode học trước khi bắt đầu session
- Resume session phải giữ mode học đã chọn từ trước
- Restart session có thể dùng lại mode cũ hoặc chọn mode mới nếu UI cho phép
- Các mode chỉ khác cách tương tác
- Không tự có rule SRS riêng
- Kết quả cuối cùng phải đi qua cùng một cơ chế chấm
- Shuffle đáp án chỉ áp dụng cho mode có danh sách đáp án hoặc vị trí đáp án cần tráo
- Shuffle đáp án không làm thay đổi thứ tự flashcard trong session

## Tài liệu liên quan
- [Study Session](./study-session.md)
- [Study Settings](./study-settings.md)
- [SRS Rules](../srs/srs-rules.md)
