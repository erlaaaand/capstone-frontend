import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/storage/domain/repositories/storage_repository.dart';

/// Hapus file dari storage berdasarkan [fileKey].
///
/// Biasanya dipanggil saat:
/// 1. User membatalkan proses setelah upload tapi sebelum prediksi dibuat.
/// 2. User menghapus prediksi (dikaskade dari [DeletePredictionUseCase]).
///
/// ```dart
/// final result = await deleteFileUseCase(
///   DeleteFileParams(fileKey: 'predictions/userId/abc123.jpg'),
/// );
/// ```
class DeleteFileUseCase extends UseCase<void, DeleteFileParams> {
  DeleteFileUseCase(this._repository);

  final StorageRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeleteFileParams params) =>
      _repository.deleteFile(params.fileKey);
}

/// Parameter untuk [DeleteFileUseCase].
class DeleteFileParams extends Equatable {
  const DeleteFileParams({required this.fileKey});

  /// Key file asli (belum di-encode). Contoh: `predictions/userId/abc123.jpg`.
  final String fileKey;

  @override
  List<Object?> get props => [fileKey];
}
