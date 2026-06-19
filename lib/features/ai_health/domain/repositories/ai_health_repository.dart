import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/ai_health/domain/entities/ai_status.dart';

abstract class AiHealthRepository {
  Future<Either<Failure, AiStatus>> getCurrentStatus();
  Stream<Either<Failure, AiStatus>> streamStatus();
}
