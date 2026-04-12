import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/ai_health/domain/entities/ai_status.dart';
import 'package:mobile_app/features/ai_health/domain/repositories/ai_health_repository.dart';

/// Stream status AI secara real-time via SSE (Server-Sent Events).
///
/// Mengembalikan `Stream<Either<Failure, AiStatus>>` yang:
/// - Emit `Right(AiStatus)` setiap server mengirim event baru.
/// - Emit `Left(Failure)` jika koneksi terputus atau timeout.
/// - Stream **tidak selesai** secara normal (long-lived connection).
///   Caller bertanggung jawab melakukan cancel via `StreamSubscription`.
///
/// Dipanggil dari [AiHealthCubit.startStatusStream].
///
/// ```dart
/// _subscription = streamAiStatusUseCase(const NoParams()).listen(
///   (either) => either.fold(
///     (failure) => handleError(failure),
///     (status)  => handleUpdate(status),
///   ),
/// );
/// ```
class StreamAiStatusUseCase extends StreamUseCase<AiStatus, NoParams> {
  StreamAiStatusUseCase(this._repository);

  final AiHealthRepository _repository;

  @override
  Stream<Either<Failure, AiStatus>> call(NoParams params) =>
      _repository.streamStatus();
}
