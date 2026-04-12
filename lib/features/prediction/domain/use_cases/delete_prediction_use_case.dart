import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/prediction/domain/repositories/prediction_repository.dart';

/// Hapus prediksi berdasarkan ID.
///
/// Backend bertanggung jawab menghapus file storage terkait secara cascade.
class DeletePredictionUseCase extends UseCase<void, DeletePredictionParams> {
  DeletePredictionUseCase(this._repository);

  final PredictionRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeletePredictionParams params) =>
      _repository.deletePrediction(params.id);
}

class DeletePredictionParams extends Equatable {
  const DeletePredictionParams(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
