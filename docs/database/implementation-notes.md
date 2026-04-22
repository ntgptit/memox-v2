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

## Core Write Flows
| Nghiệp vụ | DB action chính |
| --- | --- |
| Tạo folder root | insert `folders` với `parent_id=null` |
| Tạo subfolder | validate parent, set `content_mode=subfolders` nếu parent đang `unlocked`, insert folder con |
| Tạo deck | validate parent, set `content_mode=decks` nếu parent đang `unlocked`, insert `decks` |
| Tạo flashcard thủ công | insert `flashcards` + insert `flashcard_progress` mặc định trong cùng transaction |
| Tạo nhiều flashcard liên tiếp | lặp transaction insert content + progress cho từng flashcard |
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
| Start session | insert `study_sessions`, snapshot queue vào `study_session_items`; `study_type` dùng `new`, `due`, `mixed` |
| Resume session | load `study_sessions.status=in_progress` + item `pending` |
| Restart session | mark session cũ `restarted`, tạo session mới |
| Skip card | đổi `queue_position`, không update SRS |
| Answer card | insert `study_attempts`, update `flashcard_progress`, mark item `completed` |
| Retry incorrect | insert thêm `study_session_items` với `source_pool=retry` |
| End session early | update `study_sessions.status=ended_early` |

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
