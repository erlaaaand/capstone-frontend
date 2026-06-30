import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';
import 'package:mobile_app/features/prediction/domain/value_objects/confidence_score.dart';
import 'package:mobile_app/features/prediction/domain/value_objects/prediction_status.dart';
import 'package:mobile_app/features/prediction/infrastructure/models/paginated_prediction_response_model.dart';
import 'package:mobile_app/features/prediction/infrastructure/models/prediction_response_model.dart';

class PredictionMapper {
  PredictionMapper._();

  static Prediction fromModel(PredictionResponseModel model) {
    return Prediction(
      id: model.id,
      userId: model.userId,
      imageUrl: model.imageUrl,
      fileKey: model.fileKey,
      status: PredictionStatus.fromString(model.status),
      predictedClass: model.predictedClass,
      varietyName: model.varietyName,
      localName: model.localName,
      origin: model.origin,
      confidence: model.confidence != null
          ? ConfidenceScore.fromDouble(model.confidence!)
          : null,
      allScores: model.allScores,
      description: model.description,
      errorMessage: model.errorMessage,
      createdAt: DateTime.tryParse(model.createdAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(model.updatedAt) ?? DateTime.now(),
      marketPriceSummary: model.marketPriceSummary != null
          ? MarketPriceSummary(
              minPriceKg: model.marketPriceSummary!.minPriceKg,
              maxPriceKg: model.marketPriceSummary!.maxPriceKg,
              avgPriceKg: model.marketPriceSummary!.avgPriceKg,
              totalListings: model.marketPriceSummary!.totalListings,
            )
          : null,
    );
  }

  static PaginatedPredictions fromPaginatedModel(
    PaginatedPredictionResponseModel model,
  ) {
    return PaginatedPredictions(
      items: model.data.map((e) => fromModel(e)).toList(),
      page: model.meta.page,
      limit: model.meta.limit,
      total: model.meta.total,
      totalPages: model.meta.totalPages,
    );
  }
}