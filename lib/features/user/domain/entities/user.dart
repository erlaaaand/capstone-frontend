import 'package:equatable/equatable.dart';

/// Entity profil user lengkap.
///
/// Berbeda dari [AuthUser] yang hanya berisi id + email,
/// entity ini memuat seluruh data profil termasuk status dan timestamp.
/// Sesuai schema `UserResponseDto` dari Swagger.
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
  });

  /// UUID user.
  final String id;

  /// Email terdaftar.
  final String email;

  /// Nama lengkap, null jika belum diisi.
  final String? fullName;

  /// Apakah akun aktif.
  final bool isActive;

  /// Tanggal pembuatan akun (ISO 8601).
  final String createdAt;

  /// Tanggal terakhir profil diperbarui (ISO 8601).
  final String updatedAt;

  /// Nama tampilan — fullName jika ada, fallback ke bagian email sebelum @.
  String get displayName =>
      fullName?.trim().isNotEmpty == true
          ? fullName!
          : email.split('@').first;

  /// Inisial untuk avatar — maks 2 huruf.
  String get initials {
    final name = fullName?.trim();
    if (name == null || name.isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : '?';
    }
    final parts = name.split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  /// Buat salinan dengan field yang diperbarui.
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    bool clearFullName = false,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        fullName: clearFullName ? null : fullName ?? this.fullName,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [id, email, fullName, isActive, createdAt, updatedAt];
}
