import 'package:dio/dio.dart';
import 'package:mobile_app/core/storage/secure_storage_service.dart';

/// Interceptor Dio yang:
/// 1. Otomatis menambahkan `Authorization: Bearer <token>` ke setiap request.
/// 2. Menangani respons 401 — clear token dan trigger re-login.
///
/// Di-inject ke [ApiClient] melalui [InjectionContainer].
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureStorageService secureStorage,
    required void Function() onUnauthorized,
  })  : _secureStorage = secureStorage,
        _onUnauthorized = onUnauthorized;

  final SecureStorageService _secureStorage;

  /// Callback yang dipanggil saat menerima 401.
  /// Biasanya: clear token + navigasi ke halaman login.
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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Clear sesi lokal dan beritahu app
      _secureStorage.clearAll().then((_) => _onUnauthorized());
    }
    return handler.next(err);
  }
}
