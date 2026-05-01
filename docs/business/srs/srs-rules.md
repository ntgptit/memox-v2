# SRS Rules

## Rule dịch chuyển box
- Làm tốt:
  - tăng box
- Chưa tốt:
  - giữ hoặc giảm box
- Quên:
  - rơi về box thấp hơn, có thể về box đầu

## Rule khoảng ôn cho 8 box
- Box 1:
  - học ngay hoặc trong ngày
- Box 2:
  - 1 ngày
- Box 3:
  - 3 ngày
- Box 4:
  - 7 ngày
- Box 5:
  - 14 ngày
- Box 6:
  - 30 ngày
- Box 7:
  - 60 ngày
- Box 8:
  - 120 ngày

## Rule lập lịch
- Mỗi box có khoảng ôn riêng
- Với New Study, sau khi flashcard pass đủ 5 mode:
  - flashcard được xem là đã học
  - stage box ban đầu là box 2
  - stage ngày ôn tiếp theo là `now + 1 day`
  - stage review result chính thức là `initial_passed`; retry history vẫn nằm trong `study_attempts`
- Với SRS Review, khi Fill mode kết thúc và retry batch rỗng:
  - stage box mới
  - stage ngày ôn tiếp theo
  - flashcard từng sai trong mode được stage giảm box hoặc due sớm hơn
  - không cập nhật SRS nhiều lần theo từng attempt sai
- Tăng box, giảm box và `due_at` chính thức chỉ được commit khi New Study hoặc SRS Review session chuyển sang `completed`
- Không cập nhật `flashcard_progress` khi session còn đang chạy
- Với SRS Review, không cập nhật SRS khi user đang trả lời, flashcard vừa đúng, flashcard vừa sai, retry batch chưa rỗng hoặc Fill mode chưa hoàn thành
- SRS Review finalize phải commit toàn bộ batch trong một transaction
- Nếu một flashcard cập nhật lỗi, rollback toàn bộ cập nhật SRS và không đánh dấu session `completed`
- Các lượt trả lời New Study trước khi flashcard pass đủ 5 mode chỉ lưu vào session progress và session history
- Không cập nhật `due_at` chính thức cho New Study khi flashcard chưa pass đủ 5 mode trong session

## Rule daily pool
Danh sách hằng ngày gồm:
- thẻ mới
- thẻ due trong hôm nay
- thẻ quá hạn
- Daily pool là nguồn dữ liệu của entry point danh sách hôm nay

## Rule với study type
- New Study:
  - chỉ lấy thẻ chưa học
- SRS Review:
  - chỉ lấy thẻ đã đến due
  - gồm cả thẻ quá hạn
  - không lấy flashcard chưa học
  - chỉ dùng Fill mode
  - bắt retry trong Fill cho tới khi retry batch rỗng

## Rule mapping kết quả chấm sang nhánh SRS
- Với New Study, sau khi flashcard đã pass đủ 5 mode trong session, review result chính thức là `initial_passed` để phân biệt với SRS Review `perfect`
- Với SRS Review, mapping dưới đây áp dụng khi Fill mode kết thúc
- Nếu SRS Review flashcard từng sai trong Fill mode:
  - review result là `recovered`
  - kết quả chính thức map vào nhánh chưa tốt hoặc quên theo rule chấm hiện hành
- Nếu SRS Review flashcard pass Fill mà không sai:
  - review result là `perfect`
  - kết quả chính thức map vào nhánh làm tốt
- `correct`:
  - map vào nhánh làm tốt
- `incorrect`:
  - map vào nhánh chưa tốt
  - trong SRS Review được xem là attempt fail, vẫn vào retry batch cho tới khi pass retry
  - review result cuối cùng là `recovered` nếu flashcard từng sai nhưng pass retry
  - finalize giảm box hoặc đặt lịch ôn sớm hơn theo rule `recovered`

## Rule ưu tiên thẻ quá hạn
- Thẻ quá hạn là tập con của thẻ due
- Nếu session bật ưu tiên thẻ quá hạn và số thẻ due vượt giới hạn batch:
  - chọn thẻ quá hạn trước
- Sau khi đã ưu tiên thẻ quá hạn, phần thẻ còn lại mới được xét tiếp theo session control hiện hành

## Rule suy ra trạng thái flashcard
- `mới`:
  - chưa pass New Study đủ 5 mode
- `đang học`:
  - đã pass New Study đủ 5 mode
  - và `due_at` sau hôm nay
- `đến hạn`:
  - `due_at` nằm trong hôm nay
- `quá hạn`:
  - `due_at` trước hôm nay

## Rule với mode học
- Mode học chỉ khác cách tương tác
- Không mode nào tự xử lý SRS riêng
- Pass trong mode New Study dùng cùng raw result với SRS:
  - `correct` được xem là pass mode
  - `incorrect` được xem là chưa pass mode
- Retry round trong mode không tạo nhánh SRS riêng
- Mỗi lượt chấm thật trong round đầu hoặc retry round vẫn được ghi vào session history
- New Study chỉ cập nhật SRS chính thức khi flashcard pass đủ `Review`, `Match`, `Guess`, `Recall`, `Fill` trong session
- New Study finalize không dùng `perfect`; các lượt sai rồi retry pass vẫn được lưu bằng attempt history, còn `last_result=initial_passed`
- SRS Review stage SRS khi Fill mode kết thúc và retry batch rỗng
- SRS Review flashcard từng sai trong Fill mode được stage giảm box hoặc due sớm hơn
- SRS Review không cập nhật SRS nhiều lần theo từng attempt sai
- New Study và SRS Review chỉ commit SRS chính thức khi session hoàn thành
- Nếu New Study flashcard chưa pass đủ 5 mode:
  - lưu tiến độ session
  - chưa xem là hoàn thành học đầy đủ
  - chưa cập nhật due date chính thức

## Tài liệu liên quan
- [Study Index](../study/study-index.md)
- [New Study Flow](../study/new-study-flow.md)
- [SRS Review Flow](../study/srs-review-flow.md)
- [Study Modes](../study/study-modes.md)
- [Flashcard Rules](../flashcard/flashcard-rules.md)
