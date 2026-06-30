import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

// ── Core ─────────────────────────────────────────────────────────────────────
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/network/auth_interceptor.dart';
import 'package:mobile_app/core/network/network_info.dart';
import 'package:mobile_app/core/router/app_router.dart';
import 'package:mobile_app/core/router/route_guard.dart';
import 'package:mobile_app/core/storage/secure_storage_service.dart';

// ── Auth ─────────────────────────────────────────────────────────────────────
import 'package:mobile_app/features/auth/application/auth_bloc.dart';
import 'package:mobile_app/features/auth/application/auth_event.dart';
import 'package:mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_app/features/auth/domain/use_cases/get_auth_me_use_case.dart';
import 'package:mobile_app/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:mobile_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:mobile_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:mobile_app/features/auth/infrastructure/data_sources/auth_local_data_source.dart';
import 'package:mobile_app/features/auth/infrastructure/data_sources/auth_remote_data_source.dart';
import 'package:mobile_app/features/auth/infrastructure/repositories/auth_repository_impl.dart';

// ── Prediction ────────────────────────────────────────────────────────────────
import 'package:mobile_app/features/prediction/application/create_prediction/create_prediction_bloc.dart';
import 'package:mobile_app/features/prediction/application/prediction_list/prediction_list_bloc.dart';
import 'package:mobile_app/features/prediction/domain/repositories/prediction_repository.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/create_prediction_use_case.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/delete_prediction_use_case.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/get_prediction_by_id_use_case.dart';
import 'package:mobile_app/features/prediction/domain/use_cases/get_predictions_use_case.dart';
import 'package:mobile_app/features/prediction/infrastructure/data_sources/prediction_remote_data_source.dart';
import 'package:mobile_app/features/prediction/infrastructure/repositories/prediction_repository_impl.dart';

// ── User ──────────────────────────────────────────────────────────────────────
import 'package:mobile_app/features/user/application/profile_bloc.dart';
import 'package:mobile_app/features/user/domain/repositories/user_repository.dart';
import 'package:mobile_app/features/user/domain/use_cases/get_my_profile_use_case.dart';
import 'package:mobile_app/features/user/domain/use_cases/get_user_by_id_use_case.dart';
import 'package:mobile_app/features/user/domain/use_cases/update_user_use_case.dart';
import 'package:mobile_app/features/user/infrastructure/data_sources/user_remote_data_source.dart';
import 'package:mobile_app/features/user/infrastructure/repositories/user_repository_impl.dart';

// ── Storage ───────────────────────────────────────────────────────────────────
import 'package:mobile_app/features/storage/application/storage_cubit.dart';
import 'package:mobile_app/features/storage/domain/repositories/storage_repository.dart';
import 'package:mobile_app/features/storage/domain/use_cases/delete_file_use_case.dart';
import 'package:mobile_app/features/storage/domain/use_cases/upload_image_use_case.dart';
import 'package:mobile_app/features/storage/infrastructure/data_sources/storage_remote_data_source.dart';
import 'package:mobile_app/features/storage/infrastructure/repositories/storage_repository_impl.dart';

// ── AI Health ─────────────────────────────────────────────────────────────────
import 'package:mobile_app/features/ai_health/application/ai_health_cubit.dart';
import 'package:mobile_app/features/ai_health/domain/repositories/ai_health_repository.dart';
import 'package:mobile_app/features/ai_health/domain/use_cases/get_current_ai_status_use_case.dart';
import 'package:mobile_app/features/ai_health/domain/use_cases/stream_ai_status_use_case.dart';
import 'package:mobile_app/features/ai_health/infrastructure/data_sources/ai_health_remote_data_source.dart';
import 'package:mobile_app/features/ai_health/infrastructure/repositories/ai_health_repository_impl.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/core/theme/theme_cubit.dart';

/// Service Locator global.
final sl = GetIt.instance;

Future<void> initDependencies() async {
  await _registerCore();
  await _registerAuth();
  await _registerPrediction();
  await _registerUser();
  await _registerStorage();
  await _registerAiHealth();
}

// ── Core ──────────────────────────────────────────────────────────────────────

Future<void> _registerCore() async {
  // ── External ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Connectivity());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerFactory(() => ThemeCubit(sl<SharedPreferences>()));

  // ── Services ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => SecureStorageService(sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  // ── Network ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => AuthInterceptor(
      secureStorage: sl<SecureStorageService>(),
      onUnauthorized: () {
        sl<AuthBloc>().add(const AuthSessionExpired());
      },
    ),
  );

  sl.registerLazySingleton(
    () => ApiClient.create(
      authInterceptor: sl<AuthInterceptor>(),
    ),
  );

  // ── Router ────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => RouteGuard(sl<SecureStorageService>()),
  );
  sl.registerLazySingleton(
    () => AppRouter(sl<RouteGuard>()),
  );
}

// ── Auth ──────────────────────────────────────────────────────────────────────

Future<void> _registerAuth() async {
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl<SecureStorageService>()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetAuthMeUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));

  sl.registerLazySingleton(
    () => AuthBloc(
      secureStorage: sl<SecureStorageService>(),
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      getAuthMeUseCase: sl<GetAuthMeUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
    ),
  );
}

// ── Prediction ────────────────────────────────────────────────────────────────

Future<void> _registerPrediction() async {
  // Data Sources
  sl.registerLazySingleton<PredictionRemoteDataSource>(
    () => PredictionRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<PredictionRepository>(
    () => PredictionRepositoryImpl(sl<PredictionRemoteDataSource>()),
  );

  // Use Cases
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

  sl.registerFactory(
    () => CreatePredictionBloc(
      createPredictionUseCase: sl<CreatePredictionUseCase>(),
    ),
  );
  sl.registerFactory(
    () => PredictionListBloc(
      getPredictionsUseCase: sl<GetPredictionsUseCase>(),
      deletePredictionUseCase: sl<DeletePredictionUseCase>(),
    ),
  );
}

// ── User ──────────────────────────────────────────────────────────────────────

Future<void> _registerUser() async {
  // Data Sources
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl<UserRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetMyProfileUseCase(sl<UserRepository>()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl<UserRepository>()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl<UserRepository>()));

  sl.registerFactory(
    () => ProfileBloc(
      getMyProfileUseCase: sl<GetMyProfileUseCase>(),
      updateUserUseCase: sl<UpdateUserUseCase>(),
    ),
  );
}

// ── Storage ───────────────────────────────────────────────────────────────────

Future<void> _registerStorage() async {
  // Data Sources
  sl.registerLazySingleton<StorageRemoteDataSource>(
    () => StorageRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(
      remoteDataSource: sl<StorageRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => UploadImageUseCase(sl<StorageRepository>()));
  sl.registerLazySingleton(() => DeleteFileUseCase(sl<StorageRepository>()));

  sl.registerFactory(
    () => StorageCubit(
      uploadImageUseCase: sl<UploadImageUseCase>(),
      deleteFileUseCase: sl<DeleteFileUseCase>(),
    ),
  );
}

// ── AI Health ─────────────────────────────────────────────────────────────────

Future<void> _registerAiHealth() async {
  // Data Sources
  sl.registerLazySingleton<AiHealthRemoteDataSource>(
    () => AiHealthRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<AiHealthRepository>(
    () => AiHealthRepositoryImpl(
      remoteDataSource: sl<AiHealthRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(
    () => GetCurrentAiStatusUseCase(sl<AiHealthRepository>()),
  );
  sl.registerLazySingleton(
    () => StreamAiStatusUseCase(sl<AiHealthRepository>()),
  );

  sl.registerFactory(
    () => AiHealthCubit(
      getCurrentAiStatusUseCase: sl<GetCurrentAiStatusUseCase>(),
      streamAiStatusUseCase: sl<StreamAiStatusUseCase>(),
    ),
  );
}
