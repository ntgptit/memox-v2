# Study Concepts

> Khái niệm nền dùng xuyên suốt các tài liệu Study. Mọi file khác tham chiếu về đây.

## Study Session

Một phiên học cụ thể. Bắt đầu khi user bấm học và kết thúc khi toàn bộ điều kiện hoàn thành của flow hiện tại được thỏa mãn.

Study Session quản lý:

- nguồn học
- study flow
- danh sách flashcard trong batch
- mode hiện tại
- retry batch
- attempt history
- trạng thái hoàn thành
- thời điểm finalize

Chi tiết resume / restart / huỷ / commit boundary: [Study Session](./study-session.md).

---

## Study Flow

Loại luồng học.

Flow v1:

- [New Study](./new-study-flow.md)
- [SRS Review](./srs-review-flow.md)

Flow mở rộng sau này: Game Study, Challenge Study, Test Study — xem [Study Strategy](./study-strategy.md).

Mỗi flow có rule riêng về:

- cách lấy flashcard
- mode bắt buộc
- điều kiện pass
- điều kiện finalize
- cách cập nhật SRS

---

## Study Mode

Cách user tương tác với flashcard trong session. Mode v1:

1. Review
2. Match
3. Guess
4. Recall
5. Fill

Chi tiết tương tác: [Study Modes](./study-modes.md).

---

## Retry Batch

Danh sách flashcard chưa pass trong mode hiện tại.

- lượt đầu dùng toàn bộ batch của mode
- lượt sau chỉ dùng flashcard fail của lượt trước
- flashcard pass không xuất hiện lại trong mode hiện tại
- retry loop kết thúc khi retry batch rỗng

Chi tiết: [Retry Loop](./retry-loop.md).

---

## Attempt

Ghi nhận từng lần user trả lời một flashcard trong session.

### Mỗi attempt cần lưu

- session id
- flashcard id
- study flow
- study mode
- attempt number
- answer result
- answered at

### Answer Result

Có thể gồm:

- correct
- incorrect

Sau này có thể mở rộng:

- skipped
- timeout
- partiallyCorrect

### Vai trò của attempt

- hiển thị lịch sử học
- tính retry batch
- xác định flashcard từng sai hay không
- tính review result khi finalize
- thống kê accuracy

---

## Session Progress

Trạng thái học dở để resume an toàn.

Progress bar trong màn học hiển thị tiến độ chung của toàn session, không phải
tiến độ riêng của mode hiện tại. Với `New Study`, mẫu số là số flashcard nhân
với 5 mode chính. Với `SRS Review`, mẫu số là số flashcard nhân với số mode của
flow review đó.

Tử số của progress bar chỉ tính các đơn vị đã pass (`correct`). Kết quả
`incorrect` không làm tăng progress bar, dù đã được stage trên UI hoặc đã được
ghi vào database, vì flashcard đó vẫn phải đi qua retry round để pass mode.

### Cần lưu

- session id
- flow type
- source type
- source id
- current mode
- current round
- session status
- mode progress
- retry batch
- passed flashcards trong mode hiện tại
- failed flashcards trong mode hiện tại
- attempt history

### Resume rule

- quay lại đúng session
- quay lại đúng mode hiện tại
- tiếp tục retry batch nếu có
- không tạo batch mới
- không random lại batch
- không thay đổi Study Settings của session đang dở

---

## Session Status

6 trạng thái:

| Status | Ý nghĩa |
|---|---|
| `Draft` | Session mới được tạo nhưng chưa bắt đầu học |
| `In Progress` | User đang học |
| `Ready To Finalize` | Đã pass đủ điều kiện học, chờ finalize |
| `Completed` | Session đã finalize thành công |
| `Failed To Finalize` | Session học xong nhưng finalize lỗi — có thể retry |
| `Cancelled` | User hủy session |

Rule transition và commit boundary: [Study Session](./study-session.md).

---

## Tài liệu liên quan

- [Study Index](./study-index.md)
- [New Study Flow](./new-study-flow.md)
- [SRS Review Flow](./srs-review-flow.md)
- [Retry Loop](./retry-loop.md)
- [Study Session](./study-session.md)
