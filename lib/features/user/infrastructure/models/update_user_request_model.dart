/// Request body untuk `PATCH /users/:id`.
/// Sesuai schema `UpdateUserDto` dari Swagger.
///
/// Semua field opsional — minimal satu harus diisi.
class UpdateUserRequestModel {
  const UpdateUserRequestModel({
    this.fullName,
    this.currentPassword,
    this.newPassword,
  });

  /// Nama lengkap baru. Null = tidak diubah.
  final String? fullName;

  /// Password saat ini — wajib jika [newPassword] diisi.
  final String? currentPassword;

  /// Password baru — wajib disertai [currentPassword].
  final String? newPassword;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null) map['fullName'] = fullName;
    if (currentPassword != null) map['currentPassword'] = currentPassword;
    if (newPassword != null) map['newPassword'] = newPassword;
    return map;
  }
}