import 'package:equatable/equatable.dart';

/// Entity user minimal yang dikembalikan bersama JWT token.
/// Sesuai schema `AuthUserDto` dari Swagger.
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.email,
    this.fullName,
  });

  /// UUID user.
  final String id;

  /// Email terdaftar.
  final String email;

  /// Nama lengkap, null jika belum diisi.
  final String? fullName;

  @override
  List<Object?> get props => [id, email, fullName];
}
