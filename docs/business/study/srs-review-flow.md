# SRS Review Flow

> Flow ôn flashcard đã đến hạn. Khái niệm nền: [Study Concepts](./study-concepts.md). Vòng retry chung: [Retry Loop](./retry-loop.md).

## Mục tiêu

Ôn các flashcard đã đến hạn theo SRS, nhưng vẫn ép user nhớ đúng trước khi hoàn thành session.

## Rule lấy flashcard

SRS Review chỉ lấy:

- flashcard đã học
- flashcard có due date đã đến hạn
- flashcard thuộc deck/folder được chọn
- flashcard hợp lệ để review

Không lấy:

- flashcard chưa học
- flashcard chưa đến due
- flashcard archived
- flashcard suspended nếu sau này có hỗ trợ

## Rule tạo batch

Thứ tự xử lý:

1. xác định source review
2. gom flashcard theo source
3. lọc flashcard đã đến due
4. random danh sách
5. cắt batch theo `reviewBatchSize`
6. tạo Study Session

Nếu số flashcard hợp lệ ít hơn batch size:

- lấy toàn bộ flashcard hiện có

Nếu bật ưu tiên thẻ quá hạn: thẻ quá hạn được chọn trước thẻ vừa đến due khi cần giới hạn batch — xem [Study Settings](./study-settings.md).

## Mode bắt buộc

SRS Review chỉ dùng:

1. Fill

Không chạy đủ 5 mode như New Study.

## Rule học trong Fill mode

Khi user trả lời đúng:

- stage flashcard pass Fill mode trong state tạm
- không ghi attempt ngay tại thời điểm trả lời
- không đưa vào retry batch

Khi user trả lời sai:

- báo sai cho user
- stage kết quả sai trong state tạm
- không ghi attempt ngay tại thời điểm trả lời
- chuyển sang flashcard tiếp theo
- đưa flashcard vào retry batch khi batch cuối mode được flush thành công

Nếu raw result là `incorrect`:

- vẫn xử lý như failed attempt
- vẫn đưa flashcard vào retry batch
- review result cuối cùng của flashcard là `recovered` nếu flashcard pass retry trước khi finalize
- finalize giảm box hoặc đặt lịch ôn sớm hơn theo rule `recovered`

Sau khi đi hết lượt hiện tại:

- app flush một batch attempt cho toàn bộ pending Fill item trong current round
- toàn bộ pending item trong round được chuyển sang `completed` cùng timestamp
- nếu retry batch rỗng:
  - Fill mode hoàn thành
  - Review Session sẵn sàng finalize (`Ready To Finalize`)
- nếu retry batch còn thẻ:
  - tiếp tục học retry batch trong Fill mode

Retry loop không có số lượt cố định — xem [Retry Loop](./retry-loop.md).

## Điều kiện hoàn thành SRS Review

SRS Review Session hoàn thành khi:

- toàn bộ flashcard trong batch đã pass Fill mode
- retry batch rỗng

## Rule cập nhật SRS

Trong SRS Review, **không cập nhật box/due trong lúc user đang học**.

Không cập nhật khi:

- user vừa trả lời đúng
- user vừa trả lời sai
- flashcard vừa được đưa vào retry batch
- flashcard vừa pass Fill mode
- retry batch chưa rỗng
- session chưa hoàn thành

Chỉ cập nhật SRS khi toàn bộ Review Session chuyển sang `Completed`.

## Finalize Review Session

Khi Review Session đủ điều kiện hoàn thành, hệ thống xử lý toàn bộ batch cùng lúc:

1. tổng hợp attempt của từng flashcard
2. xác định review result
3. tính box mới
4. tính due date mới
5. cập nhật flashcard progress
6. cập nhật session status = `Completed`

Finalize phải chạy theo transaction.

Nếu có lỗi khi cập nhật:

- rollback toàn bộ thay đổi SRS
- session chuyển `Failed To Finalize` (không phải `Completed`)
- cho phép retry finalize hoặc resume an toàn

## Review Result

### Perfect

Flashcard đúng ngay từ lần đầu trong review session.

Kết quả:

- tăng box hoặc giữ box theo rule SRS
- due date xa hơn

### Recovered

Flashcard từng sai bằng `incorrect` trong review session nhưng cuối cùng đã pass.

Kết quả:

- giảm box hoặc đưa về box thấp hơn theo rule SRS
- due date sớm hơn

### Recovered after incorrect

Flashcard từng có raw result `incorrect` trong review session.

Kết quả:

- vẫn retry cho đến khi pass Fill mode
- review result cuối session là `recovered`
- finalize giảm box hoặc đặt lịch ôn sớm hơn theo rule `recovered`

## Rule tổng kết

```txt
SRS Review = ôn flashcard đến due.
Chỉ học Fill mode.
Nếu sai thì retry đến khi pass (retryBatch.isEmpty).
Nếu từng incorrect thì vẫn retry, nhưng review result cuối là recovered khi pass retry.
Stage kết quả khi kết thúc Fill mode.
Chỉ commit box/due khi session chuyển Completed.
Finalize theo transaction — rollback toàn bộ nếu lỗi.
```

## Tài liệu liên quan

- [Study Concepts](./study-concepts.md)
- [Retry Loop](./retry-loop.md)
- [Study Modes](./study-modes.md)
- [Study Session](./study-session.md)
- [Study Settings](./study-settings.md)
- [SRS Rules](../srs/srs-rules.md)
