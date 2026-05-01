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
  String get dashboardHeading => 'Trọng tâm học hôm nay';

  @override
  String get dashboardSubtitle =>
      'Chọn hành động học hữu ích tiếp theo: ôn bài, học thẻ mới, tiếp tục phiên, hoặc xem sức khỏe thư viện.';

  @override
  String get dashboardTodayReviewTitle => 'Ôn hôm nay';

  @override
  String get dashboardOverdueLabel => 'Quá hạn';

  @override
  String dashboardReviewReadyMessage(int count) {
    return '$count thẻ đã sẵn sàng để ôn SRS.';
  }

  @override
  String get dashboardReviewEmptyMessage => 'Hiện không có thẻ cần ôn.';

  @override
  String get dashboardReviewNowAction => 'Ôn';

  @override
  String get dashboardNewStudyTitle => 'Học mới';

  @override
  String get dashboardNewCardsLabel => 'Thẻ mới có thể học';

  @override
  String dashboardNewStudyMessage(int count) {
    return '$count thẻ mới đã sẵn sàng cho phiên học theo deck hoặc folder.';
  }

  @override
  String get dashboardNewStudyEmptyMessage =>
      'Hãy thêm hoặc import thẻ trước khi bắt đầu phiên học mới.';

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
      'Không có phiên học nào đang chờ tiếp tục.';

  @override
  String get dashboardContinueSessionAction => 'Tiếp tục';

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
  String get dashboardOpenLibraryAction => 'Mở';

  @override
  String get dashboardLibraryProgressTitle => 'Tiến độ thư viện';

  @override
  String dashboardLibraryProgressMessage(
    int percent,
    int folderCount,
    int cardCount,
  ) {
    return '$percent% thành thạo · $folderCount thư mục · $cardCount thẻ';
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
  String get settingsThemeModeLabel => 'Chế độ giao diện';

  @override
  String get settingsThemeSystem => 'Theo hệ thống';

  @override
  String get settingsThemeLight => 'Sáng';

  @override
  String get settingsThemeDark => 'Tối';

  @override
  String get settingsLanguageTitle => 'Ngôn ngữ';

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
  String get settingsStudyDefaultsSubtitle =>
      'Cài đặt mặc định dùng khi tạo phiên học mới.';

  @override
  String get settingsStudyDefaultsLoading => 'Đang tải mặc định học';

  @override
  String get settingsNewStudyBatchSizeLabel => 'Số thẻ New Study';

  @override
  String get settingsReviewBatchSizeLabel => 'Số thẻ Review';

  @override
  String get settingsSpeechTitle => 'Giọng nói';

  @override
  String get settingsSpeechLabel => 'Hỗ trợ phát âm tiếng Hàn và tiếng Anh';

  @override
  String get settingsSpeechLoading => 'Đang tải cài đặt giọng nói';

  @override
  String get settingsSpeechAutoPlayLabel => 'Tự phát trong khi học';

  @override
  String get settingsSpeechAutoPlaySubtitle =>
      'Tự phát âm thẻ sau các chuyển trạng thái học.';

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
  String get settingsSpeechFrontVoiceLabel => 'Giọng mặt trước';

  @override
  String get settingsSpeechSystemVoice => 'Giọng hệ thống';

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
  String foldersDeckCardProgress(int cardCount, int dueToday) {
    return '$cardCount thẻ · $dueToday thẻ đến hạn hôm nay';
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
  String get decksExportCsvAction => 'Xuất CSV';

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
  String get flashcardsEditTitle => 'Chỉnh sửa flashcard';

  @override
  String get flashcardsNewTitle => 'Flashcard mới';

  @override
  String get flashcardsFieldFrontLabel => 'Mặt trước';

  @override
  String get flashcardsFieldFrontHint => 'Prompt hoặc câu hỏi';

  @override
  String get flashcardsFieldBackLabel => 'Mặt sau';

  @override
  String get flashcardsFieldBackHint => 'Đáp án hoặc định nghĩa';

  @override
  String get flashcardsFieldNoteLabel => 'Ghi chú';

  @override
  String get flashcardsFieldNoteHint => 'Ghi chú bổ sung tùy chọn';

  @override
  String get flashcardsLongContentHelper =>
      'Hỗ trợ nhiều dòng. Hãy giữ đáp án đầy đủ và dễ đọc khi học.';

  @override
  String get flashcardsNoteHelper =>
      'Ngữ cảnh, ví dụ hoặc gợi ý ghi nhớ tùy chọn.';

  @override
  String get flashcardsSaveAndAddNext => 'Lưu + tiếp';

  @override
  String get flashcardsSavedMessage => 'Đã lưu flashcard.';

  @override
  String get flashcardsSaveChanges => 'Lưu';

  @override
  String get flashcardsSaveAction => 'Lưu';

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
  String get studySessionTitle => 'Phiên học';

  @override
  String get studyCancelAction => 'Hủy';

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
  String get studyContinueAction => 'Tiếp tục';

  @override
  String get studyEmptyAnswerMessage => 'Hãy nhập đáp án trước khi gửi.';

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
  String get importSourceTitle => 'Nguồn dữ liệu';

  @override
  String get importSourceSubtitle =>
      'Luồng import luôn preview trước và ghi atomically. Chỉ cần một dòng lỗi là chặn toàn bộ lần ghi.';

  @override
  String get importCsvLabel => 'CSV';

  @override
  String get importTextFormatLabel => 'Định dạng text';

  @override
  String get importLoadFile => 'Tải file';

  @override
  String get importCsvContentLabel => 'Nội dung CSV';

  @override
  String get importTextContentLabel => 'Text có cấu trúc';

  @override
  String get importCsvHint => 'front,back,note';

  @override
  String get importTextHint =>
      'Front: ...\nBack: ...\nNote: ...\nHoặc mỗi dòng một thẻ: thuật ngữ / định nghĩa';

  @override
  String get importSeparatorLabel => 'Dấu tách';

  @override
  String get importSeparatorAuto => 'Tự động';

  @override
  String get importSeparatorTab => 'Tab';

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
  String get importPreviewAction => 'Xem trước';

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
      'Không thể đọc file này. Hãy chọn một file CSV hoặc text khác.';

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
