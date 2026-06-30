import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/user/domain/entities/user.dart';
abstract class UserRepository {
  Future<Either<Failure, User>> getMyProfile();
  Future<Either<Failure, User>> getUserById(String id);

  Future<Either<Failure, User>> updateUser({
    required String id,
    String? fullName,
    String? currentPassword,
    String? newPassword,
  });
  void clearCache();
}
