// features/prediction/infrastructure/data_sources/prediction_remote_data_source.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mobile_app/core/constants/api_endpoints.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/utils/file_utils.dart';
import 'package:mobile_app/features/prediction/infrastructure/models/paginated_prediction_response_model.dart';
import 'package:mobile_app/features/prediction/infrastructure/models/prediction_response_model.dart';

abstract class PredictionRemoteDataSource {
  Future<PredictionResponseModel> createPrediction(
    File image, {
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  });

  Future<PredictionResponseModel> getPredictionById(String id);

  Future<PaginatedPredictionResponseModel> getPredictions({
    int page = 1,
    int limit = 10,
  });

  Future<void> deletePrediction(String id);
}

class PredictionRemoteDataSourceImpl implements PredictionRemoteDataSource {
  PredictionRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PredictionResponseModel> createPrediction(
    File image, {
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final fileName = FileUtils.getFileName(image.path);
    final mimeType = FileUtils.getMimeType(image.path) ?? 'image/jpeg';

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        image.path,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ),
    });

    final response = await _apiClient.postMultipart<Map<String, dynamic>>(
      ApiEndpoints.predictions,
      formData: formData,
      onSendProgress: onProgress,
      cancelToken: cancelToken,
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        statusCode: 500,
        message: 'Respons create prediction tidak valid.',
      );
    }

    return PredictionResponseModel.fromJson(data);
  }

  @override
  Future<PredictionResponseModel> getPredictionById(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.predictionById(id),
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        statusCode: 500,
        message: 'Respons get prediction tidak valid.',
      );
    }

    return PredictionResponseModel.fromJson(data);
  }

  @override
  Future<PaginatedPredictionResponseModel> getPredictions({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.predictionsMe,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        statusCode: 500,
        message: 'Respons list prediction tidak valid.',
      );
    }

    return PaginatedPredictionResponseModel.fromJson(data);
  }

  @override
  Future<void> deletePrediction(String id) async {
    await _apiClient.delete<void>(
      ApiEndpoints.predictionById(id),
    );
  }
}