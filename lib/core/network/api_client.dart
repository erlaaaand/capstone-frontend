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
      // Jangan throw error pada status 4xx/5xx — ErrorInterceptor yang handle
      validateStatus: (status) => status != null && status < 500,
    );

    final dio = Dio(options);

    // Urutan interceptor penting:
    // 1. Auth  → tambah token ke header
    // 2. Error → konversi response error ke exception
    // 3. Logger (hanya dev)
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
