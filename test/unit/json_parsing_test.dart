import 'package:cropdoc_app/data/models/crop_disease_info.dart';
import 'package:cropdoc_app/data/models/prediction_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PredictionResponse JSON Parsing Tests', () {
    test('Parses confident response correctly', () {
      final json = {
        'request_id': 'req_12345',
        'crop': {'name': 'rice', 'confidence': 0.98},
        'predictions': [
          {'label': 'rice/blast', 'crop': 'rice', 'disease': 'blast', 'confidence': 0.91},
          {'label': 'rice/brown_spot', 'crop': 'rice', 'disease': 'brown_spot', 'confidence': 0.06},
          {'label': 'rice/bacterial_leaf_blight', 'crop': 'rice', 'disease': 'bacterial_leaf_blight', 'confidence': 0.02},
        ],
        'status': 'confident',
        'reasons': ['energy'],
        'model_version': 'v1.2.0',
        'inference_ms': 142,
      };

      final response = PredictionResponse.fromJson(json);

      expect(response.requestId, equals('req_12345'));
      expect(response.crop.name, equals('rice'));
      expect(response.crop.confidence, equals(0.98));
      expect(response.status, equals(PredictionStatus.confident));
      expect(response.predictions.length, equals(3));
      expect(response.topPrediction?.label, equals('rice/blast'));
      expect(response.topPrediction?.confidence, equals(0.91));
      expect(response.modelVersion, equals('v1.2.0'));
      expect(response.inferenceMs, equals(142));
      expect(response.reasons, contains('energy'));
    });

    test('Parses uncertain response with competing predictions', () {
      final json = {
        'request_id': 'req_unc_1',
        'crop': {'name': 'potato', 'confidence': 0.70},
        'predictions': [
          {'label': 'potato/early_blight', 'crop': 'potato', 'disease': 'early_blight', 'confidence': 0.45},
          {'label': 'potato/late_blight', 'crop': 'potato', 'disease': 'late_blight', 'confidence': 0.43},
        ],
        'status': 'uncertain',
        'reasons': ['borderline_confidence'],
        'model_version': 'v1.2.0',
        'inference_ms': 110,
      };

      final response = PredictionResponse.fromJson(json);

      expect(response.status, equals(PredictionStatus.uncertain));
      expect(response.crop.name, equals('potato'));
      expect(response.predictions.length, equals(2));
      expect(response.topPrediction?.confidence, equals(0.45));
    });

    test('Parses unknown response for out-of-distribution foliage', () {
      final json = {
        'request_id': 'req_unk_1',
        'crop': {'name': 'unknown', 'confidence': 0.12},
        'predictions': [],
        'status': 'unknown',
        'reasons': ['energy', 'maha'],
        'model_version': 'v1.2.0',
        'inference_ms': 95,
      };

      final response = PredictionResponse.fromJson(json);

      expect(response.status, equals(PredictionStatus.unknown));
      expect(response.predictions, isEmpty);
      expect(response.reasons, containsAll(['energy', 'maha']));
    });

    test('Sorts predictions descending by confidence automatically', () {
      final json = {
        'request_id': 'req_sort',
        'crop': {'name': 'tomato', 'confidence': 0.90},
        'predictions': [
          {'label': 'tomato/leaf_mold', 'crop': 'tomato', 'disease': 'leaf_mold', 'confidence': 0.10},
          {'label': 'tomato/early_blight', 'crop': 'tomato', 'disease': 'early_blight', 'confidence': 0.85},
          {'label': 'tomato/late_blight', 'crop': 'tomato', 'disease': 'late_blight', 'confidence': 0.05},
        ],
        'status': 'confident',
        'reasons': [],
        'model_version': 'v1.0.0',
        'inference_ms': 120,
      };

      final response = PredictionResponse.fromJson(json);

      expect(response.topPrediction?.disease, equals('early_blight'));
      expect(response.topPrediction?.confidence, equals(0.85));
      expect(response.predictions[1].disease, equals('leaf_mold'));
      expect(response.predictions[2].disease, equals('late_blight'));
    });
  });

  group('CropDiseaseInfo Tests', () {
    test('Fallback produces humanized names for missing entries', () {
      final fallback = CropDiseaseInfo.fallback('papaya/ringspot_virus');

      expect(fallback.crop, equals('papaya'));
      expect(fallback.disease, equals('ringspot_virus'));
      expect(fallback.getCropName(false), equals('Papaya'));
      expect(fallback.getDiseaseName(false), equals('Ringspot Virus'));
      expect(fallback.getWhatToDo(false), contains('TODO: verify with an agronomist'));
    });
  });
}
