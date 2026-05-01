// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MemoX';

  @override
  String get commonBack => 'Back';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSort => 'Sort';

  @override
  String get commonSave => 'Save';

  @override
  String get commonImport => 'Import';

  @override
  String get commonExport => 'Export';

  @override
  String get commonMove => 'Move';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonSelect => 'Select';

  @override
  String get commonSelectAll => 'Select all';

  @override
  String get commonSaveOrder => 'Save order';

  @override
  String get commonOverview => 'Overview';

  @override
  String get commonNever => 'Never';

  @override
  String get commonReorder => 'Reorder';

  @override
  String get commonNoValidDestinationFound => 'No valid destination found.';

  @override
  String get commonDefaultOrderUpdated => 'Default order updated.';

  @override
  String commonPercentValue(int value) {
    return '$value%';
  }

  @override
  String get commonSearch => 'Search';

  @override
  String get sortManual => 'Manual';

  @override
  String get sortName => 'Name';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortLastStudied => 'Last studied';

  @override
  String get homeTitle => 'Home';

  @override
  String get libraryTitle => 'Library';

  @override
  String get progressTitle => 'Progress';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appShellHomePlaceholderDescription =>
      'Home dashboard foundation is not wired yet.';

  @override
  String get appShellProgressPlaceholderDescription =>
      'Progress foundation is not wired yet.';

  @override
  String get appShellSettingsPlaceholderDescription =>
      'Settings foundation is not wired yet.';

  @override
  String get dashboardHeading => 'Today\'s study focus';

  @override
  String get dashboardSubtitle =>
      'Choose the next useful study action: review, learn new cards, resume, or inspect library health.';

  @override
  String get dashboardTodayReviewTitle => 'Today Review';

  @override
  String get dashboardOverdueLabel => 'Overdue';

  @override
  String dashboardReviewReadyMessage(int count) {
    return '$count cards are ready for SRS review.';
  }

  @override
  String get dashboardReviewEmptyMessage =>
      'No review cards are due right now.';

  @override
  String get dashboardReviewNowAction => 'Review';

  @override
  String get dashboardNewStudyTitle => 'New Study';

  @override
  String get dashboardNewCardsLabel => 'New cards available';

  @override
  String dashboardNewStudyMessage(int count) {
    return '$count new cards are ready for a deck or folder session.';
  }

  @override
  String get dashboardNewStudyEmptyMessage =>
      'Add or import cards before starting a new study session.';

  @override
  String get dashboardStartNewStudyAction => 'Start';

  @override
  String get dashboardResumeTitle => 'Resume';

  @override
  String get dashboardActiveSessionsLabel => 'Active sessions';

  @override
  String dashboardResumeMessage(int count) {
    return '$count sessions can be continued or finalized.';
  }

  @override
  String get dashboardResumeEmptyMessage =>
      'No study session is waiting to resume.';

  @override
  String get dashboardContinueSessionAction => 'Resume';

  @override
  String get dashboardLibraryHealthTitle => 'Library health';

  @override
  String dashboardLibraryHealthSummary(
    int folderCount,
    int deckCount,
    int cardCount,
  ) {
    return '$folderCount folders · $deckCount decks · $cardCount cards';
  }

  @override
  String get dashboardMasteryLabel => 'Mastery';

  @override
  String get dashboardDueTodayTitle => 'Due today';

  @override
  String dashboardDueTodayMessage(int count) {
    return '$count cards ready to review';
  }

  @override
  String dashboardLibrarySummary(int folderCount, int cardCount) {
    return '$folderCount folders · $cardCount cards';
  }

  @override
  String get dashboardNoDueTitle => 'No cards due now';

  @override
  String get dashboardNoDueMessage =>
      'Open your library to add cards or start a focused deck session.';

  @override
  String get dashboardStudyTodayAction => 'Study';

  @override
  String get dashboardOpenLibraryAction => 'Open';

  @override
  String get dashboardLibraryProgressTitle => 'Library progress';

  @override
  String dashboardLibraryProgressMessage(
    int percent,
    int folderCount,
    int cardCount,
  ) {
    return '$percent% mastery · $folderCount folders · $cardCount cards';
  }

  @override
  String get progressOverviewHeading => 'Learning overview';

  @override
  String get progressOverviewSubtitle =>
      'Track review pressure, library mastery, and open session recovery.';

  @override
  String get progressReviewDueCount => 'Due now';

  @override
  String get progressActiveSessionsHeading => 'Active sessions';

  @override
  String get progressActiveSessionsSubtitle =>
      'Resume, finalize, retry, or cancel the study sessions that are still open.';

  @override
  String get progressActiveSessionsCount => 'Active';

  @override
  String get progressReadySessionsCount => 'Ready';

  @override
  String get progressFailedSessionsCount => 'Needs retry';

  @override
  String get progressEmptyTitle => 'No active study sessions';

  @override
  String get progressEmptyMessage =>
      'Start studying from Library. Sessions that are in progress or waiting to finalize will appear here.';

  @override
  String progressSessionTitle(Object studyType, Object entryType) {
    return '$studyType · $entryType';
  }

  @override
  String progressSessionCardProgress(int completed, int total, int remaining) {
    return '$completed of $total study steps · $remaining remaining';
  }

  @override
  String progressSessionCurrentCard(Object card) {
    return 'Current card: $card';
  }

  @override
  String progressSessionStartedAt(Object date, Object time) {
    return 'Started $date at $time';
  }

  @override
  String get progressEntryDeck => 'Deck';

  @override
  String get progressEntryFolder => 'Folder';

  @override
  String get progressEntryToday => 'Today';

  @override
  String get progressSessionStatusInProgress => 'In progress';

  @override
  String get progressSessionStatusReady => 'Ready to finalize';

  @override
  String get progressSessionStatusFailed => 'Finalize failed';

  @override
  String get progressCancelConfirmTitle => 'Cancel this study session?';

  @override
  String get progressCancelConfirmMessage =>
      'The current session will stop. Completed attempts remain in its history, but pending cards are abandoned.';

  @override
  String get progressSessionCancelledMessage => 'Session cancelled.';

  @override
  String get progressSessionFinalizedMessage => 'Session finalized.';

  @override
  String get progressSessionRetryFinalizeMessage => 'Finalize retried.';

  @override
  String get progressSessionActionFailed => 'Session action failed.';

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsThemeModeLabel => 'Theme mode';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLocaleLabel => 'App language';

  @override
  String get settingsLocaleSystem => 'System';

  @override
  String get settingsLocaleEnglish => 'English';

  @override
  String get settingsLocaleVietnamese => 'Vietnamese';

  @override
  String get settingsStudyDefaultsTitle => 'Study defaults';

  @override
  String get settingsStudyDefaultsSubtitle =>
      'Defaults used when a new study session is created.';

  @override
  String get settingsStudyDefaultsLoading => 'Loading study defaults';

  @override
  String get settingsNewStudyBatchSizeLabel => 'New Study batch size';

  @override
  String get settingsReviewBatchSizeLabel => 'Review batch size';

  @override
  String get settingsSpeechTitle => 'Speech';

  @override
  String get settingsSpeechLabel => 'Korean and English pronunciation support';

  @override
  String get settingsSpeechLoading => 'Loading speech settings';

  @override
  String get settingsSpeechAutoPlayLabel => 'Auto-play in study';

  @override
  String get settingsSpeechAutoPlaySubtitle =>
      'Automatically pronounce cards after study transitions.';

  @override
  String get settingsSpeechFrontLanguageLabel => 'Front language';

  @override
  String get settingsSpeechKorean => 'Korean';

  @override
  String get settingsSpeechEnglish => 'English';

  @override
  String get settingsSpeechRateLabel => 'Speech rate';

  @override
  String settingsSpeechRateValue(double value) {
    return '${value}x';
  }

  @override
  String get settingsSpeechFrontVoiceLabel => 'Front voice';

  @override
  String get settingsSpeechSystemVoice => 'System voice';

  @override
  String get settingsSpeechLoadingVoices => 'Loading voices...';

  @override
  String settingsSpeechNoVoices(Object language) {
    return 'No $language voice was reported by this device.';
  }

  @override
  String get settingsSpeechPreviewKorean => 'Preview Korean';

  @override
  String get settingsSpeechPreviewEnglish => 'Preview English';

  @override
  String get settingsSpeechPreviewSelected => 'Preview audio';

  @override
  String get settingsSpeechVoiceOptions => 'Voice options';

  @override
  String get settingsSpeechHideVoiceOptions => 'Hide voice options';

  @override
  String get settingsSpeechKoreanPreviewText => '안녕하세요';

  @override
  String get settingsSpeechEnglishPreviewText => 'Hello';

  @override
  String get settingsSpeechPreviewTextLabel => 'Test text';

  @override
  String get settingsSpeechPreviewTextHelper =>
      'Leave empty to use the default sample.';

  @override
  String get settingsSpeechPreviewTextHint =>
      'Type or paste any text to test...';

  @override
  String get settingsSpeechPreviewClearTooltip => 'Clear test text';

  @override
  String get settingsUpdatedMessage => 'Settings updated.';

  @override
  String get appRouterErrorTitle => 'Navigation error';

  @override
  String get errorConfiguration => 'The app configuration is invalid.';

  @override
  String get errorRequestTimedOut => 'The request timed out.';

  @override
  String get errorInvalidData => 'The received data is invalid.';

  @override
  String get errorUnsupportedAction =>
      'This action is not supported right now.';

  @override
  String get errorNetwork => 'A network problem occurred.';

  @override
  String get errorStorage => 'A local storage problem occurred.';

  @override
  String get errorNotFound => 'The requested resource could not be found.';

  @override
  String get errorUnexpected => 'Something went wrong.';

  @override
  String get foldersNewSubfolderTooltip => 'New subfolder';

  @override
  String get foldersNewDeckTooltip => 'New deck';

  @override
  String get foldersCreateChoiceTitle => 'What do you want to create?';

  @override
  String get foldersNewSubfolderTitle => 'New subfolder';

  @override
  String get foldersFolderNameLabel => 'Folder name';

  @override
  String get foldersFolderNameHint => 'e.g. Listening practice';

  @override
  String get foldersMoreActionsTooltip => 'More actions';

  @override
  String get foldersActionsTitle => 'Folder actions';

  @override
  String get foldersReorder => 'Reorder';

  @override
  String get foldersReorderManualOnlyHint =>
      'Switch sort back to manual to reorder.';

  @override
  String foldersStatusSubfolders(int subfolderCount) {
    return 'Contains $subfolderCount subfolders';
  }

  @override
  String foldersStatusDecks(int deckCount, int totalCardCount) {
    return 'Contains $deckCount decks · $totalCardCount cards';
  }

  @override
  String get foldersSegmentSubfolders => 'Subfolders';

  @override
  String get foldersSegmentDecks => 'Decks';

  @override
  String get foldersSubfolderDeckHint =>
      'To add decks here, organize them in a subfolder.';

  @override
  String foldersDeckCardProgress(int cardCount, int dueToday) {
    return '$cardCount cards · $dueToday due today';
  }

  @override
  String get foldersSubfolderCreatedMessage => 'Subfolder created.';

  @override
  String get foldersRenameTitle => 'Rename folder';

  @override
  String get foldersUpdatedMessage => 'Folder updated.';

  @override
  String get foldersMoveTitle => 'Move folder';

  @override
  String get foldersMoveRootTitle => 'Library root';

  @override
  String get foldersMoveRootSubtitle => 'Move this folder to root';

  @override
  String get foldersMovedMessage => 'Folder moved.';

  @override
  String get foldersDeleteTitle => 'Delete folder';

  @override
  String get foldersDeleteMessage =>
      'This will delete the full subtree, including decks and flashcards.';

  @override
  String get foldersDeletedMessage => 'Folder deleted.';

  @override
  String get foldersManualReorderWarning =>
      'Manual reorder is only available in manual sort.';

  @override
  String get foldersSummaryUnlocked =>
      'This folder is empty and can hold subfolders or decks.';

  @override
  String get foldersEmptyTitle => 'This folder is empty';

  @override
  String get foldersEmptyMessage =>
      'Choose a direction first. A folder can contain subfolders or decks, not both.';

  @override
  String get foldersEmptySubfoldersTitle => 'No subfolders yet';

  @override
  String get foldersEmptySubfoldersMessage =>
      'Create a subfolder to keep this branch organized.';

  @override
  String get foldersEmptyDecksTitle => 'No decks yet';

  @override
  String get foldersEmptyDecksMessage =>
      'Create a deck to start adding flashcards here.';

  @override
  String get foldersNoResultsTitle => 'No matching items';

  @override
  String get foldersNoResultsMessage => 'Clear search or try a different term.';

  @override
  String get foldersClearSearchAction => 'Clear';

  @override
  String get libraryCreateFolderTooltip => 'Create folder';

  @override
  String get libraryCreateFolderDialogTitle => 'Create folder';

  @override
  String get libraryFolderCreatedMessage => 'Folder created.';

  @override
  String get libraryDueTodayPrefix => 'You have ';

  @override
  String get libraryDueTodaySuffix => ' items due today';

  @override
  String get libraryStudyNow => 'Study now  →';

  @override
  String get libraryFoldersSectionTitle => 'Folders';

  @override
  String get libraryManageFoldersSubtitle => 'Manage your folder tree';

  @override
  String get librarySearchResultsSubtitle => 'Search results';

  @override
  String libraryHeroDueToday(int count) {
    return 'Due today: $count';
  }

  @override
  String libraryFolderStats(int subfolderCount, int deckCount, int cardCount) {
    String _temp0 = intl.Intl.pluralLogic(
      subfolderCount,
      locale: localeName,
      other: '$subfolderCount subfolders',
      one: '1 subfolder',
      zero: '0 subfolders',
    );
    String _temp1 = intl.Intl.pluralLogic(
      deckCount,
      locale: localeName,
      other: '$deckCount decks',
      one: '1 deck',
      zero: '0 decks',
    );
    String _temp2 = intl.Intl.pluralLogic(
      cardCount,
      locale: localeName,
      other: '$cardCount cards',
      one: '1 card',
      zero: '0 cards',
    );
    return '$_temp0 · $_temp1 · $_temp2';
  }

  @override
  String libraryFolderMastery(int percent) {
    return 'Mastery $percent%';
  }

  @override
  String get libraryEmptyTitle => 'No folders yet';

  @override
  String get libraryEmptyMessage =>
      'Create your first folder to start building your library.';

  @override
  String get decksCreateTitle => 'Create deck';

  @override
  String get decksNameLabel => 'Deck name';

  @override
  String get decksNameHint => 'e.g. Core vocabulary';

  @override
  String get decksCreatedMessage => 'Deck created.';

  @override
  String get decksMoreActionsTooltip => 'More actions';

  @override
  String get decksActionsTitle => 'Deck actions';

  @override
  String get decksDuplicateAction => 'Duplicate';

  @override
  String get decksExportCsvAction => 'Export CSV';

  @override
  String decksOverviewSubtitle(
    int cardCount,
    int dueToday,
    int masteryPercent,
  ) {
    return '$cardCount cards · $dueToday due today · $masteryPercent% mastery';
  }

  @override
  String decksLastStudiedLabel(Object date) {
    return 'Last studied: $date';
  }

  @override
  String get decksManageContentTitle => 'Manage content';

  @override
  String get decksManageContentSubtitle =>
      'Open flashcards, import into this deck, or continue editing content.';

  @override
  String get decksEmptyStudyTitle => 'Add cards before studying';

  @override
  String get decksEmptyStudyMessage =>
      'This deck has no flashcards yet. Add or import cards first.';

  @override
  String get decksStudyUnavailableNoCards =>
      'Study is available after this deck has at least one flashcard.';

  @override
  String get decksRenameTitle => 'Rename deck';

  @override
  String get decksUpdatedMessage => 'Deck updated.';

  @override
  String get decksMoveTitle => 'Move deck';

  @override
  String get decksMovedMessage => 'Deck moved.';

  @override
  String get decksDuplicateTitle => 'Duplicate deck';

  @override
  String get decksCurrentFolderTitle => 'Current folder';

  @override
  String get decksDuplicatedMessage => 'Deck duplicated.';

  @override
  String get decksDeleteTitle => 'Delete deck';

  @override
  String get decksDeleteMessage =>
      'This will delete the entire deck and all flashcards inside it.';

  @override
  String get decksDeletedMessage => 'Deck deleted.';

  @override
  String get flashcardsOpenListAction => 'Open';

  @override
  String get flashcardsAddAction => 'Add';

  @override
  String get flashcardsAddTooltip => 'Add flashcard';

  @override
  String get flashcardsActionsTitle => 'Flashcard actions';

  @override
  String get flashcardsSearchHint => 'Search flashcards';

  @override
  String flashcardsBulkSelected(int count) {
    return '$count selected';
  }

  @override
  String get flashcardsBulkSubtitle =>
      'Move, export, or delete the selected flashcards.';

  @override
  String get flashcardsEmptyTitle => 'No flashcards yet';

  @override
  String get flashcardsEmptyMessage =>
      'Add cards manually or import them into this deck.';

  @override
  String get flashcardsMoveTitle => 'Move flashcards';

  @override
  String get flashcardsMoveProgressKeptNote =>
      'Learning progress will be kept after moving.';

  @override
  String get flashcardsMovedMessage => 'Flashcards moved.';

  @override
  String get flashcardsDeleteTitle => 'Delete flashcards';

  @override
  String get flashcardsDeleteMessage =>
      'This will permanently delete the selected flashcards.';

  @override
  String get flashcardsDeletedMessage => 'Flashcards deleted.';

  @override
  String get flashcardsEditTitle => 'Edit flashcard';

  @override
  String get flashcardsNewTitle => 'New flashcard';

  @override
  String get flashcardsFieldFrontLabel => 'Front';

  @override
  String get flashcardsFieldFrontHint => 'Prompt or question';

  @override
  String get flashcardsFieldBackLabel => 'Back';

  @override
  String get flashcardsFieldBackHint => 'Answer or definition';

  @override
  String get flashcardsFieldNoteLabel => 'Note';

  @override
  String get flashcardsFieldNoteHint => 'Optional extra note';

  @override
  String get flashcardsLongContentHelper =>
      'Supports multiple lines. Keep the full answer readable during study.';

  @override
  String get flashcardsNoteHelper =>
      'Optional context, examples, or memory hints.';

  @override
  String get flashcardsSaveAndAddNext => 'Save + next';

  @override
  String get flashcardsSavedMessage => 'Flashcard saved.';

  @override
  String get flashcardsSaveChanges => 'Save';

  @override
  String get flashcardsSaveAction => 'Save';

  @override
  String get flashcardsLearningContentChangedTitle =>
      'You changed the learning content.';

  @override
  String get flashcardsLearningContentChangedMessage =>
      'Keep existing progress or reset this card?';

  @override
  String get flashcardsKeepProgressAction => 'Keep';

  @override
  String get flashcardsResetProgressAction => 'Reset';

  @override
  String get flashcardsUpdatedMessage => 'Flashcard updated.';

  @override
  String get flashcardsCreatedMessage => 'Flashcard created.';

  @override
  String get studyEntryTitle => 'Study';

  @override
  String get studyEntryHeading => 'Start a study session';

  @override
  String get studyEntrySubtitle =>
      'Choose a flow and snapshot settings for this session.';

  @override
  String get studyStartAction => 'Study';

  @override
  String get studyStartNewSessionAction => 'Start';

  @override
  String get studyStartNewSessionConfirmTitle => 'Start a new session?';

  @override
  String get studyStartNewSessionConfirmMessage =>
      'Starting a new session will cancel the current unfinished session.';

  @override
  String get studyRestartAction => 'Restart';

  @override
  String get studyResumeTitle => 'Session in progress';

  @override
  String get studyResumeAction => 'Continue';

  @override
  String get studyContinueSessionAction => 'Continue';

  @override
  String get studyFlowTitle => 'Study flow';

  @override
  String get studyTypeNew => 'New Study';

  @override
  String get studyTypeReview => 'SRS Review';

  @override
  String get studyTodayReviewOnly =>
      'Today supports SRS Review due and overdue cards in v1.';

  @override
  String get studySettingsTitle => 'Session settings';

  @override
  String studyBatchSizeLabel(int count) {
    return 'Batch size: $count';
  }

  @override
  String studyBatchSizeRangeLabel(int min, int max) {
    return '$min-$max cards';
  }

  @override
  String get studyDecreaseBatch => 'Decrease batch size';

  @override
  String get studyIncreaseBatch => 'Increase batch size';

  @override
  String get studyShuffleCards => 'Shuffle flashcards';

  @override
  String get studyShuffleAnswers => 'Shuffle answers';

  @override
  String get studyPrioritizeOverdue => 'Prioritize overdue cards';

  @override
  String get studySessionTitle => 'Study session';

  @override
  String get studyCancelAction => 'Cancel';

  @override
  String get studyFinalizeAction => 'Finalize';

  @override
  String get studySkipAction => 'Skip';

  @override
  String get studyTextSettingsTooltip => 'Text settings';

  @override
  String get studyAudioTooltip => 'Audio';

  @override
  String get studyMoreActionsTooltip => 'More actions';

  @override
  String get studyEditCardTooltip => 'Edit card';

  @override
  String get studyCardAudioTooltip => 'Play card audio';

  @override
  String get studyStopAudioTooltip => 'Stop audio';

  @override
  String get studyReviewTextSettingsTooltip => 'Text settings';

  @override
  String get studyReviewAudioTooltip => 'Audio';

  @override
  String get studyReviewMoreActionsTooltip => 'More actions';

  @override
  String get studyReviewEditCardTooltip => 'Edit card';

  @override
  String get studyReviewCardAudioTooltip => 'Play card audio';

  @override
  String studyReviewProgressPercent(int percent) {
    return '$percent%';
  }

  @override
  String get studySessionEnded => 'This session has ended.';

  @override
  String get studyViewResultAction => 'View';

  @override
  String studyProgressModeRound(Object mode, int round) {
    return '$mode · round $round';
  }

  @override
  String get studyResultTitle => 'Study result';

  @override
  String get studyResultHeading => 'Session summary';

  @override
  String get studyResultCards => 'Cards';

  @override
  String get studyResultAttempts => 'Attempts';

  @override
  String get studyResultCorrect => 'Correct';

  @override
  String get studyResultIncorrect => 'Incorrect';

  @override
  String get studyResultBoxUp => 'Box increased';

  @override
  String get studyResultBoxDown => 'Box decreased';

  @override
  String get studyResultRemaining => 'Remaining';

  @override
  String get studyResultAccuracyLabel => 'Accuracy';

  @override
  String get studyResultAttemptAccuracyLabel => 'Attempt accuracy';

  @override
  String get studyResultRetryCardsLabel => 'Retry cards';

  @override
  String studyResultCardsMastered(int mastered, int total) {
    return 'Cards mastered: $mastered/$total';
  }

  @override
  String studyResultCardsCompleted(int completed, int total) {
    return '$completed of $total cards completed';
  }

  @override
  String get studyResultReviewMoreAction => 'Review';

  @override
  String get studyResultStudyAgainAction => 'Study';

  @override
  String get studyRetryFinalizeAction => 'Retry';

  @override
  String get studyResultCompleted => 'Completed';

  @override
  String get studyResultCancelled => 'Cancelled';

  @override
  String get studyResultFailedFinalize => 'Finalize failed. Retry when ready.';

  @override
  String get studyResultReadyFinalize => 'Ready to finalize';

  @override
  String get studyResultInProgress => 'In progress';

  @override
  String get studyResultDraft => 'Draft';

  @override
  String get studyModeReview => 'Review';

  @override
  String get studyModeMatch => 'Match';

  @override
  String get studyModeGuess => 'Guess';

  @override
  String get studyModeRecall => 'Recall';

  @override
  String get studyModeFill => 'Fill';

  @override
  String get studyReadyToFinalizeTitle => 'Ready to finalize';

  @override
  String get studyReadyToFinalizeMessage =>
      'All required items are passed. Finalize to commit SRS progress.';

  @override
  String get studyChooseMatchingAnswer => 'Choose the matching answer.';

  @override
  String get studyTypeMatchingAnswer => 'Type the matching answer.';

  @override
  String get studyAnswerLabel => 'Answer';

  @override
  String get studySubmitAnswer => 'Submit';

  @override
  String get studyHelpAction => 'Help';

  @override
  String get studyCheckAnswerAction => 'Check';

  @override
  String get studyFillNoAnswerLabel => 'No answer entered';

  @override
  String get studyCorrectAction => 'Correct';

  @override
  String get studyIncorrectAction => 'Incorrect';

  @override
  String get studyRememberedAction => 'Remembered';

  @override
  String get studyForgotAction => 'Forgot';

  @override
  String get studyShowAnswerAction => 'Show';

  @override
  String studyShowAnswerCountdownAction(int seconds) {
    return 'Show (${seconds}s)';
  }

  @override
  String get studyNextAction => 'Next';

  @override
  String get studyAnswerCorrectTitle => 'Correct';

  @override
  String get studyAnswerIncorrectTitle => 'Not quite';

  @override
  String studyCorrectAnswerLabel(Object answer) {
    return 'Correct answer: $answer';
  }

  @override
  String studyYourAnswerLabel(Object answer) {
    return 'Your answer: $answer';
  }

  @override
  String get studyMarkCorrectAction => 'Mark correct';

  @override
  String get studyContinueAction => 'Continue';

  @override
  String get studyEmptyAnswerMessage => 'Enter an answer before submitting.';

  @override
  String get studyCancelConfirmTitle => 'Cancel this session?';

  @override
  String get studyCancelConfirmMessage =>
      'Your current study session will stop and you will be taken to the result screen.';

  @override
  String get studyCancelConfirmAction => 'Cancel';

  @override
  String get flashcardsImportTitle => 'Import flashcards';

  @override
  String get importSourceTitle => 'Source';

  @override
  String get importSourceSubtitle =>
      'Import is preview-first and atomic. Any invalid line blocks the entire write.';

  @override
  String get importCsvLabel => 'CSV';

  @override
  String get importTextFormatLabel => 'Text format';

  @override
  String get importLoadFile => 'Load file';

  @override
  String get importCsvContentLabel => 'CSV content';

  @override
  String get importTextContentLabel => 'Structured text';

  @override
  String get importCsvHint => 'front,back,note';

  @override
  String get importTextHint =>
      'Front: ...\nBack: ...\nNote: ...\nOr one card per line: term / definition';

  @override
  String get importSeparatorLabel => 'Separator';

  @override
  String get importSeparatorAuto => 'Auto';

  @override
  String get importSeparatorTab => 'Tab';

  @override
  String get importSeparatorColon => 'Colon';

  @override
  String get importSeparatorSlash => 'Slash';

  @override
  String get importSeparatorSemicolon => 'Semicolon';

  @override
  String get importSeparatorPipe => 'Pipe';

  @override
  String get importSeparatorAutoDescription =>
      'Detects clear line separators before preview.';

  @override
  String get importSeparatorTabDescription => 'term<Tab>definition';

  @override
  String get importSeparatorColonDescription => 'term: definition';

  @override
  String get importSeparatorSlashDescription => 'term / definition';

  @override
  String get importSeparatorSemicolonDescription => 'term; definition';

  @override
  String get importSeparatorPipeDescription => 'term | definition';

  @override
  String get importDuplicateHandlingTitle => 'Duplicate handling';

  @override
  String get importDuplicatePolicySkipExact => 'Skip exact duplicates';

  @override
  String get importDuplicatePolicySkipExactDescription =>
      'Same front with a different back will still be imported.';

  @override
  String get importDuplicatePolicyImportAnyway => 'Import anyway';

  @override
  String get importDuplicatePolicyImportAnywayDescription =>
      'Future option: create every valid row, even when front and back match an existing card.';

  @override
  String get importDuplicatePolicyUpdateExisting => 'Update existing cards';

  @override
  String get importDuplicatePolicyUpdateExistingDescription =>
      'Future option: update matched cards instead of creating new duplicates.';

  @override
  String get importPreviewAction => 'Preview';

  @override
  String importSuccessMessage(int count) {
    return 'Imported $count flashcards.';
  }

  @override
  String importLoadedFileMessage(Object fileName) {
    return 'Loaded $fileName.';
  }

  @override
  String get importFileUnavailableMessage =>
      'This file cannot be read. Choose another CSV or text file.';

  @override
  String get importValidationIssuesTitle => 'Validation issues';

  @override
  String get importValidationIssuesSubtitle =>
      'Fix every issue before importing.';

  @override
  String importValidationIssueLine(int line) {
    return 'Line $line';
  }

  @override
  String get importPreviewTitle => 'Preview';

  @override
  String importPreviewSubtitle(int count) {
    return '$count flashcards ready to create';
  }

  @override
  String importPreviewSummary(int valid, int invalid) {
    return '$valid valid · $invalid issues';
  }

  @override
  String importPreviewSummaryWithSkipped(int valid, int invalid, int skipped) {
    return '$valid valid · $invalid issues · $skipped skipped';
  }

  @override
  String get importSkippedDuplicatesTitle => 'Skipped duplicates';

  @override
  String importSkippedDuplicatesSubtitle(int count) {
    return '$count exact duplicates will be skipped.';
  }

  @override
  String get importSkippedDuplicateInFile => 'Exact duplicate in this file';

  @override
  String get importSkippedDuplicateInDeck => 'Exact duplicate in this deck';

  @override
  String get importNothingTitle => 'Nothing to import';

  @override
  String get importNothingMessage =>
      'No valid rows or blocks were produced from the source.';

  @override
  String get sharedErrorTitle => 'Something went wrong';

  @override
  String get sharedTryAgain => 'Try again';

  @override
  String get sharedShowDetails => 'Show details';

  @override
  String get sharedHideDetails => 'Hide details';

  @override
  String get sharedFullscreenTooltip => 'Fullscreen';

  @override
  String get sharedStreakLabel => 'Streak';

  @override
  String get sharedOfflineTitle => 'You\'re offline';

  @override
  String get sharedOfflineMessage =>
      'Check your internet connection and try again. Your local flashcards still work.';
}
