import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';
import 'package:mobile_app/features/prediction/domain/value_objects/confidence_score.dart';
import 'package:mobile_app/features/prediction/domain/value_objects/prediction_status.dart';
import 'package:mobile_app/features/prediction/infrastructure/models/paginated_prediction_response_model.dart';
import 'package:mobile_app/features/prediction/infrastructure/models/prediction_response_model.dart';

/// Konversi antara infrastructure model dan domain entity.
///
/// Dipanggil di [PredictionRepositoryImpl] setelah menerima data dari API.
class PredictionMapper {
  PredictionMapper._();

  /// Konversi [PredictionResponseModel] → [Prediction].
  static Prediction fromModel(PredictionResponseModel model) {
    return Prediction(
      id: model.id,
      userId: model.userId,
      imageUrl: model.imageUrl,
      fileKey: model.fileKey,
      status: PredictionStatus.fromString(model.status),
      predictedClass: model.predictedClass,
      confidence: model.confidence != null
          ? ConfidenceScore.fromDouble(model.confidence!)
          : null,
      allScores: model.allScores,
      errorMessage: model.errorMessage,
      createdAt: DateTime.parse(model.createdAt),
      updatedAt: DateTime.parse(model.updatedAt),
    );
  }

  /// Konversi [PaginatedPredictionResponseModel] → [PaginatedPredictions].
  static PaginatedPredictions fromPaginatedModel(
    PaginatedPredictionResponseModel model,
  ) {
    return PaginatedPredictions(
      items: model.data.map(fromModel).toList(),
      page: model.meta.page,
      limit: model.meta.limit,
      total: model.meta.total,
      totalPages: model.meta.totalPages,
    );
  }
}
