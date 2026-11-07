import 'prediction_response.dart';

class HistoryScan {
  final String id;
  final DateTime timestamp;
  final String imagePath;
  final String crop;
  final String disease;
  final PredictionStatus status;
  final double confidence;
  final PredictionResponse predictionResponse;
  final bool isReportedWrong;
  final String? userFeedbackComment;

  const HistoryScan({
    required this.id,
    required this.timestamp,
    required this.imagePath,
    required this.crop,
    required this.disease,
    required this.status,
    required this.confidence,
    required this.predictionResponse,
    this.isReportedWrong = false,
    this.userFeedbackComment,
  });

  HistoryScan copyWith({
    bool? isReportedWrong,
    String? userFeedbackComment,
    String? imagePath,
  }) {
    return HistoryScan(
      id: id,
      timestamp: timestamp,
      imagePath: imagePath ?? this.imagePath,
      crop: crop,
      disease: disease,
      status: status,
      confidence: confidence,
      predictionResponse: predictionResponse,
      isReportedWrong: isReportedWrong ?? this.isReportedWrong,
      userFeedbackComment: userFeedbackComment ?? this.userFeedbackComment,
    );
  }

  factory HistoryScan.fromJson(Map<String, dynamic> json) {
    return HistoryScan(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      imagePath: json['image_path'] as String,
      crop: json['crop'] as String,
      disease: json['disease'] as String,
      status: PredictionStatus.fromString(json['status'] as String?),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      predictionResponse: PredictionResponse.fromJson(
        Map<String, dynamic>.from(json['prediction_response'] as Map),
      ),
      isReportedWrong: (json['is_reported_wrong'] as bool?) ?? false,
      userFeedbackComment: json['user_feedback_comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'image_path': imagePath,
      'crop': crop,
      'disease': disease,
      'status': status.toApiString(),
      'confidence': confidence,
      'prediction_response': predictionResponse.toJson(),
      'is_reported_wrong': isReportedWrong,
      'user_feedback_comment': userFeedbackComment,
    };
  }
}
