import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_token.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';
abstract class AuthRepository {
  Future<Either<Failure, AuthToken>> register({
    required String email,
    required String password,
    String? fullName,
  });

  Future<Either<Failure, AuthToken>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthUser>> getMe();

  Future<Either<Failure, Unit>> logout();
}
