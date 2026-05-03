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
| `settings.study.default_new_batch_size` | batch mặc định cho học mới |
| `settings.study.default_review_batch_size` | batch mặc định cho SRS Review |
| `settings.study.shuffle_flashcards` | mặc định có trộn thẻ hay không |
| `settings.study.shuffle_answers` | mặc định có trộn đáp án hay không |
| `settings.study.prioritize_overdue` | mặc định ưu tiên overdue |
| `settings.account.cloud_link` | metadata Google account đã liên kết và trạng thái scope Drive `appDataFolder`; không chứa token |
| `settings.sync.google_drive.metadata` | baseline fingerprint/version của lần sync Drive gần nhất; không chứa dữ liệu học hoặc token |
| `settings.sync.google_drive.device_id` | id cục bộ để nhận diện thiết bị trong sync manifest |

## 3. Google Drive appDataFolder
Manual Google Drive sync V1 lưu artifact trong Drive `appDataFolder` của Google account đã liên kết:
- `memox.sync.manifest.json`: metadata nhỏ để kiểm tra version, schema và fingerprint trước khi tải DB snapshot.
- `memox.sync.snapshot.zip`: chứa `manifest.json`, `memox.sqlite`, và `settings.json`.

Artifact Drive không hiển thị trong My Drive thông thường và không thay thế SQLite local làm source of truth khi app đang chạy. Restore phải validate manifest/hash trước, đóng DB hiện tại, ghi snapshot mới, rồi mở lại app state sạch.

## 4. Không persist dài hạn
Các state sau không cần vào SQLite ở v1:
- import preview trước khi user xác nhận
- lỗi validate import theo dòng
- text import raw chưa commit
- export file tạm
- dialog state, search text tạm, filter UI tạm
- Google access token, id token, refresh token hoặc server auth code

## 5. Derived data không lưu cứng
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

## 6. Search strategy
### V1
- Folder search: query theo `folders.name`
- Deck search: query theo `decks.name`
- Flashcard search: query theo `front`, `back`
- Ưu tiên `LIKE` hoặc `LOWER(...) LIKE LOWER(...)` trong Drift cho bản đầu

### V2 khi dữ liệu lớn
- Thêm FTS5 virtual table cho flashcard text
- Đồng bộ FTS bằng trigger hoặc write-through DAO

## 7. Session resume boundary
- Queue hiện tại và log trả lời phải persist trong SQLite để app có thể resume sau khi đóng app
- Study type, study flow, mode hiện tại, retry round hiện tại và các item chưa pass phải persist trong SQLite
- Với New Study, danh sách flashcard đã pass trong mode, chưa pass trong mode và các mode đã pass có thể derive từ `study_session_items` + `study_attempts`
- Với SRS Review, retry batch, các flashcard đã pass Fill và chưa pass Fill có thể derive từ `study_session_items` + `study_attempts`
- Session resume được phép khi `study_sessions.status` thuộc (`in_progress`, `ready_to_finalize`, `failed_to_finalize`)
- Session `draft` chưa bắt đầu học thì không coi là resume, chỉ là start session lần đầu
- Session `completed` hoặc `cancelled` không resume, chỉ phục vụ history
- Box và due date chính thức không được commit khi session ở `draft`, `in_progress`, `ready_to_finalize`, `failed_to_finalize`, hoặc `cancelled`
- Commit SRS chỉ được chạy trong transaction chuyển `status` từ `ready_to_finalize` sang `completed`
- Nếu transaction commit lỗi, rollback toàn bộ cập nhật SRS và chuyển session sang `failed_to_finalize`; user có thể retry finalize hoặc resume
- Với mỗi entry point, chỉ lưu session resume-eligible gần nhất (status in `in_progress`, `ready_to_finalize`, `failed_to_finalize`) trong logic service
- Default setting của session nằm ở `SharedPreferences`, nhưng snapshot khi session được tạo phải copy vào `study_sessions`
