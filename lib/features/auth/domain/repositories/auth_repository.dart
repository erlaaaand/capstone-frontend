import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_token.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';

/// Kontrak repository untuk domain Auth.
///
/// Implementasi ada di [AuthRepositoryImpl] (infrastructure layer).
/// Domain layer HANYA mengenal interface ini — tidak tahu Dio atau model JSON.
abstract class AuthRepository {
  /// Register akun baru.
  ///
  /// POST /api/v1/auth/register
  /// - Sukses (201): [AuthToken] berisi JWT + data user
  /// - Gagal (400):  [ValidationFailure]
  /// - Gagal (409):  [EmailAlreadyUsedFailure]
  /// - Gagal (429):  [RateLimitFailure]
  Future<Either<Failure, AuthToken>> register({
    required String email,
    required String password,
    String? fullName,
  });

  /// Login dengan email dan password.
  ///
  /// POST /api/v1/auth/login
  /// - Sukses (200): [AuthToken]
  /// - Gagal (401):  [InvalidCredentialsFailure]
  /// - Gagal (429):  [RateLimitFailure]
  Future<Either<Failure, AuthToken>> login({
    required String email,
    required String password,
  });

  /// Ambil data user dari JWT token yang aktif.
  ///
  /// GET /api/v1/auth/me
  /// - Sukses (200): [AuthUser] (hanya id + email)
  /// - Gagal (401):  [UnauthorizedFailure]
  Future<Either<Failure, AuthUser>> getMe();

  /// Hapus token lokal (logout — tidak ada endpoint server).
  Future<Either<Failure, Unit>> logout();
}
