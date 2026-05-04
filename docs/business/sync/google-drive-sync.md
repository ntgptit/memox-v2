# Google Drive Sync

## Mục tiêu
Google Drive Sync V1 cho phép user tự bấm `Sync now` trong Settings, chọn rõ hướng đồng bộ, rồi xác nhận trước khi sao lưu hoặc khôi phục snapshot DB local qua Google Drive `appDataFolder`.

## Phạm vi V1
- Sync thủ công, không auto-sync nền.
- Dùng Google account đã liên kết và scope `https://www.googleapis.com/auth/drive.appdata`.
- Remote artifact nằm trong Drive `appDataFolder`, không hiển thị như file user quản lý trong My Drive.
- Payload gồm SQLite snapshot và app settings được phép sync.
- Không lưu access token, id token, refresh token hoặc server auth code.
- Không đổi Drift schema và không merge từng flashcard/entity.
- Không mã hóa snapshot trong V1.

## Remote artifact
| File | Nội dung | Mục đích |
| --- | --- | --- |
| `memox.sync.manifest.json` | manifest nhỏ gồm app id, manifest version, snapshot format version, DB schema version, device id/label, hash DB/settings, snapshot file version | kiểm tra nhanh version/conflict trước khi tải snapshot lớn |
| `memox.sync.snapshot.zip` | `manifest.json`, `memox.sqlite`, `settings.json` | bản sao dữ liệu local để upload/restore |

## Settings được sync
- Theme mode.
- Locale override.
- Study defaults: new/review batch size, shuffle flashcards, shuffle answers, prioritize overdue.
- TTS settings được user chọn.

## Settings không được sync
- Google account link.
- OAuth client config.
- Access token, id token, refresh token, server auth code.
- Local Drive sync metadata/baseline.

## Conflict policy
| Tình huống | Hành vi |
| --- | --- |
| User chọn local là mới nhất và xác nhận | Upload local snapshot, ghi đè hoặc tạo snapshot trên Drive. |
| User chọn Drive là mới nhất và xác nhận | Validate manifest/hash/schema, restore settings, restore DB, rồi mở lại app state sạch. |
| User hủy ở bước chọn hướng hoặc confirmation | Không mutate local hoặc Drive. |
| Chưa có remote snapshot | Chỉ cho phép upload local; restore Drive bị vô hiệu hóa. |
| Local giống remote | Cập nhật trạng thái, không upload/download DB. |
| Local đổi, remote không đổi từ lần sync gần nhất | User vẫn phải chọn và xác nhận local là mới nhất trước khi upload. |
| Remote đổi, local không đổi từ lần sync gần nhất | User vẫn phải chọn và xác nhận Drive là mới nhất trước khi restore. |
| Local và remote cùng đổi hoặc không có baseline tin cậy | Hỏi user chọn bản local hay bản Drive. |
| User chọn `Keep local` | Upload local và ghi đè Drive snapshot. |
| User chọn `Use Drive copy` | Validate manifest/hash/schema, restore settings, restore DB, rồi mở lại app state sạch. |
| User chọn `Cancel` | Không mutate local hoặc Drive. |

## Restore safety
- Snapshot phải pass hash DB/settings và schema version check trước khi restore.
- Nếu Drive snapshot được tạo bởi DB schema mới hơn app hiện tại, restore bị chặn.
- Web restore yêu cầu reload app sau khi ghi DB.
- Native restore đóng DB hiện tại, backup file local hiện có, ghi DB mới, xóa WAL/SHM cũ và refresh DB provider.

## Ngoài phạm vi V1
- Entity-level merge.
- Conflict UI theo từng deck/flashcard.
- Sync tự động hoặc background scheduler.
- Remote encryption.
- Xóa remote artifact khi sign out.
