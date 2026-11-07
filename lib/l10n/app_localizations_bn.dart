// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'ক্রপডক';

  @override
  String get navHome => 'হোম';

  @override
  String get navHistory => 'ইতিহাস';

  @override
  String get navGuide => 'নির্দেশিকা';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get onboardingTitle1 => 'ফসলের রোগ দ্রুত শনাক্ত করুন';

  @override
  String get onboardingDesc1 =>
      'যেকোনো ফসলের পাতার ছবি তুলে রোগ সহজে শনাক্ত করুন, ফলন সুরক্ষা নিশ্চিত করুন।';

  @override
  String get onboardingTitle2 => 'সঠিকভাবে পাতার ছবি তুলুন';

  @override
  String get onboardingDesc2 =>
      'উজ্জ্বল প্রাকৃতিক আলোয় একটি পাতার স্পষ্ট ছবি ফ্রেমের ভেতরে রাখুন এবং ছায়া এড়ান।';

  @override
  String get onboardingTitle3 => 'জরুরি কৃষি পরামর্শ সতর্কতা';

  @override
  String get onboardingDesc3 =>
      'কৃত্রিম বুদ্ধিমত্তার ফলাফল আনুমানিক হতে পারে। কোনো কীটনাশক স্প্রে করার আগে অবশ্যই কৃষি কর্মকর্তার পরামর্শ নিন।';

  @override
  String get btnSkip => 'এড়িয়ে যান';

  @override
  String get btnNext => 'পরবর্তী';

  @override
  String get btnGetStarted => 'শুরু করুন';

  @override
  String get homeGreeting => 'নমস্কার / আসসালামু আলাইকুম';

  @override
  String get homeSubtitle => 'আপনার ফসলের স্বাস্থ্য আজই যাচাই করুন';

  @override
  String get btnScanLeaf => 'পাতার ছবি তুলুন';

  @override
  String get btnChooseGallery => 'গ্যালারি থেকে নিন';

  @override
  String get supportedCropsTitle => 'সমর্থিত ফসলসমূহ';

  @override
  String get recentScansTitle => 'সাম্প্রতিক স্ক্যান';

  @override
  String get viewAll => 'সব দেখুন';

  @override
  String get tipCardTitle => 'ছবি তোলার পরামর্শ';

  @override
  String get tipCardContent =>
      'দিনের উজ্জ্বল আলোয় ক্যামেরার লেন্স পরিষ্কার রেখে একটি পাতার সম্পূর্ণ ছবি তুলুন।';

  @override
  String get noRecentScans =>
      'এখনো কোনো স্ক্যান করা হয়নি। শুরু করতে \'পাতার ছবি তুলুন\' চাপুন।';

  @override
  String get captureInstruction => 'পাতাকে নির্দেশক রেখার ভেতরে রাখুন';

  @override
  String get captureLiveTip =>
      'একটি পাতা • ফ্রেম পূর্ণ করুন • পর্যাপ্ত আলো • ছায়া এড়ান';

  @override
  String get retake => 'পুনরায় তুলুন';

  @override
  String get analyze => 'রোগ পরীক্ষা করুন';

  @override
  String get flashOn => 'ফ্ল্যাশ অন';

  @override
  String get flashOff => 'ফ্ল্যাশ অফ';

  @override
  String get rotate => 'ঘোরান';

  @override
  String get qualityWarningTitle => 'ছবির মান সংক্রান্ত সতর্কতা';

  @override
  String get blurWarningMsg =>
      'ছবিটি ঝাপসা দেখাচ্ছে। নির্ভুল ফলাফলের জন্য স্পষ্ট ছবি তোলার পরামর্শ দেওয়া হচ্ছে।';

  @override
  String get darkWarningMsg =>
      'ছবিটি বেশ অন্ধকার। পর্যাপ্ত প্রাকৃতিক আলোতে ছবি তুললে ভালো ফলাফল পাওয়া যাবে।';

  @override
  String get continueAnyway => 'এভাবেই পরীক্ষা করুন';

  @override
  String get analyzingTitle => 'পাতা পরীক্ষা করা হচ্ছে...';

  @override
  String get analyzingSubtitle =>
      'পাতার রঙ, দাগ ও গঠন এআই মডেলের মাধ্যমে বিশ্লেষণ করা হচ্ছে...';

  @override
  String get analyzingTimeout =>
      'সময় অতিক্রান্ত হয়েছে (২০ সেকেন্ড)। ইন্টারনেট সংযোগ পরীক্ষা করে পুনরায় চেষ্টা করুন।';

  @override
  String get cancel => 'বাতিল';

  @override
  String get retry => 'পুনরায় চেষ্টা করুন';

  @override
  String get statusConfident => 'শনাক্তকৃত রোগ';

  @override
  String get statusUncertain => 'নিশ্চিত নয়';

  @override
  String get statusUnknown => 'পাতাটি চেনা যায়নি';

  @override
  String get uncertainBanner => 'সম্ভাব্য ফলাফল - নিশ্চিত নয়';

  @override
  String get uncertainSubtitle =>
      'এআই মডেল কিছু রোগ চিহ্নিত করলেও পুরোপুরি নিশ্চিত হতে পারেনি। নিচের বিকল্পগুলো দেখুন বা পুনরায় ছবি তুলুন।';

  @override
  String get unknownBanner => 'এই পাতাটি চেনা যায়নি';

  @override
  String get unknownSubtitle =>
      'সিস্টেম এই পাতাটিকে পরিচিত কোনো ফসলের রোগ হিসেবে চিহ্নিত করতে পারেনি। পরিষ্কার আলোতে পুনরায় তুলুন বা কৃষি কর্মকর্তার কাছে যান।';

  @override
  String get cropLabel => 'ফসল';

  @override
  String get diseaseLabel => 'রোগ / অবস্থা';

  @override
  String get confidenceLabel => 'নিশ্চয়তা';

  @override
  String get topPredictionsTitle => 'সম্ভাব্য শীর্ষ ফলাফল';

  @override
  String get symptomsTitle => 'লক্ষণ ও উপসর্গ';

  @override
  String get whatToDoTitle => 'পরবর্তী করণীয়';

  @override
  String get extensionOfficerNotice =>
      'কীটনাশক বা কোনো ওষুধ স্প্রে করার আগে অবশ্যই স্থানীয় কৃষি সম্প্রসারণ কর্মকর্তার সাথে নিশ্চিত হন।';

  @override
  String get aiDisclaimer =>
      'এটি এআই-ভিত্তিক আনুমানিক ধারণা, কোনো চূড়ান্ত কৃষি সিদ্ধান্ত নয়।';

  @override
  String get modelVersionLabel => 'মডেল সংস্করণ';

  @override
  String get inferenceTimeLabel => 'বিশ্লেষণের সময়';

  @override
  String get btnShare => 'ফলাফল শেয়ার করুন';

  @override
  String get btnSaveHistory => 'সংরক্ষণ করুন';

  @override
  String get savedToHistoryToast => 'ইতিহাসে সংরক্ষিত হয়েছে';

  @override
  String get btnReportWrong => 'ভুল ফলাফল জানান';

  @override
  String get reportDialogTitle => 'ভুল ফলাফল রিপোর্ট করুন';

  @override
  String get reportDialogNote =>
      'আপনার মতে সঠিক রোগ কী হতে পারে তা লিখুন (ঐচ্ছিক):';

  @override
  String get btnSubmit => 'জমা দিন';

  @override
  String get feedbackSubmitted =>
      'মতামত সংরক্ষিত হয়েছে। ক্রপডক উন্নত করতে সহায়তার জন্য ধন্যবাদ!';

  @override
  String get offlineQueuedNotice =>
      'ইন্টারনেট নেই। ছবিটি সংরক্ষিত হয়েছে এবং ইন্টারনেট পেলে স্বয়ংক্রিয়ভাবে পরীক্ষা করা হবে।';

  @override
  String get historyTitle => 'স্ক্যান ইতিহাস';

  @override
  String get searchScansHint => 'ফসল বা রোগ খুঁজুন...';

  @override
  String get filterAllCrops => 'সব ফসল';

  @override
  String get filterAllStatuses => 'সব অবস্থা';

  @override
  String get exportCsv => 'CSV ফাইল এক্সপোর্ট';

  @override
  String get noHistoryFound => 'কোনো ফলাফল পাওয়া যায়নি।';

  @override
  String get noHistoryEmpty =>
      'এখনো কোনো রোগ পরীক্ষা করা হয়নি। স্ক্যান করা পাতা এখানে সংরক্ষিত থাকবে।';

  @override
  String get deleteScan => 'মুছে ফেলুন';

  @override
  String get deleteScanConfirm => 'এই ফলাফলটি ইতিহাস থেকে মুছে ফেলতে চান?';

  @override
  String get delete => 'মুছুন';

  @override
  String get guideTitle => 'ফসল নির্দেশিকা';

  @override
  String get searchGuideHint => 'ফসল বা রোগ অনুসন্ধান...';

  @override
  String get noDiseasesFound => 'কোনো তথ্য খুঁজে পাওয়া যায়নি।';

  @override
  String get viewDetails => 'বিস্তারিত দেখুন';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get languageLabel => 'ভাষা (Language)';

  @override
  String get languageSub => 'অ্যাপের ভাষা পরিবর্তন করুন';

  @override
  String get themeLabel => 'থিম নির্বাচন';

  @override
  String get themeSub => 'লাইট, ডার্ক বা সিস্টেম থিম';

  @override
  String get themeSystem => 'সিস্টেম অনুযায়ী';

  @override
  String get themeLight => 'লাইট থিম';

  @override
  String get themeDark => 'ডার্ক থিম';

  @override
  String get dataSaverLabel => 'ডাটা সেভার মোড';

  @override
  String get dataSaverSub =>
      'ধীরগতির ইন্টারনেটে দ্রুত আপলোডের জন্য ছবির সাইজ সংকুচিত করুন';

  @override
  String get clearHistoryLabel => 'সব ইতিহাস মুছুন';

  @override
  String get clearHistorySub =>
      'এই ডিভাইস থেকে সংরক্ষিত সব স্ক্যান তথ্য মুছে ফেলুন';

  @override
  String get clearHistorySuccess => 'সব ইতিহাস সফলভাবে মুছে ফেলা হয়েছে';

  @override
  String get privacyLabel => 'গোপনীয়তা নীতি';

  @override
  String get privacyContent =>
      'পাতার ছবি কেবলমাত্র রোগ শনাক্তকরণ ও এআই উন্নয়নের কাজে ব্যবহৃত হয়। কোনো ব্যক্তিগত তথ্য সংরক্ষণ করা হয় না।';

  @override
  String get aboutLabel => 'ক্রপডক পরিচিতি';

  @override
  String get versionLabel => 'সংস্করণ';

  @override
  String get developerModeTitle => 'ডেভেলপার সেটিংস';

  @override
  String get devToggleMock => 'মক (Mock) সার্ভিস ব্যবহার করুন';

  @override
  String get devBaseUrlLabel => 'ব্যাকএন্ড বেস URL';

  @override
  String get devSaveUrl => 'URL সংরক্ষণ করুন';

  @override
  String get devUrlSaved => 'বেস URL আপডেট হয়েছে';

  @override
  String get devTestHealth => 'সার্ভার সংযোগ যাচাই';

  @override
  String get devHealthSuccess => 'ব্যাকএন্ড সার্ভার সচল ও স্বাস্থ্যকর!';

  @override
  String get devHealthFailed => 'সার্ভারে সংযোগ করা সম্ভব হয়নি';

  @override
  String get devUnlockedToast => 'ডেভেলপার মোড চালু হয়েছে!';

  @override
  String get permissionCameraTitle => 'ক্যামেরার অনুমতি প্রয়োজন';

  @override
  String get permissionCameraMsg =>
      'পাতার ছবি তুলে রোগ নির্ণয়ের জন্য ক্রপডক-এ ক্যামেরা ব্যবহারের অনুমতি প্রয়োজন।';

  @override
  String get permissionGalleryTitle => 'গ্যালারির অনুমতি প্রয়োজন';

  @override
  String get permissionGalleryMsg =>
      'গ্যালারি থেকে পাতার ছবি বেছে নিতে ফটো লাইব্রেরির অনুমতি প্রয়োজন।';

  @override
  String get openSettings => 'সেটিংস খুলুন';
}
