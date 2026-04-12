import 'package:mobile_app/features/user/domain/entities/user.dart';
import 'package:mobile_app/features/user/infrastructure/models/user_response_model.dart';

/// Mapper antara model infrastruktur dan entitas domain untuk fitur User.
class UserMapper {
  UserMapper._();

  // ── UserResponseModel → User ──────────────────────────────────────────────

  static User fromModel(UserResponseModel model) => User(
        id: model.id,
        email: model.email,
        fullName: model.fullName,
        isActive: model.isActive,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );

  // ── User → UserResponseModel ──────────────────────────────────────────────

  static UserResponseModel toModel(User entity) => UserResponseModel(
        id: entity.id,
        email: entity.email,
        fullName: entity.fullName,
        isActive: entity.isActive,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}
