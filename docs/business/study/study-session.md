# Study Session

> Rule tạo session / pass mode / retry / finalize đã nằm ở [New Study Flow](./new-study-flow.md), [SRS Review Flow](./srs-review-flow.md), và [Retry Loop](./retry-loop.md).
> File này bổ sung rule resume, restart, bỏ qua thẻ, huỷ sớm, commit boundary, history.

## Session status

Session status theo đúng 6 trạng thái ở [Study Concepts — Session Status](./study-concepts.md#session-status):

- `Draft` — đã tạo, chưa bắt đầu
- `In Progress` — user đang học
- `Ready To Finalize` — đã pass đủ điều kiện học, chờ finalize
- `Completed` — finalize thành công
- `Failed To Finalize` — học xong nhưng finalize lỗi, có thể retry
- `Cancelled` — user hủy session

Ngoài ra, session cũ có thể được đánh dấu **đã restart** (xem Rule restart) — không phải session status, mà là metadata của session cũ.

## Rule resume session dang dở

- User có thể resume session ở trạng thái `In Progress`, `Ready To Finalize`, hoặc `Failed To Finalize`
- Resume không gom lại pool mới từ đầu, không random lại batch
- Resume tiếp tục ghi vào cùng session history
- Màn Progress phải liệt kê các session đang có thể resume/manage, gồm `In Progress`, `Ready To Finalize`, và `Failed To Finalize`, sắp xếp session mới bắt đầu gần nhất lên trước

### Resume New Study phải giữ nguyên
- tập thẻ còn lại
- kết quả đã ghi trước đó
- mode hiện tại
- retry round hiện tại trong mode hiện tại
- danh sách flashcard đã pass trong mode hiện tại
- danh sách flashcard chưa pass trong mode hiện tại
- Review mode chưa auto-submit thì không có attempt nào được ghi và phải resume lại từ queue Review chưa đổi
- các mode đã pass
- session control đã dùng khi tạo session

### Resume SRS Review phải giữ nguyên
- Fill queue hiện tại
- retry batch hiện tại
- các flashcard đã trả lời
- các flashcard chưa trả lời
- các flashcard đã pass Fill
- các flashcard chưa pass Fill
- kết quả review đã stage trước đó
- session control đã dùng khi tạo session

## Rule restart session

- Restart tạo ra 1 session mới từ cùng entry point
- Session mới được tạo lại từ dữ liệu hiện tại tại thời điểm restart
- Session cũ chuyển sang trạng thái đã restart và không tiếp tục dùng để resume
- Restart không rollback kết quả đã ghi và không rollback cập nhật SRS chính thức đã phát sinh trước đó

## Rule bỏ qua thẻ

- User có thể bỏ qua thẻ hiện tại mà không chấm điểm
- Thẻ bị bỏ qua không được cập nhật SRS ở lần bỏ qua đó
- Trong New Study, thẻ bị bỏ qua không được xem là pass mode hiện tại
- Thẻ bị bỏ qua được đưa về cuối queue của session hiện tại

## Rule điều hướng trong màn Study Session

- Back rời màn học hiện tại nhưng giữ session ở trạng thái có thể resume; không tự động hủy session và không commit các item còn pending
- Cancel là hành động hủy sớm session; luôn cần xác nhận trước khi chuyển session sang `Cancelled`
- Cancel trong mọi mode học phải dùng cùng confirmation và cùng commit boundary như rule hủy sớm session
- Mode view chỉ xử lý tương tác học của mode đó; back/cancel/finalize thuộc control boundary chung của Study Session

## Rule huỷ sớm session

- User có thể chuyển session sang `Cancelled` trước khi học hết queue
- Khi `Cancelled`, session giữ nguyên các kết quả đã ghi trước đó
- Trong New Study, các thẻ chưa pass đủ 5 mode không được tự động chấm hay tự động cập nhật SRS chính thức
- Trong SRS Review, các thẻ chưa pass Fill không được tự động chấm hay tự động cập nhật SRS
- Các item còn `pending` trong session đó chuyển sang trạng thái bỏ dở
- Không commit box / due date cho các flashcard chưa hoàn thành theo rule của flow
- Từ màn Progress, user có thể hủy một session đang mở sau khi xác nhận; rule hủy và commit boundary vẫn giống thao tác hủy trong màn học

## Rule commit SRS cuối session

- Commit SRS chỉ được phép khi session chuyển sang `Completed`
- Không được tăng box, giảm box hoặc cập nhật due date chính thức khi session ở bất kỳ trạng thái nào khác
- Commit SRS cuối session phải đồng bộ toàn bộ flashcard đủ điều kiện trong một transaction nghiệp vụ
- Nếu commit SRS lỗi với bất kỳ flashcard nào:
  - toàn bộ transaction rollback
  - session chuyển sang `Failed To Finalize` (không phải `Completed`)
  - user có thể retry finalize
- Từ màn Progress, user có thể finalize session ở trạng thái `Ready To Finalize`
- Từ màn Progress, user có thể retry finalize session ở trạng thái `Failed To Finalize`
- Sau khi finalize thành công, session không còn nằm trong danh sách session đang mở của màn Progress

### New Study commit
- box cũ
- box mới
- ngày ôn tiếp theo chính thức
- thời điểm hoàn thành New Study của flashcard

### SRS Review commit
- box cũ
- box mới
- ngày ôn tiếp theo chính thức
- review result: `perfect` hoặc `recovered`
- flashcard có từng sai trong mode hay không

## Sau mỗi lượt trả lời cần ghi nhận

Review mode trong New Study:

- vuốt qua từng flashcard chỉ là UI staging tạm thời
- khi tới thẻ cuối, app đợi 2 giây rồi ghi một batch attempt `correct` cho toàn bộ Review item còn pending trong cùng transaction
- mỗi pending Review item nhận đúng một attempt `correct`
- sau batch submit, Review mode pass và session chuyển sang mode tiếp theo hoặc `Ready To Finalize` nếu đó là mode cuối
- nếu màn hình bị dispose trước khi batch submit, không ghi attempt và không đổi session progress

Match mode trong New Study:

- chọn sai cặp chỉ là UI staging tạm thời, không ghi attempt và không đổi trạng thái item ngay lúc mismatch
- UI Match board chia current Match round thành các display batch tối đa 5 cặp; hoàn tất display batch hiện tại chỉ chuyển sang display batch kế tiếp
- khi toàn bộ display batch của Match round ghép xong, app ghi một batch attempt cho toàn bộ pending Match item trong cùng transaction
- mỗi pending Match item nhận đúng một attempt: `incorrect` nếu item từng mismatch trong round, ngược lại `correct`
- toàn bộ pending Match item trong round được chuyển sang `completed` cùng một completed timestamp
- nếu có item `incorrect`, app tạo Match retry round kế tiếp chỉ gồm các flashcard sai
- nếu toàn bộ item `correct`, session chuyển sang mode tiếp theo hoặc `Ready To Finalize` nếu đó là mode cuối

Guess / Recall / Fill trong New Study và Fill trong SRS Review:

- trả lời từng câu chỉ stage kết quả trong state tạm của màn hình, không ghi attempt và không đổi trạng thái item ngay
- khi toàn bộ pending item của current mode round đã có kết quả tạm, app ghi một batch attempt cho toàn bộ item đó trong cùng transaction
- mỗi pending item nhận đúng một attempt: `correct` hoặc `incorrect`
- toàn bộ pending item trong round được chuyển sang `completed` cùng một completed timestamp
- nếu có item fail (`incorrect`), app tạo retry round kế tiếp của chính mode đó chỉ gồm các flashcard fail
- nếu không có item fail, session chuyển sang mode tiếp theo hoặc `Ready To Finalize` nếu đó là mode cuối
- nếu màn hình bị dispose trước khi mode round flush, các kết quả tạm chưa được ghi và session resume lại từ database state chưa đổi

Với các lượt trả lời thông thường cần ghi nhận:

- trạng thái hoàn thành
- kết quả thống nhất `correct` / `incorrect`
- thời điểm hoàn thành
- mode hiện tại
- mode order
- round index
- attempt number
- trạng thái pass hoặc chưa pass trong mode hiện tại nếu là New Study

Cấu trúc attempt chi tiết: xem [Study Concepts — Attempt](./study-concepts.md#attempt).

## Cuối phiên học

Hiển thị:
- số thẻ đã học
- số thẻ mastered trên tổng số thẻ trong session
- attempt accuracy = số attempt đúng / tổng số attempt đã ghi
- số retry cards = số flashcard từng có ít nhất một attempt sai trong session
- số đúng / sai
- số tăng box / giảm box
- số flashcard đã pass đủ 5 mode nếu là New Study
- số flashcard review đã pass Fill nếu là SRS Review
- số flashcard còn lại nếu session chưa hoàn thành

## Rule lưu session history

- Mỗi session phải lưu history của chính session đó
- Session history phải lưu tối thiểu:
  - entry point
  - study flow
  - session control đã áp dụng
  - thời điểm bắt đầu
  - thời điểm kết thúc
  - session status
  - tổng kết kết quả
  - log kết quả theo từng lượt trả lời
  - mode, mode order và round index của từng lượt trả lời
  - các mode đã pass nếu là New Study
- Resume tiếp tục ghi thêm vào cùng session history
- Restart tạo session history mới, không ghi đè history của session cũ

## Tài liệu liên quan

- [Study Index](./study-index.md)
- [Study Concepts](./study-concepts.md)
- [New Study Flow](./new-study-flow.md)
- [SRS Review Flow](./srs-review-flow.md)
- [Retry Loop](./retry-loop.md)
- [Study Entry](./study-entry.md)
- [Study Modes](./study-modes.md)
- [Study Settings](./study-settings.md)
- [SRS Rules](../srs/srs-rules.md)
