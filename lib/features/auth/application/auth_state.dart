import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:equatable/equatable.dart';

sealed class AuthState extends Equatable {
  const AuthState();
}

/// State awal — belum tahu apakah ada sesi.
final class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  List<Object?> get props => [];
}

/// Sedang memeriksa sesi / melakukan request.
final class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  List<Object?> get props => [];
}

/// Login / register berhasil — user terautentikasi.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  final AuthUser user;

  @override
  List<Object?> get props => [user];
}

/// Tidak ada sesi atau sudah logout.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
  @override
  List<Object?> get props => [];
}

/// Login / register gagal.
final class AuthFailureState extends AuthState {
  const AuthFailureState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
