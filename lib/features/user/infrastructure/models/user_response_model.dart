import 'package:mobile_app/features/user/domain/entities/user.dart';

/// DTO untuk response body `GET /users/me` dan `GET /users/:id`.
/// Sesuai schema `UserResponseDto` dari Swagger.
class UserResponseModel {
  const UserResponseModel({
    required this.id,
    required this.email,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) =>
      UserResponseModel(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['fullName'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );

  final String id;
  final String email;
  final String? fullName;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        if (fullName != null) 'fullName': fullName,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  User toEntity() => User(
        id: id,
        email: email,
        fullName: fullName,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
