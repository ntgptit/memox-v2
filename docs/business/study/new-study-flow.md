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

Riêng Review mode:

- user xem trực tiếp `front` và `back` của từng flashcard
- app stage mỗi flashcard đã xem là `correct`
- khi user tới thẻ cuối, app tự flush một batch attempt `correct` cho toàn bộ item pending trong Review mode sau delay 2 giây
- Review mode không tạo retry batch vì không còn input `incorrect` trong UI Review
- nếu user rời màn hình trước khi auto-submit chạy, không có attempt nào được ghi và session resume lại Review mode như cũ

Riêng Match mode:

- user ghép toàn bộ cặp trong current Match round trên UI board
- UI board chia current Match round thành các display batch tối đa 5 cặp
- hoàn tất display batch hiện tại chỉ chuyển sang display batch kế tiếp, chưa ghi attempt
- mismatch chỉ hiển thị feedback tạm thời và stage flashcard đó là `incorrect`
- không ghi attempt, không complete item, và không tạo retry tại thời điểm mismatch
- khi toàn bộ display batch của Match round được ghép xong, app flush một batch attempt cho toàn bộ pending Match item trong cùng transaction
- flashcard từng mismatch trong round ghi `incorrect`; flashcard không từng mismatch ghi `correct`
- nếu batch có item `incorrect`, chỉ các flashcard sai được đưa vào retry Match round kế tiếp
- nếu toàn bộ item `correct`, Match mode pass và chuyển mode tiếp theo

Với các mode Guess / Recall / Fill:

Khi user trả lời đúng:

- stage flashcard là kết quả pass của mode hiện tại (`correct`) trong state tạm
- không ghi attempt ngay tại thời điểm trả lời
- không đưa vào retry batch nếu batch cuối mode được flush thành công

Khi user trả lời sai:

- báo sai cho user
- stage flashcard là kết quả fail của mode hiện tại (`incorrect`) trong state tạm
- không ghi attempt ngay tại thời điểm trả lời
- chuyển sang flashcard tiếp theo trong UI
- đưa flashcard vào retry batch khi batch cuối mode được flush thành công

Sau khi đi hết lượt hiện tại:

- app flush một batch attempt cho toàn bộ pending item của current mode round trong cùng transaction
- toàn bộ pending item trong round được chuyển sang `completed` cùng timestamp
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
