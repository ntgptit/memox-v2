# Database Overview

## Mục tiêu
Database của MemoX phải là source of truth cục bộ cho:
- cây folder
- deck
- flashcard
- tiến độ SRS theo flashcard
- session history để resume và theo dõi kết quả học

## Quyết định nền tảng
- Dùng SQLite làm local database chính
- Dùng Drift làm lớp schema, query và migration
- Dùng `SharedPreferences` cho app settings nhỏ, không phải dữ liệu học tập cốt lõi

## Phạm vi của DB v1
DB v1 cần bao phủ:
- folder nhiều cấp
- deck thuộc folder
- flashcard thuộc deck
- progress học tập của flashcard
- session snapshot và session history
- support cho move, duplicate, import, export ở mức dữ liệu

## Không đưa vào DB v1
- remote sync
- account cloud
- analytics event
- import preview draft lưu dài hạn
- export artifact file

## Ranh giới source of truth
- SQLite + Drift giữ dữ liệu nghiệp vụ chính
- `SharedPreferences` giữ theme, locale và default study settings
- UI state tạm thời như filter đang gõ, import preview chưa xác nhận, dialog draft không phải source of truth

## Nguyên tắc thiết kế
- Dữ liệu nội dung học tách khỏi dữ liệu progress học
- Dữ liệu tổng hợp như `dueToday`, `masteryPercent`, `breadcrumb`, `deckCount`, `itemCount` là dữ liệu suy ra, không lưu làm source of truth
- `move` chỉ đổi quan hệ cha con, không làm mất progress
- `duplicate deck` và `import` tạo content mới với progress mới
- `delete` là hard delete theo rule business hiện tại
- `study_sessions.status` theo mô hình 6 trạng thái: `draft`, `in_progress`, `ready_to_finalize`, `completed`, `failed_to_finalize`, `cancelled`
- New Study và SRS Review chỉ commit `flashcard_progress` trong transaction chuyển `status` từ `ready_to_finalize` sang `completed`
- Nếu commit lỗi, session chuyển `failed_to_finalize` và toàn bộ cập nhật SRS bị rollback; user có thể retry finalize
- Trong lúc session đang chạy, thay đổi box và due date chỉ được stage qua session history

## Giả định chốt cho v1
- Khi folder trở thành rỗng hoàn toàn, `contentMode` được reset về `unlocked` để user có thể chọn lại hướng chứa
- Flashcard không có title riêng; `front` là nhãn hiển thị và khóa sort/search chính
- `masteryPercent` là derived metric do query/service tính, chưa freeze công thức ở mức schema
- `Fill` là mode bắt buộc trong New Study và là mode duy nhất của SRS Review
- Cloze payload nâng cao cho `Fill` chưa thuộc schema v1

## Hướng gắn vào app hiện tại
Repo đã có sẵn khung:
- `lib/data/datasources/local/`
- `lib/data/repositories/`
- `lib/domain/entities/`
- `lib/domain/repositories/`

Database doc này là contract để triển khai các phần đó trong các bước tiếp theo.
