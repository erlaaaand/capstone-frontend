import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/user/domain/entities/user.dart';
import 'package:mobile_app/features/user/domain/repositories/user_repository.dart';

/// GET /api/v1/users/me — profil user yang sedang login.
class GetMyProfileUseCase extends NoParamUseCase<User> {
  GetMyProfileUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Either<Failure, User>> call() => _repository.getMyProfile();
}
