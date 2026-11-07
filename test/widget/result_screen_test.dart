import 'package:cropdoc_app/core/providers/app_state_providers.dart';
import 'package:cropdoc_app/core/theme/app_theme.dart';
import 'package:cropdoc_app/data/models/crop_disease_info.dart';
import 'package:cropdoc_app/data/models/prediction_response.dart';
import 'package:cropdoc_app/data/repositories/disease_knowledge_repository.dart';
import 'package:cropdoc_app/features/result/presentation/result_screen.dart';
import 'package:cropdoc_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDiseaseKnowledgeRepository extends DiseaseKnowledgeRepository {
  @override
  Future<CropDiseaseInfo> getInfo(String key) async {
    return const CropDiseaseInfo(
      key: 'rice/blast',
      crop: 'rice',
      disease: 'blast',
      cropNameBn: 'ধান',
      cropNameEn: 'Rice',
      diseaseNameBn: 'ব্লাস্ট রোগ',
      diseaseNameEn: 'Blast Disease',
      descriptionBn: 'পাতায় মাকু আকৃতির দাগ সৃষ্টি হয়।',
      descriptionEn: 'Produces spindle-shaped lesions on leaves.',
      symptomsBn: ['পাতায় চোখা দাগ'],
      symptomsEn: ['Diamond lesions on leaves'],
      whatToDoBn: ['জমি পরিষ্কার রাখুন', 'TODO: verify with an agronomist'],
      whatToDoEn: ['Maintain field hygiene', 'TODO: verify with an agronomist'],
    );
  }
}

class FakeLocaleNotifier extends LocaleNotifier {
  FakeLocaleNotifier(Locale initial) {
    state = initial;
  }
}

Widget createTestableWidget({
  required Widget child,
  required Locale locale,
}) {
  return ProviderScope(
    overrides: [
      diseaseKnowledgeRepositoryProvider.overrideWithValue(FakeDiseaseKnowledgeRepository()),
      localeProvider.overrideWith((ref) => FakeLocaleNotifier(locale)),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme(locale),
      home: child,
    ),
  );
}

void main() {
  const confidentResponse = PredictionResponse(
    requestId: 'req_conf_test',
    crop: CropConfidence(name: 'rice', confidence: 0.98),
    predictions: [
      SinglePrediction(
        label: 'rice/blast',
        crop: 'rice',
        disease: 'blast',
        confidence: 0.91,
      ),
    ],
    status: PredictionStatus.confident,
    reasons: [],
    modelVersion: 'v1.2.0-test',
    inferenceMs: 140,
  );

  const uncertainResponse = PredictionResponse(
    requestId: 'req_unc_test',
    crop: CropConfidence(name: 'potato', confidence: 0.65),
    predictions: [
      SinglePrediction(
        label: 'potato/early_blight',
        crop: 'potato',
        disease: 'early_blight',
        confidence: 0.48,
      ),
      SinglePrediction(
        label: 'potato/late_blight',
        crop: 'potato',
        disease: 'late_blight',
        confidence: 0.42,
      ),
    ],
    status: PredictionStatus.uncertain,
    reasons: ['energy'],
    modelVersion: 'v1.2.0-test',
    inferenceMs: 120,
  );

  const unknownResponse = PredictionResponse(
    requestId: 'req_unk_test',
    crop: CropConfidence(name: 'unknown', confidence: 0.15),
    predictions: [],
    status: PredictionStatus.unknown,
    reasons: ['energy', 'maha'],
    modelVersion: 'v1.2.0-test',
    inferenceMs: 90,
  );

  group('ResultScreen Widget Tests - Confident State', () {
    testWidgets('Renders confident state in English', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          locale: const Locale('en'),
          child: const ResultScreen(response: confidentResponse),
        ),
      );
      await tester.pumpAndSettle();

      // Confident status badge
      expect(find.text('Confirmed Match'), findsOneWidget);
      // Fixed Extension Officer Notice
      expect(
        find.text('Confirm with a local agricultural extension officer before spraying anything.'),
        findsOneWidget,
      );
      // AI disclaimer
      expect(
        find.text('AI estimate, not an official agricultural diagnosis.'),
        findsOneWidget,
      );
      // Model version
      expect(find.textContaining('v1.2.0-test'), findsOneWidget);
    });

    testWidgets('Renders confident state in Bangla', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          locale: const Locale('bn'),
          child: const ResultScreen(response: confidentResponse),
        ),
      );
      await tester.pumpAndSettle();

      // Confident status badge in Bengali
      expect(find.text('শনাক্তকৃত রোগ'), findsOneWidget);
      // Fixed Extension Officer Notice in Bengali
      expect(
        find.text('কীটনাশক বা কোনো ওষুধ স্প্রে করার আগে অবশ্যই স্থানীয় কৃষি সম্প্রসারণ কর্মকর্তার সাথে নিশ্চিত হন।'),
        findsOneWidget,
      );
      // AI disclaimer in Bengali
      expect(
        find.text('এটি এআই-ভিত্তিক আনুমানিক ধারণা, কোনো চূড়ান্ত কৃষি সিদ্ধান্ত নয়।'),
        findsOneWidget,
      );
      // Model version
      expect(find.textContaining('v1.2.0-test'), findsOneWidget);
    });
  });

  group('ResultScreen Widget Tests - Uncertain State', () {
    testWidgets('Renders uncertain state in English', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          locale: const Locale('en'),
          child: const ResultScreen(response: uncertainResponse),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Potential Match - Low Confidence'), findsOneWidget);
      expect(find.text('Tips for a Clearer Photo'), findsOneWidget);
    });

    testWidgets('Renders uncertain state in Bangla', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          locale: const Locale('bn'),
          child: const ResultScreen(response: uncertainResponse),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('সম্ভাব্য ফলাফল - নিশ্চিত নয়'), findsOneWidget);
      expect(find.text('পুনরায় ছবি তোলার পরামর্শ'), findsOneWidget);
    });
  });

  group('ResultScreen Widget Tests - Unknown State', () {
    testWidgets('Renders unknown state in English', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          locale: const Locale('en'),
          child: const ResultScreen(response: unknownResponse),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('This leaf is not recognised'), findsOneWidget);
      expect(find.text('Recommendations'), findsOneWidget);
    });

    testWidgets('Renders unknown state in Bangla', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          locale: const Locale('bn'),
          child: const ResultScreen(response: unknownResponse),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('এই পাতাটি চেনা যায়নি'), findsOneWidget);
      expect(find.text('পরামর্শ ও সহায়তা'), findsOneWidget);
    });
  });
}
