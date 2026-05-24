# Settings Screen Business Inventory

## Mục tiêu
Màn Settings là trung tâm để user quản lý các lựa chọn cấp app và các năng lực phụ trợ cho việc học:
- liên kết Google account và chuẩn bị quyền Google Drive
- sao lưu hoặc khôi phục dữ liệu local qua Google Drive thủ công
- cá nhân hóa giao diện và ngôn ngữ app
- cấu hình mặc định khi tạo phiên học mới
- cấu hình phát âm Text-to-Speech trong Study UI

Settings không phải nơi quản lý nội dung học. Folder, deck, flashcard, session history và SRS progress vẫn thuộc các màn/nghiệp vụ riêng.

## Screen map hiện tại
| Route | Màn | Vai trò nghiệp vụ |
| --- | --- | --- |
| `/settings` | Settings overview | Hiển thị các nhóm Account, Personalization, Learning experience, Audio & Speech. Overview chỉ tóm tắt và điều hướng, trừ Personalization được chỉnh trực tiếp bằng bottom sheet. |
| `/settings/account` | Account settings | Quản lý Google account link và Drive sync. Đây là nơi chứa các thao tác có rủi ro cao hơn như sign out, upload local lên Drive, restore Drive về local. |
| `/settings/learning` | Learning settings | Quản lý default cho phiên học mới và SRS Review. |
| `/settings/audio-speech` | Audio & Speech settings | Quản lý TTS front-side pronunciation cho Study UI. |

Appearance và Language không có detail route riêng trong UI hiện tại. Hai lựa chọn này nằm trong nhóm Personalization trên overview và mở bottom sheet tại chỗ.

## Overview behavior
Overview đang cố tình là màn tóm tắt nhẹ, không phơi các action nguy hiểm:
- Account overview hiển thị trạng thái liên kết và điều hướng vào Account detail. Sign out, reconnect, sync không xuất hiện ở overview.
- Personalization hiển thị hai hàng chỉnh trực tiếp: Appearance và Language.
- Learning overview chỉ hiển thị batch mặc định của New Study và Review.
- Audio & Speech overview chỉ hiển thị trạng thái Text-to-Speech bật/tắt và giọng đang chọn.
- Các nhóm async có loading state và error state riêng. Khi dữ liệu lỗi, UI hiển thị copy lỗi ngắn thay vì crash hoặc bỏ trống.

## Account linking
### Ý nghĩa nghiệp vụ
Google account trong MemoX là liên kết danh tính cục bộ để dùng Google Drive `appDataFolder` cho sync thủ công. MemoX hiện không có server-side account riêng.

User chỉ có thể liên kết một Google account tại một thời điểm.

### Dữ liệu account được lưu
Account link lưu metadata tối thiểu:
- provider: Google
- Google subject id
- email
- display name
- avatar URL nếu có
- danh sách scopes đã cấp
- trạng thái quyền Drive `appDataFolder`
- thời điểm liên kết và lần sign-in gần nhất

Account link không lưu access token, id token, refresh token hoặc server auth code.

### Trạng thái chính
| State | Ý nghĩa | UI/action chính |
| --- | --- | --- |
| `signedOut` | Chưa có Google account link cục bộ. | Account detail cho phép sign in nếu platform/config hỗ trợ. Overview chỉ hiển thị trạng thái chưa liên kết. |
| `signedIn` | Có account link và đã có quyền Drive app data. | Hiển thị avatar/tên/email, trạng thái Drive ready. Account detail có action sign out. |
| `needsDriveAuthorization` | Có account link nhưng chưa có hoặc mất quyền Drive app data/runtime auth. | Hiển thị reconnect required. Account detail cho phép reconnect Drive khi có thể. |
| `unconfigured` | Build hiện tại chưa cấu hình Google OAuth client phù hợp. | Không cho sign in; hiển thị hướng dẫn cấu hình. |
| `unsupported` | Platform hiện tại không hỗ trợ Google sign-in. | Không cho sign in; hiển thị platform không hỗ trợ. |
| `error` | Lần cập nhật/sign-in account thất bại. | Hiển thị lỗi và cho user thử lại nếu action còn hợp lệ. |

### Sign in, reconnect, sign out
- Sign in yêu cầu Google account và quyền `https://www.googleapis.com/auth/drive.appdata`.
- Nếu sign in thành công nhưng thiếu Drive scope, app vẫn lưu identity và chuyển sang trạng thái cần reconnect Drive.
- Nếu user hủy sign in khi chưa có account link, app vẫn ở signed out và không lưu account metadata mới.
- Reconnect Drive xin lại quyền Drive app data cho account đã lưu. Nếu runtime auth không còn hợp lệ, flow có thể quay lại sign-in.
- Sign out chỉ xóa account link cục bộ và sign out Google khỏi app. Sign out không xóa flashcard, progress, session history, study settings, TTS settings hoặc Drive artifact.
- Trên web, Google sign-in/reconnect có thể cần button do Google-rendered platform widget cung cấp; redesign không nên giả định nút này tùy biến được hoàn toàn như button app-native.

## Drive sync
### Ý nghĩa nghiệp vụ
Drive sync là sao lưu/khôi phục thủ công dữ liệu local. Đây không phải auto-sync nền và không merge từng entity.

Drive sync nằm trong Account detail vì phụ thuộc vào Google account link và Drive app data scope.

### Điều kiện sync
Drive sync chỉ sẵn sàng khi:
- build đã cấu hình Google OAuth cho platform hiện tại
- user đã liên kết Google account
- account có quyền Drive `appDataFolder`
- app lấy được access token ngắn hạn tại thời điểm sync

Nếu thiếu các điều kiện trên, UI hiển thị signed out, unconfigured hoặc reconnect required thay vì cho sync.

### Dữ liệu được sync
Snapshot Drive gồm:
- SQLite database local hiện tại
- app settings được phép sync: study defaults, theme/locale keys nếu có trong SharedPreferences; TTS settings nằm trong SQLite snapshot
- manifest để kiểm tra app id, format version, DB schema version, fingerprint DB/settings, device id/label và version file Drive

Snapshot Drive không gồm:
- Google account link
- OAuth config
- access token, id token, refresh token, server auth code
- local Drive sync metadata/baseline

### Sync direction
User luôn phải chọn hướng sync và xác nhận:
| Lựa chọn | Ý nghĩa | Rủi ro UX cần thể hiện |
| --- | --- | --- |
| Upload local data to Drive | Dùng dữ liệu trên thiết bị này làm bản mới nhất, tạo hoặc ghi đè snapshot Drive. | Có thể thay snapshot Drive hiện có. |
| Download Drive data to this device | Dùng snapshot Drive làm bản mới nhất, restore settings và DB vào thiết bị này. | Có tính destructive với dữ liệu local hiện tại; cần confirmation rõ. |

Restore từ Drive bị disable khi chưa có remote snapshot.

### Conflict handling
Khi local và Drive cùng thay đổi hoặc baseline không đủ tin cậy, app mở conflict sheet:
- Keep local data: upload local và ghi đè snapshot Drive.
- Use Drive copy: restore snapshot Drive vào thiết bị.
- Cancel: không mutate local hoặc Drive.

Conflict resolution phải là lựa chọn rõ của user, không tự động chọn phía thắng.

### Status và recovery
Drive sync có các trạng thái user-facing:
- signed out: cần sign in trước
- unconfigured: build chưa cấu hình Google sign-in
- reconnect required: cần reconnect Drive trong Account
- no remote snapshot: chưa có bản Drive, chỉ upload local là hướng hợp lệ
- ready/synced: có thể sync thủ công hoặc đã khớp snapshot Drive
- conflict: cần chọn local hoặc Drive
- unsupported schema: snapshot Drive được tạo bởi DB schema mới hơn, restore bị chặn
- failure: sync lỗi; UI giữ action retry khi hợp lệ và có thể hiển thị diagnostic kỹ thuật

Last synced chỉ hiển thị khi có metadata của lần sync gần nhất.

## Personalization
### Appearance
User chọn theme mode:
- System
- Light
- Dark

Theme mode được áp dụng ngay lên `MaterialApp.themeMode`. Hiện implementation là Riverpod memory state; chưa có store riêng ghi theme mode vào SharedPreferences khi user đổi. Drive snapshot store có biết key `settings.theme_mode`, nhưng UI hiện tại không tạo key này khi đổi theme.

### Language
User chọn app locale:
- System
- English
- Vietnamese

Locale override được áp dụng ngay lên `MaterialApp.locale`. Lựa chọn Language chỉ đổi ngôn ngữ giao diện app, không đổi ngôn ngữ TTS, không dịch nội dung flashcard và không đổi dữ liệu học.

Tương tự theme mode, locale hiện là Riverpod memory state trong UI hiện tại; chưa có writer SharedPreferences riêng khi user đổi language.

## Learning experience defaults
### Ý nghĩa nghiệp vụ
Learning settings quản lý default dùng khi tạo session mới. Đây là default cấp app, không phải setting của từng deck/folder.

Study Entry vẫn có thể override lựa chọn cho session hiện tại. Override lúc vào học không ghi đè default đã lưu trong Settings.

### Field user cấu hình
| Setting | Default | Range/rule | Ảnh hưởng |
| --- | --- | --- | --- |
| New Study batch size | 10 | Min 5, max 20 | Số flashcard mặc định cho phiên New Study mới. |
| Review batch size | 20 | Min 5, max 50 | Số flashcard mặc định cho phiên SRS Review mới. |
| Shuffle flashcards | On | Boolean | Trộn thứ tự flashcard sau khi đã chốt tập thẻ của session. |
| Shuffle answers | On | Boolean | Trộn đáp án trong mode có đáp án lựa chọn, ví dụ Match. Không đổi thứ tự flashcard. |
| Prioritize overdue cards | On | Boolean | Chỉ có ý nghĩa với SRS Review: chọn thẻ quá hạn trước thẻ vừa đến hạn khi batch bị giới hạn. |

### Rule áp dụng
- Settings chỉ áp dụng khi tạo session mới.
- Không thay đổi session đang học dở.
- Khi session được tạo, settings được snapshot vào session để resume ổn định.
- Batch size được clamp nếu SharedPreferences chứa giá trị cũ nằm ngoài range hợp lệ.
- Stepper tăng/giảm phải disable khi chạm min/max.
- Khi cập nhật một trong ba toggle shared, cả New Study defaults và Review defaults cùng nhận giá trị mới.

## Audio & Speech
### Ý nghĩa nghiệp vụ
Audio & Speech quản lý Text-to-Speech on-device cho Study UI. V1 không dùng Cloud TTS và không yêu cầu API key.

### Field user cấu hình
| Setting | Default | Rule |
| --- | --- | --- |
| Text-to-Speech auto-play | Off | Khi bật, Study UI có thể tự phát âm nội dung front side theo policy hiện tại. |
| Front language | Korean | Chỉ hỗ trợ Korean `ko-KR` và English `en-US`. |
| Speech rate | 0.5 | Clamp trong khoảng 0.3 đến 0.7. |
| Voice pitch | 1.0 | Clamp trong khoảng 0.7 đến 1.5 để tránh méo tiếng quá mức. |
| Volume | 1.0 | Clamp trong khoảng 0.0 đến 1.0. |
| Front voice | System voice | Có thể chọn voice platform trả về cho ngôn ngữ đang chọn; nếu không chọn thì dùng system voice. |

### Rule phát âm
- Chỉ front/term side được phát âm trong V1.
- Back/meaning/note không có nút phát và không auto-play.
- App language Vietnamese không đồng nghĩa với TTS Vietnamese; TTS hiện chỉ có Korean và English.
- Auto-play không thay đổi grading, retry, session progress hoặc SRS.
- Khi phát lượt mới, TTS service stop audio đang phát trước để tránh overlap.
- Preview audio trong settings dùng text user nhập; nếu để trống thì dùng sample mặc định theo ngôn ngữ đang chọn.
- Preview text chỉ là UI state tạm thời, không persist.

### Voice options
Voice picker là progressive disclosure:
- Mặc định chỉ hiện hàng Voice selection.
- Trong bottom sheet, user có thể mở Voice options để app query danh sách voice từ platform.
- Nếu platform trả metadata gender, voice option hiển thị nhãn nam/nữ; nếu thiếu metadata thì chỉ hiển thị tên voice.
- Nếu platform không trả voice phù hợp, UI hiển thị empty/helper state và vẫn có thể phát best-effort bằng system voice.
- Khi user đổi front language, selected front voice bị clear để tránh dùng voice không khớp locale.

## Storage ownership
| Nhóm | Source of truth hiện tại | Ghi chú |
| --- | --- | --- |
| Theme mode | Riverpod memory state | Chưa persist qua app restart trong implementation hiện tại. |
| Locale override | Riverpod memory state | Chưa persist qua app restart trong implementation hiện tại. |
| Study defaults | SharedPreferences | Được copy vào session khi tạo session mới. |
| TTS settings | SQLite/Drift `tts_settings` | Được Study UI đọc khi speak/autoplay và đi theo DB snapshot. |
| Google account link | SharedPreferences | Chỉ metadata, không token. |
| Drive sync metadata | SharedPreferences | Baseline/fingerprint cho lần sync gần nhất, không sync lên Drive. |
| Folder/deck/flashcard/progress/session | SQLite/Drift | Settings không trực tiếp sửa nội dung học. |
| Drive snapshot | Google Drive `appDataFolder` | Chứa DB snapshot và settings được phép sync. |

## Redesign guardrails
- Giữ rõ phân biệt giữa preference nhẹ và action rủi ro cao. Theme/language có thể chỉnh nhanh; sign out, upload, restore, conflict resolution cần detail surface và confirmation.
- Không đưa sync action destructive lên overview nếu không có lý do sản phẩm rõ. Overview hiện cố tình không hiển thị sign out/sync/restore.
- Account và Drive Sync liên quan nhau nhưng không phải một nghiệp vụ: Account là identity + permission, Drive Sync là backup/restore dữ liệu.
- Không thiết kế như app có auto-sync hoặc cloud account server-side trong V1.
- Không imply sign out sẽ xóa dữ liệu học hoặc xóa bản Drive.
- Không imply restore Drive có merge từng flashcard. Restore hiện thay DB/settings local sau khi validate snapshot.
- Với learning defaults, wording nên nói rõ là default cho phiên mới; không phải điều khiển session đang chạy.
- Với TTS, tránh copy khiến user hiểu app hỗ trợ mọi ngôn ngữ hoặc phát cả mặt sau. V1 chỉ front side Korean/English.
- Các trạng thái unconfigured, unsupported, reconnect required, no remote snapshot, unsupported schema và failure là state thật, không phải edge copy trang trí. Redesign cần chỗ cho recovery copy/action.

## Source files đã điều tra
- `lib/presentation/features/settings/screens/settings_screen.dart`
- `lib/presentation/features/settings/screens/account_settings_screen.dart`
- `lib/presentation/features/settings/screens/learning_settings_screen.dart`
- `lib/presentation/features/settings/screens/audio_speech_settings_screen.dart`
- `lib/presentation/features/settings/widgets/*settings*_group.dart`
- `lib/presentation/features/settings/viewmodels/*settings*_viewmodel.dart`
- `lib/presentation/features/tts/providers/tts_settings_notifier.dart`
- `lib/data/datasources/local/daos/tts_settings_dao.dart`
- `lib/data/repositories/tts_settings_repository_impl.dart`
- `lib/data/settings/*_store.dart`
- `lib/data/sync/app_settings_snapshot_store.dart`
- `lib/data/repositories/google_drive_sync_repository.dart`
