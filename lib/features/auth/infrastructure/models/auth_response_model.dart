import 'package:mobile_app/features/auth/domain/entities/auth_token.dart';
import 'package:mobile_app/features/auth/infrastructure/models/auth_user_model.dart';

/// DTO untuk response body `POST /auth/register` dan `POST /auth/login`.
/// Sesuai schema `AuthResponseDto` dari Swagger.
class AuthResponseModel {
  const AuthResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        accessToken: json['accessToken'] as String,
        tokenType: json['tokenType'] as String,
        expiresIn: json['expiresIn'] as String,
        user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
      );

  final String accessToken;
  final String tokenType;
  final String expiresIn;
  final AuthUserModel user;

  AuthToken toEntity() => AuthToken(
        accessToken: accessToken,
        tokenType: tokenType,
        expiresIn: expiresIn,
        user: user.toEntity(),
      );
}
