# Checklist kiểm tra UI/UX cho app mobile

## 1. Bố cục tổng thể

* Màn hình có mục tiêu rõ ràng, người dùng nhìn vào biết ngay đang làm gì.
* Nội dung chính được ưu tiên hiển thị trước, không bị chìm bởi thông tin phụ.
* Các khu vực trên màn hình được chia rõ: header, content, action, footer.
* Không nhồi quá nhiều thông tin vào một màn hình.
* Khoảng cách giữa các thành phần đồng đều.
* Các thành phần cùng loại có cùng cách căn lề, kích thước và style.
* Màn hình không bị lệch bố cục trên các kích thước máy khác nhau.
* Nội dung quan trọng không bị che bởi keyboard, bottom navigation hoặc system bar.
* Không có khoảng trắng quá lớn gây cảm giác trống trải.
* Không có vùng quá chật gây cảm giác khó đọc, khó thao tác.

## 2. Điều hướng

* Người dùng luôn biết mình đang ở đâu trong app.
* Có nút quay lại rõ ràng ở các màn hình con.
* Bottom navigation, tab hoặc menu được dùng nhất quán.
* Không tạo quá nhiều tầng điều hướng gây rối.
* Các action chính dễ tìm và đặt ở vị trí quen thuộc.
* Sau khi hoàn thành một thao tác, app đưa người dùng đến trạng thái hợp lý.
* Không có màn hình cụt, tức là vào được nhưng không biết thoát ra thế nào.
* Tên màn hình, tab, menu rõ nghĩa và dễ hiểu.
* Không dùng icon khó hiểu nếu không có label hỗ trợ.
* Deep link hoặc route không tạo ra trạng thái màn hình bất thường.

## 3. Typography

* Font chữ dễ đọc trên màn hình nhỏ.
* Kích thước chữ body không quá nhỏ.
* Tiêu đề, nội dung, ghi chú có phân cấp rõ ràng.
* Không dùng quá nhiều font size khác nhau.
* Line height đủ thoáng, đặc biệt với đoạn text dài.
* Text không bị cắt cụt vô lý.
* Text dài có xử lý wrap, ellipsis hoặc mở rộng hợp lý.
* Label button ngắn gọn, rõ hành động.
* Không viết toàn chữ in hoa quá nhiều.
* Nội dung quan trọng có độ nổi bật đủ mạnh.

## 4. Màu sắc và tương phản

* Màu chính, màu phụ, màu cảnh báo được dùng nhất quán.
* Text có độ tương phản đủ tốt với background.
* Button chính nổi bật hơn button phụ.
* Màu lỗi, thành công, cảnh báo dễ phân biệt.
* Không chỉ dùng màu để truyền tải ý nghĩa; nên có icon hoặc text đi kèm.
* Dark mode và light mode đều đọc được rõ.
* Không dùng quá nhiều màu trên cùng một màn hình.
* Background không làm giảm khả năng đọc nội dung.
* Disabled state nhìn rõ là không thể thao tác.
* Focus, selected, pressed state có màu sắc rõ ràng.

## 5. Button và thao tác chính

* Mỗi màn hình nên có một action chính rõ ràng.
* Button chính đặt ở vị trí dễ bấm bằng ngón tay cái.
* Button có kích thước đủ lớn, tối thiểu nên khoảng 44x44 px.
* Khoảng cách giữa các button đủ rộng để tránh bấm nhầm.
* Button nguy hiểm như Delete, Cancel, Reset không đặt quá gần button chính.
* Text trên button mô tả đúng hành động.
* Button loading không cho bấm lặp nhiều lần.
* Button disabled cần có lý do rõ ràng hoặc gợi ý điều kiện cần hoàn thành.
* Icon button nên có tooltip hoặc semantic label.
* Các thao tác quan trọng cần có xác nhận trước khi thực hiện.

## 6. Form nhập liệu

* Label input rõ ràng, không chỉ phụ thuộc vào placeholder.
* Placeholder không thay thế cho label.
* Keyboard type phù hợp với dữ liệu: email, number, phone, password.
* Có validation rõ ràng, hiển thị gần field bị lỗi.
* Error message nói rõ lỗi và cách sửa.
* Required field được đánh dấu rõ.
* Input dài có giới hạn hoặc hướng dẫn định dạng.
* Khi nhập sai, dữ liệu người dùng đã nhập không bị mất.
* Form dài nên chia nhóm hoặc chia bước.
* Nút submit chỉ bật khi dữ liệu đủ điều kiện, hoặc cho submit rồi báo lỗi rõ.

## 7. Trạng thái màn hình

Mỗi màn hình nên xử lý đủ các state sau:

* Loading state.
* Empty state.
* Error state.
* Success state.
* Offline state.
* Unauthorized state.
* Permission denied state.
* Partial data state.
* Refreshing state.
* Submitting state.

Kiểm tra thêm:

* Loading không làm màn hình nhấp nháy khó chịu.
* Empty state có hướng dẫn người dùng làm gì tiếp theo.
* Error state có nút retry nếu phù hợp.
* Success state không quá thừa, không bắt người dùng chờ vô ích.
* Offline state giải thích rõ app có thể tiếp tục dùng được không.
* Unauthorized state điều hướng hợp lý đến login.
* Khi refresh, dữ liệu cũ không biến mất nếu chưa cần thiết.

## 8. Feedback sau thao tác

* Sau khi bấm nút, người dùng thấy app có phản hồi ngay.
* Có loading indicator khi thao tác mất thời gian.
* Có thông báo thành công sau khi lưu, tạo, xóa, cập nhật.
* Có thông báo lỗi khi thao tác thất bại.
* Toast, snackbar hoặc dialog không che nội dung quan trọng.
* Message ngắn gọn, dễ hiểu.
* Không hiển thị lỗi kỹ thuật thô như `NullPointerException`, `500 Internal Server Error`.
* Với thao tác nguy hiểm, có confirm dialog.
* Với thao tác có thể undo, nên có nút Undo.
* Không spam nhiều thông báo liên tiếp.

## 9. Danh sách và bảng dữ liệu

* Danh sách có spacing dễ nhìn.
* Item trong danh sách có cấu trúc nhất quán.
* Thông tin chính và phụ được phân cấp rõ.
* Có empty state khi danh sách rỗng.
* Có loading state khi tải danh sách.
* Có pagination, infinite scroll hoặc lazy loading nếu dữ liệu lớn.
* Có pull to refresh nếu phù hợp.
* Có search, filter hoặc sort nếu danh sách dài.
* Khi chọn item, vùng bấm đủ lớn.
* Khi xóa item, có confirm hoặc undo.
* Trạng thái selected/highlight/focus rõ ràng.
* Không để list giật mạnh khi dữ liệu cập nhật.

## 10. Icon và hình ảnh

* Icon dùng nhất quán một style.
* Icon dễ hiểu, không gây hiểu nhầm.
* Icon quan trọng nên đi kèm text nếu người dùng mới khó đoán.
* Hình ảnh không bị méo, vỡ, crop sai.
* Có placeholder khi ảnh chưa tải xong.
* Có fallback khi ảnh lỗi.
* Ảnh không làm app chậm hoặc chiếm quá nhiều bộ nhớ.
* Không dùng ảnh trang trí quá nhiều làm loãng nội dung.
* Icon trạng thái như success, warning, error có ý nghĩa rõ.
* Asset hiển thị tốt trên nhiều mật độ màn hình.

## 11. Responsive và nhiều kích thước màn hình

* Màn hình hoạt động tốt trên máy nhỏ.
* Màn hình hoạt động tốt trên máy lớn.
* Không hard-code width/height gây overflow.
* Text scale lớn vẫn không phá layout.
* Keyboard mở lên không che input đang nhập.
* Landscape mode được xử lý nếu app hỗ trợ.
* Safe area được xử lý đúng trên máy có tai thỏ, dynamic island, gesture bar.
* Bottom sheet, dialog, popup không vượt khỏi màn hình.
* Scroll hoạt động đúng khi nội dung dài.
* Không có lỗi overflow, clipped content hoặc hidden button.

## 12. Accessibility

* Text đủ lớn và dễ đọc.
* Tương phản màu đủ tốt.
* Button, icon, input có semantic label.
* App hỗ trợ screen reader ở mức cơ bản.
* Không phụ thuộc hoàn toàn vào màu sắc.
* Vùng bấm đủ lớn cho người dùng thao tác bằng tay.
* Animation không quá nhanh hoặc gây khó chịu.
* Nội dung quan trọng không chỉ xuất hiện trong vài giây rồi mất.
* Form error được mô tả bằng text.
* Thứ tự focus hợp lý khi dùng keyboard hoặc accessibility navigation.

## 13. Animation và chuyển động

* Animation có mục đích rõ ràng.
* Không dùng animation quá nhiều.
* Transition giữa các màn hình mượt, không giật.
* Loading animation không gây cảm giác app bị treo.
* Pressed state của button rõ ràng.
* Swipe, drag, expand, collapse hoạt động tự nhiên.
* Animation không làm chậm thao tác chính.
* Không có hiệu ứng gây rối mắt.
* Animation nhất quán với phong cách chung của app.
* Các thao tác quan trọng không phụ thuộc hoàn toàn vào gesture ẩn.

## 14. Nội dung và microcopy

* Câu chữ ngắn gọn, dễ hiểu.
* Không dùng thuật ngữ kỹ thuật nếu người dùng phổ thông không hiểu.
* Message lỗi nói rõ vấn đề và hướng xử lý.
* Button label dùng động từ rõ ràng: Lưu, Xóa, Tiếp tục, Thử lại.
* Không dùng câu mơ hồ như “Có lỗi xảy ra” nếu có thể nói cụ thể hơn.
* Nội dung nhất quán về cách gọi tên chức năng.
* Không trộn nhiều ngôn ngữ nếu không cần thiết.
* Empty state nên hướng dẫn hành động tiếp theo.
* Confirm dialog phải nói rõ hậu quả.
* Nội dung không quá dài trên màn hình mobile.

## 15. Hiệu năng cảm nhận

* Màn hình mở nhanh.
* Dữ liệu cũ được giữ lại khi refresh nếu hợp lý.
* Không để trắng màn hình quá lâu.
* Skeleton loading được dùng cho màn hình có nhiều dữ liệu.
* Scroll mượt, không giật.
* Animation không drop frame.
* Ảnh được cache hoặc resize hợp lý.
* Không gọi API lại vô ích khi quay lại màn hình.
* Không render lại toàn bộ màn hình khi chỉ một phần nhỏ thay đổi.
* App phản hồi ngay sau thao tác của người dùng.

## 16. UX khi lỗi mạng hoặc API lỗi

* Có xử lý mất mạng.
* Có xử lý timeout.
* Có xử lý API trả lỗi 400, 401, 403, 404, 500.
* Có retry cho lỗi tạm thời.
* Không làm mất dữ liệu người dùng đã nhập khi lỗi.
* Có thông báo rõ khi session hết hạn.
* Có xử lý khi dữ liệu server trả về rỗng.
* Có xử lý khi dữ liệu server trả về chậm.
* Có fallback khi một phần dữ liệu lỗi.
* Không crash app khi API trả dữ liệu thiếu field.

## 17. Dialog, bottom sheet và popup

* Dialog chỉ dùng khi thật sự cần chặn luồng người dùng.
* Bottom sheet dùng cho lựa chọn phụ, filter, menu hoặc action nhanh.
* Nội dung dialog ngắn gọn.
* Button trong dialog rõ ràng: Cancel, Confirm, Delete.
* Button nguy hiểm có màu cảnh báo.
* Có thể đóng dialog/bottom sheet theo cách hợp lý.
* Không mở nhiều dialog chồng lên nhau.
* Keyboard không che nội dung trong bottom sheet.
* Bottom sheet có chiều cao hợp lý.
* Popup không làm người dùng mất ngữ cảnh.

## 18. Login, auth và bảo mật trải nghiệm

* Login form đơn giản, rõ ràng.
* Password field có nút show/hide nếu cần.
* Lỗi đăng nhập không tiết lộ thông tin nhạy cảm.
* Session expired được xử lý mềm, không làm app crash.
* Sau login điều hướng đến màn hình hợp lý.
* Sau logout xóa dữ liệu nhạy cảm khỏi UI.
* Màn hình yêu cầu quyền có giải thích rõ lý do.
* Không xin quyền quá sớm nếu chưa cần.
* Có trạng thái loading khi xác thực.
* Không cho bấm login nhiều lần liên tiếp.

## 19. Tính nhất quán thiết kế

* Cùng một loại button có cùng style trong toàn app.
* Cùng một loại card có cùng radius, padding, elevation.
* Cùng một loại input có cùng style.
* Cùng một loại message có cùng cách hiển thị.
* Spacing dùng theo token chung, không đặt tùy tiện từng màn hình.
* Màu sắc lấy từ theme, không hard-code lung tung.
* Typography lấy từ theme, không mỗi màn hình một kiểu.
* Icon size nhất quán.
* Border radius nhất quán.
* Component dùng lại shared widget khi có thể.

## 20. Checklist riêng cho app học tập / flashcard

* Người dùng bắt đầu học được nhanh, không qua quá nhiều bước.
* Nút “Học tiếp” hoặc “Ôn tập hôm nay” nổi bật.
* Trạng thái tiến độ học rõ ràng.
* Người dùng biết còn bao nhiêu thẻ/câu cần học.
* Feedback đúng/sai rõ ràng.
* Sau khi trả lời, app chuyển trạng thái tự nhiên.
* Không làm người dùng mất tập trung khi đang học.
* Nội dung flashcard dễ đọc, không bị chật.
* Có xử lý text dài trong mặt trước/mặt sau thẻ.
* Có trạng thái hoàn thành phiên học rõ ràng.
* Có thống kê đơn giản sau khi học xong.
* Không ép người dùng thao tác quá nhiều cho một vòng học.
* Chế độ ôn tập SRS phải cho người dùng hiểu vì sao thẻ này xuất hiện.
* Nếu có reminder, cần cho phép chỉnh giờ dễ dàng.
* Không thông báo quá nhiều gây phiền.

## 21. Checklist kỹ thuật UI cho Flutter

* Không hard-code màu trực tiếp trong widget nếu đã có theme/token.
* Không hard-code font size lung tung.
* Không dùng `Container` vô tội vạ khi `Padding`, `SizedBox`, `DecoratedBox` đủ dùng.
* Không để widget tree quá dài trong một file.
* Tách shared widget khi component được dùng lại nhiều lần.
* Không tạo shared widget mới nếu đã có component tương đương.
* Dùng `const` constructor khi có thể.
* Không để `setState` xử lý business logic phức tạp.
* UI chỉ render state, logic nên nằm ở ViewModel/Controller/UseCase.
* Tránh gọi API trực tiếp trong widget.
* Kiểm tra overflow bằng nhiều kích thước màn hình.
* Kiểm tra text scale factor.
* Kiểm tra dark mode.
* Kiểm tra loading/error/empty state.
* Kiểm tra rebuild không cần thiết.
* Kiểm tra accessibility label cho icon button quan trọng.

## 22. Checklist review nhanh trước khi merge

* Màn hình có đủ loading, empty, error, success state chưa?
* Có lỗi overflow trên màn hình nhỏ không?
* Có dùng đúng theme/token/shared widget không?
* Có hard-code màu, font, spacing không?
* Button chính có rõ không?
* Text có dễ hiểu không?
* Error message có giúp người dùng sửa lỗi không?
* Keyboard có che input hoặc button không?
* Dark mode có ổn không?
* Có thao tác nào bấm nhầm là gây mất dữ liệu không?
* Có confirm cho thao tác nguy hiểm không?
* Có bị gọi API thừa không?
* Có giữ được dữ liệu khi lỗi mạng không?
* Có responsive tốt trên nhiều màn hình không?
* Có nhất quán với các màn hình khác không?

## 23. Thang điểm đánh giá UI/UX

Có thể chấm mỗi màn hình theo thang 100 điểm:

| Nhóm kiểm tra                    | Điểm |
| -------------------------------- | ---: |
| Bố cục và phân cấp thông tin     |   15 |
| Điều hướng và luồng thao tác     |   15 |
| Typography và khả năng đọc       |   10 |
| Màu sắc và contrast              |   10 |
| Form, button, feedback           |   15 |
| State handling                   |   15 |
| Responsive và accessibility      |   10 |
| Tính nhất quán với design system |   10 |

Kết luận nên dùng:

|     Điểm | Đánh giá                    |
| -------: | --------------------------- |
| 90 - 100 | Rất tốt, có thể merge       |
|  75 - 89 | Ổn, cần chỉnh vài điểm nhỏ  |
|  60 - 74 | Chưa ổn, cần refactor UI/UX |
|  Dưới 60 | Không nên merge             |
