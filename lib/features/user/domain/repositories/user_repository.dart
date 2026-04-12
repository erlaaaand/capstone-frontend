import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/user/domain/entities/user.dart';

/// Kontrak repository untuk domain User.
///
/// Implementasi ada di [UserRepositoryImpl] (infrastructure layer).
abstract class UserRepository {
  /// Ambil profil user yang sedang login.
  ///
  /// GET /api/v1/users/me
  /// - Sukses (200): [User] lengkap
  /// - Gagal (401):  [UnauthorizedFailure]
  Future<Either<Failure, User>> getMyProfile();

  /// Ambil profil user berdasarkan UUID.
  ///
  /// GET /api/v1/users/:id
  /// - Sukses (200): [User] lengkap
  /// - Gagal (401):  [UnauthorizedFailure]
  /// - Gagal (403):  [ForbiddenFailure]
  /// - Gagal (404):  [UserNotFoundFailure]
  Future<Either<Failure, User>> getUserById(String id);

  /// Perbarui profil user (nama dan/atau password).
  ///
  /// PATCH /api/v1/users/:id
  /// - Sukses (200): [User] yang sudah diperbarui
  /// - Gagal (400):  [ValidationFailure]
  /// - Gagal (401):  [UnauthorizedFailure]
  /// - Gagal (403):  [ForbiddenFailure]
  /// - Gagal (404):  [UserNotFoundFailure]
  Future<Either<Failure, User>> updateUser({
    required String id,
    String? fullName,
    String? currentPassword,
    String? newPassword,
  });
}
