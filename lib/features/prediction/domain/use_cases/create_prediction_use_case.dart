import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';
import 'package:mobile_app/features/prediction/domain/repositories/prediction_repository.dart';

/// Upload gambar ke storage dan buat record prediksi PENDING.
///
/// Alur:
/// 1. Upload [CreatePredictionParams.imageFile] → dapat `imageUrl` & `fileKey`.
/// 2. POST `/predictions` dengan data tersebut.
/// 3. Return [Prediction] dengan status PENDING.
///
/// Polling dilakukan secara terpisah di [CreatePredictionBloc].
class CreatePredictionUseCase
    extends UseCase<Prediction, CreatePredictionParams> {
  CreatePredictionUseCase(this._repository);

  final PredictionRepository _repository;

  @override
  Future<Either<Failure, Prediction>> call(
    CreatePredictionParams params,
  ) async {
    // Step 1: Upload image
    final uploadResult = await _repository.uploadImage(
      params.imageFile,
      onProgress: params.onUploadProgress,
    );

    // Step 2: Create prediction record if upload succeeded
    return uploadResult.fold(
      Left.new,
      (uploaded) => _repository.createPrediction(
        imageUrl: uploaded.imageUrl,
        fileKey: uploaded.fileKey,
      ),
    );
  }
}

/// Parameter untuk [CreatePredictionUseCase].
class CreatePredictionParams extends Equatable {
  const CreatePredictionParams({
    required this.imageFile,
    this.onUploadProgress,
  });

  /// File gambar yang akan diupload. Harus sudah divalidasi oleh [FileUtils].
  final File imageFile;

  /// Callback progress upload (opsional) — untuk progress bar di UI.
  ///
  /// Tidak dimasukkan ke [props] karena function tidak bisa di-compare.
  final void Function(int sent, int total)? onUploadProgress;

  @override
  List<Object?> get props => [imageFile.path];
}
