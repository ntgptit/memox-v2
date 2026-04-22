# Study Entry

## Entry point
User có thể bắt đầu học từ:
- deck
- folder hoặc sub-folder
- danh sách hôm nay

## Study type
Khi user bấm học từ deck, folder hoặc danh sách hôm nay, hệ thống cho chọn:
- học mới
- học due (`Review` trên UI)
- học hỗn hợp mới và due

## Rule ưu tiên giữa settings và lựa chọn lúc vào học
- Study settings chỉ cung cấp giá trị mặc định
- Nếu user chọn lại study type hoặc session control lúc vào học:
  - lựa chọn tại entry point được ưu tiên cho session hiện tại

## Rule chọn mode học
- Trước khi tạo session, user phải chọn 1 mode học
- Mode học quyết định cách tương tác với flashcard trong session
- Chọn mode học không làm thay đổi rule lọc thẻ hay rule SRS

## Rule học từ deck
- Chỉ lấy flashcard trong deck đó

## Rule học từ folder
- Duyệt toàn bộ cây con
- Thu thập tất cả deck trong tree
- Gom tất cả flashcard từ các deck đó

## Rule học từ danh sách hôm nay
- Danh sách hôm nay dùng daily pool toàn cục của app
- Daily pool gồm:
  - thẻ mới
  - thẻ due trong hôm nay
  - thẻ quá hạn
- Khi học từ danh sách hôm nay:
  - học mới chỉ lấy thẻ mới trong daily pool
  - học due chỉ lấy thẻ due và quá hạn trong daily pool
  - học hỗn hợp lấy cả thẻ mới, due và quá hạn trong daily pool

## Rule học mới
- Chỉ lấy flashcard chưa được học
- Lọc xong mới xét session control

## Rule học due (`Review` trên UI)
- Chỉ lấy flashcard đã đến due
- Bao gồm cả thẻ due và thẻ quá hạn
- Không lấy flashcard chưa đến due
- Lọc xong mới xét session control

## Rule học hỗn hợp
- Có thể trộn thẻ mới và thẻ due trong cùng 1 session
- Pool hỗn hợp chỉ gồm:
  - thẻ mới
  - thẻ due hoặc quá hạn
- Không lấy thẻ chưa đến due ngoài pool hỗn hợp
- Lọc xong mới xét session control

## Tài liệu liên quan
- [Study Session](./study-session.md)
- [Study Modes](./study-modes.md)
- [Study Settings](./study-settings.md)
- [SRS Rules](../srs/srs-rules.md)
