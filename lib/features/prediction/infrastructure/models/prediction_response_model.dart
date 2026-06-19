class PredictionResponseModel {
  const PredictionResponseModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.fileKey,
    required this.status,
    this.predictedClass,
    this.confidence,
    this.allScores,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PredictionResponseModel.fromJson(Map<String, dynamic> json) {
    Map<String, double>? allScores;
    if (json['allScores'] is Map) {
      allScores = Map<String, double>.from(
        (json['allScores'] as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      );
    }

    double? parseConfidence(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return PredictionResponseModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      fileKey: json['fileKey'] as String? ?? '', 
      status: json['status'] as String,
      predictedClass: json['varietyCode'] as String? ?? json['predictedClass'] as String?,
      confidence: parseConfidence(json['confidenceScore'] ?? json['confidence']),
      allScores: allScores,
      errorMessage: json['errorMessage'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String? ?? json['createdAt'] as String,
    );
  }

  final String id;
  final String userId;
  final String imageUrl;
  final String fileKey;
  final String status;
  final String? predictedClass;
  final double? confidence;
  final Map<String, double>? allScores;
  final String? errorMessage;
  final String createdAt;
  final String updatedAt;

  @override
  String toString() =>
      'PredictionResponseModel(id: $id, status: $status, class: $predictedClass)';
}