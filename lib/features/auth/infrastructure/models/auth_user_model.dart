import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';

/// DTO untuk field `user` di dalam `AuthResponseDto`.
/// Sesuai schema `AuthUserDto` dari Swagger.
class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.email,
    this.fullName,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['fullName'] as String?,
      );

  final String id;
  final String email;
  final String? fullName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        if (fullName != null) 'fullName': fullName,
      };

  AuthUser toEntity() => AuthUser(
        id: id,
        email: email,
        fullName: fullName,
      );
}
