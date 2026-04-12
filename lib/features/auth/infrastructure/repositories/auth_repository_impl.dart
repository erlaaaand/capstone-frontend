import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_app/core/error/error_handler.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/network/network_info.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_token.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_app/features/auth/infrastructure/data_sources/auth_local_data_source.dart';
import 'package:mobile_app/features/auth/infrastructure/data_sources/auth_remote_data_source.dart';
import 'package:mobile_app/features/auth/infrastructure/models/login_request_model.dart';
import 'package:mobile_app/features/auth/infrastructure/models/register_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remote = remoteDataSource,
        _local = localDataSource,
        _network = networkInfo;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, AuthToken>> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    if (!await _network.isConnected) return const Left(NoInternetFailure());

    try {
      final model = await _remote.register(
        RegisterRequestModel(email: email, password: password, fullName: fullName),
      );

      // Simpan sesi setelah register berhasil
      await _local.saveSession(
        accessToken: model.accessToken,
        userId: model.user.id,
        email: model.user.email,
      );

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ErrorHandler.fromServerException(e));
    } on DioException catch (e) {
      return Left(ErrorHandler.fromDioException(e));
    } catch (e) {
      return Left(ErrorHandler.fromUnknown(e));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> login({
    required String email,
    required String password,
  }) async {
    if (!await _network.isConnected) return const Left(NoInternetFailure());

    try {
      final model = await _remote.login(
        LoginRequestModel(email: email, password: password),
      );

      await _local.saveSession(
        accessToken: model.accessToken,
        userId: model.user.id,
        email: model.user.email,
      );

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ErrorHandler.fromServerException(e));
    } on DioException catch (e) {
      return Left(ErrorHandler.fromDioException(e));
    } catch (e) {
      return Left(ErrorHandler.fromUnknown(e));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> getMe() async {
    if (!await _network.isConnected) return const Left(NoInternetFailure());

    try {
      final model = await _remote.getMe();
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ErrorHandler.fromServerException(e));
    } on DioException catch (e) {
      return Left(ErrorHandler.fromDioException(e));
    } catch (e) {
      return Left(ErrorHandler.fromUnknown(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _local.clearSession();
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler.fromUnknown(e));
    }
  }
}
