import 'package:mobile_app/features/prediction/infrastructure/models/prediction_response_model.dart';

class PaginatedPredictionResponseModel {
  const PaginatedPredictionResponseModel({
    required this.data,
    required this.meta,
  });

  factory PaginatedPredictionResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawData = json['data'] as List?;
    final dataList = rawData?.map(
          (item) => PredictionResponseModel.fromJson(
            item as Map<String, dynamic>,
          ),
        ).toList() ?? [];

    PaginationMetaModel metaData;
    if (json['meta'] != null && json['meta'] is Map) {
      metaData = PaginationMetaModel.fromJson(
        json['meta'] as Map<String, dynamic>,
      );
    } else {
      metaData = PaginationMetaModel(
        page: 1,
        limit: dataList.isNotEmpty ? dataList.length : 10,
        total: dataList.length,
        totalPages: 1,
      );
    }

    return PaginatedPredictionResponseModel(
      data: dataList,
      meta: metaData,
    );
  }

  final List<PredictionResponseModel> data;
  final PaginationMetaModel meta;
}

class PaginationMetaModel {
  const PaginationMetaModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMetaModel.fromJson(Map<String, dynamic> json) {
    return PaginationMetaModel(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }

  final int page;
  final int limit;
  final int total;
  final int totalPages;
}