import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
}

/// Muat profil user yang sedang login saat halaman pertama dibuka.
final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();

  @override
  List<Object?> get props => [];
}

/// Perbarui nama lengkap user.
final class ProfileNameUpdateRequested extends ProfileEvent {
  const ProfileNameUpdateRequested({
    required this.userId,
    required this.fullName,
  });

  final String userId;
  final String fullName;

  @override
  List<Object?> get props => [userId, fullName];
}

/// Perbarui password user.
final class ProfilePasswordUpdateRequested extends ProfileEvent {
  const ProfilePasswordUpdateRequested({
    required this.userId,
    required this.currentPassword,
    required this.newPassword,
  });

  final String userId;
  final String currentPassword;
  final String newPassword;

  @override
  List<Object?> get props => [userId, currentPassword, newPassword];
}
