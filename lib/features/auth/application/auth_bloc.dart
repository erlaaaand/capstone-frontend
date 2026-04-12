import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/auth/application/auth_event.dart';
import 'package:mobile_app/features/auth/application/auth_state.dart';
import 'package:mobile_app/features/auth/domain/use_cases/get_auth_me_use_case.dart';
import 'package:mobile_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:mobile_app/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:mobile_app/features/auth/domain/use_cases/register_use_case.dart';

/// BLoC yang mengelola state autentikasi aplikasi.
///
/// Events yang diterima:
/// - [AuthCheckSessionRequested] → cek sesi aktif (splash)
/// - [AuthLoginRequested]        → proses login
/// - [AuthRegisterRequested]     → proses register
/// - [AuthLogoutRequested]       → hapus sesi lokal
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required GetAuthMeUseCase getAuthMeUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _login = loginUseCase,
        _register = registerUseCase,
        _getMe = getAuthMeUseCase,
        _logout = logoutUseCase,
        super(const AuthInitial()) {
    on<AuthCheckSessionRequested>(_onCheckSession);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
  }

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final GetAuthMeUseCase _getMe;
  final LogoutUseCase _logout;

  // ── Handlers ────────────────────────────────────────────────────────────────

  Future<void> _onCheckSession(
    AuthCheckSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _getMe();
    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user)    => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _login(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthFailureState(failure: failure)),
      (token)   => emit(AuthAuthenticated(user: token.user)),
    );
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _register(
      RegisterParams(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailureState(failure: failure)),
      (token)   => emit(AuthAuthenticated(user: token.user)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _logout();
    result.fold(
      (failure) => emit(AuthFailureState(failure: failure)),
      (_)        => emit(const AuthUnauthenticated()),
    );
  }
}
