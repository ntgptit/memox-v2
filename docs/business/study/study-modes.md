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
- không hiển thị nút tự chấm `correct` / `incorrect`
- mỗi flashcard đã xem trong Review được stage là `correct`
- khi user tới thẻ cuối, app tự ghi một batch attempt `correct` cho toàn bộ item pending của Review mode sau delay 2 giây
- nếu màn hình bị dispose trước khi batch submit, không ghi attempt và session resume lại Review mode chưa đổi

### Match
- ghép toàn bộ cặp trong current Match round bằng board hai cột
- board chỉ hiển thị tối đa 5 cặp trong một display batch để màn hình không bị quá tải
- nếu display batch có ít cặp, mỗi tile vẫn dùng chiều cao slot như layout 5 cặp và căn lên trên, không kéo giãn theo số cặp hiện có
- khi user ghép xong toàn bộ cặp trong display batch hiện tại, app chuyển sang display batch kế tiếp của cùng Match round
- cột trái hiển thị `front` / term; cột phải hiển thị `back` / meaning
- meaning dùng font size cố định giữa các tile; nếu nội dung quá dài thì giới hạn số dòng và cắt bằng ellipsis
- thứ tự cột phải tuân theo setting `shuffleAnswers`; nếu tắt thì giữ source order của round hiện tại
- mismatch chỉ tạo trạng thái UI tạm thời: flash lỗi, rung thẻ, reset selection, không ghi database tại thời điểm sai
- ghép đúng giữ success highlight trong một nhịp ngắn rồi mới fade/scale thẻ ra khỏi board
- nếu một flashcard từng mismatch trong bất kỳ display batch nào của Match round, flashcard đó được stage là `incorrect` cho lần flush cuối round
- flashcard không từng mismatch và được ghép đúng được stage là `correct`
- khi toàn bộ display batch của Match round được ghép xong, app ghi một batch attempt cho toàn bộ pending item của Match round trong một transaction
- nếu batch có item `incorrect`, app tạo retry Match round kế tiếp chỉ gồm các flashcard sai
- nếu toàn bộ item `correct`, Match mode pass và chuyển sang mode tiếp theo
- không persist distractor riêng trong database

### Guess
- là mode trắc nghiệm: prompt hiển thị `front`, danh sách lựa chọn hiển thị tối đa 5 `back` gồm đáp án đúng và tối đa 4 distractor
- các option meaning trong cùng màn hình có chiều cao bằng nhau và lấp đầy vùng danh sách; meaning dài bị giới hạn dòng và cắt bằng ellipsis
- user chọn một option để app tự chấm, không hiển thị nút tự chấm `correct` / `incorrect`
- chọn đúng làm option được chọn chuyển trạng thái success
- chọn sai làm option được chọn chuyển trạng thái error và đồng thời tô success cho option đúng
- sau feedback delay ngắn trong khoảng 500-800ms, app stage kết quả của current item bằng `correct` hoặc `incorrect` trong state tạm và chuyển sang item tiếp theo của mode
- khi toàn bộ pending item trong current Guess round đã có kết quả tạm, app ghi một batch attempt cho cả round trong cùng transaction
- nếu batch có item `incorrect`, app tạo retry Guess round kế tiếp chỉ gồm các flashcard sai
- nếu toàn bộ item `correct`, Guess mode pass và chuyển sang mode tiếp theo
- nếu batch submit thất bại, lựa chọn tạm thời của item cuối được reset để user có thể chọn lại

### Recall
- prompt hiển thị `front` trong thẻ câu hỏi
- thẻ đáp án hiển thị `back` nhưng bị che/blur ở trạng thái ban đầu để user không đọc được trước khi lật
- khi đáp án đang che, nút `Hiển thị` chạy timer 20 giây
- bấm `Hiển thị` trước khi hết giờ chỉ reveal đáp án trên UI, không ghi attempt và không đổi session progress
- nếu timer 20 giây hết trước khi user bấm `Hiển thị`, app tự reveal đáp án và chuyển sang trạng thái timeout
- sau khi đáp án được reveal chủ động, user tự báo `Đã quên` hoặc `Nhớ được`
- `Đã quên` stage `incorrect` cho current item và chuyển sang item tiếp theo của mode
- `Nhớ được` stage `correct` cho current item và chuyển sang item tiếp theo của mode
- ở trạng thái timeout, không hiển thị nút `Đã quên` / `Nhớ được`; chỉ hiển thị `Tiếp theo`
- bấm `Tiếp theo` sau timeout stage `incorrect` cho current item
- khi toàn bộ pending item trong current Recall round đã có kết quả tạm, app ghi một batch attempt cho cả round trong cùng transaction
- nếu batch có item `incorrect`, app tạo retry Recall round kế tiếp chỉ gồm các flashcard quên
- nếu toàn bộ item `correct`, Recall mode pass và chuyển sang mode tiếp theo
- nếu batch submit thất bại, màn hình giữ trạng thái đã reveal để user có thể thử lại

### Fill
- là mode bắt buộc trong New Study (mode cuối cùng trong chuỗi 5 mode)
- là mode duy nhất của SRS Review
- prompt hiển thị `back` / meaning để user nhập `front` / term
- Fill v1 dùng dữ liệu `front` và `back` hiện có của flashcard, so khớp đáp án bằng giá trị đã trim và không phân biệt hoa thường
- khi user nhập đúng và bấm `Kiểm tra` hoặc submit bằng keyboard, app stage `correct` trong state tạm và chuyển sang item tiếp theo
- khi user nhập sai và bấm `Kiểm tra`, app chỉ chuyển sang result state tại UI, hiển thị đáp án user đã nhập và đáp án đúng; chưa ghi database
- bấm `Trợ giúp` stage `incorrect`, reveal đáp án, và chỉ cho user bấm `Tiếp theo` để đi tiếp
- trong result state sinh ra từ đáp án nhập sai, bấm `Tiếp theo` stage `incorrect`
- trong result state, không có thao tác override `Đúng` hoặc thử lại; user chỉ có thể đi tiếp bằng `Tiếp theo`
- khi toàn bộ pending item trong current Fill round đã có kết quả tạm, app ghi một batch attempt cho cả round trong cùng transaction
- nếu batch có item `incorrect`, app tạo retry Fill round kế tiếp chỉ gồm các flashcard sai
- nếu toàn bộ item `correct`, Fill mode pass và session chuyển sang mode tiếp theo hoặc `Ready To Finalize`
- khi current item đổi, input/result state được reset về trạng thái nhập liệu
- cloze nâng cao là phạm vi sau v1 và cần data contract riêng nếu được bổ sung

## Rule chung cho mode

- mode chỉ quyết định cách tương tác
- mode không tự cập nhật SRS
- mode không tự quyết định finalize session
- kết quả mode được ghi nhận qua attempt và session progress
- cả 5 mode đều stage kết quả trên UI trước; database chỉ nhận attempt khi current mode round hoàn thành
- progress bar chỉ tăng với item stage hoặc persist là `correct`; item `incorrect` không tăng progress và sẽ tăng sau khi pass retry
- Review mode ghi một batch `correct` ở cuối mode, không ghi từng lần vuốt thẻ
- Match mode ghi attempt theo batch ở cuối Match round, không ghi khi hoàn tất từng display batch và không ghi tại thời điểm mismatch
- Guess / Recall / Fill ghi attempt theo batch ở cuối current mode round, không ghi từng câu
- SRS chỉ cập nhật tại finalize boundary của session
- `Review` ở đây là tên mode tương tác, khác với study flow `SRS Review`
- Shuffle đáp án chỉ áp dụng cho mode có danh sách đáp án hoặc vị trí đáp án cần tráo
- Shuffle đáp án không làm thay đổi thứ tự flashcard trong session
- Các nút audio trong Study UI chỉ đọc mặt trước của thẻ (`front` / term) bằng TTS global settings:
  - `back` / meaning không có nút phát và không auto-play
  - chỉ support Korean và English, không support Vietnamese trong TTS v1
- TTS không ghi attempt, không làm tăng progress và không ảnh hưởng retry/finalize

## Tài liệu liên quan

- [Study Index](./study-index.md)
- [New Study Flow](./new-study-flow.md)
- [SRS Review Flow](./srs-review-flow.md)
- [Retry Loop](./retry-loop.md)
- [Study Session](./study-session.md)
- [Study Settings](./study-settings.md)
- [SRS Rules](../srs/srs-rules.md)
