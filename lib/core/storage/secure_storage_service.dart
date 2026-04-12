import 'package:mobile_app/core/constants/storage_keys.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstraksi akses [FlutterSecureStorage] untuk data sensitif (JWT, user info).
///
/// Semua operasi di-wrap dengan try-catch agar tidak ada exception mentah
/// yang bocor ke layer atasnya.
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  // ── Token ───────────────────────────────────────────────────────────────────

  Future<void> saveAccessToken(String token) =>
      _write(StorageKeys.accessToken, token);

  Future<String?> getAccessToken() => _read(StorageKeys.accessToken);

  Future<void> deleteAccessToken() => _delete(StorageKeys.accessToken);

  // ── User Session ─────────────────────────────────────────────────────────────

  Future<void> saveUserId(String id) => _write(StorageKeys.userId, id);

  Future<String?> getUserId() => _read(StorageKeys.userId);

  Future<void> saveUserEmail(String email) =>
      _write(StorageKeys.userEmail, email);

  Future<String?> getUserEmail() => _read(StorageKeys.userEmail);

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Hapus semua data (dipanggil saat logout).
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll(
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (e) {
      throw StorageAccessException(message: 'Gagal menghapus sesi: $e');
    }
  }

  /// Apakah ada token aktif di storage.
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ── Internal ─────────────────────────────────────────────────────────────────

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(
        key: key,
        value: value,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (e) {
      throw StorageAccessException(message: 'Gagal menyimpan $key: $e');
    }
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (e) {
      throw StorageAccessException(message: 'Gagal membaca $key: $e');
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (e) {
      throw StorageAccessException(message: 'Gagal menghapus $key: $e');
    }
  }
}
