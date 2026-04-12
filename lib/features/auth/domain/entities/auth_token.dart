import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:equatable/equatable.dart';

/// JWT token + data user hasil dari register / login.
/// Sesuai schema `AuthResponseDto` dari Swagger.
class AuthToken extends Equatable {
  const AuthToken({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  /// JWT access token. Gunakan di header: `Authorization: Bearer <token>`.
  final String accessToken;

  /// Selalu "Bearer".
  final String tokenType;

  /// Durasi valid token. Format: `7d`, `24h`, `60m`.
  final String expiresIn;

  /// Data user yang berhasil login / register.
  final AuthUser user;

  @override
  List<Object?> get props => [accessToken, tokenType, expiresIn, user];
}
