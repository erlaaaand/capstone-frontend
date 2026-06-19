import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/ai_health/domain/entities/ai_status.dart';
import 'package:mobile_app/features/ai_health/domain/repositories/ai_health_repository.dart';

class GetCurrentAiStatusUseCase extends NoParamUseCase<AiStatus> {
  GetCurrentAiStatusUseCase(this._repository);

  final AiHealthRepository _repository;

  @override
  Future<Either<Failure, AiStatus>> call() => _repository.getCurrentStatus();
}
