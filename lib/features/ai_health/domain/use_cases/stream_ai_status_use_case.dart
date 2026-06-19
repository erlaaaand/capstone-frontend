import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/ai_health/domain/entities/ai_status.dart';
import 'package:mobile_app/features/ai_health/domain/repositories/ai_health_repository.dart';

class StreamAiStatusUseCase extends StreamUseCase<AiStatus, NoParams> {
  StreamAiStatusUseCase(this._repository);

  final AiHealthRepository _repository;

  @override
  Stream<Either<Failure, AiStatus>> call(NoParams params) =>
      _repository.streamStatus();
}
