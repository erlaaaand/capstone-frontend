/// Model JSON untuk satu prediksi dari API NestJS.
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

    // Fungsi bantuan untuk mem-parsing confidence yang mungkin berupa String atau Double
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
      // Berikan nilai default string kosong jika fileKey tidak dikirim backend
      fileKey: json['fileKey'] as String? ?? '', 
      status: json['status'] as String,
      // Backend menggunakan key 'varietyCode' sebagai ganti 'predictedClass'
      predictedClass: json['varietyCode'] as String? ?? json['predictedClass'] as String?,
      // Backend menggunakan key 'confidenceScore' (String) sebagai ganti 'confidence'
      confidence: parseConfidence(json['confidenceScore'] ?? json['confidence']),
      allScores: allScores,
      errorMessage: json['errorMessage'] as String?,
      createdAt: json['createdAt'] as String,
      // Jika updatedAt tidak dikirim backend, gunakan nilai createdAt sebagai fallback
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