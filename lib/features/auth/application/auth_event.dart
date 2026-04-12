import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

/// Cek apakah ada sesi aktif saat splash screen.
final class AuthCheckSessionRequested extends AuthEvent {
  const AuthCheckSessionRequested();
  @override
  List<Object?> get props => [];
}

/// User menekan tombol login.
final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// User menekan tombol register.
final class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    this.fullName,
  });

  final String email;
  final String password;
  final String? fullName;

  @override
  List<Object?> get props => [email, password, fullName];
}

/// User menekan tombol logout.
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
  @override
  List<Object?> get props => [];
}
