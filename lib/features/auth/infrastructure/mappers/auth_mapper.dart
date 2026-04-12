import 'package:mobile_app/features/auth/domain/entities/auth_token.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:mobile_app/features/auth/infrastructure/models/auth_response_model.dart';
import 'package:mobile_app/features/auth/infrastructure/models/auth_user_model.dart';

/// Mapper antara model infrastruktur dan entitas domain untuk fitur Auth.
///
/// Model → Entity  : digunakan di repository saat menerima data dari API.
/// Entity → Model  : digunakan jika perlu mengirim data balik (jarang).
///
/// Sebagian besar konversi sudah ada di method [toEntity()] tiap model,
/// mapper ini menjadi titik sentral jika logika konversi bertambah kompleks.
class AuthMapper {
  AuthMapper._();

  // ── AuthResponseModel → AuthToken ─────────────────────────────────────────

  static AuthToken tokenFromModel(AuthResponseModel model) => AuthToken(
        accessToken: model.accessToken,
        tokenType: model.tokenType,
        expiresIn: model.expiresIn,
        user: userFromModel(model.user),
      );

  // ── AuthUserModel → AuthUser ──────────────────────────────────────────────

  static AuthUser userFromModel(AuthUserModel model) => AuthUser(
        id: model.id,
        email: model.email,
        fullName: model.fullName,
      );

  // ── AuthUser → AuthUserModel ──────────────────────────────────────────────

  static AuthUserModel userToModel(AuthUser entity) => AuthUserModel(
        id: entity.id,
        email: entity.email,
        fullName: entity.fullName,
      );
}
