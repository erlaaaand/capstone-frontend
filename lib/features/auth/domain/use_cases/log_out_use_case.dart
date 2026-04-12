import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/auth/domain/repositories/auth_repository.dart';

/// Hapus token lokal. Tidak ada endpoint server untuk logout.
class LogoutUseCase extends NoParamUseCase<Unit> {
  LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call() => _repository.logout();
}
