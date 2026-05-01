# Implementation Notes

## Suggested File Placement
Theo cấu trúc repo hiện tại, local DB nên đi vào:
- `lib/data/datasources/local/app_database.dart`
- `lib/data/datasources/local/tables/folders_table.dart`
- `lib/data/datasources/local/tables/decks_table.dart`
- `lib/data/datasources/local/tables/flashcards_table.dart`
- `lib/data/datasources/local/tables/flashcard_progress_table.dart`
- `lib/data/datasources/local/tables/study_sessions_table.dart`
- `lib/data/datasources/local/tables/study_session_items_table.dart`
- `lib/data/datasources/local/tables/study_attempts_table.dart`
- `lib/data/datasources/local/daos/folder_dao.dart`
- `lib/data/datasources/local/daos/deck_dao.dart`
- `lib/data/datasources/local/daos/flashcard_dao.dart`
- `lib/data/datasources/local/daos/study_session_dao.dart`

Repository mapping:
- `lib/domain/repositories/folder_repository.dart`
- `lib/domain/repositories/deck_repository.dart`
- `lib/domain/repositories/flashcard_repository.dart`
- `lib/domain/repositories/study_session_repository.dart`
- `lib/data/repositories/..._repository_impl.dart`

## App Bootstrap
Database open nên được gắn vào `AppBootstrap.beforeRun`.

Trình tự:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. open SQLite database
3. hydrate `SharedPreferences`
4. tạo root providers
5. `runApp`

## Drift Conventions
- Mỗi table 1 file
- Mỗi nhóm query chính 1 DAO
- Mọi enum đi qua mapper hoặc converter rõ ràng
- Luôn bật `foreign_keys = ON`
- Ưu tiên `WAL` mode cho local write/read song song
- Mọi timestamp lưu UTC epoch milliseconds

## Drift Migration Notes
- App `schemaVersion=2` là migration tương thích cho local DB đã được tạo khi `study_session_items.study_mode` chưa tồn tại.
- Migration thêm `study_mode`, map `srs_review` về `fill`, map New Study `mode_order` 1..5 lần lượt về `review`, `match`, `guess`, `recall`, `fill`, rồi tạo lại index idempotent.
- App `schemaVersion=5` cho phép `flashcard_progress.last_result=initial_passed` để tách nghĩa New Study completion khỏi SRS Review `perfect`, đồng thời convert các row legacy `perfect` có thể đối chiếu an toàn với completed New Study attempt.
- App `schemaVersion=6` repair flashcard thiếu `flashcard_progress` để giữ invariant mỗi flashcard có đúng một progress row; New Study query dựa vào progress row có `due_at=null`.
- Target schema sau migration vẫn khớp `schema-v1.md`; đây là sửa tương thích dữ liệu local cũ, không đổi nghĩa business của DB v1.

## Core Write Flows
| Nghiệp vụ | DB action chính |
| --- | --- |
| Tạo folder root | insert `folders` với `parent_id=null` |
| Tạo subfolder | validate parent, set `content_mode=subfolders` nếu parent đang `unlocked`, insert folder con |
| Tạo deck | validate parent, set `content_mode=decks` nếu parent đang `unlocked`, insert `decks` |
| Tạo flashcard thủ công | insert `flashcards` + insert `flashcard_progress` mặc định trong cùng transaction |
| Tạo nhiều flashcard liên tiếp | lặp transaction insert content + progress cho từng flashcard |
| Sửa flashcard | update `flashcards.front/back/note`; nếu user chọn reset progress thì update cùng transaction để đưa `flashcard_progress` về trạng thái thẻ mới |
| Move folder | validate không tạo cycle, update `folders.parent_id`, rồi kiểm tra parent nguồn có cần reset `content_mode` không |
| Move deck | update `decks.folder_id`, không đụng progress, rồi kiểm tra folder nguồn có cần reset `content_mode` không |
| Move flashcard | update `flashcards.deck_id`, không đụng progress |
| Delete folder | hard delete row folder, cascade xuống subtree, rồi kiểm tra parent của folder bị xóa có cần reset `content_mode` không |
| Delete deck | hard delete row deck, cascade flashcards + progress, rồi kiểm tra folder cha có cần reset `content_mode` không |
| Delete flashcard | hard delete flashcard, cascade progress |
| Duplicate deck | insert deck mới, copy flashcards, tạo progress mới mặc định |
| Import CSV/text | validate ngoài DB, nếu hợp lệ thì insert flashcards + progress trong transaction |
| Export deck/flashcard | read-only query, không cần lưu job row |
| Reorder folder/deck/flashcard | update `sort_order` của các sibling trong cùng scope |
| Create New Study session draft | insert `study_sessions` với `study_type=new`, `study_flow=new_full_cycle`, `status=draft`, snapshot batch học mới, tạo queue cho mode `review` |
| Create SRS Review session draft | insert `study_sessions` với `study_type=srs_review`, `study_flow=srs_fill_review`, `status=draft`, snapshot batch review, tạo queue cho mode `fill` |
| Start session | transition `status` từ `draft` sang `in_progress` khi user trả lời lượt đầu tiên |
| Resume session | load `study_sessions` có `status` trong (`in_progress`, `ready_to_finalize`, `failed_to_finalize`) + item `pending` theo `mode_order`, `round_index`, `queue_position` |
| Restart session | mark session cũ `cancelled`, tạo session mới với `restarted_from_session_id` trỏ về session cũ |
| Skip card | đổi `queue_position`, không update SRS |
| Answer New Study card | insert `study_attempts` kèm `attempt_number`, mark item `completed`; không update `flashcard_progress` khi session còn đang chạy |
| Answer SRS Review card | insert `study_attempts` kèm `attempt_number`, mark item `completed`; chưa update `flashcard_progress` cho tới khi Fill mode kết thúc |
| Retry New Study incorrect | sau khi hết queue của round hiện tại, insert thêm `study_session_items` với `source_pool=retry`, cùng `study_mode`, cùng `mode_order`, và `round_index` lớn hơn; lặp đến khi không còn item pending nào ở `source_pool=retry` trong mode hiện tại |
| Retry SRS Review incorrect | sau khi hết queue của Fill round hiện tại, insert thêm `study_session_items` với `source_pool=retry`, `study_mode=fill`, `mode_order=1`, và `round_index` lớn hơn; lặp đến khi retry batch rỗng |
| Advance New Study mode | khi toàn bộ batch pass mode hiện tại, insert queue cho mode tiếp theo từ batch flashcard gốc của session |
| Mark ready to finalize | khi đã pass đủ điều kiện hoàn thành của flow (New Study pass 5 mode / SRS Review retry batch rỗng), transition `status` sang `ready_to_finalize` |
| Commit New Study SRS | khi session ở `ready_to_finalize`, trong cùng transaction: update `flashcard_progress` với `last_result=initial_passed`, ghi `old_box`, `new_box`, `next_due_at` cho các flashcard pass đủ 5 mode, rồi chuyển `status=completed`; retry history vẫn nằm trong `study_attempts` |
| Commit SRS Review SRS | khi session ở `ready_to_finalize`, trong cùng transaction: tổng hợp attempt toàn batch, tính `perfect` hoặc `recovered`, update `flashcard_progress`, rồi chuyển `status=completed` |
| Finalize rollback | nếu transaction finalize lỗi, rollback cập nhật SRS và chuyển `status=failed_to_finalize` |
| Retry finalize | với session `failed_to_finalize`, chạy lại pipeline finalize; nếu thành công chuyển `completed` |
| Cancel session | update `study_sessions.status=cancelled`, chuyển các item `pending` còn lại sang `abandoned` |

## Search Query Notes
- Folder search cần trả về path cha để phân biệt cùng tên
- Deck search cần trả về folder cha
- Flashcard search cần trả về deck cha
- Các query search nên tách `search input` khỏi query builder để sau này nâng cấp FTS dễ hơn

## Migration Order Đề Xuất
1. `folders`, `decks`, `flashcards`
2. `flashcard_progress`
3. query aggregate cho library và folder detail
4. `study_sessions`, `study_session_items`, `study_attempts`
5. `SharedPreferences` datasource cho theme, locale, default study settings

## Test Nên Có
- Tạo deck trong folder `unlocked` sẽ khóa folder sang `decks`
- Tạo subfolder trong folder `unlocked` sẽ khóa folder sang `subfolders`
- Xóa folder cascade đúng subtree
- Move deck và flashcard không làm đổi progress
- Duplicate deck không copy progress
- Resume session giữ nguyên queue và history
- Restart session tạo session mới, không rollback progress cũ
- New Study retry trong mode chỉ lấy flashcard fail từ round vừa kết thúc
- New Study chỉ chuyển mode sau khi toàn bộ batch pass mode hiện tại
- New Study flashcard chưa pass đủ 5 mode không được cập nhật due date chính thức
- SRS Review chỉ dùng Fill và tạo retry bắt buộc cho flashcard fail
- SRS Review chỉ hoàn thành khi retry batch rỗng
- New Study và SRS Review chỉ được tăng box, giảm box và cập nhật due date khi session chuyển `completed`
- Commit SRS cuối session phải chạy trong cùng transaction với cập nhật trạng thái session
- Nếu finalize SRS Review lỗi ở bất kỳ flashcard nào, rollback toàn bộ transaction và giữ session chưa `completed`
- Sau finalize lỗi, user có thể retry finalize hoặc resume an toàn từ session history
