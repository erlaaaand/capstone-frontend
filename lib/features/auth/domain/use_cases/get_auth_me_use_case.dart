import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:mobile_app/features/auth/domain/repositories/auth_repository.dart';

/// GET /api/v1/auth/me — info user dari JWT aktif.
class GetAuthMeUseCase extends NoParamUseCase<AuthUser> {
  GetAuthMeUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthUser>> call() => _repository.getMe();
}
