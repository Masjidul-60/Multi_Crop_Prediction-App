import 'package:cropdoc_app/data/models/history_scan.dart';
import 'package:cropdoc_app/data/models/prediction_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HistoryScan Model & Serialization Tests', () {
    test('Serializes to JSON and deserializes correctly', () {
      final now = DateTime.now();
      const response = PredictionResponse(
        requestId: 'req_scan_1',
        crop: CropConfidence(name: 'rice', confidence: 0.95),
        predictions: [
          SinglePrediction(
            label: 'rice/blast',
            crop: 'rice',
            disease: 'blast',
            confidence: 0.92,
          ),
        ],
        status: PredictionStatus.confident,
        reasons: [],
        modelVersion: 'v1.2.0',
        inferenceMs: 140,
      );

      final scan = HistoryScan(
        id: 'scan_101',
        timestamp: now,
        imagePath: '/data/user/0/thumbnails/thumb_1.jpg',
        crop: 'rice',
        disease: 'blast',
        status: PredictionStatus.confident,
        confidence: 0.92,
        predictionResponse: response,
      );

      final json = scan.toJson();
      final fromJson = HistoryScan.fromJson(json);

      expect(fromJson.id, equals('scan_101'));
      expect(fromJson.crop, equals('rice'));
      expect(fromJson.disease, equals('blast'));
      expect(fromJson.status, equals(PredictionStatus.confident));
      expect(fromJson.confidence, equals(0.92));
      expect(fromJson.isReportedWrong, isFalse);
      expect(fromJson.userFeedbackComment, isNull);
    });

    test('copyWith updates report wrong and feedback comment', () {
      const response = PredictionResponse(
        requestId: 'req_scan_2',
        crop: CropConfidence(name: 'wheat', confidence: 0.88),
        predictions: [],
        status: PredictionStatus.uncertain,
        reasons: ['maha'],
        modelVersion: 'v1.2.0',
        inferenceMs: 130,
      );

      final scan = HistoryScan(
        id: 'scan_102',
        timestamp: DateTime.now(),
        imagePath: '/data/thumb_2.jpg',
        crop: 'wheat',
        disease: 'yellow_rust',
        status: PredictionStatus.uncertain,
        confidence: 0.88,
        predictionResponse: response,
      );

      final updated = scan.copyWith(
        isReportedWrong: true,
        userFeedbackComment: 'Possible stem rust instead',
      );

      expect(updated.isReportedWrong, isTrue);
      expect(updated.userFeedbackComment, equals('Possible stem rust instead'));
    });
  });
}
