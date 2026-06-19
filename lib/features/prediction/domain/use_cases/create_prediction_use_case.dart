import 'dart:io';

import 'package:dartz/dartz.dart';
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
    final uploadResult = await _repository.uploadImage(
      params.imageFile,
      onProgress: params.onUploadProgress,
    );

    return uploadResult.fold(
      Left.new,
      (uploaded) => _repository.createPrediction(
        imageUrl: uploaded.imageUrl,
        fileKey: uploaded.fileKey,
      ),
    );
  }
}

class CreatePredictionParams extends Equatable {
  const CreatePredictionParams({
    required this.imageFile,
    this.onUploadProgress,
  });

  final File imageFile;

  final void Function(int sent, int total)? onUploadProgress;

  @override
  List<Object?> get props => [imageFile.path];
}
