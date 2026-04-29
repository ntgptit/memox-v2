# System Overview

## Mục tiêu
MemoX là hệ thống học tập cá nhân dùng flashcard và spaced repetition để:
- lưu trữ kiến thức
- học đúng lúc
- theo dõi tiến độ
- giảm quên

## Nghiệp vụ chính
- Quản lý nội dung theo cây
- Tạo, sửa, xóa và di chuyển folder, deck, flashcard
- Hỗ trợ reorder thủ công folder, deck và flashcard
- Tạo flashcard thủ công và tạo nhiều flashcard liên tiếp
- Nhân bản deck để tạo bộ thẻ mới từ nội dung sẵn có
- Bulk move và bulk delete flashcard
- Import flashcard từ CSV hoặc text theo format
- Preview và validate dữ liệu trước khi import
- Export deck và export flashcard
- Hỗ trợ New Study và SRS Review
- New Study yêu cầu pass đủ 5 mode học, bao gồm `Fill`
- SRS Review chỉ dùng Fill mode và retry cho tới khi batch review pass
- Resume session dang dở hoặc restart session
- Theo dõi và quản lý session đang mở từ màn Progress: tiếp tục học, hủy, finalize hoặc retry finalize
- Màn Progress phải có lớp learning overview tối thiểu gồm áp lực ôn tập, thẻ mới, mastery thư viện và số session đang mở; quản lý session đang mở là một section riêng trong màn này
- Bỏ qua thẻ, học lại thẻ sai trong mode hiện tại và kết thúc sớm session
- Điều khiển session bằng study type, batch size, shuffle và ưu tiên thẻ quá hạn
- Phát âm nội dung flashcard bằng on-device TTS cho tiếng Hàn và tiếng Anh trong Study UI
- Lưu session history để theo dõi kết quả học
- Tìm kiếm folder, deck, flashcard
- Sắp xếp theo tên, mới nhất, học gần nhất
- Tổ chức bộ thẻ để học
- Hỗ trợ học từ deck, folder hoặc danh sách hôm nay
- Dashboard định hướng học hằng ngày theo Today Review, New Study, Resume và Library health
- Điều phối phiên học
- Lập lịch ôn theo SRS 8 box
- Nhắc học
- Theo dõi kết quả

## Tài liệu liên quan
- [Folder Overview](../folder/folder-overview.md)
- [Deck Overview](../deck/deck-overview.md)
- [Flashcard Overview](../flashcard/flashcard-overview.md)
- [Study Index](../study/study-index.md)
- [Study Entry](../study/study-entry.md)
- [SRS Overview](../srs/srs-overview.md)
