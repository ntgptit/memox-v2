# Google Account And Drive Sync Foundation

## Mục tiêu
Google account trong MemoX là liên kết danh tính cục bộ để chuẩn bị cho đồng bộ DB local qua Google Drive.

## Rule nghiệp vụ
- MemoX vẫn cho dùng app khi chưa login; trạng thái này dùng local database dạng guest.
- Google Login chỉ dùng để định danh owner cho backup/restore Google Drive, không tạo session server, JWT hoặc backend account riêng.
- User có thể liên kết đúng một Google account tại một thời điểm.
- Account link lưu thông tin nhận diện tối thiểu: Google subject id, email, display name, avatar URL, scopes đã cấp và timestamp liên kết.
- Account link phải xin quyền `https://www.googleapis.com/auth/drive.appdata` để chuẩn bị cho sync.
- Sync artifact nằm trong Google Drive `appDataFolder`, không phải file/folder user nhìn thấy trong My Drive.
- App không lưu access token, id token, refresh token hoặc server auth code trong local storage.
- Khi access token hết hạn hoặc Drive scope bị thu hồi, app chuyển trạng thái account sang cần kết nối lại Drive.
- Sign out chỉ xóa account link cục bộ và sign out Google khỏi app; không xóa flashcard, progress, session history hoặc sync artifact trên Drive.
- Manual Drive sync V1 dùng account link này để xin access token ngắn hạn on-demand; token không được ghi vào snapshot hoặc SharedPreferences.
- Account switching không được tự reuse DB của account trước. Account B phải nhận DB context riêng hoặc trạng thái trống/restore riêng, không nhìn thấy dữ liệu local của account A.
- Khi user đang dùng guest DB rồi login Google, app phải có lựa chọn rõ ràng: gắn dữ liệu guest hiện tại vào Google account hoặc tạo DB mới cho Google account.

## Ngoài phạm vi của bước này
- Account link không tự động merge dữ liệu học.
- Account link không quản lý vòng đời file sync artifact trên Drive khi user sign out.
- Không có server-side account riêng của MemoX trong V1.
