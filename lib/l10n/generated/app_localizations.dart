import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MemoX'**
  String get appName;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get commonSort;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get commonImport;

  /// No description provided for @commonExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get commonExport;

  /// No description provided for @commonMove.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get commonMove;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get commonSelect;

  /// No description provided for @commonSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get commonSelectAll;

  /// No description provided for @commonSaveOrder.
  ///
  /// In en, this message translates to:
  /// **'Save order'**
  String get commonSaveOrder;

  /// No description provided for @commonOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get commonOverview;

  /// No description provided for @commonNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get commonNever;

  /// No description provided for @commonReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get commonReorder;

  /// No description provided for @commonNoValidDestinationFound.
  ///
  /// In en, this message translates to:
  /// **'No valid destination found.'**
  String get commonNoValidDestinationFound;

  /// No description provided for @commonDefaultOrderUpdated.
  ///
  /// In en, this message translates to:
  /// **'Default order updated.'**
  String get commonDefaultOrderUpdated;

  /// No description provided for @commonPercentValue.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String commonPercentValue(int value);

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @sortManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get sortManual;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortLastStudied.
  ///
  /// In en, this message translates to:
  /// **'Last studied'**
  String get sortLastStudied;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appShellHomePlaceholderDescription.
  ///
  /// In en, this message translates to:
  /// **'Home dashboard foundation is not wired yet.'**
  String get appShellHomePlaceholderDescription;

  /// No description provided for @appShellProgressPlaceholderDescription.
  ///
  /// In en, this message translates to:
  /// **'Progress foundation is not wired yet.'**
  String get appShellProgressPlaceholderDescription;

  /// No description provided for @appShellSettingsPlaceholderDescription.
  ///
  /// In en, this message translates to:
  /// **'Settings foundation is not wired yet.'**
  String get appShellSettingsPlaceholderDescription;

  /// No description provided for @dashboardGreetingTitle.
  ///
  /// In en, this message translates to:
  /// **'Hello 👋'**
  String get dashboardGreetingTitle;

  /// No description provided for @dashboardGreetingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to study today?'**
  String get dashboardGreetingSubtitle;

  /// No description provided for @dashboardHeading.
  ///
  /// In en, this message translates to:
  /// **'Today\'s study focus'**
  String get dashboardHeading;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review, study new cards, or continue a session.'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardTodayReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Today Review'**
  String get dashboardTodayReviewTitle;

  /// No description provided for @dashboardOverdueLabel.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get dashboardOverdueLabel;

  /// No description provided for @dashboardReviewReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} cards are ready for SRS review.'**
  String dashboardReviewReadyMessage(int count);

  /// No description provided for @dashboardReviewEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No review cards are due right now.'**
  String get dashboardReviewEmptyMessage;

  /// No description provided for @dashboardReviewNowAction.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get dashboardReviewNowAction;

  /// No description provided for @dashboardNewStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'New Study'**
  String get dashboardNewStudyTitle;

  /// No description provided for @dashboardNewCardsLabel.
  ///
  /// In en, this message translates to:
  /// **'New cards available'**
  String get dashboardNewCardsLabel;

  /// No description provided for @dashboardNewStudyMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} new cards are ready.'**
  String dashboardNewStudyMessage(int count);

  /// No description provided for @dashboardNewStudyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add or import cards before starting a new study session.'**
  String get dashboardNewStudyEmptyMessage;

  /// No description provided for @dashboardStartNewStudyAction.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get dashboardStartNewStudyAction;

  /// No description provided for @dashboardResumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get dashboardResumeTitle;

  /// No description provided for @dashboardActiveSessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Active sessions'**
  String get dashboardActiveSessionsLabel;

  /// No description provided for @dashboardResumeMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions can be continued or finalized.'**
  String dashboardResumeMessage(int count);

  /// No description provided for @dashboardResumeEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No active study session right now.'**
  String get dashboardResumeEmptyMessage;

  /// No description provided for @dashboardContinueSessionAction.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get dashboardContinueSessionAction;

  /// No description provided for @dashboardLibraryHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Library health'**
  String get dashboardLibraryHealthTitle;

  /// No description provided for @dashboardLibraryHealthSummary.
  ///
  /// In en, this message translates to:
  /// **'{folderCount, plural, =0{0 folders} =1{1 folder} other{{folderCount} folders}} · {deckCount, plural, =0{0 decks} =1{1 deck} other{{deckCount} decks}} · {cardCount, plural, =0{0 cards} =1{1 card} other{{cardCount} cards}}'**
  String dashboardLibraryHealthSummary(
    int folderCount,
    int deckCount,
    int cardCount,
  );

  /// No description provided for @dashboardMasteryLabel.
  ///
  /// In en, this message translates to:
  /// **'Mastery'**
  String get dashboardMasteryLabel;

  /// No description provided for @dashboardDueTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dashboardDueTodayTitle;

  /// No description provided for @dashboardDueTodayMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} cards ready to review'**
  String dashboardDueTodayMessage(int count);

  /// No description provided for @dashboardLibrarySummary.
  ///
  /// In en, this message translates to:
  /// **'{folderCount} folders · {cardCount} cards'**
  String dashboardLibrarySummary(int folderCount, int cardCount);

  /// No description provided for @dashboardNoDueTitle.
  ///
  /// In en, this message translates to:
  /// **'No cards due now'**
  String get dashboardNoDueTitle;

  /// No description provided for @dashboardNoDueMessage.
  ///
  /// In en, this message translates to:
  /// **'Open your library to add cards or start a focused deck session.'**
  String get dashboardNoDueMessage;

  /// No description provided for @dashboardStudyTodayAction.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get dashboardStudyTodayAction;

  /// No description provided for @dashboardOpenLibraryAction.
  ///
  /// In en, this message translates to:
  /// **'View library'**
  String get dashboardOpenLibraryAction;

  /// No description provided for @dashboardLibraryProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Library progress'**
  String get dashboardLibraryProgressTitle;

  /// No description provided for @dashboardLibraryProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'{percent}% mastery'**
  String dashboardLibraryProgressMessage(int percent);

  /// No description provided for @dashboardRecentDecksTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent decks'**
  String get dashboardRecentDecksTitle;

  /// No description provided for @dashboardStartDeckTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a deck'**
  String get dashboardStartDeckTitle;

  /// No description provided for @dashboardDeckStats.
  ///
  /// In en, this message translates to:
  /// **'{cardCount, plural, =0{0 cards} =1{1 card} other{{cardCount} cards}}'**
  String dashboardDeckStats(int cardCount);

  /// No description provided for @progressOverviewHeading.
  ///
  /// In en, this message translates to:
  /// **'Learning overview'**
  String get progressOverviewHeading;

  /// No description provided for @progressOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track review pressure, library mastery, and open session recovery.'**
  String get progressOverviewSubtitle;

  /// No description provided for @progressReviewDueCount.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get progressReviewDueCount;

  /// No description provided for @progressActiveSessionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Active sessions'**
  String get progressActiveSessionsHeading;

  /// No description provided for @progressActiveSessionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Resume, finalize, retry, or cancel the study sessions that are still open.'**
  String get progressActiveSessionsSubtitle;

  /// No description provided for @progressActiveSessionsCount.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get progressActiveSessionsCount;

  /// No description provided for @progressReadySessionsCount.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get progressReadySessionsCount;

  /// No description provided for @progressFailedSessionsCount.
  ///
  /// In en, this message translates to:
  /// **'Needs retry'**
  String get progressFailedSessionsCount;

  /// No description provided for @progressEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No active study sessions'**
  String get progressEmptyTitle;

  /// No description provided for @progressEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Start studying from Library. Sessions that are in progress or waiting to finalize will appear here.'**
  String get progressEmptyMessage;

  /// No description provided for @progressSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'{studyType} · {entryType}'**
  String progressSessionTitle(Object studyType, Object entryType);

  /// No description provided for @progressSessionCardProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} study steps · {remaining} remaining'**
  String progressSessionCardProgress(int completed, int total, int remaining);

  /// No description provided for @progressSessionCurrentCard.
  ///
  /// In en, this message translates to:
  /// **'Current card: {card}'**
  String progressSessionCurrentCard(Object card);

  /// No description provided for @progressSessionStartedAt.
  ///
  /// In en, this message translates to:
  /// **'Started {date} at {time}'**
  String progressSessionStartedAt(Object date, Object time);

  /// No description provided for @progressEntryDeck.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get progressEntryDeck;

  /// No description provided for @progressEntryFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get progressEntryFolder;

  /// No description provided for @progressEntryToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get progressEntryToday;

  /// No description provided for @progressSessionStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get progressSessionStatusInProgress;

  /// No description provided for @progressSessionStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to finalize'**
  String get progressSessionStatusReady;

  /// No description provided for @progressSessionStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Finalize failed'**
  String get progressSessionStatusFailed;

  /// No description provided for @progressCancelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this study session?'**
  String get progressCancelConfirmTitle;

  /// No description provided for @progressCancelConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The current session will stop. Completed attempts remain in its history, but pending cards are abandoned.'**
  String get progressCancelConfirmMessage;

  /// No description provided for @progressSessionCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'Session cancelled.'**
  String get progressSessionCancelledMessage;

  /// No description provided for @progressSessionFinalizedMessage.
  ///
  /// In en, this message translates to:
  /// **'Session finalized.'**
  String get progressSessionFinalizedMessage;

  /// No description provided for @progressSessionRetryFinalizeMessage.
  ///
  /// In en, this message translates to:
  /// **'Finalize retried.'**
  String get progressSessionRetryFinalizeMessage;

  /// No description provided for @progressSessionActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Session action failed.'**
  String get progressSessionActionFailed;

  /// No description provided for @settingsAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceTitle;

  /// No description provided for @settingsThemeModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get settingsThemeModeLabel;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLocaleLabel.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsLocaleLabel;

  /// No description provided for @settingsLocaleSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsLocaleSystem;

  /// No description provided for @settingsLocaleEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLocaleEnglish;

  /// No description provided for @settingsLocaleVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get settingsLocaleVietnamese;

  /// No description provided for @settingsStudyDefaultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Study defaults'**
  String get settingsStudyDefaultsTitle;

  /// No description provided for @settingsStudyDefaultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Defaults used when a new study session is created.'**
  String get settingsStudyDefaultsSubtitle;

  /// No description provided for @settingsStudyDefaultsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading study defaults'**
  String get settingsStudyDefaultsLoading;

  /// No description provided for @settingsNewStudyBatchSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'New Study batch size'**
  String get settingsNewStudyBatchSizeLabel;

  /// No description provided for @settingsReviewBatchSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Review batch size'**
  String get settingsReviewBatchSizeLabel;

  /// No description provided for @settingsSpeechTitle.
  ///
  /// In en, this message translates to:
  /// **'Speech'**
  String get settingsSpeechTitle;

  /// No description provided for @settingsSpeechLabel.
  ///
  /// In en, this message translates to:
  /// **'Korean and English pronunciation support'**
  String get settingsSpeechLabel;

  /// No description provided for @settingsSpeechLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading speech settings'**
  String get settingsSpeechLoading;

  /// No description provided for @settingsSpeechAutoPlayLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto-play in study'**
  String get settingsSpeechAutoPlayLabel;

  /// No description provided for @settingsSpeechAutoPlaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically pronounce cards after study transitions.'**
  String get settingsSpeechAutoPlaySubtitle;

  /// No description provided for @settingsSpeechFrontLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Front language'**
  String get settingsSpeechFrontLanguageLabel;

  /// No description provided for @settingsSpeechKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get settingsSpeechKorean;

  /// No description provided for @settingsSpeechEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsSpeechEnglish;

  /// No description provided for @settingsSpeechRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Speech rate'**
  String get settingsSpeechRateLabel;

  /// No description provided for @settingsSpeechRateValue.
  ///
  /// In en, this message translates to:
  /// **'{value}x'**
  String settingsSpeechRateValue(double value);

  /// No description provided for @settingsSpeechFrontVoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Front voice'**
  String get settingsSpeechFrontVoiceLabel;

  /// No description provided for @settingsSpeechSystemVoice.
  ///
  /// In en, this message translates to:
  /// **'System voice'**
  String get settingsSpeechSystemVoice;

  /// No description provided for @settingsSpeechLoadingVoices.
  ///
  /// In en, this message translates to:
  /// **'Loading voices...'**
  String get settingsSpeechLoadingVoices;

  /// No description provided for @settingsSpeechNoVoices.
  ///
  /// In en, this message translates to:
  /// **'No {language} voice was reported by this device.'**
  String settingsSpeechNoVoices(Object language);

  /// No description provided for @settingsSpeechPreviewKorean.
  ///
  /// In en, this message translates to:
  /// **'Preview Korean'**
  String get settingsSpeechPreviewKorean;

  /// No description provided for @settingsSpeechPreviewEnglish.
  ///
  /// In en, this message translates to:
  /// **'Preview English'**
  String get settingsSpeechPreviewEnglish;

  /// No description provided for @settingsSpeechPreviewSelected.
  ///
  /// In en, this message translates to:
  /// **'Preview audio'**
  String get settingsSpeechPreviewSelected;

  /// No description provided for @settingsSpeechVoiceOptions.
  ///
  /// In en, this message translates to:
  /// **'Voice options'**
  String get settingsSpeechVoiceOptions;

  /// No description provided for @settingsSpeechHideVoiceOptions.
  ///
  /// In en, this message translates to:
  /// **'Hide voice options'**
  String get settingsSpeechHideVoiceOptions;

  /// No description provided for @settingsSpeechKoreanPreviewText.
  ///
  /// In en, this message translates to:
  /// **'안녕하세요'**
  String get settingsSpeechKoreanPreviewText;

  /// No description provided for @settingsSpeechEnglishPreviewText.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get settingsSpeechEnglishPreviewText;

  /// No description provided for @settingsSpeechPreviewTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Test text'**
  String get settingsSpeechPreviewTextLabel;

  /// No description provided for @settingsSpeechPreviewTextHelper.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use the default sample.'**
  String get settingsSpeechPreviewTextHelper;

  /// No description provided for @settingsSpeechPreviewTextHint.
  ///
  /// In en, this message translates to:
  /// **'Type or paste any text to test...'**
  String get settingsSpeechPreviewTextHint;

  /// No description provided for @settingsSpeechPreviewClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear test text'**
  String get settingsSpeechPreviewClearTooltip;

  /// No description provided for @settingsUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Settings updated.'**
  String get settingsUpdatedMessage;

  /// No description provided for @appRouterErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation error'**
  String get appRouterErrorTitle;

  /// No description provided for @errorConfiguration.
  ///
  /// In en, this message translates to:
  /// **'The app configuration is invalid.'**
  String get errorConfiguration;

  /// No description provided for @errorRequestTimedOut.
  ///
  /// In en, this message translates to:
  /// **'The request timed out.'**
  String get errorRequestTimedOut;

  /// No description provided for @errorInvalidData.
  ///
  /// In en, this message translates to:
  /// **'The received data is invalid.'**
  String get errorInvalidData;

  /// No description provided for @errorUnsupportedAction.
  ///
  /// In en, this message translates to:
  /// **'This action is not supported right now.'**
  String get errorUnsupportedAction;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'A network problem occurred.'**
  String get errorNetwork;

  /// No description provided for @errorStorage.
  ///
  /// In en, this message translates to:
  /// **'A local storage problem occurred.'**
  String get errorStorage;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested resource could not be found.'**
  String get errorNotFound;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorUnexpected;

  /// No description provided for @foldersNewSubfolderTooltip.
  ///
  /// In en, this message translates to:
  /// **'New subfolder'**
  String get foldersNewSubfolderTooltip;

  /// No description provided for @foldersNewDeckTooltip.
  ///
  /// In en, this message translates to:
  /// **'New deck'**
  String get foldersNewDeckTooltip;

  /// No description provided for @foldersCreateChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want to create?'**
  String get foldersCreateChoiceTitle;

  /// No description provided for @foldersNewSubfolderTitle.
  ///
  /// In en, this message translates to:
  /// **'New subfolder'**
  String get foldersNewSubfolderTitle;

  /// No description provided for @foldersFolderNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get foldersFolderNameLabel;

  /// No description provided for @foldersFolderNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Listening practice'**
  String get foldersFolderNameHint;

  /// No description provided for @foldersMoreActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get foldersMoreActionsTooltip;

  /// No description provided for @foldersActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Folder actions'**
  String get foldersActionsTitle;

  /// No description provided for @foldersReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get foldersReorder;

  /// No description provided for @foldersReorderManualOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Switch sort back to manual to reorder.'**
  String get foldersReorderManualOnlyHint;

  /// No description provided for @foldersStatusSubfolders.
  ///
  /// In en, this message translates to:
  /// **'Contains {subfolderCount} subfolders'**
  String foldersStatusSubfolders(int subfolderCount);

  /// No description provided for @foldersStatusDecks.
  ///
  /// In en, this message translates to:
  /// **'Contains {deckCount} decks · {totalCardCount} cards'**
  String foldersStatusDecks(int deckCount, int totalCardCount);

  /// No description provided for @foldersSegmentSubfolders.
  ///
  /// In en, this message translates to:
  /// **'Subfolders'**
  String get foldersSegmentSubfolders;

  /// No description provided for @foldersSegmentDecks.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get foldersSegmentDecks;

  /// No description provided for @foldersSubfolderDeckHint.
  ///
  /// In en, this message translates to:
  /// **'To add decks here, organize them in a subfolder.'**
  String get foldersSubfolderDeckHint;

  /// No description provided for @foldersDeckStats.
  ///
  /// In en, this message translates to:
  /// **'{cardCount, plural, =0{0 cards} =1{1 card} other{{cardCount} cards}}'**
  String foldersDeckStats(int cardCount);

  /// No description provided for @foldersSubfolderCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Subfolder created.'**
  String get foldersSubfolderCreatedMessage;

  /// No description provided for @foldersRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get foldersRenameTitle;

  /// No description provided for @foldersUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Folder updated.'**
  String get foldersUpdatedMessage;

  /// No description provided for @foldersMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move folder'**
  String get foldersMoveTitle;

  /// No description provided for @foldersMoveRootTitle.
  ///
  /// In en, this message translates to:
  /// **'Library root'**
  String get foldersMoveRootTitle;

  /// No description provided for @foldersMoveRootSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Move this folder to root'**
  String get foldersMoveRootSubtitle;

  /// No description provided for @foldersMovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Folder moved.'**
  String get foldersMovedMessage;

  /// No description provided for @foldersDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete folder'**
  String get foldersDeleteTitle;

  /// No description provided for @foldersDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete the full subtree, including decks and flashcards.'**
  String get foldersDeleteMessage;

  /// No description provided for @foldersDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Folder deleted.'**
  String get foldersDeletedMessage;

  /// No description provided for @foldersManualReorderWarning.
  ///
  /// In en, this message translates to:
  /// **'Manual reorder is only available in manual sort.'**
  String get foldersManualReorderWarning;

  /// No description provided for @foldersSummaryUnlocked.
  ///
  /// In en, this message translates to:
  /// **'This folder is empty and can hold subfolders or decks.'**
  String get foldersSummaryUnlocked;

  /// No description provided for @foldersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'This folder is empty'**
  String get foldersEmptyTitle;

  /// No description provided for @foldersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a direction first. A folder can contain subfolders or decks, not both.'**
  String get foldersEmptyMessage;

  /// No description provided for @foldersEmptySubfoldersTitle.
  ///
  /// In en, this message translates to:
  /// **'No subfolders yet'**
  String get foldersEmptySubfoldersTitle;

  /// No description provided for @foldersEmptySubfoldersMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a subfolder to keep this branch organized.'**
  String get foldersEmptySubfoldersMessage;

  /// No description provided for @foldersEmptyDecksTitle.
  ///
  /// In en, this message translates to:
  /// **'No decks yet'**
  String get foldersEmptyDecksTitle;

  /// No description provided for @foldersEmptyDecksMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a deck to start adding flashcards here.'**
  String get foldersEmptyDecksMessage;

  /// No description provided for @foldersNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching items'**
  String get foldersNoResultsTitle;

  /// No description provided for @foldersNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Clear search or try a different term.'**
  String get foldersNoResultsMessage;

  /// No description provided for @foldersClearSearchAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get foldersClearSearchAction;

  /// No description provided for @libraryCreateFolderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create folder'**
  String get libraryCreateFolderTooltip;

  /// No description provided for @libraryCreateFolderDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Create folder'**
  String get libraryCreateFolderDialogTitle;

  /// No description provided for @libraryFolderCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Folder created.'**
  String get libraryFolderCreatedMessage;

  /// No description provided for @libraryDueTodayPrefix.
  ///
  /// In en, this message translates to:
  /// **'You have '**
  String get libraryDueTodayPrefix;

  /// No description provided for @libraryDueTodaySuffix.
  ///
  /// In en, this message translates to:
  /// **' items due today'**
  String get libraryDueTodaySuffix;

  /// No description provided for @libraryStudyNow.
  ///
  /// In en, this message translates to:
  /// **'Study now  →'**
  String get libraryStudyNow;

  /// No description provided for @libraryFoldersSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get libraryFoldersSectionTitle;

  /// No description provided for @libraryManageFoldersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your folder tree'**
  String get libraryManageFoldersSubtitle;

  /// No description provided for @librarySearchResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get librarySearchResultsSubtitle;

  /// No description provided for @libraryHeroDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today: {count}'**
  String libraryHeroDueToday(int count);

  /// No description provided for @libraryFolderStats.
  ///
  /// In en, this message translates to:
  /// **'{subfolderCount, plural, =0{0 subfolders} =1{1 subfolder} other{{subfolderCount} subfolders}} · {deckCount, plural, =0{0 decks} =1{1 deck} other{{deckCount} decks}} · {cardCount, plural, =0{0 cards} =1{1 card} other{{cardCount} cards}}'**
  String libraryFolderStats(int subfolderCount, int deckCount, int cardCount);

  /// No description provided for @libraryFolderMastery.
  ///
  /// In en, this message translates to:
  /// **'Mastery {percent}%'**
  String libraryFolderMastery(int percent);

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No folders yet'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Create your first folder to start building your library.'**
  String get libraryEmptyMessage;

  /// No description provided for @decksCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create deck'**
  String get decksCreateTitle;

  /// No description provided for @decksNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Deck name'**
  String get decksNameLabel;

  /// No description provided for @decksNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Core vocabulary'**
  String get decksNameHint;

  /// No description provided for @decksCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deck created.'**
  String get decksCreatedMessage;

  /// No description provided for @decksMoreActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get decksMoreActionsTooltip;

  /// No description provided for @decksActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Deck actions'**
  String get decksActionsTitle;

  /// No description provided for @decksDuplicateAction.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get decksDuplicateAction;

  /// No description provided for @decksExportCsvAction.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get decksExportCsvAction;

  /// No description provided for @decksOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{cardCount} cards · {dueToday} due today · {masteryPercent}% mastery'**
  String decksOverviewSubtitle(int cardCount, int dueToday, int masteryPercent);

  /// No description provided for @decksLastStudiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last studied: {date}'**
  String decksLastStudiedLabel(Object date);

  /// No description provided for @decksManageContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage content'**
  String get decksManageContentTitle;

  /// No description provided for @decksManageContentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open flashcards, import into this deck, or continue editing content.'**
  String get decksManageContentSubtitle;

  /// No description provided for @decksEmptyStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add cards before studying'**
  String get decksEmptyStudyTitle;

  /// No description provided for @decksEmptyStudyMessage.
  ///
  /// In en, this message translates to:
  /// **'This deck has no flashcards yet. Add or import cards first.'**
  String get decksEmptyStudyMessage;

  /// No description provided for @decksStudyUnavailableNoCards.
  ///
  /// In en, this message translates to:
  /// **'Study is available after this deck has at least one flashcard.'**
  String get decksStudyUnavailableNoCards;

  /// No description provided for @decksRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename deck'**
  String get decksRenameTitle;

  /// No description provided for @decksUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deck updated.'**
  String get decksUpdatedMessage;

  /// No description provided for @decksMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move deck'**
  String get decksMoveTitle;

  /// No description provided for @decksMovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deck moved.'**
  String get decksMovedMessage;

  /// No description provided for @decksDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate deck'**
  String get decksDuplicateTitle;

  /// No description provided for @decksCurrentFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Current folder'**
  String get decksCurrentFolderTitle;

  /// No description provided for @decksDuplicatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deck duplicated.'**
  String get decksDuplicatedMessage;

  /// No description provided for @decksDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete deck'**
  String get decksDeleteTitle;

  /// No description provided for @decksDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete the entire deck and all flashcards inside it.'**
  String get decksDeleteMessage;

  /// No description provided for @decksDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deck deleted.'**
  String get decksDeletedMessage;

  /// No description provided for @flashcardsOpenListAction.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get flashcardsOpenListAction;

  /// No description provided for @flashcardsAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get flashcardsAddAction;

  /// No description provided for @flashcardsAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add flashcard'**
  String get flashcardsAddTooltip;

  /// No description provided for @flashcardsActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Flashcard actions'**
  String get flashcardsActionsTitle;

  /// No description provided for @flashcardsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search flashcards'**
  String get flashcardsSearchHint;

  /// No description provided for @flashcardsPreviewDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview card'**
  String get flashcardsPreviewDialogTitle;

  /// No description provided for @flashcardsDeckSummary.
  ///
  /// In en, this message translates to:
  /// **'{cardCount, plural, =0{0 cards} =1{1 card} other{{cardCount} cards}} · {masteryPercent}% mastery'**
  String flashcardsDeckSummary(int cardCount, int masteryPercent);

  /// No description provided for @flashcardsStudyModesTitle.
  ///
  /// In en, this message translates to:
  /// **'Study modes'**
  String get flashcardsStudyModesTitle;

  /// No description provided for @flashcardsProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get flashcardsProgressTitle;

  /// No description provided for @flashcardsProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Progress is derived from this deck\'s SRS state.'**
  String get flashcardsProgressSubtitle;

  /// No description provided for @flashcardsProgressNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get flashcardsProgressNew;

  /// No description provided for @flashcardsProgressLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get flashcardsProgressLearning;

  /// No description provided for @flashcardsProgressMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get flashcardsProgressMastered;

  /// No description provided for @flashcardsProgressCountValue.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String flashcardsProgressCountValue(int count);

  /// No description provided for @flashcardsCardsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get flashcardsCardsSectionTitle;

  /// No description provided for @flashcardsLearnDeckAction.
  ///
  /// In en, this message translates to:
  /// **'Study this deck'**
  String get flashcardsLearnDeckAction;

  /// No description provided for @flashcardsBulkSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String flashcardsBulkSelected(int count);

  /// No description provided for @flashcardsBulkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Move, export, or delete the selected flashcards.'**
  String get flashcardsBulkSubtitle;

  /// No description provided for @flashcardsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No flashcards yet'**
  String get flashcardsEmptyTitle;

  /// No description provided for @flashcardsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add cards manually or import them into this deck.'**
  String get flashcardsEmptyMessage;

  /// No description provided for @flashcardsMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move flashcards'**
  String get flashcardsMoveTitle;

  /// No description provided for @flashcardsMoveProgressKeptNote.
  ///
  /// In en, this message translates to:
  /// **'Learning progress will be kept after moving.'**
  String get flashcardsMoveProgressKeptNote;

  /// No description provided for @flashcardsMovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Flashcards moved.'**
  String get flashcardsMovedMessage;

  /// No description provided for @flashcardsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete flashcards'**
  String get flashcardsDeleteTitle;

  /// No description provided for @flashcardsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the selected flashcards.'**
  String get flashcardsDeleteMessage;

  /// No description provided for @flashcardsDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Flashcards deleted.'**
  String get flashcardsDeletedMessage;

  /// No description provided for @flashcardsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit flashcard'**
  String get flashcardsEditTitle;

  /// No description provided for @flashcardsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New flashcard'**
  String get flashcardsNewTitle;

  /// No description provided for @flashcardsFieldFrontLabel.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get flashcardsFieldFrontLabel;

  /// No description provided for @flashcardsFieldFrontHint.
  ///
  /// In en, this message translates to:
  /// **'Prompt or question'**
  String get flashcardsFieldFrontHint;

  /// No description provided for @flashcardsFieldBackLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get flashcardsFieldBackLabel;

  /// No description provided for @flashcardsFieldBackHint.
  ///
  /// In en, this message translates to:
  /// **'Answer or definition'**
  String get flashcardsFieldBackHint;

  /// No description provided for @flashcardsFieldNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get flashcardsFieldNoteLabel;

  /// No description provided for @flashcardsFieldNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Optional extra note'**
  String get flashcardsFieldNoteHint;

  /// No description provided for @flashcardsLongContentHelper.
  ///
  /// In en, this message translates to:
  /// **'Supports multiple lines. Keep the full answer readable during study.'**
  String get flashcardsLongContentHelper;

  /// No description provided for @flashcardsNoteHelper.
  ///
  /// In en, this message translates to:
  /// **'Optional context, examples, or memory hints.'**
  String get flashcardsNoteHelper;

  /// No description provided for @flashcardsSaveAndAddNext.
  ///
  /// In en, this message translates to:
  /// **'Save + next'**
  String get flashcardsSaveAndAddNext;

  /// No description provided for @flashcardsSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Flashcard saved.'**
  String get flashcardsSavedMessage;

  /// No description provided for @flashcardsSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get flashcardsSaveChanges;

  /// No description provided for @flashcardsSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get flashcardsSaveAction;

  /// No description provided for @flashcardsLearningContentChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'You changed the learning content.'**
  String get flashcardsLearningContentChangedTitle;

  /// No description provided for @flashcardsLearningContentChangedMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep existing progress or reset this card?'**
  String get flashcardsLearningContentChangedMessage;

  /// No description provided for @flashcardsKeepProgressAction.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get flashcardsKeepProgressAction;

  /// No description provided for @flashcardsResetProgressAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get flashcardsResetProgressAction;

  /// No description provided for @flashcardsUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Flashcard updated.'**
  String get flashcardsUpdatedMessage;

  /// No description provided for @flashcardsCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Flashcard created.'**
  String get flashcardsCreatedMessage;

  /// No description provided for @studyEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get studyEntryTitle;

  /// No description provided for @studyEntryHeading.
  ///
  /// In en, this message translates to:
  /// **'Start a study session'**
  String get studyEntryHeading;

  /// No description provided for @studyEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a flow and snapshot settings for this session.'**
  String get studyEntrySubtitle;

  /// No description provided for @studyStartAction.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get studyStartAction;

  /// No description provided for @studyStartNewSessionAction.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get studyStartNewSessionAction;

  /// No description provided for @studyStartNewSessionConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new session?'**
  String get studyStartNewSessionConfirmTitle;

  /// No description provided for @studyStartNewSessionConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Starting a new session will cancel the current unfinished session.'**
  String get studyStartNewSessionConfirmMessage;

  /// No description provided for @studyRestartAction.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get studyRestartAction;

  /// No description provided for @studyResumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Session in progress'**
  String get studyResumeTitle;

  /// No description provided for @studyResumeAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get studyResumeAction;

  /// No description provided for @studyContinueSessionAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get studyContinueSessionAction;

  /// No description provided for @studyFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Study flow'**
  String get studyFlowTitle;

  /// No description provided for @studyTypeNew.
  ///
  /// In en, this message translates to:
  /// **'New Study'**
  String get studyTypeNew;

  /// No description provided for @studyTypeReview.
  ///
  /// In en, this message translates to:
  /// **'SRS Review'**
  String get studyTypeReview;

  /// No description provided for @studyTodayReviewOnly.
  ///
  /// In en, this message translates to:
  /// **'Today supports SRS Review due and overdue cards in v1.'**
  String get studyTodayReviewOnly;

  /// No description provided for @studySettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Session settings'**
  String get studySettingsTitle;

  /// No description provided for @studyBatchSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Batch size: {count}'**
  String studyBatchSizeLabel(int count);

  /// No description provided for @studyBatchSizeRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'{min}-{max} cards'**
  String studyBatchSizeRangeLabel(int min, int max);

  /// No description provided for @studyDecreaseBatch.
  ///
  /// In en, this message translates to:
  /// **'Decrease batch size'**
  String get studyDecreaseBatch;

  /// No description provided for @studyIncreaseBatch.
  ///
  /// In en, this message translates to:
  /// **'Increase batch size'**
  String get studyIncreaseBatch;

  /// No description provided for @studyShuffleCards.
  ///
  /// In en, this message translates to:
  /// **'Shuffle flashcards'**
  String get studyShuffleCards;

  /// No description provided for @studyShuffleAnswers.
  ///
  /// In en, this message translates to:
  /// **'Shuffle answers'**
  String get studyShuffleAnswers;

  /// No description provided for @studyPrioritizeOverdue.
  ///
  /// In en, this message translates to:
  /// **'Prioritize overdue cards'**
  String get studyPrioritizeOverdue;

  /// No description provided for @studySessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Study session'**
  String get studySessionTitle;

  /// No description provided for @studyCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get studyCancelAction;

  /// No description provided for @studyFinalizeAction.
  ///
  /// In en, this message translates to:
  /// **'Finalize'**
  String get studyFinalizeAction;

  /// No description provided for @studySkipAction.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get studySkipAction;

  /// No description provided for @studyTextSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Text settings'**
  String get studyTextSettingsTooltip;

  /// No description provided for @studyAudioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get studyAudioTooltip;

  /// No description provided for @studyMoreActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get studyMoreActionsTooltip;

  /// No description provided for @studyEditCardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get studyEditCardTooltip;

  /// No description provided for @studyCardAudioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Play card audio'**
  String get studyCardAudioTooltip;

  /// No description provided for @studyStopAudioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Stop audio'**
  String get studyStopAudioTooltip;

  /// No description provided for @studyReviewTextSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Text settings'**
  String get studyReviewTextSettingsTooltip;

  /// No description provided for @studyReviewAudioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get studyReviewAudioTooltip;

  /// No description provided for @studyReviewMoreActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get studyReviewMoreActionsTooltip;

  /// No description provided for @studyReviewEditCardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get studyReviewEditCardTooltip;

  /// No description provided for @studyReviewCardAudioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Play card audio'**
  String get studyReviewCardAudioTooltip;

  /// No description provided for @studyReviewProgressPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String studyReviewProgressPercent(int percent);

  /// No description provided for @studySessionEnded.
  ///
  /// In en, this message translates to:
  /// **'This session has ended.'**
  String get studySessionEnded;

  /// No description provided for @studyViewResultAction.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get studyViewResultAction;

  /// No description provided for @studyProgressModeRound.
  ///
  /// In en, this message translates to:
  /// **'{mode} · round {round}'**
  String studyProgressModeRound(Object mode, int round);

  /// No description provided for @studyResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Study result'**
  String get studyResultTitle;

  /// No description provided for @studyResultHeading.
  ///
  /// In en, this message translates to:
  /// **'Session summary'**
  String get studyResultHeading;

  /// No description provided for @studyResultCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get studyResultCards;

  /// No description provided for @studyResultAttempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get studyResultAttempts;

  /// No description provided for @studyResultCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get studyResultCorrect;

  /// No description provided for @studyResultIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get studyResultIncorrect;

  /// No description provided for @studyResultBoxUp.
  ///
  /// In en, this message translates to:
  /// **'Box increased'**
  String get studyResultBoxUp;

  /// No description provided for @studyResultBoxDown.
  ///
  /// In en, this message translates to:
  /// **'Box decreased'**
  String get studyResultBoxDown;

  /// No description provided for @studyResultRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get studyResultRemaining;

  /// No description provided for @studyResultAccuracyLabel.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get studyResultAccuracyLabel;

  /// No description provided for @studyResultAttemptAccuracyLabel.
  ///
  /// In en, this message translates to:
  /// **'Attempt accuracy'**
  String get studyResultAttemptAccuracyLabel;

  /// No description provided for @studyResultRetryCardsLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry cards'**
  String get studyResultRetryCardsLabel;

  /// No description provided for @studyResultCardsMastered.
  ///
  /// In en, this message translates to:
  /// **'Cards mastered: {mastered}/{total}'**
  String studyResultCardsMastered(int mastered, int total);

  /// No description provided for @studyResultCardsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} cards completed'**
  String studyResultCardsCompleted(int completed, int total);

  /// No description provided for @studyResultReviewMoreAction.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get studyResultReviewMoreAction;

  /// No description provided for @studyResultStudyAgainAction.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get studyResultStudyAgainAction;

  /// No description provided for @studyRetryFinalizeAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get studyRetryFinalizeAction;

  /// No description provided for @studyResultCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get studyResultCompleted;

  /// No description provided for @studyResultCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get studyResultCancelled;

  /// No description provided for @studyResultFailedFinalize.
  ///
  /// In en, this message translates to:
  /// **'Finalize failed. Retry when ready.'**
  String get studyResultFailedFinalize;

  /// No description provided for @studyResultReadyFinalize.
  ///
  /// In en, this message translates to:
  /// **'Ready to finalize'**
  String get studyResultReadyFinalize;

  /// No description provided for @studyResultInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get studyResultInProgress;

  /// No description provided for @studyResultDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get studyResultDraft;

  /// No description provided for @studyModeReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get studyModeReview;

  /// No description provided for @studyModeMatch.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get studyModeMatch;

  /// No description provided for @studyModeGuess.
  ///
  /// In en, this message translates to:
  /// **'Guess'**
  String get studyModeGuess;

  /// No description provided for @studyModeRecall.
  ///
  /// In en, this message translates to:
  /// **'Recall'**
  String get studyModeRecall;

  /// No description provided for @studyModeFill.
  ///
  /// In en, this message translates to:
  /// **'Fill'**
  String get studyModeFill;

  /// No description provided for @studyReadyToFinalizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to finalize'**
  String get studyReadyToFinalizeTitle;

  /// No description provided for @studyReadyToFinalizeMessage.
  ///
  /// In en, this message translates to:
  /// **'All required items are passed. Finalize to commit SRS progress.'**
  String get studyReadyToFinalizeMessage;

  /// No description provided for @studyChooseMatchingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Choose the matching answer.'**
  String get studyChooseMatchingAnswer;

  /// No description provided for @studyTypeMatchingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Type the matching answer.'**
  String get studyTypeMatchingAnswer;

  /// No description provided for @studyAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get studyAnswerLabel;

  /// No description provided for @studySubmitAnswer.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get studySubmitAnswer;

  /// No description provided for @studyHelpAction.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get studyHelpAction;

  /// No description provided for @studyCheckAnswerAction.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get studyCheckAnswerAction;

  /// No description provided for @studyFillNoAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'No answer entered'**
  String get studyFillNoAnswerLabel;

  /// No description provided for @studyCorrectAction.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get studyCorrectAction;

  /// No description provided for @studyIncorrectAction.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get studyIncorrectAction;

  /// No description provided for @studyRememberedAction.
  ///
  /// In en, this message translates to:
  /// **'Remembered'**
  String get studyRememberedAction;

  /// No description provided for @studyForgotAction.
  ///
  /// In en, this message translates to:
  /// **'Forgot'**
  String get studyForgotAction;

  /// No description provided for @studyShowAnswerAction.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get studyShowAnswerAction;

  /// No description provided for @studyShowAnswerCountdownAction.
  ///
  /// In en, this message translates to:
  /// **'Show ({seconds}s)'**
  String studyShowAnswerCountdownAction(int seconds);

  /// No description provided for @studyNextAction.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get studyNextAction;

  /// No description provided for @studyAnswerCorrectTitle.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get studyAnswerCorrectTitle;

  /// No description provided for @studyAnswerIncorrectTitle.
  ///
  /// In en, this message translates to:
  /// **'Not quite'**
  String get studyAnswerIncorrectTitle;

  /// No description provided for @studyCorrectAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String studyCorrectAnswerLabel(Object answer);

  /// No description provided for @studyYourAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Your answer: {answer}'**
  String studyYourAnswerLabel(Object answer);

  /// No description provided for @studyMarkCorrectAction.
  ///
  /// In en, this message translates to:
  /// **'Mark correct'**
  String get studyMarkCorrectAction;

  /// No description provided for @studyContinueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get studyContinueAction;

  /// No description provided for @studyEmptyAnswerMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter an answer before submitting.'**
  String get studyEmptyAnswerMessage;

  /// No description provided for @studyCancelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this session?'**
  String get studyCancelConfirmTitle;

  /// No description provided for @studyCancelConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Your current study session will stop and you will be taken to the result screen.'**
  String get studyCancelConfirmMessage;

  /// No description provided for @studyCancelConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get studyCancelConfirmAction;

  /// No description provided for @flashcardsImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import flashcards'**
  String get flashcardsImportTitle;

  /// No description provided for @importSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get importSourceTitle;

  /// No description provided for @importSourceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import is preview-first and atomic. Any invalid line blocks the entire write.'**
  String get importSourceSubtitle;

  /// No description provided for @importCsvLabel.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get importCsvLabel;

  /// No description provided for @importTextFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'Text format'**
  String get importTextFormatLabel;

  /// No description provided for @importLoadFile.
  ///
  /// In en, this message translates to:
  /// **'Load file'**
  String get importLoadFile;

  /// No description provided for @importCsvContentLabel.
  ///
  /// In en, this message translates to:
  /// **'CSV content'**
  String get importCsvContentLabel;

  /// No description provided for @importTextContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Structured text'**
  String get importTextContentLabel;

  /// No description provided for @importCsvHint.
  ///
  /// In en, this message translates to:
  /// **'front,back,note'**
  String get importCsvHint;

  /// No description provided for @importTextHint.
  ///
  /// In en, this message translates to:
  /// **'Front: ...\nBack: ...\nNote: ...\nOr one card per line: term / definition'**
  String get importTextHint;

  /// No description provided for @importSeparatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Separator'**
  String get importSeparatorLabel;

  /// No description provided for @importSeparatorAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get importSeparatorAuto;

  /// No description provided for @importSeparatorTab.
  ///
  /// In en, this message translates to:
  /// **'Tab'**
  String get importSeparatorTab;

  /// No description provided for @importSeparatorColon.
  ///
  /// In en, this message translates to:
  /// **'Colon'**
  String get importSeparatorColon;

  /// No description provided for @importSeparatorSlash.
  ///
  /// In en, this message translates to:
  /// **'Slash'**
  String get importSeparatorSlash;

  /// No description provided for @importSeparatorSemicolon.
  ///
  /// In en, this message translates to:
  /// **'Semicolon'**
  String get importSeparatorSemicolon;

  /// No description provided for @importSeparatorPipe.
  ///
  /// In en, this message translates to:
  /// **'Pipe'**
  String get importSeparatorPipe;

  /// No description provided for @importSeparatorAutoDescription.
  ///
  /// In en, this message translates to:
  /// **'Detects clear line separators before preview.'**
  String get importSeparatorAutoDescription;

  /// No description provided for @importSeparatorTabDescription.
  ///
  /// In en, this message translates to:
  /// **'term<Tab>definition'**
  String get importSeparatorTabDescription;

  /// No description provided for @importSeparatorColonDescription.
  ///
  /// In en, this message translates to:
  /// **'term: definition'**
  String get importSeparatorColonDescription;

  /// No description provided for @importSeparatorSlashDescription.
  ///
  /// In en, this message translates to:
  /// **'term / definition'**
  String get importSeparatorSlashDescription;

  /// No description provided for @importSeparatorSemicolonDescription.
  ///
  /// In en, this message translates to:
  /// **'term; definition'**
  String get importSeparatorSemicolonDescription;

  /// No description provided for @importSeparatorPipeDescription.
  ///
  /// In en, this message translates to:
  /// **'term | definition'**
  String get importSeparatorPipeDescription;

  /// No description provided for @importDuplicateHandlingTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate handling'**
  String get importDuplicateHandlingTitle;

  /// No description provided for @importDuplicatePolicySkipExact.
  ///
  /// In en, this message translates to:
  /// **'Skip exact duplicates'**
  String get importDuplicatePolicySkipExact;

  /// No description provided for @importDuplicatePolicySkipExactDescription.
  ///
  /// In en, this message translates to:
  /// **'Same front with a different back will still be imported.'**
  String get importDuplicatePolicySkipExactDescription;

  /// No description provided for @importDuplicatePolicyImportAnyway.
  ///
  /// In en, this message translates to:
  /// **'Import anyway'**
  String get importDuplicatePolicyImportAnyway;

  /// No description provided for @importDuplicatePolicyImportAnywayDescription.
  ///
  /// In en, this message translates to:
  /// **'Future option: create every valid row, even when front and back match an existing card.'**
  String get importDuplicatePolicyImportAnywayDescription;

  /// No description provided for @importDuplicatePolicyUpdateExisting.
  ///
  /// In en, this message translates to:
  /// **'Update existing cards'**
  String get importDuplicatePolicyUpdateExisting;

  /// No description provided for @importDuplicatePolicyUpdateExistingDescription.
  ///
  /// In en, this message translates to:
  /// **'Future option: update matched cards instead of creating new duplicates.'**
  String get importDuplicatePolicyUpdateExistingDescription;

  /// No description provided for @importPreviewAction.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get importPreviewAction;

  /// No description provided for @importSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} flashcards.'**
  String importSuccessMessage(int count);

  /// No description provided for @importLoadedFileMessage.
  ///
  /// In en, this message translates to:
  /// **'Loaded {fileName}.'**
  String importLoadedFileMessage(Object fileName);

  /// No description provided for @importFileUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'This file cannot be read. Choose another CSV or text file.'**
  String get importFileUnavailableMessage;

  /// No description provided for @importValidationIssuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Validation issues'**
  String get importValidationIssuesTitle;

  /// No description provided for @importValidationIssuesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fix every issue before importing.'**
  String get importValidationIssuesSubtitle;

  /// No description provided for @importValidationIssueLine.
  ///
  /// In en, this message translates to:
  /// **'Line {line}'**
  String importValidationIssueLine(int line);

  /// No description provided for @importPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get importPreviewTitle;

  /// No description provided for @importPreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} flashcards ready to create'**
  String importPreviewSubtitle(int count);

  /// No description provided for @importPreviewSummary.
  ///
  /// In en, this message translates to:
  /// **'{valid} valid · {invalid} issues'**
  String importPreviewSummary(int valid, int invalid);

  /// No description provided for @importPreviewSummaryWithSkipped.
  ///
  /// In en, this message translates to:
  /// **'{valid} valid · {invalid} issues · {skipped} skipped'**
  String importPreviewSummaryWithSkipped(int valid, int invalid, int skipped);

  /// No description provided for @importSkippedDuplicatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Skipped duplicates'**
  String get importSkippedDuplicatesTitle;

  /// No description provided for @importSkippedDuplicatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} exact duplicates will be skipped.'**
  String importSkippedDuplicatesSubtitle(int count);

  /// No description provided for @importSkippedDuplicateInFile.
  ///
  /// In en, this message translates to:
  /// **'Exact duplicate in this file'**
  String get importSkippedDuplicateInFile;

  /// No description provided for @importSkippedDuplicateInDeck.
  ///
  /// In en, this message translates to:
  /// **'Exact duplicate in this deck'**
  String get importSkippedDuplicateInDeck;

  /// No description provided for @importNothingTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to import'**
  String get importNothingTitle;

  /// No description provided for @importNothingMessage.
  ///
  /// In en, this message translates to:
  /// **'No valid rows or blocks were produced from the source.'**
  String get importNothingMessage;

  /// No description provided for @sharedErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get sharedErrorTitle;

  /// No description provided for @sharedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get sharedTryAgain;

  /// No description provided for @sharedShowDetails.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get sharedShowDetails;

  /// No description provided for @sharedHideDetails.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get sharedHideDetails;

  /// No description provided for @sharedFullscreenTooltip.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get sharedFullscreenTooltip;

  /// No description provided for @sharedStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get sharedStreakLabel;

  /// No description provided for @sharedOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get sharedOfflineTitle;

  /// No description provided for @sharedOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again. Your local flashcards still work.'**
  String get sharedOfflineMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
