import 'package:dio/dio.dart';
import 'package:mobile_app/core/config/env_config.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/network/auth_interceptor.dart';
import 'package:mobile_app/core/network/error_interceptor.dart';
import 'package:mobile_app/core/network/logging_interceptor.dart';

/// Wrapper Dio yang dikonfigurasi untuk API NestJS.
///
/// Satu instance dibuat via DI dan dipakai oleh semua data source.
/// Endpoint SSE (AI Health) menggunakan stream terpisah karena
/// Dio tidak mendukung SSE natively.
class ApiClient {
  ApiClient._({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Base URL backend NestJS (dari env).
  String get baseUrl => EnvConfig.apiBaseUrl;

  // ── Factory ──────────────────────────────────────────────────────────────

  factory ApiClient.create({
    required AuthInterceptor authInterceptor,
  }) {
    final options = BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // FIX [CRITICAL]: Hanya terima response 2xx sebagai sukses.
      //
      // SEBELUM (bermasalah):
      //   validateStatus: (status) => status != null && status < 500
      //
      //   Dengan ini, Dio menganggap SEMUA response < 500 sebagai sukses —
      //   termasuk 401, 403, 404, 422, 429. Akibatnya:
      //   1. DioException TIDAK dilempar untuk response 4xx
      //   2. ErrorInterceptor.onError TIDAK pernah dipanggil untuk 4xx
      //   3. AuthInterceptor.onError TIDAK pernah dipanggil untuk 401
      //      → mekanisme auto-logout tidak bekerja
      //   4. Repository menerima Response{statusCode: 401, data: {message: "..."}}
      //      sebagai response "sukses" dan mencoba parse body error sebagai
      //      data domain (UserResponseDto, PredictionResponseDto, dll)
      //      → parse gagal atau menghasilkan data kosong
      //   5. Profil tidak bisa di-load, prediksi tidak tampil
      //
      // SESUDAH (benar):
      //   validateStatus: (status) => status != null && status >= 200 && status < 300
      //
      //   Hanya 2xx yang dianggap sukses. Response 4xx dan 5xx akan
      //   melempar DioException, sehingga:
      //   - ErrorInterceptor.onError bekerja → konversi ke ServerException
      //   - AuthInterceptor.onError bekerja → auto-logout saat 401
      //   - Repository menerima exception yang benar → Failure yang tepat ke UI
      validateStatus: (status) => status != null && status >= 200 && status < 300,
    );

    final dio = Dio(options);

    // Urutan interceptor penting:
    // 1. Auth  → tambah token ke header, handle 401 auto-logout
    // 2. Error → konversi response error ke exception yang spesifik
    // 3. Logger (hanya dev) → log request/response untuk debugging
    dio.interceptors.addAll([
      authInterceptor,
      ErrorInterceptor(),
      if (LoggingInterceptor.create() case final logger?) logger,
    ]);

    return ApiClient._(dio: dio);
  }

  // ── HTTP Methods ─────────────────────────────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.patch<T>(path, data: data, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    Options? options,
  }) =>
      _dio.delete<T>(path, options: options);

  /// Upload file menggunakan [FormData] (multipart/form-data).
  ///
  /// [onSendProgress] untuk menampilkan progress bar upload.
  Future<Response<T>> postMultipart<T>(
    String path, {
    required FormData formData,
    void Function(int sent, int total)? onSendProgress,
  }) =>
      _dio.post<T>(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
        onSendProgress: onSendProgress,
      );

  /// Akses raw Dio untuk kebutuhan khusus (mis. cancel token).
  Dio get raw => _dio;
}