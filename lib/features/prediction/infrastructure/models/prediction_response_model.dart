/// Model JSON untuk satu prediksi dari API NestJS.
///
/// Sesuai response body endpoint:
/// - `GET  /predictions/:id`
/// - `POST /predictions`
///
/// Format JSON:
/// ```json
/// {
///   "id": "uuid",
///   "userId": "uuid",
///   "imageUrl": "https://...",
///   "fileKey": "predictions/userId/abc.jpg",
///   "status": "PENDING|SUCCESS|FAILED",
///   "predictedClass": "D197",
///   "confidence": 0.9231,
///   "allScores": { "D101": 0.01, "D197": 0.9231, ... },
///   "errorMessage": null,
///   "createdAt": "2024-01-01T00:00:00.000Z",
///   "updatedAt": "2024-01-01T00:00:00.000Z"
/// }
/// ```
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

    return PredictionResponseModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      fileKey: json['fileKey'] as String,
      status: json['status'] as String,
      predictedClass: json['predictedClass'] as String?,
      confidence: json['confidence'] != null
          ? (json['confidence'] as num).toDouble()
          : null,
      allScores: allScores,
      errorMessage: json['errorMessage'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
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
