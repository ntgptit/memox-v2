# Study Settings

## User cấu hình được
- số flashcard cho batch học mới
- số flashcard cho batch due
- số flashcard cho batch hỗn hợp mới và due
- bật hoặc tắt shuffle flashcard
- bật hoặc tắt shuffle đáp án
- chọn 1 trong 3 rule pool học:
  - chỉ học thẻ mới
  - chỉ học thẻ due
  - trộn thẻ mới và thẻ due
- bật hoặc tắt ưu tiên thẻ quá hạn

## Rule áp dụng
- Settings áp dụng khi tạo session mới
- Settings chỉ là giá trị mặc định trước khi user vào học
- Batch size được dùng sau bước filter và sau bước ưu tiên thẻ quá hạn nếu có
- Nếu số thẻ hợp lệ ít hơn settings:
  - lấy toàn bộ
- Shuffle flashcard chỉ áp dụng sau khi đã chốt tập thẻ của session
- Shuffle đáp án chỉ áp dụng trong mode học có hỗ trợ đáp án để tráo
- Trong 1 session chỉ áp dụng đúng 1 rule pool học
- Chỉ học thẻ mới tương ứng với session chỉ lấy thẻ mới
- Chỉ học thẻ due tương ứng với session chỉ lấy thẻ due và quá hạn
- Trộn thẻ mới và thẻ due tương ứng với session học hỗn hợp
- Nếu user đổi lại study type hoặc session control lúc vào học:
  - lựa chọn lúc vào học sẽ override settings mặc định cho session hiện tại
- Nếu bật ưu tiên thẻ quá hạn:
  - thẻ quá hạn được chọn trước thẻ vừa đến due khi cần giới hạn batch
- Settings không tự thay đổi kết quả SRS; chỉ thay đổi cách tạo session

## Tài liệu liên quan
- [Study Entry](./study-entry.md)
- [Study Session](./study-session.md)
