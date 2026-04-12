import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/user/domain/entities/user.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();
}

/// State awal sebelum data dimuat.
final class ProfileInitial extends ProfileState {
  const ProfileInitial();

  @override
  List<Object?> get props => [];
}

/// Sedang memuat profil pertama kali (full loading screen).
final class ProfileLoading extends ProfileState {
  const ProfileLoading();

  @override
  List<Object?> get props => [];
}

/// Profil berhasil dimuat — data tersedia.
final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

/// Sedang menyimpan perubahan (nama/password).
/// Membawa [user] agar UI bisa tetap menampilkan data saat update berjalan.
final class ProfileUpdating extends ProfileState {
  const ProfileUpdating({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

/// Perubahan berhasil disimpan.
final class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess({
    required this.user,
    required this.message,
  });

  final User user;

  /// Pesan sukses untuk ditampilkan via snackbar.
  final String message;

  @override
  List<Object?> get props => [user, message];
}

/// Terjadi kegagalan — bisa saat load maupun update.
final class ProfileFailure extends ProfileState {
  const ProfileFailure({
    required this.failure,
    this.user,
  });

  final Failure failure;

  /// Data user terakhir (jika tersedia) agar UI tidak kosong saat error update.
  final User? user;

  @override
  List<Object?> get props => [failure, user];
}