enum PredictionStatus {
  confident,
  uncertain,
  unknown;

  static PredictionStatus fromString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'confident':
        return PredictionStatus.confident;
      case 'uncertain':
        return PredictionStatus.uncertain;
      case 'unknown':
      default:
        return PredictionStatus.unknown;
    }
  }

  String toApiString() {
    switch (this) {
      case PredictionStatus.confident:
        return 'confident';
      case PredictionStatus.uncertain:
        return 'uncertain';
      case PredictionStatus.unknown:
        return 'unknown';
    }
  }
}

class CropConfidence {
  final String name;
  final double confidence;

  const CropConfidence({
    required this.name,
    required this.confidence,
  });

  factory CropConfidence.fromJson(Map<String, dynamic> json) {
    return CropConfidence(
      name: (json['name'] ?? 'unknown').toString(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'confidence': confidence,
  };
}

class SinglePrediction {
  final String label;
  final String crop;
  final String disease;
  final double confidence;

  const SinglePrediction({
    required this.label,
    required this.crop,
    required this.disease,
    required this.confidence,
  });

  factory SinglePrediction.fromJson(Map<String, dynamic> json) {
    final label = (json['label'] ?? '').toString();
    String crop = (json['crop'] ?? '').toString();
    String disease = (json['disease'] ?? '').toString();

    // Fall back to split if crop/disease fields are empty
    if ((crop.isEmpty || disease.isEmpty) && label.contains('/')) {
      final parts = label.split('/');
      if (crop.isEmpty && parts.isNotEmpty) crop = parts[0];
      if (disease.isEmpty && parts.length > 1) disease = parts[1];
    }

    return SinglePrediction(
      label: label.isNotEmpty ? label : '$crop/$disease',
      crop: crop.isNotEmpty ? crop : 'unknown',
      disease: disease.isNotEmpty ? disease : 'unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'crop': crop,
    'disease': disease,
    'confidence': confidence,
  };
}

class PredictionResponse {
  final String requestId;
  final CropConfidence crop;
  final List<SinglePrediction> predictions;
  final PredictionStatus status;
  final List<String> reasons;
  final String modelVersion;
  final int inferenceMs;

  const PredictionResponse({
    required this.requestId,
    required this.crop,
    required this.predictions,
    required this.status,
    required this.reasons,
    required this.modelVersion,
    required this.inferenceMs,
  });

  SinglePrediction? get topPrediction =>
      predictions.isNotEmpty ? predictions.first : null;

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    final rawPredictions = json['predictions'];
    final List<SinglePrediction> preds = [];
    if (rawPredictions is List) {
      for (final item in rawPredictions) {
        if (item is Map<String, dynamic>) {
          preds.add(SinglePrediction.fromJson(item));
        }
      }
    }

    // Sort predictions descending by confidence
    preds.sort((a, b) => b.confidence.compareTo(a.confidence));

    final rawCrop = json['crop'];
    final CropConfidence cropConf = rawCrop is Map<String, dynamic>
        ? CropConfidence.fromJson(rawCrop)
        : CropConfidence(
            name: preds.isNotEmpty ? preds.first.crop : 'unknown',
            confidence: preds.isNotEmpty ? preds.first.confidence : 0.0,
          );

    final List<String> reasonsList = [];
    final rawReasons = json['reasons'];
    if (rawReasons is List) {
      for (final r in rawReasons) {
        if (r != null) reasonsList.add(r.toString());
      }
    }

    return PredictionResponse(
      requestId: (json['request_id'] ?? '').toString(),
      crop: cropConf,
      predictions: preds,
      status: PredictionStatus.fromString(json['status']?.toString()),
      reasons: reasonsList,
      modelVersion: (json['model_version'] ?? 'v1.0.0').toString(),
      inferenceMs: (json['inference_ms'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'request_id': requestId,
    'crop': crop.toJson(),
    'predictions': predictions.map((p) => p.toJson()).toList(),
    'status': status.toApiString(),
    'reasons': reasons,
    'model_version': modelVersion,
    'inference_ms': inferenceMs,
  };
}
