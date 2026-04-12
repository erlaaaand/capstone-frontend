import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_token.dart';
import 'package:mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class LoginUseCase extends UseCase<AuthToken, LoginParams> {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthToken>> call(LoginParams params) =>
      _repository.login(
        email: params.email,
        password: params.password,
      );
}

class LoginParams extends Equatable {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
