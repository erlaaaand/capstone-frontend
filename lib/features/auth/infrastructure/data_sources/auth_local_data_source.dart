import 'package:mobile_app/core/storage/secure_storage_service.dart';

/// Akses token & session dari secure storage.
abstract class AuthLocalDataSource {
  Future<void> saveSession({
    required String accessToken,
    required String userId,
    required String email,
  });

  Future<String?> getAccessToken();
  Future<bool> hasSession();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._storage);

  final SecureStorageService _storage;

  @override
  Future<void> saveSession({
    required String accessToken,
    required String userId,
    required String email,
  }) async {
    await Future.wait([
      _storage.saveAccessToken(accessToken),
      _storage.saveUserId(userId),
      _storage.saveUserEmail(email),
    ]);
  }

  @override
  Future<String?> getAccessToken() => _storage.getAccessToken();

  @override
  Future<bool> hasSession() => _storage.hasAccessToken();

  @override
  Future<void> clearSession() => _storage.clearAll();
}
