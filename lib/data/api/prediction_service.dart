import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/config.dart';
import '../models/prediction_response.dart';
import 'api_exceptions.dart';

abstract class PredictionService {
  Future<PredictionResponse> predictLeaf(XFile imageFile);
  Future<Map<String, dynamic>> checkHealth();
  Future<bool> submitFeedback({
    required String requestId,
    required bool isCorrect,
    String? note,
    String? suggestedLabel,
  });
}

class MockPredictionService implements PredictionService {
  int _cycleIndex = 0;

  @override
  Future<PredictionResponse> predictLeaf(XFile imageFile) async {
    // 1.5s delay to realistically demonstrate analysis animation
    await Future.delayed(const Duration(milliseconds: 1500));

    final currentIndex = _cycleIndex % 4;
    _cycleIndex++;

    switch (currentIndex) {
      case 0:
        // Confident State: Rice Blast
        return PredictionResponse(
          requestId: 'mock_req_${DateTime.now().millisecondsSinceEpoch}_conf1',
          crop: const CropConfidence(name: 'rice', confidence: 0.98),
          predictions: const [
            SinglePrediction(
              label: 'rice/blast',
              crop: 'rice',
              disease: 'blast',
              confidence: 0.91,
            ),
            SinglePrediction(
              label: 'rice/brown_spot',
              crop: 'rice',
              disease: 'brown_spot',
              confidence: 0.06,
            ),
            SinglePrediction(
              label: 'rice/bacterial_leaf_blight',
              crop: 'rice',
              disease: 'bacterial_leaf_blight',
              confidence: 0.02,
            ),
          ],
          status: PredictionStatus.confident,
          reasons: const [],
          modelVersion: 'v1.2.0-mock',
          inferenceMs: 142,
        );

      case 1:
        // Uncertain State: Potato Blight ambiguity
        return PredictionResponse(
          requestId: 'mock_req_${DateTime.now().millisecondsSinceEpoch}_unc',
          crop: const CropConfidence(name: 'potato', confidence: 0.74),
          predictions: const [
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
            SinglePrediction(
              label: 'potato/healthy',
              crop: 'potato',
              disease: 'healthy',
              confidence: 0.08,
            ),
          ],
          status: PredictionStatus.uncertain,
          reasons: const ['energy', 'borderline_confidence'],
          modelVersion: 'v1.2.0-mock',
          inferenceMs: 168,
        );

      case 2:
        // Unknown State: Out of distribution leaf or object
        return PredictionResponse(
          requestId: 'mock_req_${DateTime.now().millisecondsSinceEpoch}_unk',
          crop: const CropConfidence(name: 'unknown', confidence: 0.21),
          predictions: const [
            SinglePrediction(
              label: 'unknown/unrecognized',
              crop: 'unknown',
              disease: 'unknown',
              confidence: 0.21,
            ),
          ],
          status: PredictionStatus.unknown,
          reasons: const ['energy', 'maha'],
          modelVersion: 'v1.2.0-mock',
          inferenceMs: 115,
        );

      case 3:
      default:
        // Confident State: Tomato Early Blight
        return PredictionResponse(
          requestId: 'mock_req_${DateTime.now().millisecondsSinceEpoch}_conf2',
          crop: const CropConfidence(name: 'tomato', confidence: 0.95),
          predictions: const [
            SinglePrediction(
              label: 'tomato/early_blight',
              crop: 'tomato',
              disease: 'early_blight',
              confidence: 0.89,
            ),
            SinglePrediction(
              label: 'tomato/leaf_mold',
              crop: 'tomato',
              disease: 'leaf_mold',
              confidence: 0.07,
            ),
            SinglePrediction(
              label: 'tomato/healthy',
              crop: 'tomato',
              disease: 'healthy',
              confidence: 0.03,
            ),
          ],
          status: PredictionStatus.confident,
          reasons: const [],
          modelVersion: 'v1.2.0-mock',
          inferenceMs: 139,
        );
    }
  }

  @override
  Future<Map<String, dynamic>> checkHealth() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'status': 'ok',
      'model_version': 'v1.2.0-mock',
      'service': 'MockPredictionService',
    };
  }

  @override
  Future<bool> submitFeedback({
    required String requestId,
    required bool isCorrect,
    String? note,
    String? suggestedLabel,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }
}

class HttpPredictionService implements PredictionService {
  final Dio _dio;
  final String baseUrl;

  HttpPredictionService({required this.baseUrl, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(
                seconds: AppConfig.requestTimeoutSeconds,
              ),
              receiveTimeout: const Duration(
                seconds: AppConfig.requestTimeoutSeconds,
              ),
              sendTimeout: const Duration(
                seconds: AppConfig.requestTimeoutSeconds,
              ),
              headers: {'Accept': 'application/json'},
            ),
          );

  @override
  Future<PredictionResponse> predictLeaf(XFile imageFile) async {
    try {
      final fileName = imageFile.name;
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          await imageFile.readAsBytes(),
          filename: fileName.isNotEmpty ? fileName : 'leaf.jpg',
        ),
      });

      final response = await _dio.post('/v1/predict', data: formData);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
        return PredictionResponse.fromJson(data);
      } else {
        throw const ServerException();
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkTimeoutException();
      }

      if (e.type == DioExceptionType.connectionError ||
          e.response?.statusCode == null) {
        throw BackendUnavailableException(baseUrl);
      }

      final statusCode = e.response?.statusCode;
      switch (statusCode) {
        case 400:
          throw const InvalidImageException();
        case 413:
          throw const ImageTooLargeException();
        case 422:
          throw const NoLeafFoundException();
        case 500:
          throw ServerException(
            e.response?.data?['message']?.toString() ??
                'Server error occurred (${e.response?.statusCode ?? 'unknown status'})',
          );
        default:
          throw ServerException(
            e.response?.data?['message']?.toString() ??
                'Server error occurred (${e.response?.statusCode})',
          );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _dio.get('/v1/health');
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return {'status': 'error', 'statusCode': response.statusCode};
    } catch (e) {
      return {'status': 'unreachable', 'error': e.toString()};
    }
  }

  @override
  Future<bool> submitFeedback({
    required String requestId,
    required bool isCorrect,
    String? note,
    String? suggestedLabel,
  }) async {
    try {
      final response = await _dio.post(
        '/v1/feedback',
        data: {
          'request_id': requestId,
          'is_correct': isCorrect,
          'user_note': note,
          'suggested_label': suggestedLabel,
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      // Local stub fallback
      return true;
    }
  }
}

/// Dynamic Riverpod provider for PredictionService switching seamlessly between Mock and Http
final predictionServiceProvider = Provider<PredictionService>((ref) {
  final config = ref.watch(configProvider);
  if (config.useMock) {
    return MockPredictionService();
  } else {
    return HttpPredictionService(baseUrl: config.baseUrl);
  }
});
