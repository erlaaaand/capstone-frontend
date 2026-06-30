// features/prediction/domain/use_cases/create_prediction_use_case.dart
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';
import 'package:mobile_app/features/prediction/domain/repositories/prediction_repository.dart';

class CreatePredictionUseCase
    extends UseCase<Prediction, CreatePredictionParams> {
  CreatePredictionUseCase(this._repository);

  final PredictionRepository _repository;

  @override
  Future<Either<Failure, Prediction>> call(
    CreatePredictionParams params,
  ) async {
    return await _repository.createPrediction(
      imageFile: params.imageFile,
      onProgress: params.onUploadProgress,
      cancelToken: params.cancelToken,
    );
  }
}

class CreatePredictionParams extends Equatable {
  const CreatePredictionParams({
    required this.imageFile,
    this.onUploadProgress,
    this.cancelToken,
  });

  final File imageFile;

  final void Function(int sent, int total)? onUploadProgress;

  final CancelToken? cancelToken;

  @override
  List<Object?> get props => [imageFile.path];
}