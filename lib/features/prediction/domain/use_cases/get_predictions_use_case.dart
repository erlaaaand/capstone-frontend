import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/prediction/domain/entities/prediction.dart';
import 'package:mobile_app/features/prediction/domain/repositories/prediction_repository.dart';

/// Ambil list prediksi milik user dengan pagination.
///
/// Dipakai di [PredictionListBloc] untuk halaman riwayat.
class GetPredictionsUseCase
    extends UseCase<PaginatedPredictions, GetPredictionsParams> {
  GetPredictionsUseCase(this._repository);

  final PredictionRepository _repository;

  @override
  Future<Either<Failure, PaginatedPredictions>> call(
    GetPredictionsParams params,
  ) =>
      _repository.getPredictions(
        page: params.page,
        limit: params.limit,
      );
}

class GetPredictionsParams extends Equatable {
  const GetPredictionsParams({
    this.page = 1,
    this.limit = AppConstants.defaultPageSize,
  });

  final int page;
  final int limit;

  @override
  List<Object?> get props => [page, limit];
}
