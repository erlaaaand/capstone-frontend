import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/prediction/domain/value_objects/confidence_score.dart';
import 'package:mobile_app/features/prediction/domain/value_objects/prediction_status.dart';

class Prediction extends Equatable {
  const Prediction({
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

  final String id;

  final String userId;

  final String imageUrl;

  final String fileKey;

  final PredictionStatus status;

  final String? predictedClass;

  final ConfidenceScore? confidence;

  final Map<String, double>? allScores;

  final String? errorMessage;

  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Convenience getters ────────────────────────────────────────────────────

  bool get isSuccess  => status.isSuccess;
  bool get isPending  => status.isPending;
  bool get isFailed   => status.isFailed;
  bool get isComplete => status.isComplete;

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
