import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('bn'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'CropDoc'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navGuide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get navGuide;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Identify Crop Diseases Fast'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Photograph any crop leaf to detect diseases early, safeguard crops, and avoid yield loss.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Take Clear Leaf Photos'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Capture a single leaf in bright natural light. Fill the frame and avoid casting dark shadows.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Important Advisory Notice'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'AI estimates can be wrong. Always confirm with an agricultural expert before spraying or taking critical steps.'**
  String get onboardingDesc3;

  /// No description provided for @btnSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get btnSkip;

  /// No description provided for @btnNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNext;

  /// No description provided for @btnGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get btnGetStarted;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, Farmer'**
  String get homeGreeting;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your crop\'s health today'**
  String get homeSubtitle;

  /// No description provided for @btnScanLeaf.
  ///
  /// In en, this message translates to:
  /// **'Scan a Leaf'**
  String get btnScanLeaf;

  /// No description provided for @btnChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get btnChooseGallery;

  /// No description provided for @supportedCropsTitle.
  ///
  /// In en, this message translates to:
  /// **'Supported Crops'**
  String get supportedCropsTitle;

  /// No description provided for @recentScansTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Scans'**
  String get recentScansTitle;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @tipCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Photography Tip'**
  String get tipCardTitle;

  /// No description provided for @tipCardContent.
  ///
  /// In en, this message translates to:
  /// **'Focus on a single leaf with good daylight. Wipe dirty lenses and avoid blurry movement.'**
  String get tipCardContent;

  /// No description provided for @noRecentScans.
  ///
  /// In en, this message translates to:
  /// **'No recent scans yet. Tap \'Scan a Leaf\' to begin.'**
  String get noRecentScans;

  /// No description provided for @captureInstruction.
  ///
  /// In en, this message translates to:
  /// **'Align leaf inside the guideline'**
  String get captureInstruction;

  /// No description provided for @captureLiveTip.
  ///
  /// In en, this message translates to:
  /// **'One leaf • Fill frame • Bright light • No shadows'**
  String get captureLiveTip;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @analyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze Leaf'**
  String get analyze;

  /// No description provided for @flashOn.
  ///
  /// In en, this message translates to:
  /// **'Flash On'**
  String get flashOn;

  /// No description provided for @flashOff.
  ///
  /// In en, this message translates to:
  /// **'Flash Off'**
  String get flashOff;

  /// No description provided for @rotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get rotate;

  /// No description provided for @qualityWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Quality Advisory'**
  String get qualityWarningTitle;

  /// No description provided for @blurWarningMsg.
  ///
  /// In en, this message translates to:
  /// **'The photo appears blurry or out of focus. A clear shot ensures accurate diagnosis.'**
  String get blurWarningMsg;

  /// No description provided for @darkWarningMsg.
  ///
  /// In en, this message translates to:
  /// **'The photo is too dark. Good natural lighting gives the best recognition results.'**
  String get darkWarningMsg;

  /// No description provided for @continueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue Anyway'**
  String get continueAnyway;

  /// No description provided for @analyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Leaf...'**
  String get analyzingTitle;

  /// No description provided for @analyzingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Examining leaf texture, spots, and color patterns...'**
  String get analyzingSubtitle;

  /// No description provided for @analyzingTimeout.
  ///
  /// In en, this message translates to:
  /// **'Analysis timed out (20s). Please check your internet connection and try again.'**
  String get analyzingTimeout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @statusConfident.
  ///
  /// In en, this message translates to:
  /// **'Confirmed Match'**
  String get statusConfident;

  /// No description provided for @statusUncertain.
  ///
  /// In en, this message translates to:
  /// **'Not Sure'**
  String get statusUncertain;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Leaf Not Recognised'**
  String get statusUnknown;

  /// No description provided for @uncertainBanner.
  ///
  /// In en, this message translates to:
  /// **'Potential Match - Low Confidence'**
  String get uncertainBanner;

  /// No description provided for @uncertainSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The AI model detected possible diseases but confidence is low. Compare options below or retake the photo.'**
  String get uncertainSubtitle;

  /// No description provided for @unknownBanner.
  ///
  /// In en, this message translates to:
  /// **'This leaf is not recognised'**
  String get unknownBanner;

  /// No description provided for @unknownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The system could not identify this as a known crop disease. Please take another photo in clear daylight or consult an officer.'**
  String get unknownSubtitle;

  /// No description provided for @cropLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get cropLabel;

  /// No description provided for @diseaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Disease'**
  String get diseaseLabel;

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidenceLabel;

  /// No description provided for @topPredictionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Predictions'**
  String get topPredictionsTitle;

  /// No description provided for @symptomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Symptoms & Indicators'**
  String get symptomsTitle;

  /// No description provided for @whatToDoTitle.
  ///
  /// In en, this message translates to:
  /// **'What To Do Next'**
  String get whatToDoTitle;

  /// No description provided for @extensionOfficerNotice.
  ///
  /// In en, this message translates to:
  /// **'Confirm with a local agricultural extension officer before spraying anything.'**
  String get extensionOfficerNotice;

  /// No description provided for @aiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI estimate, not an official agricultural diagnosis.'**
  String get aiDisclaimer;

  /// No description provided for @modelVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Model Version'**
  String get modelVersionLabel;

  /// No description provided for @inferenceTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Inference Time'**
  String get inferenceTimeLabel;

  /// No description provided for @btnShare.
  ///
  /// In en, this message translates to:
  /// **'Share Diagnosis'**
  String get btnShare;

  /// No description provided for @btnSaveHistory.
  ///
  /// In en, this message translates to:
  /// **'Save to History'**
  String get btnSaveHistory;

  /// No description provided for @savedToHistoryToast.
  ///
  /// In en, this message translates to:
  /// **'Scan saved to history'**
  String get savedToHistoryToast;

  /// No description provided for @btnReportWrong.
  ///
  /// In en, this message translates to:
  /// **'Report Wrong Result'**
  String get btnReportWrong;

  /// No description provided for @reportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Incorrect Diagnosis'**
  String get reportDialogTitle;

  /// No description provided for @reportDialogNote.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you believe the correct diagnosis is (optional):'**
  String get reportDialogNote;

  /// No description provided for @btnSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get btnSubmit;

  /// No description provided for @feedbackSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Feedback recorded locally. Thank you for improving CropDoc!'**
  String get feedbackSubmitted;

  /// No description provided for @offlineQueuedNotice.
  ///
  /// In en, this message translates to:
  /// **'Device is offline. This scan is saved locally and queued for analysis.'**
  String get offlineQueuedNotice;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis History'**
  String get historyTitle;

  /// No description provided for @searchScansHint.
  ///
  /// In en, this message translates to:
  /// **'Search crop or disease...'**
  String get searchScansHint;

  /// No description provided for @filterAllCrops.
  ///
  /// In en, this message translates to:
  /// **'All Crops'**
  String get filterAllCrops;

  /// No description provided for @filterAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get filterAllStatuses;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportCsv;

  /// No description provided for @noHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No scans match your search or filter.'**
  String get noHistoryFound;

  /// No description provided for @noHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No diagnosis history yet. Scanned leaves will appear here.'**
  String get noHistoryEmpty;

  /// No description provided for @deleteScan.
  ///
  /// In en, this message translates to:
  /// **'Delete Scan'**
  String get deleteScan;

  /// No description provided for @deleteScanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this diagnosis from history?'**
  String get deleteScanConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop Library'**
  String get guideTitle;

  /// No description provided for @searchGuideHint.
  ///
  /// In en, this message translates to:
  /// **'Search crops or diseases...'**
  String get searchGuideHint;

  /// No description provided for @noDiseasesFound.
  ///
  /// In en, this message translates to:
  /// **'No entries match your search query.'**
  String get noDiseasesFound;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageSub.
  ///
  /// In en, this message translates to:
  /// **'Select app display language'**
  String get languageSub;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'App Appearance'**
  String get themeLabel;

  /// No description provided for @themeSub.
  ///
  /// In en, this message translates to:
  /// **'Light, Dark, or System mode'**
  String get themeSub;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get themeDark;

  /// No description provided for @dataSaverLabel.
  ///
  /// In en, this message translates to:
  /// **'Data Saver Mode'**
  String get dataSaverLabel;

  /// No description provided for @dataSaverSub.
  ///
  /// In en, this message translates to:
  /// **'Compress images to smaller file size for slow mobile data'**
  String get dataSaverSub;

  /// No description provided for @clearHistoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear Scan History'**
  String get clearHistoryLabel;

  /// No description provided for @clearHistorySub.
  ///
  /// In en, this message translates to:
  /// **'Remove all stored scans from this device'**
  String get clearHistorySub;

  /// No description provided for @clearHistorySuccess.
  ///
  /// In en, this message translates to:
  /// **'History cleared successfully'**
  String get clearHistorySuccess;

  /// No description provided for @privacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data Use'**
  String get privacyLabel;

  /// No description provided for @privacyContent.
  ///
  /// In en, this message translates to:
  /// **'Leaf photos are processed strictly for crop identification and disease diagnosis. No personal data is stored.'**
  String get privacyContent;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About CropDoc'**
  String get aboutLabel;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @developerModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Developer Settings'**
  String get developerModeTitle;

  /// No description provided for @devToggleMock.
  ///
  /// In en, this message translates to:
  /// **'Use Mock Prediction Service'**
  String get devToggleMock;

  /// No description provided for @devBaseUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Backend Base URL'**
  String get devBaseUrlLabel;

  /// No description provided for @devSaveUrl.
  ///
  /// In en, this message translates to:
  /// **'Save URL'**
  String get devSaveUrl;

  /// No description provided for @devUrlSaved.
  ///
  /// In en, this message translates to:
  /// **'Base URL updated'**
  String get devUrlSaved;

  /// No description provided for @devTestHealth.
  ///
  /// In en, this message translates to:
  /// **'Test Backend Health'**
  String get devTestHealth;

  /// No description provided for @devHealthSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backend is reachable and healthy!'**
  String get devHealthSuccess;

  /// No description provided for @devHealthFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to backend'**
  String get devHealthFailed;

  /// No description provided for @devUnlockedToast.
  ///
  /// In en, this message translates to:
  /// **'Developer mode unlocked!'**
  String get devUnlockedToast;

  /// No description provided for @permissionCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission Needed'**
  String get permissionCameraTitle;

  /// No description provided for @permissionCameraMsg.
  ///
  /// In en, this message translates to:
  /// **'CropDoc requires camera access to scan leaves and detect diseases.'**
  String get permissionCameraMsg;

  /// No description provided for @permissionGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Library Access Needed'**
  String get permissionGalleryTitle;

  /// No description provided for @permissionGalleryMsg.
  ///
  /// In en, this message translates to:
  /// **'CropDoc requires access to select leaf photos from your library.'**
  String get permissionGalleryMsg;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
