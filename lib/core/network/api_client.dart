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
      // Gunakan perilaku default Dio: throw DioException untuk semua
      // status non-2xx. ErrorInterceptor.onError akan menangkap 4xx (401,
      // 403, 404, 409, 422, 429) dan mengonversinya ke exception yang tepat.
      // AuthInterceptor.onError juga dapat mendeteksi 401 untuk logout otomatis.
      //
      // JANGAN set validateStatus ke (status) => status < 500 — ini
      // menyebabkan 4xx lolos sebagai Response sukses dan melewati
      // seluruh error handling chain.
    );

    final dio = Dio(options);

    // Urutan interceptor penting:
    // 1. Auth  → tambah token ke header SEBELUM request dikirim
    // 2. Error → konversi response error 4xx/5xx ke exception spesifik
    // 3. Logger (hanya dev) → log request + response terakhir
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
  /// Prediction creation endpoint mungkin perlu receiveTimeout lebih panjang
  /// karena AI processing berjalan async di server — gunakan [options] untuk
  /// override jika diperlukan per-call.
  Future<Response<T>> postMultipart<T>(
    String path, {
    required FormData formData,
    void Function(int sent, int total)? onSendProgress,
    Options? options,
  }) =>
      _dio.post<T>(
        path,
        data: formData,
        options: options ??
            Options(
              contentType: 'multipart/form-data',
            ),
        onSendProgress: onSendProgress,
      );

  /// Akses raw Dio untuk kebutuhan khusus (mis. cancel token).
  Dio get raw => _dio;
}
