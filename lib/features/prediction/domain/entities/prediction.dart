import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/prediction/domain/value_objects/confidence_score.dart';
import 'package:mobile_app/features/prediction/domain/value_objects/prediction_status.dart';

class MarketPriceSummary extends Equatable {
  const MarketPriceSummary({
    required this.minPriceKg,
    required this.maxPriceKg,
    required this.avgPriceKg,
    required this.totalListings,
  });

  final int minPriceKg;
  final int maxPriceKg;
  final int avgPriceKg;
  final int totalListings;

  @override
  List<Object?> get props => [
        minPriceKg,
        maxPriceKg,
        avgPriceKg,
        totalListings,
      ];
}

class Prediction extends Equatable {
  const Prediction({
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

  final PredictionStatus status;

  final String? predictedClass;

  final String? varietyName;
  
  final String? localName;
  
  final String? origin;

  final ConfidenceScore? confidence;

  final Map<String, double>? allScores;

  final String? description;

  final String? errorMessage;

  final MarketPriceSummary? marketPriceSummary;

  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Convenience getters ────────────────────────────────────────────────────

  bool get isSuccess  => status.isSuccess;
  bool get isPending  => status.isPending;
  bool get isFailed   => status.isFailed;
  bool get isComplete => status.isComplete;

  bool get hasHighConfidence => (confidence?.value ?? 0.0) > 0.8;
  
  bool get isStrictSuccess => isSuccess && hasHighConfidence;

  @override
  List<Object?> get props => [
        id,
        userId,
        imageUrl,
        fileKey,
        status,
        predictedClass,
        confidence,
        allScores,
        errorMessage,
        marketPriceSummary,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() =>
      'Prediction(id: $id, status: ${status.value}, class: $predictedClass)';
}

class PaginatedPredictions extends Equatable {
  const PaginatedPredictions({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<Prediction> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasNextPage => page < totalPages;
  bool get isFirstPage => page == 1;
  bool get isEmpty     => items.isEmpty;

  @override
  List<Object?> get props => [items, page, limit, total, totalPages];
}