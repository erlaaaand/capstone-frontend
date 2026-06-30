import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/storage/secure_storage_service.dart';
import 'package:mobile_app/features/auth/application/auth_event.dart';
import 'package:mobile_app/features/auth/application/auth_state.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:mobile_app/features/auth/domain/use_cases/get_auth_me_use_case.dart';
import 'package:mobile_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:mobile_app/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:mobile_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_app/features/user/domain/repositories/user_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SecureStorageService secureStorage,
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required GetAuthMeUseCase getAuthMeUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _secureStorage = secureStorage,
        _login = loginUseCase,
        _register = registerUseCase,
        _getMe = getAuthMeUseCase,
        _logout = logoutUseCase,
        super(const AuthInitial()) {
    
    on<AuthCheckSessionRequested>(_onCheckSession);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    
    on<AuthSessionExpired>((event, emit) => emit(const AuthUnauthenticated()));
  }

  final SecureStorageService _secureStorage;
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

    final hasToken = await _secureStorage.hasAccessToken();

    if (hasToken) {
      final userId = await _secureStorage.getUserId();
      final email = await _secureStorage.getUserEmail();
      
      if (userId != null && email != null) {
        final user = AuthUser(id: userId, email: email);
        emit(AuthAuthenticated(user: user));
      } else {
        final result = await _getMe();
        result.fold(
          (failure) => emit(const AuthUnauthenticated()),
          (user) => emit(AuthAuthenticated(user: user)),
        );
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    if (GetIt.instance.isRegistered<UserRepository>()) {
      GetIt.instance<UserRepository>().clearCache();
    }

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

    if (GetIt.instance.isRegistered<UserRepository>()) {
      GetIt.instance<UserRepository>().clearCache();
    }
    
    await _logout();
    emit(const AuthUnauthenticated());
  }
}