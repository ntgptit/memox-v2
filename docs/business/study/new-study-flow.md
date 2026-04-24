# New Study Flow

> Flow học flashcard mới. Khái niệm nền: [Study Concepts](./study-concepts.md). Vòng retry chung: [Retry Loop](./retry-loop.md).

## Mục tiêu

Ép user học thuộc flashcard mới trong batch trước khi đưa vào SRS.

## Rule lấy flashcard

New Study chỉ lấy:

- flashcard chưa học
- flashcard thuộc deck/folder được chọn
- flashcard hợp lệ để học

Không lấy:

- flashcard đã học
- flashcard đã archived
- flashcard bị suspended nếu sau này có hỗ trợ

## Rule tạo batch

Thứ tự xử lý:

1. xác định source học
2. gom flashcard theo source
3. lọc flashcard chưa học
4. random danh sách
5. cắt batch theo `newStudyBatchSize`
6. tạo Study Session

Nếu số flashcard hợp lệ ít hơn batch size:

- lấy toàn bộ flashcard hiện có

## Mode bắt buộc

New Study phải pass đủ 5 mode theo thứ tự:

1. Review
2. Match
3. Guess
4. Recall
5. Fill

Không được bỏ mode.

Nếu user thấy session quá nặng, user chỉnh batch size trong [Study Settings](./study-settings.md).

## Rule pass trong từng mode

Trong mỗi mode, toàn bộ flashcard của batch phải pass.

Khi user trả lời đúng:

- đánh dấu flashcard pass trong mode hiện tại
- không đưa vào retry batch

Khi user trả lời sai:

- báo sai cho user
- ghi nhận attempt sai
- chuyển sang flashcard tiếp theo
- đưa flashcard vào retry batch

Sau khi đi hết lượt hiện tại:

- nếu retry batch rỗng:
  - mode hiện tại pass
  - chuyển mode tiếp theo
- nếu retry batch còn thẻ:
  - tiếp tục học retry batch trong cùng mode

Retry loop không có số lượt cố định — xem [Retry Loop](./retry-loop.md).

## Điều kiện chuyển mode

Chỉ chuyển sang mode tiếp theo khi:

- toàn bộ flashcard trong batch đã pass mode hiện tại
- retry batch rỗng

Không chuyển mode nếu còn flashcard fail.

## Điều kiện hoàn thành New Study

New Study Session hoàn thành khi:

- toàn bộ batch pass Review
- toàn bộ batch pass Match
- toàn bộ batch pass Guess
- toàn bộ batch pass Recall
- toàn bộ batch pass Fill

Sau khi hoàn thành:

- đánh dấu flashcard là đã học
- tạo/cập nhật progress SRS ban đầu với `initial_box = 2`
- tính due date đầu tiên là `now + 1 day`
- cập nhật session status = `Completed`

Commit SRS chính thức chỉ xảy ra khi session chuyển sang `Completed` — xem [Study Session](./study-session.md#rule-commit-srs-cuối-session).

## Rule tổng kết

```txt
New Study = học flashcard mới.
Phải pass đủ 5 mode.
Mỗi mode retry đến khi toàn bộ batch pass.
Chỉ hoàn thành khi pass đủ Review, Match, Guess, Recall, Fill.
Chỉ commit SRS khi session chuyển Completed.
```

## Tài liệu liên quan

- [Study Concepts](./study-concepts.md)
- [Retry Loop](./retry-loop.md)
- [Study Modes](./study-modes.md)
- [Study Session](./study-session.md)
- [Study Settings](./study-settings.md)
- [SRS Rules](../srs/srs-rules.md)
