// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CropDoc';

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'History';

  @override
  String get navGuide => 'Guide';

  @override
  String get navSettings => 'Settings';

  @override
  String get onboardingTitle1 => 'Identify Crop Diseases Fast';

  @override
  String get onboardingDesc1 =>
      'Photograph any crop leaf to detect diseases early, safeguard crops, and avoid yield loss.';

  @override
  String get onboardingTitle2 => 'Take Clear Leaf Photos';

  @override
  String get onboardingDesc2 =>
      'Capture a single leaf in bright natural light. Fill the frame and avoid casting dark shadows.';

  @override
  String get onboardingTitle3 => 'Important Advisory Notice';

  @override
  String get onboardingDesc3 =>
      'AI estimates can be wrong. Always confirm with an agricultural expert before spraying or taking critical steps.';

  @override
  String get btnSkip => 'Skip';

  @override
  String get btnNext => 'Next';

  @override
  String get btnGetStarted => 'Get Started';

  @override
  String get homeGreeting => 'Hello, Farmer';

  @override
  String get homeSubtitle => 'Check your crop\'s health today';

  @override
  String get btnScanLeaf => 'Scan a Leaf';

  @override
  String get btnChooseGallery => 'Choose from Gallery';

  @override
  String get supportedCropsTitle => 'Supported Crops';

  @override
  String get recentScansTitle => 'Recent Scans';

  @override
  String get viewAll => 'View All';

  @override
  String get tipCardTitle => 'Photography Tip';

  @override
  String get tipCardContent =>
      'Focus on a single leaf with good daylight. Wipe dirty lenses and avoid blurry movement.';

  @override
  String get noRecentScans =>
      'No recent scans yet. Tap \'Scan a Leaf\' to begin.';

  @override
  String get captureInstruction => 'Align leaf inside the guideline';

  @override
  String get captureLiveTip =>
      'One leaf • Fill frame • Bright light • No shadows';

  @override
  String get retake => 'Retake';

  @override
  String get analyze => 'Analyze Leaf';

  @override
  String get flashOn => 'Flash On';

  @override
  String get flashOff => 'Flash Off';

  @override
  String get rotate => 'Rotate';

  @override
  String get qualityWarningTitle => 'Photo Quality Advisory';

  @override
  String get blurWarningMsg =>
      'The photo appears blurry or out of focus. A clear shot ensures accurate diagnosis.';

  @override
  String get darkWarningMsg =>
      'The photo is too dark. Good natural lighting gives the best recognition results.';

  @override
  String get continueAnyway => 'Continue Anyway';

  @override
  String get analyzingTitle => 'Analyzing Leaf...';

  @override
  String get analyzingSubtitle =>
      'Examining leaf texture, spots, and color patterns...';

  @override
  String get analyzingTimeout =>
      'Analysis timed out (20s). Please check your internet connection and try again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get statusConfident => 'Confirmed Match';

  @override
  String get statusUncertain => 'Not Sure';

  @override
  String get statusUnknown => 'Leaf Not Recognised';

  @override
  String get uncertainBanner => 'Potential Match - Low Confidence';

  @override
  String get uncertainSubtitle =>
      'The AI model detected possible diseases but confidence is low. Compare options below or retake the photo.';

  @override
  String get unknownBanner => 'This leaf is not recognised';

  @override
  String get unknownSubtitle =>
      'The system could not identify this as a known crop disease. Please take another photo in clear daylight or consult an officer.';

  @override
  String get cropLabel => 'Crop';

  @override
  String get diseaseLabel => 'Disease';

  @override
  String get confidenceLabel => 'Confidence';

  @override
  String get topPredictionsTitle => 'Top Predictions';

  @override
  String get symptomsTitle => 'Symptoms & Indicators';

  @override
  String get whatToDoTitle => 'What To Do Next';

  @override
  String get extensionOfficerNotice =>
      'Confirm with a local agricultural extension officer before spraying anything.';

  @override
  String get aiDisclaimer =>
      'AI estimate, not an official agricultural diagnosis.';

  @override
  String get modelVersionLabel => 'Model Version';

  @override
  String get inferenceTimeLabel => 'Inference Time';

  @override
  String get btnShare => 'Share Diagnosis';

  @override
  String get btnSaveHistory => 'Save to History';

  @override
  String get savedToHistoryToast => 'Scan saved to history';

  @override
  String get btnReportWrong => 'Report Wrong Result';

  @override
  String get reportDialogTitle => 'Report Incorrect Diagnosis';

  @override
  String get reportDialogNote =>
      'Tell us what you believe the correct diagnosis is (optional):';

  @override
  String get btnSubmit => 'Submit';

  @override
  String get feedbackSubmitted =>
      'Feedback recorded locally. Thank you for improving CropDoc!';

  @override
  String get offlineQueuedNotice =>
      'Device is offline. This scan is saved locally and queued for analysis.';

  @override
  String get historyTitle => 'Diagnosis History';

  @override
  String get searchScansHint => 'Search crop or disease...';

  @override
  String get filterAllCrops => 'All Crops';

  @override
  String get filterAllStatuses => 'All Statuses';

  @override
  String get exportCsv => 'Export to CSV';

  @override
  String get noHistoryFound => 'No scans match your search or filter.';

  @override
  String get noHistoryEmpty =>
      'No diagnosis history yet. Scanned leaves will appear here.';

  @override
  String get deleteScan => 'Delete Scan';

  @override
  String get deleteScanConfirm => 'Delete this diagnosis from history?';

  @override
  String get delete => 'Delete';

  @override
  String get guideTitle => 'Crop Library';

  @override
  String get searchGuideHint => 'Search crops or diseases...';

  @override
  String get noDiseasesFound => 'No entries match your search query.';

  @override
  String get viewDetails => 'View Details';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSub => 'Select app display language';

  @override
  String get themeLabel => 'App Appearance';

  @override
  String get themeSub => 'Light, Dark, or System mode';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeLight => 'Light Theme';

  @override
  String get themeDark => 'Dark Theme';

  @override
  String get dataSaverLabel => 'Data Saver Mode';

  @override
  String get dataSaverSub =>
      'Compress images to smaller file size for slow mobile data';

  @override
  String get clearHistoryLabel => 'Clear Scan History';

  @override
  String get clearHistorySub => 'Remove all stored scans from this device';

  @override
  String get clearHistorySuccess => 'History cleared successfully';

  @override
  String get privacyLabel => 'Privacy & Data Use';

  @override
  String get privacyContent =>
      'Leaf photos are processed strictly for crop identification and disease diagnosis. No personal data is stored.';

  @override
  String get aboutLabel => 'About CropDoc';

  @override
  String get versionLabel => 'Version';

  @override
  String get developerModeTitle => 'Developer Settings';

  @override
  String get devToggleMock => 'Use Mock Prediction Service';

  @override
  String get devBaseUrlLabel => 'Backend Base URL';

  @override
  String get devSaveUrl => 'Save URL';

  @override
  String get devUrlSaved => 'Base URL updated';

  @override
  String get devTestHealth => 'Test Backend Health';

  @override
  String get devHealthSuccess => 'Backend is reachable and healthy!';

  @override
  String get devHealthFailed => 'Failed to connect to backend';

  @override
  String get devUnlockedToast => 'Developer mode unlocked!';

  @override
  String get permissionCameraTitle => 'Camera Permission Needed';

  @override
  String get permissionCameraMsg =>
      'CropDoc requires camera access to scan leaves and detect diseases.';

  @override
  String get permissionGalleryTitle => 'Photo Library Access Needed';

  @override
  String get permissionGalleryMsg =>
      'CropDoc requires access to select leaf photos from your library.';

  @override
  String get openSettings => 'Open Settings';
}
