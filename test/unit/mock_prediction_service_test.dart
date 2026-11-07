import 'package:cropdoc_app/data/api/prediction_service.dart';
import 'package:cropdoc_app/data/models/prediction_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  group('MockPredictionService Tests', () {
    late MockPredictionService service;

    setUp(() {
      service = MockPredictionService();
    });

    test('Cycles through Confident, Uncertain, Unknown, Confident', () async {
      final dummyFile = XFile('dummy.jpg');

      // 1st call -> Confident (Rice Blast)
      final res1 = await service.predictLeaf(dummyFile);
      expect(res1.status, equals(PredictionStatus.confident));
      expect(res1.crop.name, equals('rice'));

      // 2nd call -> Uncertain (Potato Blight)
      final res2 = await service.predictLeaf(dummyFile);
      expect(res2.status, equals(PredictionStatus.uncertain));
      expect(res2.crop.name, equals('potato'));

      // 3rd call -> Unknown
      final res3 = await service.predictLeaf(dummyFile);
      expect(res3.status, equals(PredictionStatus.unknown));

      // 4th call -> Confident (Tomato)
      final res4 = await service.predictLeaf(dummyFile);
      expect(res4.status, equals(PredictionStatus.confident));
      expect(res4.crop.name, equals('tomato'));
    });

    test('checkHealth returns ok', () async {
      final health = await service.checkHealth();
      expect(health['status'], equals('ok'));
      expect(health['model_version'], isNotNull);
    });

    test('submitFeedback returns true', () async {
      final success = await service.submitFeedback(
        requestId: 'req_test',
        isCorrect: false,
        note: 'Looks like bacterial wilt',
      );
      expect(success, isTrue);
    });
  });
}
