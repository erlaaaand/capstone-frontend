import 'package:mobile_app/core/router/route_names.dart';
import 'package:mobile_app/core/storage/secure_storage_service.dart';
import 'package:go_router/go_router.dart';

/// Guard yang melindungi halaman yang butuh autentikasi.
///
/// Dipanggil di `redirect` callback [GoRouter].
class RouteGuard {
  RouteGuard(this._secureStorage);

  final SecureStorageService _secureStorage;

  /// Public paths yang boleh diakses tanpa token.
  static const _publicPaths = {
    RoutePaths.splash,
    RoutePaths.login,
    RoutePaths.register,
  };

  /// Dipanggil oleh GoRouter pada setiap navigasi.
  ///
  /// Return null = lanjutkan navigasi.
  /// Return path = redirect ke path tersebut.
  Future<String?> redirect(GoRouterState state) async {
    final isPublic = _publicPaths.contains(state.matchedLocation);
    final hasToken = await _secureStorage.hasAccessToken();

    // Belum login, akses halaman protected → ke login
    if (!isPublic && !hasToken) {
      return RoutePaths.login;
    }

    // Sudah login, akses halaman auth → ke scan (home)
    if (isPublic &&
        hasToken &&
        state.matchedLocation != RoutePaths.splash) {
      return RoutePaths.scan;
    }

    return null;
  }
}
