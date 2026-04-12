import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/network/auth_interceptor.dart';
import 'package:mobile_app/core/network/network_info.dart';
import 'package:mobile_app/core/router/app_router.dart';
import 'package:mobile_app/core/router/route_guard.dart';
import 'package:mobile_app/core/storage/secure_storage_service.dart';
import 'package:mobile_app/features/auth/application/auth_bloc.dart';
import 'package:mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_app/features/auth/domain/use_cases/get_auth_me_use_case.dart';
import 'package:mobile_app/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:mobile_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:mobile_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:mobile_app/features/auth/infrastructure/data_sources/auth_local_data_source.dart';
import 'package:mobile_app/features/auth/infrastructure/data_sources/auth_remote_data_source.dart';
import 'package:mobile_app/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_bloc.dart';
import 'package:mobile_app/features/prediction/application/prediction_list/prediction_list_bloc.dart';
import 'package:mobile_app/features/prediction/domain/repositories/prediction_repository.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/create_prediction_use_case.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/delete_prediction_use_case.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/get_prediction_by_id_use_case.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/get_predictions_use_case.dart';
import 'package:mobile_app/features/prediction/infrastructure/data_sources/prediction_remote_data_source.dart';
import 'package:mobile_app/features/prediction/infrastructure/repositories/prediction_repository_impl.dart';
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
  await _registerAuth();
  await _registerPrediction();
  // await _registerUser();
  // await _registerStorage();
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
  sl.registerLazySingleton(
    () => AuthInterceptor(
      secureStorage: sl<SecureStorageService>(),
      onUnauthorized: () {
        // Dipanggil ketika token expired / 401.
        // AppRouter akan handle navigasi ke login via GoRouter redirect.
        sl<SecureStorageService>().clearAll();
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

Future<void> _registerAuth() async {
  // ── Data Sources ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl<SecureStorageService>()),
  );

  // ── Repository ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetAuthMeUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));

  // ── Bloc ──────────────────────────────────────────────────────────────────
  // registerFactory agar setiap widget yang membutuhkan AuthBloc
  // mendapat instance baru (tidak share state antar tree yang berbeda).
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      getAuthMeUseCase: sl<GetAuthMeUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
    ),
  );
}

Future<void> _registerPrediction() async {
  // ── Data Sources ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<PredictionRemoteDataSource>(
    () => PredictionRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // ── Repository ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PredictionRepository>(
    () => PredictionRepositoryImpl(sl<PredictionRemoteDataSource>()),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => CreatePredictionUseCase(sl<PredictionRepository>()),
  );
  sl.registerLazySingleton(
    () => GetPredictionByIdUseCase(sl<PredictionRepository>()),
  );
  sl.registerLazySingleton(
    () => GetPredictionsUseCase(sl<PredictionRepository>()),
  );
  sl.registerLazySingleton(
    () => DeletePredictionUseCase(sl<PredictionRepository>()),
  );

  // ── BLoC ──────────────────────────────────────────────────────────────────
  // registerFactory agar setiap halaman mendapat instance baru.
  sl.registerFactory(
    () => CreatePredictionBloc(
      createPredictionUseCase: sl<CreatePredictionUseCase>(),
      getPredictionByIdUseCase: sl<GetPredictionByIdUseCase>(),
    ),
  );
  sl.registerFactory(
    () => PredictionListBloc(
      getPredictionsUseCase: sl<GetPredictionsUseCase>(),
      deletePredictionUseCase: sl<DeletePredictionUseCase>(),
    ),
  );
}

// ── Feature registrations (uncomment saat feature dibangun) ─────────────────
//
// Future<void> _registerUser() async { ... }
// Future<void> _registerStorage() async { ... }
// Future<void> _registerAiHealth() async { ... }
