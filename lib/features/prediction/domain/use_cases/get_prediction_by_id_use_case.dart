import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';
import 'package:mobile_app/features/prediction/domain/repositories/prediction_repository.dart';

/// Ambil detail satu prediksi berdasarkan ID.
///
/// Dipakai untuk:
/// - Polling status (di [CreatePredictionBloc])
/// - Menampilkan detail dari riwayat
class GetPredictionByIdUseCase
    extends UseCase<Prediction, GetPredictionByIdParams> {
  GetPredictionByIdUseCase(this._repository);

  final PredictionRepository _repository;

  @override
  Future<Either<Failure, Prediction>> call(
    GetPredictionByIdParams params,
  ) =>
      _repository.getPredictionById(params.id);
}

class GetPredictionByIdParams extends Equatable {
  const GetPredictionByIdParams(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
