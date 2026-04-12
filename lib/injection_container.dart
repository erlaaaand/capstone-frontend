import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/network/auth_interceptor.dart';
import 'package:mobile_app/core/network/network_info.dart';
import 'package:mobile_app/core/router/app_router.dart';
import 'package:mobile_app/core/router/route_guard.dart';
import 'package:mobile_app/core/storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

/// Service Locator global.
final sl = GetIt.instance;

/// Inisialisasi seluruh dependency injection.
///
/// Dipanggil sekali di [main] sebelum [runApp]:
/// ```dart
/// await initDependencies();
/// runApp(const App());
/// ```
Future<void> initDependencies() async {
  await _registerCore();
  // Feature dependencies didaftarkan di sini setelah dibangun:
  // await _registerAuth();
  // await _registerUser();
  // await _registerStorage();
  // await _registerPrediction();
  // await _registerAiHealth();
}

Future<void> _registerCore() async {
  // ── External ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Connectivity());

  // ── Core Services ─────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => SecureStorageService(sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  // ── Network ───────────────────────────────────────────────────────────────
  // AuthInterceptor butuh callback onUnauthorized yang akan di-set
  // setelah router siap. Gunakan late binding via setter.
  sl.registerLazySingleton(
    () => AuthInterceptor(
      secureStorage: sl<SecureStorageService>(),
      // Router belum ada saat ini, akan di-update via AppRouter.
      // Di production gunakan navigatorKey atau event bus.
      onUnauthorized: () {
        // Placeholder — di-override setelah AppRouter tersedia.
        // Lihat App.dart untuk setup lengkap.
      },
    ),
  );

  sl.registerLazySingleton(
    () => ApiClient.create(
      authInterceptor: sl<AuthInterceptor>(),
    ),
  );

  // ── Router ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => RouteGuard(sl<SecureStorageService>()),
  );

  sl.registerLazySingleton(
    () => AppRouter(sl<RouteGuard>()),
  );
}

// ── Feature registrations (uncomment saat feature dibangun) ─────────────────
//
// Future<void> _registerAuth() async {
//   // Data Sources
//   sl.registerLazySingleton<AuthRemoteDataSource>(
//     () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
//   );
//   sl.registerLazySingleton<AuthLocalDataSource>(
//     () => AuthLocalDataSourceImpl(sl<SecureStorageService>()),
//   );
//   // Repository
//   sl.registerLazySingleton<AuthRepository>(
//     () => AuthRepositoryImpl(
//       remoteDataSource: sl<AuthRemoteDataSource>(),
//       localDataSource: sl<AuthLocalDataSource>(),
//       networkInfo: sl<NetworkInfo>(),
//     ),
//   );
//   // Use Cases
//   sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
//   sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
//   sl.registerLazySingleton(() => GetAuthMeUseCase(sl<AuthRepository>()));
//   // Bloc
//   sl.registerFactory(
//     () => AuthBloc(
//       loginUseCase: sl<LoginUseCase>(),
//       registerUseCase: sl<RegisterUseCase>(),
//       getAuthMeUseCase: sl<GetAuthMeUseCase>(),
//     ),
//   );
// }
