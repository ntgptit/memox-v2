// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'MemoX';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonOk => 'Đồng ý';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonClose => 'Đóng';

  @override
  String get bottomSheetDragHandleLabel => 'Đóng bottom sheet';

  @override
  String get commonCreate => 'Tạo';

  @override
  String get commonEdit => 'Chỉnh sửa';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get commonSort => 'Sắp xếp';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonImport => 'Nhập';

  @override
  String get commonExport => 'Xuất';

  @override
  String get commonMove => 'Di chuyển';

  @override
  String get commonClear => 'Xóa chọn';

  @override
  String get commonSelect => 'Chọn';

  @override
  String get commonSelectAll => 'Chọn tất cả';

  @override
  String get commonSaveOrder => 'Lưu thứ tự';

  @override
  String get commonOverview => 'Tổng quan';

  @override
  String get commonNever => 'Chưa từng';

  @override
  String get commonReorder => 'Sắp xếp lại';

  @override
  String get commonNoValidDestinationFound => 'Không có đích hợp lệ.';

  @override
  String get commonDefaultOrderUpdated => 'Đã cập nhật thứ tự mặc định.';

  @override
  String commonPercentValue(int value) {
    return '$value%';
  }

  @override
  String get commonSearch => 'Tìm kiếm';

  @override
  String get sortManual => 'Thủ công';

  @override
  String get sortName => 'Tên';

  @override
  String get sortNewest => 'Mới nhất';

  @override
  String get sortLastStudied => 'Học gần nhất';

  @override
  String get homeTitle => 'Trang chủ';

  @override
  String get libraryTitle => 'Thư viện';

  @override
  String get progressTitle => 'Tiến độ';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get appShellHomePlaceholderDescription =>
      'Phần nền cho Trang chủ chưa được nối xong.';

  @override
  String get appShellProgressPlaceholderDescription =>
      'Phần nền cho Tiến độ chưa được nối xong.';

  @override
  String get appShellSettingsPlaceholderDescription =>
      'Phần nền cho Cài đặt chưa được nối xong.';

  @override
  String get dashboardTodayLabel => 'Hôm nay';

  @override
  String get dashboardGreetingTitle => 'Chào buổi tối, learner';

  @override
  String get dashboardGreetingSubtitle => 'Sẵn sàng học hôm nay chưa?';

  @override
  String get dashboardHeading => 'Trọng tâm học hôm nay';

  @override
  String get dashboardSubtitle => 'Ôn bài, học thẻ mới hoặc tiếp tục phiên.';

  @override
  String get dashboardTodayReviewTitle => 'Ôn hôm nay';

  @override
  String get dashboardOverdueLabel => 'Quá hạn';

  @override
  String dashboardReviewReadyMessage(int count) {
    return '$count thẻ đã sẵn sàng để ôn SRS.';
  }

  @override
  String get dashboardReviewEmptyMessage =>
      'Hiện không có thẻ cần ôn. Mở Thư viện để thêm thẻ.';

  @override
  String dashboardReviewCompactStatus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count đến hạn',
      one: '1 đến hạn',
      zero: '0 đến hạn',
    );
    return '$_temp0';
  }

  @override
  String get dashboardReviewNowAction => 'Ôn';

  @override
  String get dashboardDueNowLabel => 'Đến hạn';

  @override
  String dashboardDueNowSummary(int cardCount, int deckCount) {
    return '$cardCount thẻ trong $deckCount bộ thẻ';
  }

  @override
  String dashboardReviewTimeEstimate(int minutes) {
    return 'Khoảng $minutes phút';
  }

  @override
  String get dashboardStartReviewAction => 'Bắt đầu ôn';

  @override
  String get dashboardAllCaughtUpTitle => 'Đã xong hôm nay';

  @override
  String get dashboardNewStudyTitle => 'Học mới';

  @override
  String get dashboardNewCardsLabel => 'Thẻ mới có thể học';

  @override
  String dashboardNewStudyMessage(int count) {
    return '$count thẻ mới đã sẵn sàng.';
  }

  @override
  String get dashboardNewStudyEmptyMessage =>
      'Hãy thêm hoặc import thẻ trước khi bắt đầu phiên học mới.';

  @override
  String dashboardNewStudyCompactStatus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mới',
      one: '1 mới',
      zero: '0 mới',
    );
    return '$_temp0';
  }

  @override
  String get dashboardStartNewStudyAction => 'Bắt đầu';

  @override
  String get dashboardResumeTitle => 'Tiếp tục';

  @override
  String get dashboardActiveSessionsLabel => 'Phiên đang mở';

  @override
  String dashboardResumeMessage(int count) {
    return '$count phiên có thể tiếp tục hoặc finalize.';
  }

  @override
  String get dashboardResumeEmptyMessage =>
      'Hiện không có phiên học đang mở. Bắt đầu học để tiếp tục sau.';

  @override
  String dashboardResumeCompactStatus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count đang mở',
      one: '1 đang mở',
      zero: '0 đang mở',
    );
    return '$_temp0';
  }

  @override
  String get dashboardContinueSessionAction => 'Tiếp tục';

  @override
  String get dashboardResumeSectionTitle => 'Tiếp tục học';

  @override
  String get dashboardDiscardAction => 'Hủy phiên';

  @override
  String dashboardMorePausedSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count phiên đang tạm dừng',
      one: '+ 1 phiên đang tạm dừng',
    );
    return '$_temp0';
  }

  @override
  String dashboardPausedSessionsSheetTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count phiên tạm dừng',
      one: '1 phiên tạm dừng',
    );
    return '$_temp0';
  }

  @override
  String get dashboardDiscardSessionTitle => 'Hủy phiên học này?';

  @override
  String get dashboardDiscardSessionMessage =>
      'Tiến độ với các thẻ đã trả lời được giữ lại, nhưng các thẻ còn lại trong phiên này sẽ bị bỏ.';

  @override
  String get dashboardSessionDiscardedMessage => 'Đã hủy phiên học.';

  @override
  String get dashboardSessionDiscardFailedMessage =>
      'Không thể hủy phiên học. Hãy thử lại.';

  @override
  String get dashboardStartNewLearningAction => 'Bắt đầu học mới';

  @override
  String get dashboardScopePickerTitle => 'Bạn muốn học gì?';

  @override
  String get dashboardScopeToday => 'Hôm nay';

  @override
  String dashboardScopeTodaySubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ đến hạn',
      one: '1 thẻ đến hạn',
      zero: 'Không có thẻ đến hạn',
    );
    return '$_temp0';
  }

  @override
  String get dashboardScopeDeck => 'Bộ thẻ';

  @override
  String get dashboardScopeDeckSubtitle => 'Chọn một bộ thẻ để học';

  @override
  String get dashboardScopeFolder => 'Thư mục';

  @override
  String get dashboardScopeFolderSubtitle => 'Chọn một thư mục để học';

  @override
  String get dashboardScopeDeckPickerTitle => 'Chọn bộ thẻ';

  @override
  String get dashboardScopeFolderPickerTitle => 'Chọn thư mục';

  @override
  String get dashboardScopeDeckSearchHint => 'Tìm bộ thẻ';

  @override
  String get dashboardScopeFolderSearchHint => 'Tìm thư mục';

  @override
  String get dashboardScopeDeckEmpty =>
      'Chưa có bộ thẻ nào. Hãy tạo một bộ thẻ trước.';

  @override
  String get dashboardScopeFolderEmpty => 'Chưa có thư mục nào.';

  @override
  String get dashboardLibraryHealthTitle => 'Sức khỏe thư viện';

  @override
  String dashboardLibraryHealthSummary(
    int folderCount,
    int deckCount,
    int cardCount,
  ) {
    return '$folderCount thư mục · $deckCount bộ thẻ · $cardCount thẻ';
  }

  @override
  String get dashboardMasteryLabel => 'Thành thạo';

  @override
  String dashboardStreakDays(int count) {
    return '$count ngày';
  }

  @override
  String dashboardMasteredCards(int count) {
    return '$count thẻ';
  }

  @override
  String get dashboardDueTodayTitle => 'Đến hạn hôm nay';

  @override
  String dashboardDueTodayMessage(int count) {
    return '$count thẻ sẵn sàng để ôn';
  }

  @override
  String dashboardLibrarySummary(int folderCount, int cardCount) {
    return '$folderCount thư mục · $cardCount thẻ';
  }

  @override
  String get dashboardNoDueTitle => 'Hiện không có thẻ đến hạn';

  @override
  String get dashboardNoDueMessage =>
      'Mở thư viện để thêm thẻ hoặc bắt đầu học một bộ thẻ cụ thể.';

  @override
  String get dashboardStudyTodayAction => 'Học';

  @override
  String get dashboardOpenLibraryAction => 'Xem thư viện';

  @override
  String get dashboardLibraryProgressTitle => 'Tiến độ thư viện';

  @override
  String dashboardLibraryProgressMessage(int percent) {
    return '$percent% thành thạo';
  }

  @override
  String get dashboardRecentDecksTitle => 'Deck gần đây';

  @override
  String get dashboardPickUpTitle => 'Tiếp tục từ nơi bạn dừng lại';

  @override
  String get dashboardStartDeckTitle => 'Bắt đầu với deck';

  @override
  String dashboardDeckStats(int cardCount) {
    return '$cardCount thẻ';
  }

  @override
  String dashboardDeckDueSummary(int dueCount, int cardCount) {
    return '$dueCount đến hạn · $cardCount thẻ';
  }

  @override
  String dashboardDeckCaughtUpSummary(int cardCount) {
    return 'Đã xong hôm nay · $cardCount thẻ';
  }

  @override
  String get progressOverviewHeading => 'Tổng quan tiến độ';

  @override
  String get progressOverviewSubtitle =>
      'Theo dõi áp lực ôn tập, độ thành thạo thư viện và các phiên cần khôi phục.';

  @override
  String get progressReviewDueCount => 'Cần ôn';

  @override
  String get progressActiveSessionsHeading => 'Phiên học đang mở';

  @override
  String get progressActiveSessionsSubtitle =>
      'Tiếp tục, finalize, thử lại finalize hoặc hủy các phiên học vẫn đang mở.';

  @override
  String get progressActiveSessionsCount => 'Đang mở';

  @override
  String get progressReadySessionsCount => 'Sẵn sàng';

  @override
  String get progressFailedSessionsCount => 'Cần thử lại';

  @override
  String get progressEmptyTitle => 'Không có phiên học đang mở';

  @override
  String get progressEmptyMessage =>
      'Bắt đầu học từ Thư viện. Các phiên đang học hoặc đang chờ finalize sẽ xuất hiện ở đây.';

  @override
  String progressSessionTitle(Object studyType, Object entryType) {
    return '$studyType · $entryType';
  }

  @override
  String progressSessionCardProgress(int completed, int total, int remaining) {
    return 'Đã xong $completed/$total bước học · còn $remaining';
  }

  @override
  String progressSessionCurrentCard(Object card) {
    return 'Thẻ hiện tại: $card';
  }

  @override
  String progressSessionStartedAt(Object date, Object time) {
    return 'Bắt đầu $date lúc $time';
  }

  @override
  String get progressEntryDeck => 'Bộ thẻ';

  @override
  String get progressEntryFolder => 'Thư mục';

  @override
  String get progressEntryToday => 'Hôm nay';

  @override
  String get progressSessionStatusInProgress => 'Đang học';

  @override
  String get progressSessionStatusReady => 'Sẵn sàng finalize';

  @override
  String get progressSessionStatusFailed => 'Finalize lỗi';

  @override
  String get progressCancelConfirmTitle => 'Hủy phiên học này?';

  @override
  String get progressCancelConfirmMessage =>
      'Phiên học hiện tại sẽ dừng lại. Các lượt đã hoàn thành vẫn nằm trong lịch sử, nhưng thẻ còn pending sẽ bị bỏ dở.';

  @override
  String get progressSessionCancelledMessage => 'Đã hủy phiên học.';

  @override
  String get progressSessionFinalizedMessage => 'Đã finalize phiên học.';

  @override
  String get progressSessionRetryFinalizeMessage => 'Đã thử finalize lại.';

  @override
  String get progressSessionActionFailed => 'Thao tác với phiên học thất bại.';

  @override
  String get settingsAppearanceTitle => 'Giao diện';

  @override
  String get settingsPersonalizationTitle => 'Cá nhân hóa';

  @override
  String get settingsStudySectionTitle => 'Học';

  @override
  String get settingsAppSectionTitle => 'Ứng dụng';

  @override
  String get settingsAboutSectionTitle => 'Thông tin';

  @override
  String get settingsOverviewFooter => 'Tạo cho việc học bình tĩnh · MemoX';

  @override
  String get settingsAccountTitle => 'Tài khoản';

  @override
  String get settingsAccountLoading => 'Đang tải tài khoản';

  @override
  String get settingsAccountLinkedOverviewTitle => 'Tài khoản & đồng bộ';

  @override
  String get settingsAccountSignInSyncTitle => 'Đăng nhập & đồng bộ';

  @override
  String get settingsAccountSignInSyncSubtitle =>
      'Lưu tiến độ học trên nhiều thiết bị';

  @override
  String get settingsAccountSigningIn => 'Đang đăng nhập...';

  @override
  String get settingsAccountSubtitleSignedOut =>
      'Liên kết Google ngay để có thể bật đồng bộ Drive sau này.';

  @override
  String get settingsAccountSubtitleReady =>
      'Quyền truy cập dữ liệu ứng dụng trên Google Drive đã sẵn sàng cho đồng bộ sau này.';

  @override
  String get settingsAccountSubtitleReconnect =>
      'Cần kết nối lại quyền Drive trước khi chạy đồng bộ.';

  @override
  String get settingsAccountSubtitleConfig =>
      'Bản build này chưa cấu hình Google sign-in.';

  @override
  String get settingsAccountSubtitleUnsupported =>
      'Nền tảng này chưa hỗ trợ Google sign-in.';

  @override
  String get settingsAccountSubtitleError =>
      'Không thể cập nhật tài khoản Google.';

  @override
  String get settingsAccountSignedOut => 'Chưa liên kết tài khoản Google.';

  @override
  String get settingsAccountMissingConfig =>
      'Thêm Google OAuth client ID để bật liên kết tài khoản.';

  @override
  String get settingsAccountUnsupported =>
      'Hãy dùng Android, iOS hoặc web để liên kết tài khoản Google.';

  @override
  String get settingsAccountDriveReady => 'Google Drive đã sẵn sàng';

  @override
  String get settingsAccountDriveReconnectRequired =>
      'Cần kết nối lại Google Drive';

  @override
  String settingsAccountOverviewSubtitle(Object status, Object email) {
    return '$status\n$email';
  }

  @override
  String settingsAccountOverviewSyncedSubtitle(Object email, Object time) {
    return '$email · đã đồng bộ $time';
  }

  @override
  String settingsAccountOverviewSyncedMockSubtitle(Object email) {
    return '$email · đã đồng bộ 2 phút trước';
  }

  @override
  String settingsAccountOverviewSyncErrorSubtitle(Object email) {
    return '$email · đồng bộ lần cuối 2 ngày trước';
  }

  @override
  String get settingsOverviewSyncRetry => 'Thử lại';

  @override
  String get settingsAccountDriveAuthorizationRequired =>
      'Cấp quyền dữ liệu ứng dụng Google Drive để chuẩn bị đồng bộ.';

  @override
  String get settingsAccountSignIn => 'Đăng nhập bằng Google';

  @override
  String get settingsAccountReconnectDrive => 'Kết nối lại Google Drive';

  @override
  String get settingsAccountSkipDrive => 'Dùng không cần sao lưu đám mây';

  @override
  String get settingsAccountSignOut => 'Đăng xuất';

  @override
  String get settingsAccountSignOutConfirmTitle => 'Đăng xuất khỏi Google?';

  @override
  String get settingsAccountSignOutConfirmMessage =>
      'Bản backup trên Drive vẫn được giữ. Đăng nhập lại bất cứ lúc nào để khôi phục.';

  @override
  String get settingsAccountDisconnect => 'Ngắt kết nối Google';

  @override
  String get settingsAccountDisconnectConfirmTitle =>
      'Ngắt kết nối tài khoản Google?';

  @override
  String get settingsAccountDisconnectConfirmMessage =>
      'Thao tác này thu hồi token Drive đã cấp cho app. Bản backup trên Drive vẫn được giữ. Dùng khi thiết bị bị mất hoặc dùng chung.';

  @override
  String get settingsAccountDisconnectedMessage =>
      'Đã ngắt kết nối Google. Token Drive đã được thu hồi.';

  @override
  String get settingsAccountSignInCanceled => 'Đã hủy đăng nhập Google.';

  @override
  String get settingsAccountSignInFailed =>
      'Đăng nhập Google thất bại. Hãy thử lại.';

  @override
  String settingsAccountLastSignedIn(Object at) {
    return 'Đăng nhập lần cuối: $at';
  }

  @override
  String get settingsAccountSignedOutMessage =>
      'Đã đăng xuất. Flashcard cục bộ vẫn ở trên thiết bị này.';

  @override
  String get settingsDriveSyncTitle => 'Đồng bộ Drive';

  @override
  String get settingsDriveSyncLoading => 'Đang tải trạng thái đồng bộ';

  @override
  String get settingsDriveSyncSubtitleSignedOut =>
      'Liên kết tài khoản Google trước khi đồng bộ.';

  @override
  String get settingsDriveSyncSubtitleUnconfigured =>
      'Bản build này chưa cấu hình Google sign-in.';

  @override
  String get settingsDriveSyncSubtitleReconnect =>
      'Cần kết nối lại quyền Drive trước khi chạy đồng bộ.';

  @override
  String get settingsDriveSyncSubtitleNoRemote =>
      'Tạo bản sao Drive đầu tiên từ thiết bị này.';

  @override
  String get settingsDriveSyncSubtitleSynced =>
      'Dữ liệu cục bộ khớp với snapshot mới nhất trên Drive.';

  @override
  String get settingsDriveSyncSubtitleReady => 'Có thể đồng bộ thủ công.';

  @override
  String get settingsDriveSyncSubtitleConflict =>
      'Chọn bản dữ liệu được giữ lại.';

  @override
  String get settingsDriveSyncSubtitleUnsupportedSchema =>
      'Cập nhật app trước khi khôi phục bản Drive này.';

  @override
  String get settingsDriveSyncSubtitleError =>
      'Không thể hoàn tất đồng bộ Drive.';

  @override
  String get settingsDriveSyncSignedOut =>
      'Đăng nhập Google để đồng bộ DB cục bộ với Drive.';

  @override
  String get settingsDriveSyncUnconfigured =>
      'Thêm Google OAuth client ID để bật đồng bộ Drive.';

  @override
  String get settingsDriveSyncReconnectRequired =>
      'Hãy kết nối lại Google Drive trong mục Tài khoản trước.';

  @override
  String get settingsDriveSyncNoRemote => 'Chưa có snapshot nào trên Drive.';

  @override
  String get settingsDriveSyncSynced => 'Google Drive đã được cập nhật.';

  @override
  String get settingsDriveSyncReady => 'Đã có snapshot trên Drive.';

  @override
  String get settingsDriveSyncConflictStatus =>
      'Dữ liệu cục bộ và Drive đều đã thay đổi.';

  @override
  String get settingsDriveSyncUnsupportedSchema =>
      'Bản Drive được tạo bởi schema DB mới hơn.';

  @override
  String settingsDriveSyncLastSynced(Object value) {
    return 'Đồng bộ lần cuối: $value';
  }

  @override
  String settingsDriveSyncRemoteDevice(Object device) {
    return 'Bản Drive từ: $device';
  }

  @override
  String get settingsDriveSyncAction => 'Đồng bộ ngay';

  @override
  String get settingsDriveSyncDirectionTitle => 'Chọn hướng đồng bộ';

  @override
  String get settingsDriveSyncDirectionMessage =>
      'Chọn bản dữ liệu được xem là mới nhất cho lần đồng bộ này.';

  @override
  String get settingsDriveSyncUploadLocalAction =>
      'Tải dữ liệu cục bộ lên Drive';

  @override
  String get settingsDriveSyncUploadLocalSubtitle =>
      'Dùng thiết bị này làm bản mới nhất và thay snapshot trên Drive.';

  @override
  String get settingsDriveSyncRestoreDriveAction =>
      'Tải dữ liệu Drive về thiết bị';

  @override
  String get settingsDriveSyncRestoreDriveSubtitle =>
      'Dùng snapshot trên Drive làm bản mới nhất và thay dữ liệu cục bộ.';

  @override
  String get settingsDriveSyncRestoreUnavailable =>
      'Chưa có snapshot Drive để tải về.';

  @override
  String get settingsDriveSyncUploadConfirmTitle => 'Tải dữ liệu cục bộ lên?';

  @override
  String get settingsDriveSyncUploadConfirmMessage =>
      'Thao tác này sẽ thay snapshot Google Drive bằng DB và cài đặt hiện tại trên thiết bị này.';

  @override
  String get settingsDriveSyncUploadConfirmAction => 'Tải lên Drive';

  @override
  String get settingsDriveSyncRestoreConfirmTitle => 'Khôi phục bản Drive?';

  @override
  String get settingsDriveSyncRestoreConfirmMessage =>
      'Khôi phục từ Drive sẽ thay DB và cài đặt cục bộ trên thiết bị này bằng dữ liệu backup. Những thay đổi cục bộ gần đây chưa tải lên có thể bị mất. Hãy tải dữ liệu cục bộ lên trước nếu bạn chưa chắc, và chỉ tiếp tục khi bạn tin tưởng bản backup Drive này.';

  @override
  String get settingsDriveSyncRestoreConfirmAction => 'Khôi phục từ Drive';

  @override
  String settingsDriveSyncBackupSource(Object device, Object when) {
    return 'Backup từ thiết bị $device • $when';
  }

  @override
  String settingsDriveSyncBackupAppVersion(Object version) {
    return 'Phiên bản app: $version';
  }

  @override
  String get settingsDriveSyncCrossDeviceTitle =>
      'Ghi đè backup từ thiết bị khác?';

  @override
  String get settingsDriveSyncCrossDeviceMessage =>
      'Backup hiện tại trên Google Drive được tạo bởi một thiết bị KHÁC. Tải lên từ thiết bị này sẽ ghi đè backup đó. Hãy chắc chắn thiết bị kia không còn dữ liệu bạn muốn giữ.';

  @override
  String get settingsDriveSyncCrossDeviceContinue => 'Vẫn ghi đè';

  @override
  String get settingsDriveSyncRestoreCrossDeviceWarning =>
      'Cảnh báo: backup này được tạo trên thiết bị khác. Khôi phục sẽ thay thế dữ liệu local của thiết bị này bằng dữ liệu của thiết bị kia.';

  @override
  String get settingsDriveSyncUploadInProgressTitle =>
      'Đang sao lưu lên Google Drive';

  @override
  String get settingsDriveSyncUploadInProgressMessage =>
      'Vui lòng giữ ứng dụng mở. Không đóng app hoặc đổi tài khoản.';

  @override
  String get settingsDriveSyncRestoreInProgressTitle =>
      'Đang khôi phục từ Google Drive';

  @override
  String get settingsDriveSyncRestoreInProgressMessage =>
      'Vui lòng giữ ứng dụng mở. Ứng dụng sẽ tự làm mới khi hoàn tất.';

  @override
  String get settingsDriveSyncUploaded =>
      'Đã sao lưu dữ liệu cục bộ lên Google Drive.';

  @override
  String get settingsDriveSyncRestored => 'Đã khôi phục bản Drive.';

  @override
  String get settingsDriveSyncNoChanges => 'Dữ liệu đã được cập nhật.';

  @override
  String get settingsDriveSyncCanceled => 'Đã hủy đồng bộ.';

  @override
  String get settingsDriveSyncFailed => 'Đồng bộ Drive thất bại. Hãy thử lại.';

  @override
  String get settingsDriveSyncConflictTitle => 'Xử lý xung đột đồng bộ';

  @override
  String get settingsDriveSyncConflictMessage =>
      'Dữ liệu cục bộ và bản Drive đều đã thay đổi từ lần đồng bộ trước.';

  @override
  String get settingsDriveSyncKeepLocal => 'Giữ dữ liệu cục bộ';

  @override
  String get settingsDriveSyncKeepLocalSubtitle =>
      'Tải DB của thiết bị này lên và thay snapshot trên Drive.';

  @override
  String get settingsDriveSyncUseDrive => 'Dùng bản Drive';

  @override
  String get settingsDriveSyncUseDriveSubtitle =>
      'Khôi phục snapshot Drive đè lên DB cục bộ của thiết bị này.';

  @override
  String get settingsThemeModeLabel => 'Chế độ giao diện';

  @override
  String get settingsThemeSystem => 'Theo hệ thống';

  @override
  String get settingsThemeLight => 'Sáng';

  @override
  String get settingsThemeDark => 'Tối';

  @override
  String get settingsAppearanceOverviewSubtitle => 'Sáng, tối, hệ thống';

  @override
  String get settingsSoonChip => 'SẮP CÓ';

  @override
  String get settingsLanguageTitle => 'Ngôn ngữ';

  @override
  String get settingsLanguageOverviewSubtitle => 'Tiếng Anh';

  @override
  String get settingsLocaleLabel => 'Ngôn ngữ app';

  @override
  String get settingsLocaleSystem => 'Theo hệ thống';

  @override
  String get settingsLocaleEnglish => 'Tiếng Anh';

  @override
  String get settingsLocaleVietnamese => 'Tiếng Việt';

  @override
  String get settingsStudyDefaultsTitle => 'Mặc định học';

  @override
  String get settingsLearningExperienceTitle => 'Trải nghiệm học';

  @override
  String get settingsLearningOverviewTitle => 'Học';

  @override
  String get settingsStudyDefaultsSubtitle =>
      'Cài đặt mặc định dùng khi tạo phiên học mới.';

  @override
  String get settingsStudyDefaultsLoading => 'Đang tải mặc định học';

  @override
  String get settingsNewStudyBatchSizeLabel => 'Số thẻ New Study';

  @override
  String get settingsReviewBatchSizeLabel => 'Số thẻ Review';

  @override
  String get settingsLearningOverviewSummary => '20 thẻ / ngày · 5 chế độ học';

  @override
  String settingsCardsCountValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
      one: '1 thẻ',
    );
    return '$_temp0';
  }

  @override
  String get settingsSrsIntervalsTitle => 'Khoảng ôn SRS';

  @override
  String get settingsSrsIntervalsSubtitle => 'Lịch hiện tại của runtime';

  @override
  String settingsSrsIntervalBoxLabel(int box) {
    return 'Box $box';
  }

  @override
  String get settingsSrsIntervalToday => 'Hôm nay';

  @override
  String settingsSrsIntervalDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ngày',
    );
    return '$_temp0';
  }

  @override
  String get settingsTagsSectionTitle => 'Tag';

  @override
  String get settingsManageTagsLearningSubtitle => 'Mở quản lý tag';

  @override
  String get settingsManageTagsTitle => 'Quản lý tag';

  @override
  String get settingsManageTagsOverviewSubtitle => '14 tag';

  @override
  String tagHashLabel(String tag) {
    return '#$tag';
  }

  @override
  String get settingsTagsSearchHint => 'Tìm tag';

  @override
  String settingsTagsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tag',
    );
    return '$_temp0';
  }

  @override
  String settingsTagsCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
    );
    return '$_temp0';
  }

  @override
  String get settingsTagsSortMostCards => 'Nhiều thẻ nhất';

  @override
  String get settingsTagsSortNameAsc => 'A → Z';

  @override
  String get settingsTagsSortNameDesc => 'Z → A';

  @override
  String get settingsTagsEmptyTitle => 'Chưa có tag nào';

  @override
  String get settingsTagsEmptyMessage =>
      'Tag được thêm khi bạn tạo hoặc sửa thẻ. Mở một thẻ để thêm tag đầu tiên.';

  @override
  String get settingsTagsEmptyAction => 'Tới thư viện';

  @override
  String get settingsTagsSearchEmptyTitle => 'Không có tag phù hợp';

  @override
  String get settingsTagsSearchEmptyMessage =>
      'Không có tag nào khớp với tìm kiếm.';

  @override
  String get settingsTagsActionRename => 'Đổi tên';

  @override
  String get settingsTagsActionMerge => 'Gộp vào tag khác';

  @override
  String get settingsTagsActionDelete => 'Xóa tag (giữ thẻ)';

  @override
  String get settingsTagsRenameTitle => 'Đổi tên tag';

  @override
  String get settingsTagsRenameLabel => 'Tên tag';

  @override
  String get settingsTagsRenameHint => 'Nhập tên mới';

  @override
  String get settingsTagsRenameConfirm => 'Đổi tên';

  @override
  String get settingsTagsRenamedMessage => 'Đã đổi tên tag.';

  @override
  String settingsTagsMergeSheetTitle(String source) {
    return 'Gộp \"$source\" vào…';
  }

  @override
  String get settingsTagsMergeSheetEmpty => 'Không có tag nào khác để gộp.';

  @override
  String get settingsTagsMergeConfirmTitle => 'Gộp tag?';

  @override
  String settingsTagsMergeConfirmMessage(String source, String destination) {
    return 'Tất cả thẻ gắn \"$source\" sẽ được gắn lại \"$destination\". Tag \"$source\" sẽ bị xóa.';
  }

  @override
  String get settingsTagsMergeConfirmAction => 'Gộp';

  @override
  String get settingsTagsMergedMessage => 'Đã gộp tag.';

  @override
  String get settingsTagsDeleteTitle => 'Xóa tag?';

  @override
  String settingsTagsDeleteMessage(String tag, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
    );
    return 'Xóa \"$tag\"? Thao tác này gỡ tag khỏi $_temp0. Các thẻ không bị xóa.';
  }

  @override
  String get settingsTagsDeleteConfirm => 'Xóa';

  @override
  String get settingsTagsDeletedMessage => 'Đã xóa tag.';

  @override
  String get flashcardsTagErrorEmpty => 'Cần nhập tên tag.';

  @override
  String get flashcardsTagErrorComma => 'Tag không được chứa dấu phẩy.';

  @override
  String get flashcardsTagErrorTooLong => 'Tag quá dài (tối đa 50 ký tự).';

  @override
  String get settingsSpeechTitle => 'Giọng nói';

  @override
  String get settingsAudioSpeechTitle => 'Âm thanh & giọng nói';

  @override
  String get settingsAudioSpeechEnabled => 'Bật';

  @override
  String get settingsAudioSpeechDisabled => 'Tắt';

  @override
  String get settingsAudioSpeechOverviewSummary => 'Giọng Hàn · tốc độ 0.9×';

  @override
  String get settingsSpeechLabel => 'Hỗ trợ phát âm tiếng Hàn và tiếng Anh';

  @override
  String get settingsSpeechLoading => 'Đang tải cài đặt giọng nói';

  @override
  String get settingsSpeechAutoPlayLabel => 'Tự phát trong khi học';

  @override
  String get settingsSpeechTextToSpeechLabel => 'Text-to-Speech';

  @override
  String get settingsSpeechAutoPlaySubtitle =>
      'Tự phát âm thẻ sau các chuyển trạng thái học.';

  @override
  String get settingsSpeechVoiceSelectionLabel => 'Chọn giọng';

  @override
  String get settingsSpeechFrontLanguageLabel => 'Ngôn ngữ mặt trước';

  @override
  String get settingsSpeechKorean => 'Tiếng Hàn';

  @override
  String get settingsSpeechEnglish => 'Tiếng Anh';

  @override
  String get settingsSpeechRateLabel => 'Tốc độ phát âm';

  @override
  String settingsSpeechRateValue(double value) {
    return '${value}x';
  }

  @override
  String get settingsSpeechPitchLabel => 'Cao độ giọng';

  @override
  String settingsSpeechPitchValue(double value) {
    return '${value}x';
  }

  @override
  String get settingsSpeechVolumeLabel => 'Âm lượng';

  @override
  String settingsSpeechVolumeValue(int value) {
    return '$value%';
  }

  @override
  String get settingsSpeechFrontVoiceLabel => 'Giọng mặt trước';

  @override
  String get settingsSpeechSystemVoice => 'Giọng hệ thống';

  @override
  String get settingsSpeechStoredVoice => 'Giọng thiết bị';

  @override
  String settingsSpeechKoreanVoiceLabel(Object index) {
    return 'Giọng tiếng Hàn $index';
  }

  @override
  String settingsSpeechEnglishVoiceLabel(Object index) {
    return 'Giọng tiếng Anh $index';
  }

  @override
  String get settingsSpeechVoiceDeviceSource => 'Thiết bị';

  @override
  String get settingsSpeechVoiceOnlineSource => 'Trực tuyến';

  @override
  String get settingsSpeechVoiceMale => 'Nam';

  @override
  String get settingsSpeechVoiceFemale => 'Nữ';

  @override
  String get settingsSpeechLoadingVoices => 'Đang tải danh sách giọng...';

  @override
  String settingsSpeechNoVoices(Object language) {
    return 'Thiết bị chưa báo có giọng $language.';
  }

  @override
  String get settingsSpeechPreviewKorean => 'Nghe thử tiếng Hàn';

  @override
  String get settingsSpeechPreviewEnglish => 'Nghe thử tiếng Anh';

  @override
  String get settingsSpeechPreviewSelected => 'Nghe thử';

  @override
  String get settingsSpeechVoiceOptions => 'Tùy chọn giọng';

  @override
  String get settingsSpeechHideVoiceOptions => 'Ẩn tùy chọn giọng';

  @override
  String get settingsSpeechKoreanPreviewText => '안녕하세요';

  @override
  String get settingsSpeechEnglishPreviewText => 'Hello';

  @override
  String get settingsSpeechPreviewTextLabel => 'Văn bản thử';

  @override
  String get settingsSpeechPreviewTextHelper =>
      'Để trống sẽ dùng văn bản mẫu mặc định.';

  @override
  String get settingsSpeechPreviewTextHint =>
      'Nhập hoặc dán văn bản bất kỳ để thử...';

  @override
  String get settingsSpeechPreviewClearTooltip => 'Xóa văn bản thử';

  @override
  String get settingsAboutMemoXTitle => 'Thông tin MemoX';

  @override
  String settingsAboutVersion(Object version) {
    return 'Phiên bản $version';
  }

  @override
  String get settingsAboutVersionUnknown => 'Chưa có thông tin phiên bản';

  @override
  String get settingsAboutMessage =>
      'MemoX giữ việc học flashcard theo hướng local-first, bình tĩnh và sẵn sàng sao lưu khi bạn chọn.';

  @override
  String get settingsAboutLegalese => 'MemoX';

  @override
  String get settingsUpdatedMessage => 'Đã cập nhật cài đặt.';

  @override
  String get appRouterErrorTitle => 'Lỗi điều hướng';

  @override
  String get errorConfiguration => 'Cấu hình ứng dụng không hợp lệ.';

  @override
  String get errorRequestTimedOut => 'Yêu cầu đã hết thời gian chờ.';

  @override
  String get errorInvalidData => 'Dữ liệu nhận được không hợp lệ.';

  @override
  String get errorUnsupportedAction => 'Thao tác này hiện chưa được hỗ trợ.';

  @override
  String get errorNetwork => 'Đã xảy ra sự cố kết nối mạng.';

  @override
  String get errorStorage => 'Đã xảy ra sự cố lưu trữ cục bộ.';

  @override
  String get errorNotFound => 'Không tìm thấy tài nguyên được yêu cầu.';

  @override
  String get errorUnexpected => 'Đã xảy ra lỗi.';

  @override
  String get errorFolderContainsDecks =>
      'Thư mục này đã có bộ thẻ. Hãy tạo bộ thẻ tại đây hoặc chọn thư mục khác để tạo thư mục con.';

  @override
  String get errorFolderContainsSubfolders =>
      'Thư mục này đã có thư mục con. Hãy tạo thư mục con tại đây hoặc chọn thư mục khác để tạo bộ thẻ.';

  @override
  String get foldersNewSubfolderTooltip => 'Thư mục con mới';

  @override
  String get foldersNewDeckTooltip => 'Bộ thẻ mới';

  @override
  String get foldersCreateChoiceTitle => 'Bạn muốn tạo gì?';

  @override
  String get foldersNewSubfolderTitle => 'Thư mục con mới';

  @override
  String get foldersFolderNameLabel => 'Tên thư mục';

  @override
  String get foldersFolderNameHint => 'ví dụ: Luyện nghe';

  @override
  String get foldersMoreActionsTooltip => 'Thêm thao tác';

  @override
  String get foldersActionsTitle => 'Thao tác thư mục';

  @override
  String get foldersReorder => 'Sắp xếp lại';

  @override
  String get foldersReorderManualOnlyHint =>
      'Hãy chuyển sắp xếp về chế độ thủ công để sắp xếp lại.';

  @override
  String get foldersImportChoiceTitle => 'Nhập flashcard';

  @override
  String get foldersImportCreateDeckAction => 'Tạo bộ thẻ mới';

  @override
  String get foldersImportExistingDeckAction => 'Thêm vào bộ thẻ có sẵn';

  @override
  String get foldersImportChooseDeckTitle => 'Chọn bộ thẻ';

  @override
  String get foldersImportNoDecksHint =>
      'Chưa có bộ thẻ nào trong thư mục này.';

  @override
  String foldersStatusSubfolders(int subfolderCount) {
    return 'Có $subfolderCount thư mục con';
  }

  @override
  String foldersStatusDecks(int deckCount, int totalCardCount) {
    return 'Có $deckCount bộ thẻ · $totalCardCount thẻ';
  }

  @override
  String get foldersSegmentSubfolders => 'Thư mục con';

  @override
  String get foldersSegmentDecks => 'Bộ thẻ';

  @override
  String get foldersSubfolderDeckHint =>
      'Để thêm bộ thẻ ở đây, hãy sắp xếp chúng trong một thư mục con.';

  @override
  String foldersDeckStats(int cardCount) {
    return '$cardCount thẻ';
  }

  @override
  String get foldersSubfolderCreatedMessage => 'Đã tạo thư mục con.';

  @override
  String get foldersRenameTitle => 'Đổi tên thư mục';

  @override
  String get foldersUpdatedMessage => 'Đã cập nhật thư mục.';

  @override
  String get foldersMoveTitle => 'Di chuyển thư mục';

  @override
  String get foldersMoveRootTitle => 'Gốc thư viện';

  @override
  String get foldersMoveRootSubtitle => 'Di chuyển thư mục này về gốc';

  @override
  String get foldersMovedMessage => 'Đã di chuyển thư mục.';

  @override
  String get foldersDeleteTitle => 'Xóa thư mục';

  @override
  String get foldersDeleteMessage =>
      'Thao tác này sẽ xóa toàn bộ cây con, bao gồm cả bộ thẻ và flashcard.';

  @override
  String get foldersDeletedMessage => 'Đã xóa thư mục.';

  @override
  String get foldersManualReorderWarning =>
      'Chỉ có thể sắp xếp thủ công khi đang ở chế độ sắp xếp thủ công.';

  @override
  String get foldersSummaryUnlocked =>
      'Thư mục này đang trống và có thể chứa thư mục con hoặc bộ thẻ.';

  @override
  String get foldersEmptyTitle => 'Thư mục này đang trống';

  @override
  String get foldersEmptyMessage =>
      'Hãy chọn một hướng trước. Một thư mục chỉ có thể chứa thư mục con hoặc bộ thẻ, không thể chứa cả hai.';

  @override
  String get foldersEmptySubfoldersTitle => 'Chưa có thư mục con';

  @override
  String get foldersEmptySubfoldersMessage =>
      'Tạo thư mục con để sắp xếp nhánh này.';

  @override
  String get foldersEmptyDecksTitle => 'Chưa có bộ thẻ';

  @override
  String get foldersEmptyDecksMessage =>
      'Tạo bộ thẻ để bắt đầu thêm flashcard tại đây.';

  @override
  String get foldersNoResultsTitle => 'Không có mục phù hợp';

  @override
  String get foldersNoResultsMessage => 'Xóa tìm kiếm hoặc thử từ khóa khác.';

  @override
  String get foldersClearSearchAction => 'Xóa';

  @override
  String get libraryCreateFolderTooltip => 'Tạo thư mục';

  @override
  String get libraryCreateFolderDialogTitle => 'Tạo thư mục';

  @override
  String get libraryFolderCreatedMessage => 'Đã tạo thư mục.';

  @override
  String get libraryDueTodayPrefix => 'Bạn có ';

  @override
  String get libraryDueTodaySuffix => ' mục cần học hôm nay';

  @override
  String get libraryStudyNow => 'Học ngay  →';

  @override
  String get libraryFoldersSectionTitle => 'Thư mục';

  @override
  String get libraryManageFoldersSubtitle => 'Quản lý cây thư mục của bạn';

  @override
  String get librarySearchResultsSubtitle => 'Kết quả tìm kiếm';

  @override
  String libraryHeroDueToday(int count) {
    return 'Đến hạn hôm nay: $count';
  }

  @override
  String libraryFolderStats(int subfolderCount, int deckCount, int cardCount) {
    return '$subfolderCount thư mục con · $deckCount bộ thẻ · $cardCount thẻ';
  }

  @override
  String libraryFolderMastery(int percent) {
    return '$percent% thành thạo';
  }

  @override
  String get libraryEmptyTitle => 'Chưa có thư mục nào';

  @override
  String get libraryEmptyMessage =>
      'Tạo thư mục đầu tiên để bắt đầu xây dựng thư viện của bạn.';

  @override
  String get libraryLoadFailedTitle => 'Không thể tải thư viện của bạn';

  @override
  String get libraryLoadFailedMessage =>
      'Dữ liệu của bạn vẫn an toàn trên thiết bị này. Hãy thử lại sau giây lát.';

  @override
  String get libraryOverflowTooltip => 'Tùy chọn thư mục';

  @override
  String get libraryFiltersTooltip => 'Bộ lọc';

  @override
  String get librarySearchHint => 'Tìm bộ thẻ, thẻ, nhãn';

  @override
  String get libraryNewFolderLabel => 'Thư mục mới';

  @override
  String libraryFolderCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thư mục',
      one: '1 thư mục',
    );
    return '$_temp0';
  }

  @override
  String libraryDueSummaryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ đến hạn hôm nay',
      one: '1 thẻ đến hạn hôm nay',
    );
    return '$_temp0';
  }

  @override
  String get decksCreateTitle => 'Tạo bộ thẻ';

  @override
  String get decksNameLabel => 'Tên bộ thẻ';

  @override
  String get decksNameHint => 'ví dụ: Từ vựng cốt lõi';

  @override
  String get decksCreatedMessage => 'Đã tạo bộ thẻ.';

  @override
  String get decksMoreActionsTooltip => 'Thêm thao tác';

  @override
  String get decksActionsTitle => 'Thao tác bộ thẻ';

  @override
  String get decksDuplicateAction => 'Nhân bản';

  @override
  String get decksExportAction => 'Xuất bộ thẻ';

  @override
  String decksOverviewSubtitle(
    int cardCount,
    int dueToday,
    int masteryPercent,
  ) {
    return '$cardCount thẻ · $dueToday thẻ đến hạn hôm nay · $masteryPercent% thành thạo';
  }

  @override
  String decksLastStudiedLabel(Object date) {
    return 'Học gần nhất: $date';
  }

  @override
  String get decksManageContentTitle => 'Quản lý nội dung';

  @override
  String get decksManageContentSubtitle =>
      'Mở flashcard, nhập dữ liệu vào bộ thẻ này, hoặc tiếp tục chỉnh sửa nội dung.';

  @override
  String get decksEmptyStudyTitle => 'Thêm thẻ trước khi học';

  @override
  String get decksEmptyStudyMessage =>
      'Bộ thẻ này chưa có flashcard. Hãy thêm hoặc nhập thẻ trước.';

  @override
  String get decksStudyUnavailableNoCards =>
      'Có thể học sau khi bộ thẻ có ít nhất một flashcard.';

  @override
  String get decksRenameTitle => 'Đổi tên bộ thẻ';

  @override
  String get decksUpdatedMessage => 'Đã cập nhật bộ thẻ.';

  @override
  String get decksMoveTitle => 'Di chuyển bộ thẻ';

  @override
  String get decksMovedMessage => 'Đã di chuyển bộ thẻ.';

  @override
  String get decksDuplicateTitle => 'Nhân bản bộ thẻ';

  @override
  String get decksCurrentFolderTitle => 'Thư mục hiện tại';

  @override
  String get decksDuplicatedMessage => 'Đã nhân bản bộ thẻ.';

  @override
  String get decksDeleteTitle => 'Xóa bộ thẻ';

  @override
  String get decksDeleteMessage =>
      'Thao tác này sẽ xóa toàn bộ bộ thẻ và tất cả flashcard bên trong.';

  @override
  String get decksDeletedMessage => 'Đã xóa bộ thẻ.';

  @override
  String get flashcardsOpenListAction => 'Mở';

  @override
  String get flashcardsAddAction => 'Thêm';

  @override
  String get flashcardsAddTooltip => 'Thêm flashcard';

  @override
  String get flashcardsActionsTitle => 'Thao tác flashcard';

  @override
  String get flashcardsSearchHint => 'Tìm flashcard';

  @override
  String get flashcardsPreviewDialogTitle => 'Xem trước thẻ';

  @override
  String flashcardsDeckSummary(int cardCount, int masteryPercent) {
    return '$cardCount thẻ · $masteryPercent% thành thạo';
  }

  @override
  String get flashcardsStudyModesTitle => 'Chế độ học';

  @override
  String get flashcardsProgressTitle => 'Tiến độ của bạn';

  @override
  String get flashcardsProgressSubtitle =>
      'Tiến độ được tính từ trạng thái SRS của bộ thẻ này.';

  @override
  String get flashcardsProgressNew => 'Chưa học';

  @override
  String get flashcardsProgressLearning => 'Đang học';

  @override
  String get flashcardsProgressMastered => 'Thành thạo';

  @override
  String flashcardsProgressCountValue(int count) {
    return '$count';
  }

  @override
  String get flashcardsCardsSectionTitle => 'Thẻ';

  @override
  String get flashcardsLearnDeckAction => 'Học bộ thẻ này';

  @override
  String flashcardsBulkSelected(int count) {
    return 'Đã chọn $count';
  }

  @override
  String get flashcardsBulkSubtitle =>
      'Di chuyển, xuất, hoặc xóa các flashcard đã chọn.';

  @override
  String get flashcardsEmptyTitle => 'Chưa có flashcard nào';

  @override
  String get flashcardsEmptyMessage =>
      'Hãy thêm thẻ thủ công hoặc nhập chúng vào bộ thẻ này.';

  @override
  String get flashcardsNoResultsTitle => 'Không có flashcard phù hợp';

  @override
  String get flashcardsNoResultsMessage =>
      'Không có flashcard nào trong bộ thẻ này khớp với tìm kiếm của bạn.';

  @override
  String get flashcardsClearSearchAction => 'Xóa';

  @override
  String get flashcardsMoveTitle => 'Di chuyển flashcard';

  @override
  String get flashcardsMoveProgressKeptNote =>
      'Tiến độ học sẽ được giữ nguyên sau khi di chuyển.';

  @override
  String get flashcardsMovedMessage => 'Đã di chuyển flashcard.';

  @override
  String get flashcardsDeleteTitle => 'Xóa flashcard';

  @override
  String get flashcardsDeleteMessage =>
      'Thao tác này sẽ xóa vĩnh viễn các flashcard đã chọn.';

  @override
  String get flashcardsDeletedMessage => 'Đã xóa flashcard.';

  @override
  String get flashcardsEditTitle => 'Sửa thẻ';

  @override
  String get flashcardsNewTitle => 'Thẻ mới';

  @override
  String get flashcardsFieldFrontLabel => 'Mặt trước';

  @override
  String get flashcardsFieldFrontHint => 'Nhập thuật ngữ';

  @override
  String get flashcardsFieldBackLabel => 'Mặt sau';

  @override
  String get flashcardsFieldBackHint =>
      'Tiếng Anh, tiếng Việt hoặc cả hai — phân cách bằng dấu phẩy.';

  @override
  String get flashcardsFieldNoteLabel => 'Ghi chú';

  @override
  String get flashcardsFieldNoteHint => 'Ghi chú bổ sung tùy chọn';

  @override
  String get flashcardsFieldExampleLabel => 'Câu ví dụ';

  @override
  String get flashcardsFieldExampleHint =>
      'Thêm một câu sử dụng thuật ngữ này…';

  @override
  String get flashcardsFieldTagsLabel => 'Thẻ phân loại';

  @override
  String get flashcardsFieldTagsHint => 'Thêm tag';

  @override
  String get flashcardsFieldPronunciationLabel => 'Phát âm';

  @override
  String get flashcardsFieldPronunciationHint =>
      'Phiên âm hoặc chữ La-tinh hóa';

  @override
  String get flashcardsFieldHintLabel => 'Gợi ý';

  @override
  String get flashcardsFieldHintHint => 'Gợi ý giúp nhớ mà không lộ đáp án.';

  @override
  String get flashcardsFieldStartingStatusLabel => 'Trạng thái bắt đầu';

  @override
  String get flashcardsStatusNew => 'Mới';

  @override
  String get flashcardsStatusLearning => 'Đang học';

  @override
  String get flashcardsStatusReviewing => 'Đang ôn';

  @override
  String get flashcardsRecordPronunciationTooltip => 'Ghi âm phát âm';

  @override
  String get flashcardsListenPronunciationTooltip => 'Nghe phát âm';

  @override
  String get flashcardsTagsAddAction => 'Thêm tag';

  @override
  String get flashcardsTagsSheetTitle => 'Thêm tag';

  @override
  String get flashcardsTagsConfirmAction => 'Thêm';

  @override
  String get flashcardsOptionalSuffix => 'tùy chọn';

  @override
  String flashcardsFieldLabelOptional(String label) {
    return '$label · tùy chọn';
  }

  @override
  String get flashcardsShowAdvanced => 'Hiện trường nâng cao';

  @override
  String get flashcardsHideAdvanced => 'Ẩn nâng cao';

  @override
  String get flashcardsDeckPickerLabel => 'Lưu vào';

  @override
  String get flashcardsDeckPickerSheetTitle => 'Lưu thẻ vào';

  @override
  String get flashcardsSaveAndAddNextTooltip => 'Lưu và thêm thẻ khác';

  @override
  String get flashcardsLongContentHelper =>
      'Hỗ trợ nhiều dòng. Hãy giữ đáp án đầy đủ và dễ đọc khi học.';

  @override
  String get flashcardsNoteHelper =>
      'Ngữ cảnh, ví dụ hoặc gợi ý ghi nhớ tùy chọn.';

  @override
  String get flashcardsSaveAndAddNext => 'Lưu & thêm thẻ khác';

  @override
  String get flashcardsSavedMessage => 'Đã lưu thẻ.';

  @override
  String get flashcardsSaveChanges => 'Lưu thay đổi';

  @override
  String get flashcardsSaveAction => 'Lưu thẻ';

  @override
  String get flashcardsLearningContentChangedTitle =>
      'Bạn đã thay đổi nội dung học.';

  @override
  String get flashcardsLearningContentChangedMessage =>
      'Giữ tiến độ hiện tại hay reset flashcard này?';

  @override
  String get flashcardsKeepProgressAction => 'Giữ';

  @override
  String get flashcardsResetProgressAction => 'Reset';

  @override
  String get flashcardsUpdatedMessage => 'Đã cập nhật flashcard.';

  @override
  String get flashcardsCreatedMessage => 'Đã tạo flashcard.';

  @override
  String get flashcardsDiscardChangesTitle => 'Hủy thay đổi?';

  @override
  String get flashcardsDiscardChangesMessage =>
      'Các thay đổi flashcard chưa lưu sẽ bị mất.';

  @override
  String get flashcardsDiscardChangesAction => 'Hủy thay đổi';

  @override
  String get flashcardsKeepEditingAction => 'Tiếp tục sửa';

  @override
  String get studyEntryTitle => 'Học';

  @override
  String get studyEntryHeading => 'Bắt đầu phiên học';

  @override
  String get studyEntrySubtitle =>
      'Chọn luồng học và chốt thiết lập cho phiên này.';

  @override
  String get studyStartAction => 'Học';

  @override
  String get studyStartNewSessionAction => 'Bắt đầu';

  @override
  String get studyStartNewSessionConfirmTitle => 'Bắt đầu phiên mới?';

  @override
  String get studyStartNewSessionConfirmMessage =>
      'Bắt đầu phiên mới sẽ hủy phiên hiện tại còn dang dở.';

  @override
  String get studyRestartAction => 'Bắt đầu lại';

  @override
  String get studyResumeTitle => 'Phiên học đang dở';

  @override
  String get studyResumeAction => 'Tiếp tục';

  @override
  String get studyContinueSessionAction => 'Tiếp tục';

  @override
  String get studyResumeChoiceTitle => 'Tiếp tục phiên trước?';

  @override
  String get studyResumeChoiceMessage =>
      'Bạn có một phiên học đang tạm dừng cho phạm vi này. Tiếp tục từ chỗ đang dở, hay học lại từ đầu?';

  @override
  String get studyResumeChoiceResumeAction => 'Tiếp tục';

  @override
  String get folderResumeMessage =>
      'Bạn có một phiên học đang tạm dừng cho thư mục này.';

  @override
  String get folderStudyEntryTitle => 'Học thư mục này';

  @override
  String get folderStudyTodayAction => 'Học thẻ đến hạn';

  @override
  String get folderStudyFolderAction => 'Học cả thư mục';

  @override
  String folderStudyDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ đến hạn hôm nay',
      one: '1 thẻ đến hạn hôm nay',
    );
    return '$_temp0';
  }

  @override
  String folderStudyCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
      one: '1 thẻ',
    );
    return '$_temp0';
  }

  @override
  String get folderDetailMasteryOverline => 'Tiến độ thư mục';

  @override
  String folderDetailDeckCountAndCards(int deckCount, int cardCount) {
    String _temp0 = intl.Intl.pluralLogic(
      deckCount,
      locale: localeName,
      other: '$deckCount bộ thẻ',
      one: '1 bộ thẻ',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cardCount,
      locale: localeName,
      other: '$cardCount thẻ',
      one: '1 thẻ',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String folderDetailDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count đến hạn',
      one: '1 đến hạn',
    );
    return '$_temp0';
  }

  @override
  String folderDetailStartStudyDueAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count đến hạn',
      one: '1 đến hạn',
    );
    return 'Bắt đầu học · $_temp0';
  }

  @override
  String get folderDetailStartStudyAction => 'Bắt đầu học';

  @override
  String folderDetailDecksSectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bộ thẻ',
      one: '1 bộ thẻ',
    );
    return '$_temp0';
  }

  @override
  String folderDetailSubfoldersSectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thư mục con',
      one: '1 thư mục con',
    );
    return '$_temp0';
  }

  @override
  String get deckResumeMessage =>
      'Bạn có một phiên học đang tạm dừng cho bộ thẻ này.';

  @override
  String get deckStudyEntryTitle => 'Học bộ thẻ này';

  @override
  String get deckStudyTodayAction => 'Học thẻ đến hạn';

  @override
  String get deckStudyDeckAction => 'Học bộ thẻ';

  @override
  String deckStudyDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ đến hạn hôm nay',
      one: '1 thẻ đến hạn hôm nay',
    );
    return '$_temp0';
  }

  @override
  String deckStudyCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
      one: '1 thẻ',
    );
    return '$_temp0';
  }

  @override
  String get studyStartOverAction => 'Học lại từ đầu';

  @override
  String get studyFlowTitle => 'Luồng học';

  @override
  String get studyTypeNew => 'Học mới';

  @override
  String get studyTypeReview => 'Ôn SRS';

  @override
  String get studyTodayReviewOnly =>
      'Hôm nay chỉ hỗ trợ ôn SRS cho thẻ đến hạn và quá hạn trong v1.';

  @override
  String get studySettingsTitle => 'Thiết lập phiên';

  @override
  String studyBatchSizeLabel(int count) {
    return 'Số thẻ: $count';
  }

  @override
  String studyBatchSizeRangeLabel(int min, int max) {
    return '$min-$max thẻ';
  }

  @override
  String get studyDecreaseBatch => 'Giảm số thẻ';

  @override
  String get studyIncreaseBatch => 'Tăng số thẻ';

  @override
  String get studyShuffleCards => 'Trộn flashcard';

  @override
  String get studyShuffleAnswers => 'Trộn đáp án';

  @override
  String get studyPrioritizeOverdue => 'Ưu tiên thẻ quá hạn';

  @override
  String get studyBatchSizeShortLabel => 'Số thẻ mỗi phiên';

  @override
  String studyStartWithCountAction(int count) {
    return 'Bắt đầu · $count thẻ';
  }

  @override
  String studyStartNewWithCountAction(int count) {
    return 'Tạo phiên mới · $count thẻ';
  }

  @override
  String get studySessionTitle => 'Phiên học';

  @override
  String get studyCancelAction => 'Hủy';

  @override
  String get studyActionFailed => 'Không thể thực hiện thao tác học.';

  @override
  String get studyFinalizeAction => 'Finalize';

  @override
  String get studySkipAction => 'Bỏ qua';

  @override
  String get studyTextSettingsTooltip => 'Tùy chỉnh chữ';

  @override
  String get studyAudioTooltip => 'Âm thanh';

  @override
  String get studyMoreActionsTooltip => 'Thêm thao tác';

  @override
  String get studyEditCardTooltip => 'Chỉnh sửa thẻ';

  @override
  String get studyCardAudioTooltip => 'Phát âm thanh thẻ';

  @override
  String get studyStopAudioTooltip => 'Dừng âm thanh';

  @override
  String get studyReviewTextSettingsTooltip => 'Tùy chỉnh chữ';

  @override
  String get studyReviewAudioTooltip => 'Âm thanh';

  @override
  String get studyReviewMoreActionsTooltip => 'Thêm thao tác';

  @override
  String get studyReviewEditCardTooltip => 'Chỉnh sửa thẻ';

  @override
  String get studyReviewCardAudioTooltip => 'Phát âm thanh thẻ';

  @override
  String studyReviewProgressPercent(int percent) {
    return '$percent%';
  }

  @override
  String get studySessionEnded => 'Phiên học này đã kết thúc.';

  @override
  String get studyViewResultAction => 'Xem';

  @override
  String studyProgressModeRound(Object mode, int round) {
    return '$mode · lượt $round';
  }

  @override
  String get studyResultTitle => 'Kết quả học';

  @override
  String get studyResultHeading => 'Tổng kết phiên';

  @override
  String get studyResultCards => 'Thẻ';

  @override
  String get studyResultAttempts => 'Lượt trả lời';

  @override
  String get studyResultCorrect => 'Đúng';

  @override
  String get studyResultIncorrect => 'Sai';

  @override
  String get studyResultBoxUp => 'Tăng box';

  @override
  String get studyResultBoxDown => 'Giảm box';

  @override
  String get studyResultRemaining => 'Còn lại';

  @override
  String get studyResultAccuracyLabel => 'Độ chính xác';

  @override
  String get studyResultAttemptAccuracyLabel => 'Độ chính xác lượt trả lời';

  @override
  String get studyResultRetryCardsLabel => 'Thẻ phải retry';

  @override
  String studyResultCardsMastered(int mastered, int total) {
    return 'Thẻ mastered: $mastered/$total';
  }

  @override
  String studyResultCardsCompleted(int completed, int total) {
    return 'Đã hoàn thành $completed/$total thẻ';
  }

  @override
  String get studyResultReviewMoreAction => 'Ôn';

  @override
  String get studyResultStudyAgainAction => 'Học';

  @override
  String get studyRetryFinalizeAction => 'Thử lại';

  @override
  String get studyResultCompleted => 'Đã hoàn thành';

  @override
  String get studyResultCancelled => 'Đã hủy';

  @override
  String get studyResultFailedFinalize => 'Finalize lỗi. Có thể thử lại.';

  @override
  String get studyResultReadyFinalize => 'Sẵn sàng finalize';

  @override
  String get studyResultInProgress => 'Đang học';

  @override
  String get studyResultDraft => 'Bản nháp';

  @override
  String get studyResultDoneAction => 'Xong';

  @override
  String get studyResultStudyMoreAction => 'Học thêm';

  @override
  String get studyResultBreakdownTitle => 'Kết quả';

  @override
  String get studyResultPerfect => 'Hoàn hảo';

  @override
  String get studyResultPassed => 'Qua';

  @override
  String get studyResultRecovered => 'Hồi phục';

  @override
  String get studyResultForgot => 'Quên';

  @override
  String get studyResultBoxChangesTitle => 'Thay đổi box';

  @override
  String get studyResultBoxAdvanced => 'Tăng box';

  @override
  String get studyResultBoxStayed => 'Giữ nguyên';

  @override
  String get studyResultBoxReset => 'Về box 1';

  @override
  String get studyResultBoxReachedMax => 'Đạt box 8';

  @override
  String get studyResultFailedFinalizeBanner =>
      'Một số dữ liệu chưa lưu. Vui lòng thử lại.';

  @override
  String get studyResultEmpty => 'Chưa trả lời thẻ nào';

  @override
  String get studyResultCardsToReviewTitle => 'Thẻ cần ôn lại';

  @override
  String get studyResultCardsToReviewEmpty => 'Không có thẻ nào cần ôn thêm.';

  @override
  String get studyResultRecoveredLabel => 'Hồi phục';

  @override
  String get studyResultForgotLabel => 'Quên';

  @override
  String studyResultBoxChangedLabel(int oldBox, int newBox) {
    return 'Box $oldBox → $newBox';
  }

  @override
  String get studyModeReview => 'Xem lại';

  @override
  String get studyModeMatch => 'Ghép đôi';

  @override
  String get studyModeGuess => 'Đoán';

  @override
  String get studyModeRecall => 'Nhớ lại';

  @override
  String get studyModeFill => 'Điền';

  @override
  String get studyModeReviewSubtitle => 'Lật thẻ theo lịch SRS';

  @override
  String get studyModeMatchSubtitle => 'Ghép mặt trước với mặt sau';

  @override
  String get studyModeGuessSubtitle => 'Trắc nghiệm A / B / C / D';

  @override
  String get studyModeRecallSubtitle => 'Viết lại từ trí nhớ';

  @override
  String get studyModeFillSubtitle => 'Điền vào chỗ trống';

  @override
  String get studyModeMixTitle => 'Mix';

  @override
  String get studyModeMixSubtitle => 'Cả 5 chế độ, một phiên';

  @override
  String get studyModeMixBadge => 'Thích ứng';

  @override
  String get studyModeMixSummary => 'Xem lại · Ghép · Đoán · Nhớ · Điền';

  @override
  String get deckBreakdownTitle => 'Phân loại thẻ';

  @override
  String get deckBreakdownNew => 'Mới';

  @override
  String get deckBreakdownLearning => 'Đang học';

  @override
  String get deckBreakdownReviewing => 'Đang ôn';

  @override
  String get deckBreakdownMastered => 'Thuộc';

  @override
  String libraryDeckDueSuffix(int dueCount) {
    return '· $dueCount đến hạn';
  }

  @override
  String get libraryDeckAllCaughtUp => 'Đã ôn hết';

  @override
  String get libraryFilterAll => 'Tất cả';

  @override
  String get deckMasteryLabel => 'Mastery';

  @override
  String deckMasteryProgress(int mastered, int total) {
    return '$mastered trên $total thẻ đã thuộc';
  }

  @override
  String get studyReadyToFinalizeTitle => 'Sẵn sàng finalize';

  @override
  String get studyReadyToFinalizeMessage =>
      'Toàn bộ thẻ bắt buộc đã pass. Finalize để commit tiến độ SRS.';

  @override
  String get studyChooseMatchingAnswer => 'Chọn đáp án khớp.';

  @override
  String get studyTypeMatchingAnswer => 'Nhập đáp án khớp.';

  @override
  String get studyAnswerLabel => 'Đáp án';

  @override
  String get studySubmitAnswer => 'Gửi';

  @override
  String get studyHelpAction => 'Trợ giúp';

  @override
  String get studyCheckAnswerAction => 'Kiểm tra';

  @override
  String get studyFillNoAnswerLabel => 'Chưa nhập đáp án';

  @override
  String get studyCorrectAction => 'Đúng';

  @override
  String get studyIncorrectAction => 'Sai';

  @override
  String get studyRememberedAction => 'Nhớ được';

  @override
  String get studyForgotAction => 'Đã quên';

  @override
  String get studyShowAnswerAction => 'Hiển thị';

  @override
  String studyShowAnswerCountdownAction(int seconds) {
    return 'Hiển thị (${seconds}s)';
  }

  @override
  String get studyNextAction => 'Tiếp theo';

  @override
  String get studyAnswerCorrectTitle => 'Đúng';

  @override
  String get studyAnswerIncorrectTitle => 'Chưa đúng';

  @override
  String studyCorrectAnswerLabel(Object answer) {
    return 'Đáp án đúng: $answer';
  }

  @override
  String studyYourAnswerLabel(Object answer) {
    return 'Đáp án của bạn: $answer';
  }

  @override
  String get studyMarkCorrectAction => 'Đánh dấu đúng';

  @override
  String get studyTryAgainAction => 'Thử lại';

  @override
  String get studyHintAction => 'Gợi ý';

  @override
  String get studyGotItAction => 'Đã nhớ';

  @override
  String get studyReviewSwipeHint => 'Vuốt hoặc bấm Tiếp';

  @override
  String get studyReviewMeaningLabel => 'Ý nghĩa';

  @override
  String get studyGuessPromptLabel => 'Đây là gì?';

  @override
  String studyGuessAutoAdvanceLabel(String seconds) {
    return 'Thẻ tiếp theo sau ${seconds}s';
  }

  @override
  String studyMatchBoardStatus(int board, int totalBoards, num pairsLeft) {
    return 'Bảng $board/$totalBoards · còn $pairsLeft cặp';
  }

  @override
  String studyMatchMistakesLabel(num mistakes) {
    String _temp0 = intl.Intl.pluralLogic(
      mistakes,
      locale: localeName,
      other: '$mistakes lỗi',
      zero: 'Không lỗi',
    );
    return '$_temp0';
  }

  @override
  String studyCounterFormat(int current, int total) {
    return '$current / $total';
  }

  @override
  String get studyContinueAction => 'Tiếp tục';

  @override
  String get studyEmptyAnswerMessage => 'Hãy nhập đáp án trước khi gửi.';

  @override
  String get studyEmpty_deck_noCards_title => 'Bộ này chưa có thẻ nào';

  @override
  String get studyEmpty_deck_noCards_cta => 'Thêm thẻ';

  @override
  String get studyEmpty_deck_noDueCards_title => 'Đã ôn hết hôm nay';

  @override
  String studyEmpty_deck_noDueCards_subtitle(String relativeTime) {
    return 'Hạn ôn tiếp theo $relativeTime.';
  }

  @override
  String get studyEmpty_deck_noDueCards_cta => 'Học bài mới';

  @override
  String get studyEmpty_folder_noCards_title => 'Thư mục này chưa có thẻ';

  @override
  String get studyEmpty_folder_noCards_cta => 'Thêm bộ thẻ';

  @override
  String get studyEmpty_folder_noDueCards_title => 'Thư mục này đã ôn xong';

  @override
  String studyEmpty_folder_noDueCards_subtitle(String relativeTime) {
    return 'Hạn ôn tiếp theo $relativeTime.';
  }

  @override
  String get studyEmpty_folder_noDueCards_cta => 'Học bài mới';

  @override
  String get studyEmpty_today_allDone_title => 'Đã ôn xong hôm nay!';

  @override
  String get studyEmpty_today_allDone_message =>
      'Tuyệt vời. Hẹn gặp lại ngày mai cho lượt ôn tiếp theo.';

  @override
  String get studyEmpty_today_allDone_cta => 'Về trang chính';

  @override
  String get studyEmpty_today_noContent_title => 'Bạn chưa tạo thẻ nào';

  @override
  String get studyEmpty_today_noContent_cta => 'Tạo bộ thẻ đầu tiên';

  @override
  String studyEmptyNextDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ngày',
      one: '1 ngày',
    );
    return 'sau $_temp0';
  }

  @override
  String studyEmptyNextDueInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giờ',
      one: '1 giờ',
    );
    return 'sau $_temp0';
  }

  @override
  String get studyEmptyNextDueSoon => 'sắp tới';

  @override
  String get studyEmpty_allBuried_title => 'Đã ẩn hết thẻ hôm nay';

  @override
  String get studyEmpty_allBuried_message =>
      'Bạn đã ẩn tất cả thẻ. Chúng sẽ quay lại vào ngày mai.';

  @override
  String get studyEmpty_allBuried_cta => 'Học bài mới';

  @override
  String get studyEmpty_allSuspended_title => 'Tất cả thẻ đã tạm dừng';

  @override
  String get studyEmpty_allSuspended_message =>
      'Khôi phục một vài thẻ để học lại.';

  @override
  String get studyEmpty_allSuspended_cta => 'Xem thẻ';

  @override
  String get cardActionsTitle => 'Tùy chọn thẻ';

  @override
  String get cardActionBury => 'Ẩn đến ngày mai';

  @override
  String get cardActionSuspend => 'Tạm dừng thẻ';

  @override
  String get studyCardBuriedMessage => 'Đã ẩn thẻ đến ngày mai.';

  @override
  String get studyCardSuspendedMessage => 'Đã tạm dừng thẻ.';

  @override
  String get commonUndo => 'Hoàn tác';

  @override
  String get studyCancelConfirmTitle => 'Hủy phiên học này?';

  @override
  String get studyCancelConfirmMessage =>
      'Phiên học hiện tại sẽ dừng lại và bạn sẽ được đưa đến màn hình kết quả.';

  @override
  String get studyCancelConfirmAction => 'Hủy';

  @override
  String get flashcardsImportTitle => 'Nhập flashcard';

  @override
  String get bulkAddTitle => 'Thêm hàng loạt';

  @override
  String get bulkAddBreadcrumbLeaf => 'Thêm hàng loạt';

  @override
  String get bulkAddTabPaste => 'Dán';

  @override
  String get bulkAddTabPreview => 'Xem trước';

  @override
  String bulkAddTabPreviewWithCount(int count) {
    return 'Xem trước ($count)';
  }

  @override
  String get bulkAddPasteHint =>
      '연구자\tnhà nghiên cứu\n공부하다\thọc\n도서관\tthư viện';

  @override
  String get bulkAddHelper =>
      'Mỗi dòng một thẻ. Ngăn cách thuật ngữ và nghĩa bằng tab hoặc hai khoảng trắng. Dán thẳng từ bảng tính — vẫn chạy ngon.';

  @override
  String bulkAddCardsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sẵn sàng $count thẻ',
      one: 'Sẵn sàng 1 thẻ',
    );
    return '$_temp0';
  }

  @override
  String get bulkAddNoDuplicates => 'Không trùng lặp';

  @override
  String bulkAddDuplicatesSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bỏ qua $count trùng',
      one: 'Bỏ qua 1 trùng',
    );
    return '$_temp0';
  }

  @override
  String bulkAddIssuesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lỗi',
      one: '1 lỗi',
    );
    return '$_temp0';
  }

  @override
  String bulkAddCommit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Thêm $count thẻ',
      one: 'Thêm 1 thẻ',
    );
    return '$_temp0';
  }

  @override
  String bulkAddFooterSummary(int count, String deckName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ · $deckName',
      one: '1 thẻ · $deckName',
    );
    return '$_temp0';
  }

  @override
  String get bulkAddEmptyPaste => 'Dán danh sách để xem trước.';

  @override
  String get bulkAddHelpTooltip => 'Hướng dẫn định dạng';

  @override
  String get bulkAddSeparatorLabel => 'DẤU TÁCH';

  @override
  String get bulkAddSourceTabText => 'Văn bản';

  @override
  String get bulkAddSourceTabFile => 'Tệp';

  @override
  String get bulkAddFileEmptyTitle => 'Chưa có tệp';

  @override
  String get bulkAddFileEmptyDescription =>
      'Chọn tệp CSV (.csv) hoặc Excel (.xlsx) tối đa 10 MB. Excel chỉ đọc sheet đầu tiên.';

  @override
  String get bulkAddFileChooseAction => 'Chọn tệp';

  @override
  String get bulkAddFileSizeError =>
      'Tệp vượt quá 10 MB. Hãy chọn tệp nhỏ hơn.';

  @override
  String get bulkAddFileFormatHint => 'CSV · XLSX · tối đa 10 MB';

  @override
  String get exportFormatChoiceTitle => 'Xuất ra';

  @override
  String get exportFormatCsvLabel => 'CSV';

  @override
  String get exportFormatCsvDescription =>
      'Văn bản thuần · mở bằng mọi bảng tính';

  @override
  String get exportFormatExcelLabel => 'Excel (.xlsx)';

  @override
  String get exportFormatExcelDescription => 'Tệp Excel · một sheet';

  @override
  String bulkAddFileLoadedTitle(String name) {
    return '$name';
  }

  @override
  String bulkAddFileSizeLabel(String size) {
    return '$size KB';
  }

  @override
  String bulkAddFooterTrailing(String deckName) {
    return 'thẻ · $deckName';
  }

  @override
  String get importSourceTitle => 'Nhập từ';

  @override
  String get importSourceSubtitle =>
      'Luồng import luôn preview trước và ghi atomically. Chỉ cần một dòng lỗi là chặn toàn bộ lần ghi.';

  @override
  String get importCsvLabel => 'CSV';

  @override
  String get importExcelLabel => 'Excel';

  @override
  String get importTextFormatLabel => 'Text';

  @override
  String get importLoadFile => 'Tải file';

  @override
  String get importSelectExcelFile => 'Chọn file Excel';

  @override
  String get importChangeFile => 'Đổi';

  @override
  String get importRemoveFile => 'Xóa';

  @override
  String get importFileReadyToPreview => 'Sẵn sàng xem trước';

  @override
  String importDetectedRowsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã nhận diện $count dòng',
      one: 'Đã nhận diện 1 dòng',
    );
    return '$_temp0';
  }

  @override
  String get importCsvContentLabel => 'Nội dung CSV';

  @override
  String get importExcelFileLabel => 'File Excel';

  @override
  String get importExcelNoFileTitle => 'Chưa tải file Excel';

  @override
  String get importExcelNoFileDescription =>
      'Tải file .xlsx. Cột A là mặt trước, cột B là mặt sau, cột C là ghi chú tùy chọn.';

  @override
  String get importExcelLoadedFileDescription =>
      'Preview đọc sheet đầu tiên từ A1. Bật tùy chọn header nếu dòng 1 là nhãn cột.';

  @override
  String get importExcelHasHeaderLabel => 'Dòng đầu là header';

  @override
  String get importExcelHasHeaderDescription => 'Dữ liệu bắt đầu từ dòng 2.';

  @override
  String get importTextContentLabel => 'Text có cấu trúc';

  @override
  String get importCsvHint => 'front,back,note';

  @override
  String get importTextHint =>
      'Front: ...\nBack: ...\nNote: ...\nHoặc mỗi dòng một thẻ: thuật ngữ / định nghĩa';

  @override
  String get importCsvRulesText => 'Dùng các cột front, back và note tùy chọn.';

  @override
  String get importExcelRulesText =>
      'Cột A = mặt trước, cột B = mặt sau, cột C = ghi chú.';

  @override
  String get importTextRulesText =>
      'Dùng các dòng Front:, Back: và Note: tùy chọn.';

  @override
  String get importSeparatorLabel => 'Dấu tách';

  @override
  String get importSeparatorAuto => 'Tự động';

  @override
  String get importSeparatorTab => 'Tab';

  @override
  String get importSeparatorComma => 'Phẩy';

  @override
  String get importSeparatorColon => 'Dấu hai chấm';

  @override
  String get importSeparatorSlash => 'Dấu gạch chéo';

  @override
  String get importSeparatorSemicolon => 'Dấu chấm phẩy';

  @override
  String get importSeparatorPipe => 'Dấu gạch đứng';

  @override
  String get importSeparatorAutoDescription =>
      'Tự nhận diện dấu tách rõ trước khi xem trước.';

  @override
  String get importSeparatorTabDescription => 'thuật ngữ<Tab>định nghĩa';

  @override
  String get importSeparatorCommaDescription => 'thuật ngữ, định nghĩa';

  @override
  String get importSeparatorColonDescription => 'thuật ngữ: định nghĩa';

  @override
  String get importSeparatorSlashDescription => 'thuật ngữ / định nghĩa';

  @override
  String get importSeparatorSemicolonDescription => 'thuật ngữ; định nghĩa';

  @override
  String get importSeparatorPipeDescription => 'thuật ngữ | định nghĩa';

  @override
  String get importDuplicateHandlingTitle => 'Xử lý trùng lặp';

  @override
  String get importDuplicatePolicySkipExact => 'Bỏ qua trùng khớp hoàn toàn';

  @override
  String get importDuplicatePolicySkipExactDescription =>
      'Cùng mặt trước nhưng mặt sau khác vẫn sẽ được import.';

  @override
  String get importDuplicatePolicyImportAnyway => 'Vẫn import';

  @override
  String get importDuplicatePolicyImportAnywayDescription =>
      'Tùy chọn sau MVP: tạo mọi dòng hợp lệ, kể cả khi mặt trước và mặt sau trùng thẻ đã có.';

  @override
  String get importDuplicatePolicyUpdateExisting => 'Cập nhật thẻ đã có';

  @override
  String get importDuplicatePolicyUpdateExistingDescription =>
      'Tùy chọn sau MVP: cập nhật thẻ khớp thay vì tạo duplicate mới.';

  @override
  String get importPreviewAction => 'Xem trước import';

  @override
  String importCommitCardsAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nhập $count thẻ',
      one: 'Nhập 1 thẻ',
    );
    return '$_temp0';
  }

  @override
  String importSuccessMessage(int count) {
    return 'Đã nhập $count flashcard.';
  }

  @override
  String importLoadedFileMessage(Object fileName) {
    return 'Đã tải $fileName.';
  }

  @override
  String get importFileUnavailableMessage =>
      'Không thể đọc file này. Hãy chọn một file CSV, text hoặc .xlsx khác.';

  @override
  String get importValidationIssuesTitle => 'Lỗi xác thực';

  @override
  String get importValidationIssuesSubtitle =>
      'Hãy sửa toàn bộ lỗi trước khi nhập.';

  @override
  String importValidationIssueLine(int line) {
    return 'Dòng $line';
  }

  @override
  String get importPreviewTitle => 'Xem trước';

  @override
  String importPreviewSubtitle(int count) {
    return '$count flashcard sẵn sàng được tạo';
  }

  @override
  String importPreviewSummary(int valid, int invalid) {
    return '$valid hợp lệ · $invalid lỗi';
  }

  @override
  String importPreviewSummaryWithSkipped(int valid, int invalid, int skipped) {
    return '$valid hợp lệ · $invalid lỗi · $skipped bỏ qua';
  }

  @override
  String get importSkippedDuplicatesTitle => 'Duplicate bị bỏ qua';

  @override
  String importSkippedDuplicatesSubtitle(int count) {
    return '$count duplicate trùng khớp hoàn toàn sẽ bị bỏ qua.';
  }

  @override
  String get importSkippedDuplicateInFile =>
      'Trùng khớp hoàn toàn trong file này';

  @override
  String get importSkippedDuplicateInDeck =>
      'Trùng khớp hoàn toàn trong deck này';

  @override
  String get importNothingTitle => 'Không có dữ liệu để nhập';

  @override
  String get importNothingMessage =>
      'Không có dòng hoặc block hợp lệ nào được tạo từ nguồn dữ liệu.';

  @override
  String get sharedErrorTitle => 'Đã xảy ra lỗi';

  @override
  String get sharedTryAgain => 'Thử lại';

  @override
  String get sharedShowDetails => 'Xem chi tiết';

  @override
  String get sharedHideDetails => 'Ẩn chi tiết';

  @override
  String get sharedFullscreenTooltip => 'Toàn màn hình';

  @override
  String get sharedStreakLabel => 'Chuỗi';

  @override
  String get sharedOfflineTitle => 'Bạn đang ngoại tuyến';

  @override
  String get sharedOfflineMessage =>
      'Hãy kiểm tra kết nối internet và thử lại. Bộ flashcard cục bộ của bạn vẫn hoạt động.';
}
