import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobile_app/core/constants/api_endpoints.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/utils/base64_utils.dart';
import 'package:mobile_app/features/storage/infrastructure/models/storage_response_model.dart';
import 'package:path/path.dart' as p;

/// Kontrak akses remote storage.
abstract class StorageRemoteDataSource {
  /// Upload gambar ke `POST /storage/upload`.
  ///
  /// Lempar [ServerException] untuk error HTTP, [DioException] untuk
  /// network/timeout issues.
  Future<StorageResponseModel> uploadImage(
    File file, {
    void Function(double progress)? onProgress,
  });

  /// Hapus file via `DELETE /storage/:encodedFileKey`.
  ///
  /// [fileKey] — key asli, encoding dilakukan di sini.
  Future<void> deleteFile(String fileKey);
}

class StorageRemoteDataSourceImpl implements StorageRemoteDataSource {
  StorageRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<StorageResponseModel> uploadImage(
    File file, {
    void Function(double progress)? onProgress,
  }) async {
    final fileName = p.basename(file.path);

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await _apiClient.postMultipart<Map<String, dynamic>>(
      ApiEndpoints.storageUpload,
      formData: formData,
      onSendProgress: onProgress != null
          ? (sent, total) {
              if (total > 0) onProgress(sent / total);
            }
          : null,
    );

    _assertSuccess(response);

    final data = response.data;
    if (data == null) {
      throw const ServerException(
        statusCode: 500,
        message: 'Respons upload kosong dari server.',
      );
    }

    return StorageResponseModel.fromJson(data);
  }

  @override
  Future<void> deleteFile(String fileKey) async {
    final encodedKey = Base64Utils.encodeFileKey(fileKey);
    final response = await _apiClient.delete<void>(
      ApiEndpoints.storageDelete(encodedKey),
    );
    _assertSuccess(response);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Karena [ApiClient] menggunakan `validateStatus: status < 500`,
  /// response 4xx tidak otomatis throw. Kita periksa manual di sini.
  ///
  /// [ErrorInterceptor] sudah mem-parse body error NestJS dan menyimpannya
  /// di [DioException.error] sebagai [ServerException]. Namun karena 4xx
  /// dianggap "valid" oleh validateStatus, kita tidak mendapat DioException —
  /// jadi kita extract error dari body response langsung.
  void _assertSuccess(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 400) {
      final data = response.data;
      final rawMessage = data is Map ? data['message'] : null;
      final String message = switch (rawMessage) {
        List()   => (rawMessage as List).join(', '),
        String() => rawMessage as String,
        _        => 'Terjadi kesalahan (HTTP $statusCode).',
      };

      final List<String>? errors =
          rawMessage is List ? List<String>.from(rawMessage as List) : null;

      final module = data is Map ? data['module'] as String? : null;

      throw switch (statusCode) {
        401 => UnauthorizedException(message: message),
        403 => ForbiddenException(message: message),
        404 => NotFoundException(message: message),
        409 => ConflictException(message: message),
        413 => FileTooLargeException(message: message),
        422 => UnsupportedFileException(message: message),
        429 => RateLimitException(message: message),
        _   => ServerException(
            statusCode: statusCode,
            message: message,
            errors: errors,
            module: module,
          ),
      };
    }
  }
}
