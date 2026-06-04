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
  String get commonClose => 'Close';

  @override
  String get bottomSheetDragHandleLabel => 'Dismiss bottom sheet';

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
  String get dashboardTodayLabel => 'Today';

  @override
  String get dashboardGreetingTitle => 'Good evening, learner';

  @override
  String get dashboardGreetingSubtitle => 'Ready to study today?';

  @override
  String get dashboardHeading => 'Today\'s study focus';

  @override
  String get dashboardSubtitle =>
      'Review, study new cards, or continue a session.';

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
      'No review cards are due. Open your library to add cards.';

  @override
  String dashboardReviewCompactStatus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count due',
      one: '1 due',
      zero: '0 due',
    );
    return '$_temp0';
  }

  @override
  String get dashboardReviewNowAction => 'Review';

  @override
  String get dashboardDueNowLabel => 'Due now';

  @override
  String dashboardDueNowSummary(int cardCount, int deckCount) {
    String _temp0 = intl.Intl.pluralLogic(
      cardCount,
      locale: localeName,
      other: '$cardCount cards',
      one: '1 card',
    );
    String _temp1 = intl.Intl.pluralLogic(
      deckCount,
      locale: localeName,
      other: '$deckCount decks',
      one: '1 deck',
    );
    return '$_temp0 across $_temp1';
  }

  @override
  String dashboardReviewTimeEstimate(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return 'About $_temp0';
  }

  @override
  String get dashboardStartReviewAction => 'Start review';

  @override
  String get dashboardAllCaughtUpTitle => 'All caught up';

  @override
  String get dashboardNewStudyTitle => 'New Study';

  @override
  String get dashboardNewCardsLabel => 'New cards available';

  @override
  String dashboardNewStudyMessage(int count) {
    return '$count new cards are ready.';
  }

  @override
  String get dashboardNewStudyEmptyMessage =>
      'Add or import cards before starting a new study session.';

  @override
  String dashboardNewStudyCompactStatus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new',
      one: '1 new',
      zero: '0 new',
    );
    return '$_temp0';
  }

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
      'No active session. Start studying to resume later.';

  @override
  String dashboardResumeCompactStatus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active',
      one: '1 active',
      zero: '0 active',
    );
    return '$_temp0';
  }

  @override
  String get dashboardContinueSessionAction => 'Resume';

  @override
  String get dashboardResumeSectionTitle => 'Continue studying';

  @override
  String get dashboardDiscardAction => 'Discard';

  @override
  String dashboardMorePausedSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count more paused sessions',
      one: '+ 1 more paused session',
    );
    return '$_temp0';
  }

  @override
  String dashboardPausedSessionsSheetTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paused sessions',
      one: '1 paused session',
    );
    return '$_temp0';
  }

  @override
  String get dashboardDiscardSessionTitle => 'Discard this session?';

  @override
  String get dashboardDiscardSessionMessage =>
      'Your progress on answered cards is kept, but the remaining cards in this session will be abandoned.';

  @override
  String get dashboardSessionDiscardedMessage => 'Session discarded.';

  @override
  String get dashboardSessionDiscardFailedMessage =>
      'Couldn\'t discard the session. Try again.';

  @override
  String get dashboardStartNewLearningAction => 'Start new learning';

  @override
  String get dashboardScopePickerTitle => 'What do you want to study?';

  @override
  String get dashboardScopeToday => 'Today';

  @override
  String dashboardScopeTodaySubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards due now',
      one: '1 card due now',
      zero: 'No cards due now',
    );
    return '$_temp0';
  }

  @override
  String get dashboardScopeDeck => 'Deck';

  @override
  String get dashboardScopeDeckSubtitle => 'Pick a deck to study';

  @override
  String get dashboardScopeFolder => 'Folder';

  @override
  String get dashboardScopeFolderSubtitle => 'Pick a folder to study';

  @override
  String get dashboardScopeDeckPickerTitle => 'Pick a deck';

  @override
  String get dashboardScopeFolderPickerTitle => 'Pick a folder';

  @override
  String get dashboardScopeDeckSearchHint => 'Search decks';

  @override
  String get dashboardScopeFolderSearchHint => 'Search folders';

  @override
  String get dashboardScopeDeckEmpty => 'No decks yet. Create a deck first.';

  @override
  String get dashboardScopeFolderEmpty => 'No folders yet.';

  @override
  String get dashboardLibraryHealthTitle => 'Library health';

  @override
  String dashboardLibraryHealthSummary(
    int folderCount,
    int deckCount,
    int cardCount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      folderCount,
      locale: localeName,
      other: '$folderCount folders',
      one: '1 folder',
      zero: '0 folders',
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
  String get dashboardMasteryLabel => 'Mastery';

  @override
  String dashboardStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String dashboardMasteredCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

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
  String get dashboardOpenLibraryAction => 'View library';

  @override
  String get dashboardLibraryProgressTitle => 'Library progress';

  @override
  String dashboardLibraryProgressMessage(int percent) {
    return '$percent% mastery';
  }

  @override
  String get dashboardRecentDecksTitle => 'Recent decks';

  @override
  String get dashboardPickUpTitle => 'Pick up where you left off';

  @override
  String get dashboardStartDeckTitle => 'Start a deck';

  @override
  String dashboardDeckStats(int cardCount) {
    String _temp0 = intl.Intl.pluralLogic(
      cardCount,
      locale: localeName,
      other: '$cardCount cards',
      one: '1 card',
      zero: '0 cards',
    );
    return '$_temp0';
  }

  @override
  String dashboardDeckDueSummary(int dueCount, int cardCount) {
    String _temp0 = intl.Intl.pluralLogic(
      dueCount,
      locale: localeName,
      other: '$dueCount due',
      one: '1 due',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cardCount,
      locale: localeName,
      other: '$cardCount cards',
      one: '1 card',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String dashboardDeckCaughtUpSummary(int cardCount) {
    String _temp0 = intl.Intl.pluralLogic(
      cardCount,
      locale: localeName,
      other: '$cardCount cards',
      one: '1 card',
    );
    return 'All caught up · $_temp0';
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
  String get settingsPersonalizationTitle => 'Personalization';

  @override
  String get settingsStudySectionTitle => 'Study';

  @override
  String get settingsAppSectionTitle => 'App';

  @override
  String get settingsAboutSectionTitle => 'About';

  @override
  String get settingsOverviewFooter => 'Made for calm learning · MemoX';

  @override
  String get settingsAccountTitle => 'Account';

  @override
  String get settingsAccountLoading => 'Loading account';

  @override
  String get settingsAccountLinkedOverviewTitle => 'Account & sync';

  @override
  String get settingsAccountSignInSyncTitle => 'Sign in & sync';

  @override
  String get settingsAccountSignInSyncSubtitle =>
      'Save your progress across devices';

  @override
  String get settingsAccountSigningIn => 'Signing in...';

  @override
  String get settingsAccountSubtitleSignedOut =>
      'Link Google now so Drive sync can be enabled later.';

  @override
  String get settingsAccountSubtitleReady =>
      'Google Drive app data access is ready for future sync.';

  @override
  String get settingsAccountSubtitleReconnect =>
      'Reconnect Drive access before sync can run.';

  @override
  String get settingsAccountSubtitleConfig =>
      'Google sign-in is not configured for this build.';

  @override
  String get settingsAccountSubtitleUnsupported =>
      'Google sign-in is not available on this platform.';

  @override
  String get settingsAccountSubtitleError =>
      'Google account could not be updated.';

  @override
  String get settingsAccountSignedOut => 'No Google account is linked.';

  @override
  String get settingsAccountMissingConfig =>
      'Add Google OAuth client IDs to enable account linking.';

  @override
  String get settingsAccountUnsupported =>
      'Use Android, iOS, or web to link Google account.';

  @override
  String get settingsAccountDriveReady => 'Google Drive ready';

  @override
  String get settingsAccountDriveReconnectRequired =>
      'Google Drive reconnect required';

  @override
  String settingsAccountOverviewSubtitle(Object status, Object email) {
    return '$status\n$email';
  }

  @override
  String settingsAccountOverviewSyncedSubtitle(Object email, Object time) {
    return '$email · synced $time';
  }

  @override
  String settingsAccountOverviewSyncedMockSubtitle(Object email) {
    return '$email · synced 2 min ago';
  }

  @override
  String settingsAccountOverviewSyncErrorSubtitle(Object email) {
    return '$email · last synced 2 days ago';
  }

  @override
  String get settingsOverviewSyncRetry => 'Retry';

  @override
  String get settingsAccountDriveAuthorizationRequired =>
      'Grant Google Drive app data access to prepare sync.';

  @override
  String get settingsAccountSignIn => 'Sign in with Google';

  @override
  String get settingsAccountReconnectDrive => 'Reconnect Google Drive';

  @override
  String get settingsAccountSkipDrive => 'Use without cloud backup';

  @override
  String get settingsAccountSignOut => 'Sign out';

  @override
  String get settingsAccountSignOutConfirmTitle => 'Sign out of Google?';

  @override
  String get settingsAccountSignOutConfirmMessage =>
      'Your Drive backup is kept. Sign in again later to restore it.';

  @override
  String get settingsAccountDisconnect => 'Disconnect Google';

  @override
  String get settingsAccountDisconnectConfirmTitle =>
      'Disconnect Google account?';

  @override
  String get settingsAccountDisconnectConfirmMessage =>
      'This revokes Drive access tokens for this app. The Drive backup itself is kept. Use this on shared or lost devices.';

  @override
  String get settingsAccountDisconnectedMessage =>
      'Google account disconnected. Drive access tokens revoked.';

  @override
  String get settingsAccountSignInCanceled => 'Google sign-in was canceled.';

  @override
  String get settingsAccountSignInFailed => 'Google sign-in failed. Try again.';

  @override
  String settingsAccountLastSignedIn(Object at) {
    return 'Last signed in $at';
  }

  @override
  String get settingsAccountSignedOutMessage =>
      'Signed out. Local flashcards stay on this device.';

  @override
  String get settingsDriveSyncTitle => 'Drive sync';

  @override
  String get settingsDriveSyncLoading => 'Loading sync state';

  @override
  String get settingsDriveSyncSubtitleSignedOut =>
      'Link Google account before syncing.';

  @override
  String get settingsDriveSyncSubtitleUnconfigured =>
      'Google sign-in is not configured for this build.';

  @override
  String get settingsDriveSyncSubtitleReconnect =>
      'Reconnect Drive access before sync can run.';

  @override
  String get settingsDriveSyncSubtitleNoRemote =>
      'Create the first Drive backup from this device.';

  @override
  String get settingsDriveSyncSubtitleSynced =>
      'Local data matches the latest Drive snapshot.';

  @override
  String get settingsDriveSyncSubtitleReady => 'Manual sync is ready.';

  @override
  String get settingsDriveSyncSubtitleConflict =>
      'Choose which copy should win.';

  @override
  String get settingsDriveSyncSubtitleUnsupportedSchema =>
      'Update the app before restoring this Drive copy.';

  @override
  String get settingsDriveSyncSubtitleError => 'Drive sync could not complete.';

  @override
  String get settingsDriveSyncSignedOut =>
      'Sign in with Google to sync the local database with Drive.';

  @override
  String get settingsDriveSyncUnconfigured =>
      'Add Google OAuth client IDs to enable Drive sync.';

  @override
  String get settingsDriveSyncReconnectRequired =>
      'Reconnect Google Drive in Account first.';

  @override
  String get settingsDriveSyncNoRemote => 'No Drive snapshot exists yet.';

  @override
  String get settingsDriveSyncSynced => 'Google Drive is up to date.';

  @override
  String get settingsDriveSyncReady => 'A Drive snapshot is available.';

  @override
  String get settingsDriveSyncConflictStatus =>
      'Local and Drive data both changed.';

  @override
  String get settingsDriveSyncUnsupportedSchema =>
      'The Drive copy was created by a newer database schema.';

  @override
  String settingsDriveSyncLastSynced(Object value) {
    return 'Last synced: $value';
  }

  @override
  String settingsDriveSyncRemoteDevice(Object device) {
    return 'Drive copy from: $device';
  }

  @override
  String get settingsDriveSyncAction => 'Sync now';

  @override
  String get settingsDriveSyncDirectionTitle => 'Choose sync direction';

  @override
  String get settingsDriveSyncDirectionMessage =>
      'Choose which copy is the source of truth for this sync.';

  @override
  String get settingsDriveSyncUploadLocalAction => 'Upload local data to Drive';

  @override
  String get settingsDriveSyncUploadLocalSubtitle =>
      'Use this device as latest and replace the Drive snapshot.';

  @override
  String get settingsDriveSyncRestoreDriveAction =>
      'Download Drive data to this device';

  @override
  String get settingsDriveSyncRestoreDriveSubtitle =>
      'Use the Drive snapshot as latest and replace local data.';

  @override
  String get settingsDriveSyncRestoreUnavailable =>
      'No Drive snapshot is available to download.';

  @override
  String get settingsDriveSyncUploadConfirmTitle => 'Upload local data?';

  @override
  String get settingsDriveSyncUploadConfirmMessage =>
      'This will replace the Google Drive snapshot with this device\'s current database and settings.';

  @override
  String get settingsDriveSyncUploadConfirmAction => 'Upload to Drive';

  @override
  String get settingsDriveSyncRestoreConfirmTitle => 'Restore Drive copy?';

  @override
  String get settingsDriveSyncRestoreConfirmMessage =>
      'Restoring from Drive will replace this device\'s local database and settings with backup data. Recent local changes that were not uploaded may be lost. Upload local data first if you are unsure, and continue only if you trust this Drive backup.';

  @override
  String get settingsDriveSyncRestoreConfirmAction => 'Restore from Drive';

  @override
  String settingsDriveSyncBackupSource(Object device, Object when) {
    return 'Backup from $device • $when';
  }

  @override
  String settingsDriveSyncBackupAppVersion(Object version) {
    return 'App version: $version';
  }

  @override
  String get settingsDriveSyncCrossDeviceTitle =>
      'Overwrite backup from another device?';

  @override
  String get settingsDriveSyncCrossDeviceMessage =>
      'The current Google Drive backup was created by a DIFFERENT device. Uploading from this device will replace it. Make sure that other device does not still hold data you want to keep.';

  @override
  String get settingsDriveSyncCrossDeviceContinue => 'Overwrite anyway';

  @override
  String get settingsDriveSyncRestoreCrossDeviceWarning =>
      'Warning: this backup was created on a different device. Restoring replaces this device\'s local data with that device\'s data.';

  @override
  String get settingsDriveSyncUploadInProgressTitle =>
      'Backing up to Google Drive';

  @override
  String get settingsDriveSyncUploadInProgressMessage =>
      'Please keep the app open. Do not close or switch accounts.';

  @override
  String get settingsDriveSyncRestoreInProgressTitle =>
      'Restoring from Google Drive';

  @override
  String get settingsDriveSyncRestoreInProgressMessage =>
      'Please keep the app open. The app will refresh when restore completes.';

  @override
  String get settingsDriveSyncUploaded =>
      'Local data backed up to Google Drive.';

  @override
  String get settingsDriveSyncRestored => 'Drive copy restored.';

  @override
  String get settingsDriveSyncNoChanges => 'Already up to date.';

  @override
  String get settingsDriveSyncCanceled => 'Sync canceled.';

  @override
  String get settingsDriveSyncFailed => 'Drive sync failed. Try again.';

  @override
  String get settingsDriveSyncConflictTitle => 'Resolve sync conflict';

  @override
  String get settingsDriveSyncConflictMessage =>
      'Local data and the Drive copy both changed since the last sync.';

  @override
  String get settingsDriveSyncKeepLocal => 'Keep local data';

  @override
  String get settingsDriveSyncKeepLocalSubtitle =>
      'Upload this device\'s database and replace the Drive snapshot.';

  @override
  String get settingsDriveSyncUseDrive => 'Use Drive copy';

  @override
  String get settingsDriveSyncUseDriveSubtitle =>
      'Restore the Drive snapshot over this device\'s local database.';

  @override
  String get settingsThemeModeLabel => 'Theme mode';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsAppearanceOverviewSubtitle => 'Light, dark, system';

  @override
  String get settingsSoonChip => 'SOON';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageOverviewSubtitle => 'English';

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
  String get settingsLearningExperienceTitle => 'Learning experience';

  @override
  String get settingsLearningOverviewTitle => 'Learning';

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
  String get settingsLearningOverviewSummary =>
      '20 cards / day · 5 study modes';

  @override
  String settingsCardsCountValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get settingsSrsIntervalsTitle => 'SRS intervals';

  @override
  String get settingsSrsIntervalsSubtitle => 'Current runtime schedule';

  @override
  String settingsSrsIntervalBoxLabel(int box) {
    return 'Box $box';
  }

  @override
  String get settingsSrsIntervalToday => 'Today';

  @override
  String settingsSrsIntervalDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get settingsTagsSectionTitle => 'Tags';

  @override
  String get settingsManageTagsLearningSubtitle => 'Open tag management';

  @override
  String get settingsManageTagsTitle => 'Manage tags';

  @override
  String get settingsManageTagsOverviewSubtitle => '14 tags';

  @override
  String tagHashLabel(String tag) {
    return '#$tag';
  }

  @override
  String get settingsTagsSearchHint => 'Search tags';

  @override
  String settingsTagsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags',
      one: '1 tag',
    );
    return '$_temp0';
  }

  @override
  String settingsTagsCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get settingsTagsSortMostCards => 'Most cards';

  @override
  String get settingsTagsSortNameAsc => 'A → Z';

  @override
  String get settingsTagsSortNameDesc => 'Z → A';

  @override
  String get settingsTagsEmptyTitle => 'No tags yet';

  @override
  String get settingsTagsEmptyMessage =>
      'Tags are added when you create or edit flashcards. Open a card to add your first tag.';

  @override
  String get settingsTagsEmptyAction => 'Go to library';

  @override
  String get settingsTagsSearchEmptyTitle => 'No matching tags';

  @override
  String get settingsTagsSearchEmptyMessage => 'No tags match your search.';

  @override
  String get settingsTagsActionRename => 'Rename';

  @override
  String get settingsTagsActionMerge => 'Merge into another tag';

  @override
  String get settingsTagsActionDelete => 'Delete tag (keeps cards)';

  @override
  String get settingsTagsRenameTitle => 'Rename tag';

  @override
  String get settingsTagsRenameLabel => 'Tag name';

  @override
  String get settingsTagsRenameHint => 'Enter a new name';

  @override
  String get settingsTagsRenameConfirm => 'Rename';

  @override
  String get settingsTagsRenamedMessage => 'Tag renamed.';

  @override
  String settingsTagsMergeSheetTitle(String source) {
    return 'Merge \"$source\" into…';
  }

  @override
  String get settingsTagsMergeSheetEmpty => 'No other tags to merge into.';

  @override
  String get settingsTagsMergeConfirmTitle => 'Merge tags?';

  @override
  String settingsTagsMergeConfirmMessage(String source, String destination) {
    return 'All cards tagged \"$source\" will be re-tagged with \"$destination\". The tag \"$source\" will be deleted.';
  }

  @override
  String get settingsTagsMergeConfirmAction => 'Merge';

  @override
  String get settingsTagsMergedMessage => 'Tags merged.';

  @override
  String get settingsTagsDeleteTitle => 'Delete tag?';

  @override
  String settingsTagsDeleteMessage(String tag, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return 'Delete \"$tag\"? This removes the tag from $_temp0. Cards are not deleted.';
  }

  @override
  String get settingsTagsDeleteConfirm => 'Delete';

  @override
  String get settingsTagsDeletedMessage => 'Tag deleted.';

  @override
  String get flashcardsTagErrorEmpty => 'Tag name is required.';

  @override
  String get flashcardsTagErrorComma => 'Tags cannot contain commas.';

  @override
  String get flashcardsTagErrorTooLong => 'Tag too long (max 50 chars).';

  @override
  String get settingsSpeechTitle => 'Speech';

  @override
  String get settingsAudioSpeechTitle => 'Audio & speech';

  @override
  String get settingsAudioSpeechEnabled => 'On';

  @override
  String get settingsAudioSpeechDisabled => 'Off';

  @override
  String get settingsAudioSpeechOverviewSummary => 'Korean voice · 0.9× speed';

  @override
  String get settingsSpeechLabel => 'Korean and English pronunciation support';

  @override
  String get settingsSpeechLoading => 'Loading speech settings';

  @override
  String get settingsSpeechAutoPlayLabel => 'Auto-play in study';

  @override
  String get settingsSpeechTextToSpeechLabel => 'Text-to-Speech';

  @override
  String get settingsSpeechAutoPlaySubtitle =>
      'Automatically pronounce cards after study transitions.';

  @override
  String get settingsSpeechVoiceSelectionLabel => 'Voice selection';

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
  String get settingsSpeechPitchLabel => 'Voice pitch';

  @override
  String settingsSpeechPitchValue(double value) {
    return '${value}x';
  }

  @override
  String get settingsSpeechVolumeLabel => 'Volume';

  @override
  String settingsSpeechVolumeValue(int value) {
    return '$value%';
  }

  @override
  String get settingsSpeechFrontVoiceLabel => 'Front voice';

  @override
  String get settingsSpeechSystemVoice => 'System voice';

  @override
  String get settingsSpeechStoredVoice => 'Device voice';

  @override
  String settingsSpeechKoreanVoiceLabel(Object index) {
    return 'Korean voice $index';
  }

  @override
  String settingsSpeechEnglishVoiceLabel(Object index) {
    return 'English voice $index';
  }

  @override
  String get settingsSpeechVoiceDeviceSource => 'Device';

  @override
  String get settingsSpeechVoiceOnlineSource => 'Online';

  @override
  String get settingsSpeechVoiceMale => 'Male';

  @override
  String get settingsSpeechVoiceFemale => 'Female';

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
  String get settingsAboutMemoXTitle => 'About MemoX';

  @override
  String settingsAboutVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get settingsAboutVersionUnknown => 'Version unavailable';

  @override
  String get settingsAboutMessage =>
      'MemoX keeps flashcard learning local-first, calm, and ready to back up when you choose.';

  @override
  String get settingsAboutLegalese => 'MemoX';

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
  String get errorFolderContainsDecks =>
      'This folder already contains decks. Create a deck here or choose another folder for subfolders.';

  @override
  String get errorFolderContainsSubfolders =>
      'This folder already contains subfolders. Create a subfolder here or choose another folder for decks.';

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
  String get foldersImportChoiceTitle => 'Import flashcards';

  @override
  String get foldersImportCreateDeckAction => 'Create new deck';

  @override
  String get foldersImportExistingDeckAction => 'Add to existing deck';

  @override
  String get foldersImportChooseDeckTitle => 'Choose deck';

  @override
  String get foldersImportNoDecksHint => 'No decks in this folder yet.';

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
  String foldersDeckStats(int cardCount) {
    String _temp0 = intl.Intl.pluralLogic(
      cardCount,
      locale: localeName,
      other: '$cardCount cards',
      one: '1 card',
      zero: '0 cards',
    );
    return '$_temp0';
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
  String get libraryLoadFailedTitle => 'Couldn\'t load your library';

  @override
  String get libraryLoadFailedMessage =>
      'Your data is safe on this device. Try again in a moment.';

  @override
  String get libraryOverflowTooltip => 'Folder options';

  @override
  String get libraryFiltersTooltip => 'Filters';

  @override
  String get librarySearchHint => 'Search decks, cards, tags';

  @override
  String get libraryNewFolderLabel => 'New folder';

  @override
  String libraryFolderCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count folders',
      one: '1 folder',
    );
    return '$_temp0';
  }

  @override
  String libraryDueSummaryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards due today',
      one: '1 card due today',
    );
    return '$_temp0';
  }

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
  String get decksExportAction => 'Export deck';

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
  String get flashcardsPreviewDialogTitle => 'Preview card';

  @override
  String flashcardsDeckSummary(int cardCount, int masteryPercent) {
    String _temp0 = intl.Intl.pluralLogic(
      cardCount,
      locale: localeName,
      other: '$cardCount cards',
      one: '1 card',
      zero: '0 cards',
    );
    return '$_temp0 · $masteryPercent% mastery';
  }

  @override
  String get flashcardsStudyModesTitle => 'Study modes';

  @override
  String get flashcardsProgressTitle => 'Your progress';

  @override
  String get flashcardsProgressSubtitle =>
      'Progress is derived from this deck\'s SRS state.';

  @override
  String get flashcardsProgressNew => 'New';

  @override
  String get flashcardsProgressLearning => 'Learning';

  @override
  String get flashcardsProgressMastered => 'Mastered';

  @override
  String flashcardsProgressCountValue(int count) {
    return '$count';
  }

  @override
  String get flashcardsCardsSectionTitle => 'Cards';

  @override
  String get flashcardsLearnDeckAction => 'Study this deck';

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
  String get flashcardsNoResultsTitle => 'No matching flashcards';

  @override
  String get flashcardsNoResultsMessage =>
      'No flashcards in this deck match your search.';

  @override
  String get flashcardsClearSearchAction => 'Clear';

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
  String get flashcardsEditTitle => 'Edit card';

  @override
  String get flashcardsNewTitle => 'New card';

  @override
  String get flashcardsFieldFrontLabel => 'Front';

  @override
  String get flashcardsFieldFrontHint => 'Type the term';

  @override
  String get flashcardsFieldBackLabel => 'Back';

  @override
  String get flashcardsFieldBackHint =>
      'English, Vietnamese, or both — comma-separated reads cleanest.';

  @override
  String get flashcardsFieldNoteLabel => 'Note';

  @override
  String get flashcardsFieldNoteHint => 'Optional extra note';

  @override
  String get flashcardsFieldExampleLabel => 'Example sentence';

  @override
  String get flashcardsFieldExampleHint => 'Add a sentence using this term…';

  @override
  String get flashcardsFieldTagsLabel => 'Tags';

  @override
  String get flashcardsFieldTagsHint => 'Add tag';

  @override
  String get flashcardsFieldPronunciationLabel => 'Pronunciation';

  @override
  String get flashcardsFieldPronunciationHint =>
      'Romanization or phonetic spelling';

  @override
  String get flashcardsFieldHintLabel => 'Hint';

  @override
  String get flashcardsFieldHintHint =>
      'A clue that jogs memory without giving the answer.';

  @override
  String get flashcardsFieldStartingStatusLabel => 'Starting status';

  @override
  String get flashcardsStatusNew => 'New';

  @override
  String get flashcardsStatusLearning => 'Learning';

  @override
  String get flashcardsStatusReviewing => 'Reviewing';

  @override
  String get flashcardsRecordPronunciationTooltip => 'Record pronunciation';

  @override
  String get flashcardsListenPronunciationTooltip => 'Listen to pronunciation';

  @override
  String get flashcardsTagsAddAction => 'Add tag';

  @override
  String get flashcardsTagsSheetTitle => 'Add tag';

  @override
  String get flashcardsTagsConfirmAction => 'Add';

  @override
  String get flashcardsOptionalSuffix => 'optional';

  @override
  String flashcardsFieldLabelOptional(String label) {
    return '$label · optional';
  }

  @override
  String get flashcardsShowAdvanced => 'Show advanced fields';

  @override
  String get flashcardsHideAdvanced => 'Hide advanced';

  @override
  String get flashcardsDeckPickerLabel => 'Saving to';

  @override
  String get flashcardsDeckPickerSheetTitle => 'Save card to';

  @override
  String get flashcardsSaveAndAddNextTooltip => 'Save and add another';

  @override
  String get flashcardsLongContentHelper =>
      'Supports multiple lines. Keep the full answer readable during study.';

  @override
  String get flashcardsNoteHelper =>
      'Optional context, examples, or memory hints.';

  @override
  String get flashcardsSaveAndAddNext => 'Save & add another';

  @override
  String get flashcardsSavedMessage => 'Flashcard saved.';

  @override
  String get flashcardsSaveChanges => 'Save changes';

  @override
  String get flashcardsSaveAction => 'Save card';

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
  String get flashcardsDiscardChangesTitle => 'Discard changes?';

  @override
  String get flashcardsDiscardChangesMessage =>
      'Your unsaved flashcard changes will be lost.';

  @override
  String get flashcardsDiscardChangesAction => 'Discard';

  @override
  String get flashcardsKeepEditingAction => 'Keep editing';

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
  String get studyResumeChoiceTitle => 'Resume previous session?';

  @override
  String get studyResumeChoiceMessage =>
      'You have a paused study session for this scope. Resume where you left off, or start over?';

  @override
  String get studyResumeChoiceResumeAction => 'Resume';

  @override
  String get folderResumeMessage =>
      'You have a paused study session for this folder.';

  @override
  String get folderStudyEntryTitle => 'Study this folder';

  @override
  String get folderStudyTodayAction => 'Study due cards';

  @override
  String get folderStudyFolderAction => 'Study folder';

  @override
  String folderStudyDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards due today',
      one: '1 card due today',
    );
    return '$_temp0';
  }

  @override
  String folderStudyCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get folderDetailMasteryOverline => 'Folder mastery';

  @override
  String folderDetailDeckCountAndCards(int deckCount, int cardCount) {
    String _temp0 = intl.Intl.pluralLogic(
      deckCount,
      locale: localeName,
      other: '$deckCount decks',
      one: '1 deck',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cardCount,
      locale: localeName,
      other: '$cardCount cards',
      one: '1 card',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String folderDetailDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count due',
      one: '1 due',
    );
    return '$_temp0';
  }

  @override
  String folderDetailStartStudyDueAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count due',
      one: '1 due',
    );
    return 'Start study · $_temp0';
  }

  @override
  String get folderDetailStartStudyAction => 'Start study';

  @override
  String folderDetailDecksSectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count decks',
      one: '1 deck',
    );
    return '$_temp0';
  }

  @override
  String folderDetailSubfoldersSectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subfolders',
      one: '1 subfolder',
    );
    return '$_temp0';
  }

  @override
  String get deckResumeMessage =>
      'You have a paused study session for this deck.';

  @override
  String get deckStudyEntryTitle => 'Study this deck';

  @override
  String get deckStudyTodayAction => 'Study due cards';

  @override
  String get deckStudyDeckAction => 'Study deck';

  @override
  String deckStudyDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards due today',
      one: '1 card due today',
    );
    return '$_temp0';
  }

  @override
  String deckStudyCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get studyStartOverAction => 'Start over';

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
  String get studyBatchSizeShortLabel => 'Batch size';

  @override
  String studyStartWithCountAction(int count) {
    return 'Start · $count cards';
  }

  @override
  String studyStartNewWithCountAction(int count) {
    return 'Start new · $count cards';
  }

  @override
  String get studySessionTitle => 'Study session';

  @override
  String get studyCancelAction => 'Cancel';

  @override
  String get studyActionFailed => 'Study action failed.';

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
  String get studyResultDoneAction => 'Done';

  @override
  String get studyResultStudyMoreAction => 'Study more';

  @override
  String get studyResultBreakdownTitle => 'Results';

  @override
  String get studyResultPerfect => 'Perfect';

  @override
  String get studyResultPassed => 'Passed';

  @override
  String get studyResultRecovered => 'Recovered';

  @override
  String get studyResultForgot => 'Forgot';

  @override
  String get studyResultBoxChangesTitle => 'Box changes';

  @override
  String get studyResultBoxAdvanced => 'Advanced';

  @override
  String get studyResultBoxStayed => 'Stayed';

  @override
  String get studyResultBoxReset => 'Reset to box 1';

  @override
  String get studyResultBoxReachedMax => 'Reached box 8';

  @override
  String get studyResultFailedFinalizeBanner =>
      'Some data couldn\'t be saved. Please retry.';

  @override
  String get studyResultEmpty => 'No cards answered';

  @override
  String get studyResultCardsToReviewTitle => 'Cards to review';

  @override
  String get studyResultCardsToReviewEmpty => 'No cards need extra review.';

  @override
  String get studyResultRecoveredLabel => 'Recovered';

  @override
  String get studyResultForgotLabel => 'Forgot';

  @override
  String studyResultBoxChangedLabel(int oldBox, int newBox) {
    return 'Box $oldBox → $newBox';
  }

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
  String get studyModeReviewSubtitle => 'Flip cards on SRS schedule';

  @override
  String get studyModeMatchSubtitle => 'Pair fronts & backs';

  @override
  String get studyModeGuessSubtitle => 'Multiple choice A / B / C / D';

  @override
  String get studyModeRecallSubtitle => 'Write from memory';

  @override
  String get studyModeFillSubtitle => 'Complete the blank';

  @override
  String get studyModeMixTitle => 'Mix';

  @override
  String get studyModeMixSubtitle => 'All 5 modes, one session';

  @override
  String get studyModeMixBadge => 'Adaptive';

  @override
  String get studyModeMixSummary => 'Review · Match · Guess · Recall · Fill';

  @override
  String get deckBreakdownTitle => 'Card breakdown';

  @override
  String get deckBreakdownNew => 'New';

  @override
  String get deckBreakdownLearning => 'Learning';

  @override
  String get deckBreakdownReviewing => 'Reviewing';

  @override
  String get deckBreakdownMastered => 'Mastered';

  @override
  String libraryDeckDueSuffix(int dueCount) {
    return '· $dueCount due';
  }

  @override
  String get libraryDeckAllCaughtUp => 'All caught up';

  @override
  String get libraryFilterAll => 'All';

  @override
  String get deckMasteryLabel => 'Mastery';

  @override
  String deckMasteryProgress(int mastered, int total) {
    return '$mastered of $total cards mastered';
  }

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
  String get studyTryAgainAction => 'Try again';

  @override
  String get studyHintAction => 'Hint';

  @override
  String get studyGotItAction => 'Got it';

  @override
  String get studyReviewSwipeHint => 'Swipe or tap Next';

  @override
  String get studyReviewMeaningLabel => 'Meaning';

  @override
  String get studyGuessPromptLabel => 'What is this?';

  @override
  String studyGuessAutoAdvanceLabel(String seconds) {
    return 'Next card in ${seconds}s';
  }

  @override
  String studyMatchBoardStatus(int board, int totalBoards, num pairsLeft) {
    String _temp0 = intl.Intl.pluralLogic(
      pairsLeft,
      locale: localeName,
      other: '$pairsLeft pairs left',
      one: '1 pair left',
    );
    return 'Board $board of $totalBoards · $_temp0';
  }

  @override
  String studyMatchMistakesLabel(num mistakes) {
    String _temp0 = intl.Intl.pluralLogic(
      mistakes,
      locale: localeName,
      other: '$mistakes mistakes',
      one: '1 mistake',
      zero: 'No mistakes',
    );
    return '$_temp0';
  }

  @override
  String studyCounterFormat(int current, int total) {
    return '$current / $total';
  }

  @override
  String get studyContinueAction => 'Continue';

  @override
  String get studyEmptyAnswerMessage => 'Enter an answer before submitting.';

  @override
  String get studyEmpty_deck_noCards_title => 'No flashcards in this deck';

  @override
  String get studyEmpty_deck_noCards_cta => 'Add flashcards';

  @override
  String get studyEmpty_deck_noDueCards_title => 'All caught up';

  @override
  String studyEmpty_deck_noDueCards_subtitle(String relativeTime) {
    return 'Next due $relativeTime.';
  }

  @override
  String get studyEmpty_deck_noDueCards_cta => 'Study new instead';

  @override
  String get studyEmpty_folder_noCards_title => 'No cards in this folder';

  @override
  String get studyEmpty_folder_noCards_cta => 'Add a deck';

  @override
  String get studyEmpty_folder_noDueCards_title =>
      'All caught up for this folder';

  @override
  String studyEmpty_folder_noDueCards_subtitle(String relativeTime) {
    return 'Next due $relativeTime.';
  }

  @override
  String get studyEmpty_folder_noDueCards_cta => 'Study new instead';

  @override
  String get studyEmpty_today_allDone_title => 'All done for today!';

  @override
  String get studyEmpty_today_allDone_message =>
      'Great work. Check back tomorrow for your next review.';

  @override
  String get studyEmpty_today_allDone_cta => 'Back to dashboard';

  @override
  String get studyEmpty_today_noContent_title =>
      'You haven\'t created any flashcards yet';

  @override
  String get studyEmpty_today_noContent_cta => 'Create your first deck';

  @override
  String studyEmptyNextDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return 'in $_temp0';
  }

  @override
  String studyEmptyNextDueInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return 'in $_temp0';
  }

  @override
  String get studyEmptyNextDueSoon => 'soon';

  @override
  String get studyEmpty_allBuried_title => 'All cards buried';

  @override
  String get studyEmpty_allBuried_message =>
      'You buried every card for now. They\'ll return tomorrow.';

  @override
  String get studyEmpty_allBuried_cta => 'Study new instead';

  @override
  String get studyEmpty_allSuspended_title => 'All cards suspended';

  @override
  String get studyEmpty_allSuspended_message =>
      'Resume some cards to study them again.';

  @override
  String get studyEmpty_allSuspended_cta => 'View flashcards';

  @override
  String get cardActionsTitle => 'Card actions';

  @override
  String get cardActionBury => 'Bury until tomorrow';

  @override
  String get cardActionSuspend => 'Suspend card';

  @override
  String get studyCardBuriedMessage => 'Card buried until tomorrow.';

  @override
  String get studyCardSuspendedMessage => 'Card suspended.';

  @override
  String get commonUndo => 'Undo';

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
  String get bulkAddTitle => 'Bulk add';

  @override
  String get bulkAddBreadcrumbLeaf => 'Bulk add';

  @override
  String get bulkAddTabPaste => 'Paste';

  @override
  String get bulkAddTabPreview => 'Preview';

  @override
  String bulkAddTabPreviewWithCount(int count) {
    return 'Preview ($count)';
  }

  @override
  String get bulkAddPasteHint =>
      '연구자\tresearcher\n공부하다\tto study\n도서관\tlibrary';

  @override
  String get bulkAddHelper =>
      'One card per line. Separate the term and meaning with a tab or two spaces. Paste straight from a spreadsheet — it just works.';

  @override
  String bulkAddCardsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards ready',
      one: '1 card ready',
    );
    return '$_temp0';
  }

  @override
  String get bulkAddNoDuplicates => 'No duplicates';

  @override
  String bulkAddDuplicatesSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count duplicates skipped',
      one: '1 duplicate skipped',
    );
    return '$_temp0';
  }

  @override
  String bulkAddIssuesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count issues',
      one: '1 issue',
    );
    return '$_temp0';
  }

  @override
  String bulkAddCommit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count cards',
      one: 'Add 1 card',
    );
    return '$_temp0';
  }

  @override
  String bulkAddFooterSummary(int count, String deckName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards · $deckName',
      one: '1 card · $deckName',
    );
    return '$_temp0';
  }

  @override
  String get bulkAddEmptyPaste => 'Paste your list to see a preview.';

  @override
  String get bulkAddHelpTooltip => 'Format help';

  @override
  String get bulkAddSeparatorLabel => 'SEPARATOR';

  @override
  String get bulkAddSourceTabText => 'Text';

  @override
  String get bulkAddSourceTabFile => 'File';

  @override
  String get bulkAddFileEmptyTitle => 'No file loaded';

  @override
  String get bulkAddFileEmptyDescription =>
      'Choose a CSV (.csv) or Excel (.xlsx) file up to 10 MB. Only the first sheet is read for Excel.';

  @override
  String get bulkAddFileChooseAction => 'Choose file';

  @override
  String get bulkAddFileSizeError =>
      'File exceeds 10 MB. Please choose a smaller file.';

  @override
  String get bulkAddFileFormatHint => 'CSV · XLSX · 10 MB max';

  @override
  String get exportFormatChoiceTitle => 'Export as';

  @override
  String get exportFormatCsvLabel => 'CSV';

  @override
  String get exportFormatCsvDescription =>
      'Plain text · opens in any spreadsheet';

  @override
  String get exportFormatExcelLabel => 'Excel (.xlsx)';

  @override
  String get exportFormatExcelDescription =>
      'Native Excel workbook · single sheet';

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
    return 'cards · $deckName';
  }

  @override
  String get importSourceTitle => 'Import from';

  @override
  String get importSourceSubtitle =>
      'Import is preview-first and atomic. Any invalid line blocks the entire write.';

  @override
  String get importCsvLabel => 'CSV';

  @override
  String get importExcelLabel => 'Excel';

  @override
  String get importTextFormatLabel => 'Text';

  @override
  String get importLoadFile => 'Load file';

  @override
  String get importSelectExcelFile => 'Select Excel file';

  @override
  String get importChangeFile => 'Change';

  @override
  String get importRemoveFile => 'Remove';

  @override
  String get importFileReadyToPreview => 'Ready to preview';

  @override
  String importDetectedRowsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows detected',
      one: '1 row detected',
    );
    return '$_temp0';
  }

  @override
  String get importCsvContentLabel => 'CSV content';

  @override
  String get importExcelFileLabel => 'Excel file';

  @override
  String get importExcelNoFileTitle => 'No Excel file loaded';

  @override
  String get importExcelNoFileDescription =>
      'Load a .xlsx file. Column A is front, column B is back, and column C is optional note.';

  @override
  String get importExcelLoadedFileDescription =>
      'Preview reads the first sheet from A1. Use the header option if row 1 contains labels.';

  @override
  String get importExcelHasHeaderLabel => 'First row is header';

  @override
  String get importExcelHasHeaderDescription => 'Data starts at row 2.';

  @override
  String get importTextContentLabel => 'Structured text';

  @override
  String get importCsvHint => 'front,back,note';

  @override
  String get importTextHint =>
      'Front: ...\nBack: ...\nNote: ...\nOr one card per line: term / definition';

  @override
  String get importCsvRulesText =>
      'Use front, back, and optional note columns.';

  @override
  String get importExcelRulesText =>
      'Column A = front, Column B = back, Column C = note.';

  @override
  String get importTextRulesText =>
      'Use Front:, Back:, and optional Note: lines.';

  @override
  String get importSeparatorLabel => 'Separator';

  @override
  String get importSeparatorAuto => 'Auto';

  @override
  String get importSeparatorTab => 'Tab';

  @override
  String get importSeparatorComma => 'Comma';

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
  String get importSeparatorCommaDescription => 'term, definition';

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
  String get importPreviewAction => 'Preview import';

  @override
  String importCommitCardsAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count cards',
      one: 'Import 1 card',
    );
    return '$_temp0';
  }

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
      'This file cannot be read. Choose another CSV, text, or .xlsx file.';

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
