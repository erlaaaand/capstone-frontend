import 'package:mobile_app/features/prediction/infrastructure/models/prediction_response_model.dart';

/// Model JSON untuk response paginated list prediksi.
///
/// Sesuai response NestJS standard pagination:
/// ```json
/// {
///   "data": [ {...}, {...} ],
///   "meta": {
///     "page": 1,
///     "limit": 10,
///     "total": 50,
///     "totalPages": 5
///   }
/// }
/// ```
class PaginatedPredictionResponseModel {
  const PaginatedPredictionResponseModel({
    required this.data,
    required this.meta,
  });

  factory PaginatedPredictionResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PaginatedPredictionResponseModel(
      data: (json['data'] as List)
          .map(
            (item) => PredictionResponseModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      meta: PaginationMetaModel.fromJson(
        json['meta'] as Map<String, dynamic>,
      ),
    );
  }

  final List<PredictionResponseModel> data;
  final PaginationMetaModel meta;
}

/// Meta informasi pagination dari NestJS.
class PaginationMetaModel {
  const PaginationMetaModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMetaModel.fromJson(Map<String, dynamic> json) {
    return PaginationMetaModel(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  final int page;
  final int limit;
  final int total;
  final int totalPages;
}
