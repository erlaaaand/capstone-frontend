import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_app/core/error/error_handler.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';
import 'package:mobile_app/features/prediction/domain/repositories/prediction_repository.dart';
import 'package:mobile_app/features/prediction/infrastructure/data_sources/prediction_remote_data_source.dart';
import 'package:mobile_app/features/prediction/infrastructure/mappers/prediction_mapper.dart';
import 'package:mobile_app/features/prediction/infrastructure/models/create_prediction_request_model.dart';

/// Implementasi konkret [PredictionRepository].
///
/// Setiap method:
/// 1. Memanggil data source
/// 2. Map model → entity (sukses)
/// 3. Konversi exception → Failure (gagal)
class PredictionRepositoryImpl implements PredictionRepository {
  PredictionRepositoryImpl(this._dataSource);

  final PredictionRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, ({String imageUrl, String fileKey})>> uploadImage(
    File image, {
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final result = await _dataSource.uploadImage(
        image,
        onProgress: onProgress,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ErrorHandler.fromUnknown(e));
    }
  }

  @override
  Future<Either<Failure, Prediction>> createPrediction({
    required String imageUrl,
    required String fileKey,
  }) async {
    try {
      final model = await _dataSource.createPrediction(
        CreatePredictionRequestModel(imageUrl: imageUrl),
      );
      return Right(PredictionMapper.fromModel(model));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ErrorHandler.fromUnknown(e));
    }
  }

  @override
  Future<Either<Failure, Prediction>> getPredictionById(String id) async {
    try {
      final model = await _dataSource.getPredictionById(id);
      return Right(PredictionMapper.fromModel(model));
    } on DioException catch (e) {
      return Left(_handleDioException(e, is404: const PredictionNotFoundFailure()));
    } catch (e) {
      return Left(ErrorHandler.fromUnknown(e));
    }
  }

  @override
  Future<Either<Failure, PaginatedPredictions>> getPredictions({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final model = await _dataSource.getPredictions(page: page, limit: limit);
      return Right(PredictionMapper.fromPaginatedModel(model));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ErrorHandler.fromUnknown(e));
    }
  }

  @override
  Future<Either<Failure, void>> deletePrediction(String id) async {
    try {
      await _dataSource.deletePrediction(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioException(e, is404: const PredictionNotFoundFailure()));
    } catch (e) {
      return Left(ErrorHandler.fromUnknown(e));
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Handle DioException — unwrap ServerException dari error interceptor.
  ///
  /// [is404] override failure untuk status 404 (agar tidak pakai UserNotFoundFailure).
  Failure _handleDioException(DioException e, {Failure? is404}) {
    final error = e.error;
    if (error is ServerException) {
      if (is404 != null && error.statusCode == 404) return is404;
      return ErrorHandler.fromServerException(error);
    }
    return ErrorHandler.fromDioException(e);
  }
}