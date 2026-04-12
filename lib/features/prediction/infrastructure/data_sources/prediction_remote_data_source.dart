import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mobile_app/core/constants/api_endpoints.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/utils/file_utils.dart';
import 'package:mobile_app/features/prediction/infrastructure/models/create_prediction_request_model.dart';
import 'package:mobile_app/features/prediction/infrastructure/models/paginated_prediction_response_model.dart';
import 'package:mobile_app/features/prediction/infrastructure/models/prediction_response_model.dart';

/// Kontrak data source prediksi.
abstract class PredictionRemoteDataSource {
  /// Upload gambar ke storage. Return `(imageUrl, fileKey)`.
  Future<({String imageUrl, String fileKey})> uploadImage(
    File image, {
    void Function(int sent, int total)? onProgress,
  });

  /// Buat record prediksi baru via `POST /predictions`.
  Future<PredictionResponseModel> createPrediction(
    CreatePredictionRequestModel request,
  );

  /// Ambil detail prediksi via `GET /predictions/:id`.
  Future<PredictionResponseModel> getPredictionById(String id);

  /// Ambil list prediksi paginated via `GET /predictions`.
  Future<PaginatedPredictionResponseModel> getPredictions({
    int page = 1,
    int limit = 10,
  });

  /// Hapus prediksi via `DELETE /predictions/:id`.
  Future<void> deletePrediction(String id);
}

/// Implementasi [PredictionRemoteDataSource] menggunakan [ApiClient] (Dio).
class PredictionRemoteDataSourceImpl implements PredictionRemoteDataSource {
  PredictionRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<({String imageUrl, String fileKey})> uploadImage(
    File image, {
    void Function(int sent, int total)? onProgress,
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
      ApiEndpoints.storageUpload,
      formData: formData,
      onSendProgress: onProgress,
    );

    final data = response.data;
    if (data == null ||
        data['imageUrl'] == null ||
        data['fileKey'] == null) {
      throw const ServerException(
        statusCode: 500,
        message: 'Respons upload tidak valid.',
      );
    }

    return (
      imageUrl: data['imageUrl'] as String,
      fileKey: data['fileKey'] as String,
    );
  }

  @override
  Future<PredictionResponseModel> createPrediction(
    CreatePredictionRequestModel request,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.predictions,
      data: request.toJson(),
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
      ApiEndpoints.predictions,
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
