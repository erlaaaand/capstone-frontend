import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/ai_health/domain/entities/ai_status.dart';
import 'package:mobile_app/features/ai_health/domain/repositories/ai_health_repository.dart';

/// Ambil snapshot status AI satu kali via REST.
///
/// Dipanggil saat:
/// - Halaman scan pertama kali dibuka.
/// - User menekan "Coba lagi" pada [AiStatusBanner].
/// - App kembali dari background (resume).
///
/// ```dart
/// final result = await getCurrentAiStatusUseCase(const NoParams());
/// result.fold(
///   (failure) => ...,
///   (status) => print(status.isOnline),
/// );
/// ```
class GetCurrentAiStatusUseCase extends NoParamUseCase<AiStatus> {
  GetCurrentAiStatusUseCase(this._repository);

  final AiHealthRepository _repository;

  @override
  Future<Either<Failure, AiStatus>> call() => _repository.getCurrentStatus();
}
