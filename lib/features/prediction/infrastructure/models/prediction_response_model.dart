// prediction/infrastructure/models/prediction_response_model.dart
class MarketPriceSummaryModel {
  const MarketPriceSummaryModel({
    required this.minPriceKg,
    required this.maxPriceKg,
    required this.avgPriceKg,
    required this.totalListings,
  });

  final int minPriceKg;
  final int maxPriceKg;
  final int avgPriceKg;
  final int totalListings;

  factory MarketPriceSummaryModel.fromJson(Map<String, dynamic> json) =>
      MarketPriceSummaryModel(
        minPriceKg: json['minPriceKg'] as int? ?? 0,
        maxPriceKg: json['maxPriceKg'] as int? ?? 0,
        avgPriceKg: json['avgPriceKg'] as int? ?? 0,
        totalListings: json['totalListings'] as int? ?? 0,
      );
}

class PredictionResponseModel {
  const PredictionResponseModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.fileKey,
    required this.status,
    this.predictedClass,
    this.varietyName,
    this.localName,
    this.origin,
    this.confidence,
    this.allScores,
    this.description,
    this.errorMessage,
    this.marketPriceSummary,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String imageUrl;
  final String fileKey;
  final String status;
  final String? predictedClass;
  final String? varietyName;
  final String? localName;
  final String? origin;
  final double? confidence;
  final Map<String, double>? allScores;
  final String? description;
  final String? errorMessage;
  final MarketPriceSummaryModel? marketPriceSummary;
  final String createdAt;
  final String updatedAt;

  factory PredictionResponseModel.fromJson(Map<String, dynamic> json) {
    Map<String, double>? allScores;
    
    if (json['allVarieties'] is List) {
      allScores = {};
      for (var item in (json['allVarieties'] as List)) {
        if (item is Map<String, dynamic>) {
          final code = item['varietyCode'] as String?;
          final score = item['confidenceScore'] as num?;
          if (code != null && score != null) {
            allScores[code] = score.toDouble();
          }
        }
      }
    } else if (json['allScores'] is Map) {
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
      userId: json['userId'] as String? ?? '', 
      imageUrl: json['imageUrl'] as String,
      fileKey: json['fileKey'] as String? ?? '', 
      status: json['status'] as String,
      predictedClass: json['varietyCode'] as String? ?? 
                      json['predictedClass'] as String? ?? 
                      json['varietyName'] as String?,
      varietyName: json['varietyName'] as String?,
      localName: json['localName'] as String?,
      origin: json['origin'] as String?,
      confidence: parseConfidence(json['confidenceScore'] ?? json['confidence']),
      allScores: allScores,
      errorMessage: json['errorMessage'] as String?,
      description: json['description'] as String?,
      marketPriceSummary: json['marketPriceSummary'] != null
          ? MarketPriceSummaryModel.fromJson(
              json['marketPriceSummary'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String? ?? json['createdAt'] as String,
    );
  }
}