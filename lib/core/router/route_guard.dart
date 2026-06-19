import 'package:mobile_app/core/router/route_names.dart';
import 'package:mobile_app/core/storage/secure_storage_service.dart';
import 'package:go_router/go_router.dart';

class RouteGuard {
  RouteGuard(this._secureStorage);

  final SecureStorageService _secureStorage;

  static const _publicPaths = {
    RoutePaths.splash,
    RoutePaths.login,
    RoutePaths.register,
  };

  Future<String?> redirect(GoRouterState state) async {
    final isPublic = _publicPaths.contains(state.matchedLocation);
    final hasToken = await _secureStorage.hasAccessToken();

    if (!isPublic && !hasToken) {
      return RoutePaths.login;
    }

    if (isPublic &&
        hasToken &&
        state.matchedLocation != RoutePaths.splash) {
      return RoutePaths.scan;
    }

    return null;
  }
}
