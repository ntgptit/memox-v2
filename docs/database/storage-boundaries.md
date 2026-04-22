# Storage Boundaries

## 1. SQLite + Drift
SQLite là source of truth cho:
- `folders`
- `decks`
- `flashcards`
- `flashcard_progress`
- `study_sessions`
- `study_session_items`
- `study_attempts`

## 2. SharedPreferences
`SharedPreferences` chỉ nên giữ app settings nhỏ, không phải dữ liệu học.

### Key đang có trong code
| Key | Ý nghĩa |
| --- | --- |
| `settings.theme_mode` | theme mode của app |
| `settings.locale` | locale override của app |

### Key nên bổ sung cho default study settings
| Key | Ý nghĩa |
| --- | --- |
| `settings.study.default_new_batch_size` | batch mặc định cho học mới |
| `settings.study.default_due_batch_size` | batch mặc định cho due |
| `settings.study.default_mixed_batch_size` | batch mặc định cho mixed |
| `settings.study.shuffle_flashcards` | mặc định có trộn thẻ hay không |
| `settings.study.shuffle_answers` | mặc định có trộn đáp án hay không |
| `settings.study.default_pool_rule` | `new`, `due`, `mixed` |
| `settings.study.prioritize_overdue` | mặc định ưu tiên overdue |

## 3. Không persist dài hạn
Các state sau không cần vào SQLite ở v1:
- import preview trước khi user xác nhận
- lỗi validate import theo dòng
- text import raw chưa commit
- export file tạm
- dialog state, search text tạm, filter UI tạm

## 4. Derived data không lưu cứng
Các field sau chỉ nên query hoặc compute khi cần:
- breadcrumb của folder
- số deck trong folder
- số flashcard trong folder hoặc deck
- `dueToday`
- `lastStudiedAt` của folder hoặc deck
- `masteryPercent`
- ranking của search result

Lý do:
- tránh double source of truth
- tránh phải backfill nhiều nơi sau mỗi write
- giảm risk sai số khi move, duplicate, import, delete cascade

## 5. Search strategy
### V1
- Folder search: query theo `folders.name`
- Deck search: query theo `decks.name`
- Flashcard search: query theo `COALESCE(title, front)`, `front`, `back`
- Ưu tiên `LIKE` hoặc `LOWER(...) LIKE LOWER(...)` trong Drift cho bản đầu

### V2 khi dữ liệu lớn
- Thêm FTS5 virtual table cho flashcard text
- Đồng bộ FTS bằng trigger hoặc write-through DAO

## 6. Session resume boundary
- Queue hiện tại và log trả lời phải persist trong SQLite để app có thể resume sau khi đóng app
- Chỉ lưu session `in_progress` gần nhất cho mỗi entry point trong logic service
- Default setting của session nằm ở `SharedPreferences`, nhưng snapshot khi session được tạo phải copy vào `study_sessions`
