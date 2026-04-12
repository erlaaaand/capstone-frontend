import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_app/core/error/error_handler.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/network/network_info.dart';
import 'package:mobile_app/features/user/domain/entities/user.dart';
import 'package:mobile_app/features/user/domain/repositories/user_repository.dart';
import 'package:mobile_app/features/user/infrastructure/data_sources/user_remote_data_source.dart';
import 'package:mobile_app/features/user/infrastructure/models/update_user_request_model.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required UserRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remote = remoteDataSource,
        _network = networkInfo;

  final UserRemoteDataSource _remote;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, User>> getMyProfile() async {
    if (!await _network.isConnected) return const Left(NoInternetFailure());

    try {
      final model = await _remote.getMyProfile();
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
  Future<Either<Failure, User>> getUserById(String id) async {
    if (!await _network.isConnected) return const Left(NoInternetFailure());

    try {
      final model = await _remote.getUserById(id);
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
  Future<Either<Failure, User>> updateUser({
    required String id,
    String? fullName,
    String? currentPassword,
    String? newPassword,
  }) async {
    if (!await _network.isConnected) return const Left(NoInternetFailure());

    try {
      final model = await _remote.updateUser(
        id: id,
        request: UpdateUserRequestModel(
          fullName: fullName,
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
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
}
