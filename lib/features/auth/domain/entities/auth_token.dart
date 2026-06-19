import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  const AuthToken({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  final String accessToken;

  final String tokenType;

  final String expiresIn;

  final AuthUser user;

  @override
  List<Object?> get props => [accessToken, tokenType, expiresIn, user];
}
