import 'package:dio/dio.dart';
import 'package:mobile_app/core/config/env_config.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/network/auth_interceptor.dart';
import 'package:mobile_app/core/network/error_interceptor.dart';
import 'package:mobile_app/core/network/logging_interceptor.dart';

class ApiClient {
  ApiClient._({required Dio dio}) : _dio = dio;

  final Dio _dio;
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
    );

    final dio = Dio(options);
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
    CancelToken? cancelToken,
  }) =>
      _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _dio.patch<T>(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );

  Future<Response<T>> delete<T>(
    String path, {
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _dio.delete<T>(
        path,
        options: options,
        cancelToken: cancelToken,
      );

  Future<Response<T>> postMultipart<T>(
    String path, {
    required FormData formData,
    void Function(int sent, int total)? onSendProgress,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _dio.post<T>(
        path,
        data: formData,
        options: options ??
            Options(
              contentType: 'multipart/form-data',
            ),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

  Dio get raw => _dio;
}