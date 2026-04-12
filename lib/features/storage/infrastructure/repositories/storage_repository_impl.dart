import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_app/core/error/error_handler.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/network/network_info.dart';
import 'package:mobile_app/features/storage/domain/entities/uploaded_file.dart';
import 'package:mobile_app/features/storage/domain/repositories/storage_repository.dart';
import 'package:mobile_app/features/storage/infrastructure/data_sources/storage_remote_data_source.dart';
import 'package:mobile_app/features/storage/infrastructure/mappers/storage_mapper.dart';

class StorageRepositoryImpl implements StorageRepository {
  StorageRepositoryImpl({
    required StorageRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final StorageRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, UploadedFile>> uploadImage(
    File file, {
    void Function(double progress)? onProgress,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NoInternetFailure());
    }

    try {
      final model = await _remoteDataSource.uploadImage(
        file,
        onProgress: onProgress,
      );
      return Right(StorageMapper.toEntity(model));
    } on ServerException catch (e) {
      return Left(ErrorHandler.fromServerException(e));
    } on DioException catch (e) {
      // ErrorInterceptor mungkin membungkus ServerException di dalam error field
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

  @override
  Future<Either<Failure, void>> deleteFile(String fileKey) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NoInternetFailure());
    }

    try {
      await _remoteDataSource.deleteFile(fileKey);
      return const Right(null);
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
}