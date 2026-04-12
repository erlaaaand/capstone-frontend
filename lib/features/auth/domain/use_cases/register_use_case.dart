import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_token.dart';
import 'package:mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class RegisterUseCase extends UseCase<AuthToken, RegisterParams> {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthToken>> call(RegisterParams params) =>
      _repository.register(
        email: params.email,
        password: params.password,
        fullName: params.fullName,
      );
}

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.email,
    required this.password,
    this.fullName,
  });

  final String email;
  final String password;
  final String? fullName;

  @override
  List<Object?> get props => [email, password, fullName];
}
