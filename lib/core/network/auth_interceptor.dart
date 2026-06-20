import 'package:dio/dio.dart';
import 'package:mobile_app/core/storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureStorageService secureStorage,
    required void Function() onUnauthorized,
  })  : _secureStorage = secureStorage,
        _onUnauthorized = onUnauthorized;

  final SecureStorageService _secureStorage;
  final void Function() _onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _secureStorage.clearAll();
      _onUnauthorized();
    }
    return handler.next(err);
  }
}