import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';

abstract class PredictionRepository {
  Future<Either<Failure, Prediction>> createPrediction({
    required File imageFile, 
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  });

  Future<Either<Failure, Prediction>> getPredictionById(String id);
  Future<Either<Failure, PaginatedPredictions>> getPredictions({int page = 1, int limit = 10});
  Future<Either<Failure, void>> deletePrediction(String id);
}