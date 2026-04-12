import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_app/core/error/error_handler.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/network/network_info.dart';
import 'package:mobile_app/features/ai_health/domain/entities/ai_status.dart';
import 'package:mobile_app/features/ai_health/domain/repositories/ai_health_repository.dart';
import 'package:mobile_app/features/ai_health/infrastructure/data_sources/ai_health_remote_data_source.dart';
import 'package:mobile_app/features/ai_health/infrastructure/mappers/ai_health_mapper.dart';

class AiHealthRepositoryImpl implements AiHealthRepository {
  AiHealthRepositoryImpl({
    required AiHealthRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final AiHealthRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  // ── REST ──────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, AiStatus>> getCurrentStatus() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NoInternetFailure());
    }

    try {
      final model = await _remoteDataSource.getCurrentStatus();
      return Right(AiHealthMapper.toEntity(model));
    } on ServerException catch (e) {
      return Left(ErrorHandler.fromServerException(e));
    } on DioException catch (e) {
      if (e.error is ServerException) {
        return Left(
          ErrorHandler.fromServerException(e.error! as ServerException),
        );
      }
      return Left(ErrorHandler.fromDioException(e));
    } catch (e) {
      return Left(ErrorHandler.fromUnknown(e));
    }
  }

  // ── SSE ───────────────────────────────────────────────────────────────────

  @override
  Stream<Either<Failure, AiStatus>> streamStatus() async* {
    if (!await _networkInfo.isConnected) {
      yield const Left(NoInternetFailure());
      return;
    }

    try {
      await for (final model in _remoteDataSource.streamStatus()) {
        yield Right(AiHealthMapper.toEntity(model));
      }
    } on ServerException catch (e) {
      yield Left(ErrorHandler.fromServerException(e));
    } on DioException catch (e) {
      if (e.error is ServerException) {
        yield Left(
          ErrorHandler.fromServerException(e.error! as ServerException),
        );
        return;
      }
      yield Left(ErrorHandler.fromDioException(e));
    } catch (e) {
      yield Left(ErrorHandler.fromUnknown(e));
    }
  }
}
