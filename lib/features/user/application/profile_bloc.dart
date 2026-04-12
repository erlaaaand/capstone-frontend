import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/user/application/profile_event.dart';
import 'package:mobile_app/features/user/application/profile_state.dart';
import 'package:mobile_app/features/user/domain/entities/user.dart';
import 'package:mobile_app/features/user/domain/use_cases/get_my_profile_use_case.dart';
import 'package:mobile_app/features/user/domain/use_cases/update_user_use_case.dart';

/// BLoC yang mengelola state halaman profil.
///
/// Events:
/// - [ProfileLoadRequested]           → load data profil dari API
/// - [ProfileNameUpdateRequested]     → update nama lengkap
/// - [ProfilePasswordUpdateRequested] → update password
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetMyProfileUseCase getMyProfileUseCase,
    required UpdateUserUseCase updateUserUseCase,
  })  : _getMyProfile = getMyProfileUseCase,
        _updateUser = updateUserUseCase,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileNameUpdateRequested>(_onUpdateName);
    on<ProfilePasswordUpdateRequested>(_onUpdatePassword);
  }

  final GetMyProfileUseCase _getMyProfile;
  final UpdateUserUseCase _updateUser;

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Ambil [User] dari state saat ini jika tersedia.
  User? get _currentUser => switch (state) {
        ProfileLoaded(user: final u) => u,
        ProfileUpdating(user: final u) => u,
        ProfileUpdateSuccess(user: final u) => u,
        ProfileFailure(user: final u) => u,
        _ => null,
      };

  // ── Handlers ────────────────────────────────────────────────────────────────

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await _getMyProfile();
    result.fold(
      (failure) => emit(ProfileFailure(failure: failure)),
      (user)    => emit(ProfileLoaded(user: user)),
    );
  }

  Future<void> _onUpdateName(
    ProfileNameUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = _currentUser;
    if (current == null) return;

    emit(ProfileUpdating(user: current));

    final result = await _updateUser(
      UpdateUserParams(
        id: event.userId,
        fullName: event.fullName.trim().isEmpty ? null : event.fullName.trim(),
      ),
    );

    result.fold(
      (failure) => emit(ProfileFailure(failure: failure, user: current)),
      (updated) => emit(
        ProfileUpdateSuccess(user: updated, message: 'Nama berhasil diperbarui'),
      ),
    );
  }

  Future<void> _onUpdatePassword(
    ProfilePasswordUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = _currentUser;
    if (current == null) return;

    emit(ProfileUpdating(user: current));

    final result = await _updateUser(
      UpdateUserParams(
        id: event.userId,
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      ),
    );

    result.fold(
      (failure) => emit(ProfileFailure(failure: failure, user: current)),
      (updated) => emit(
        ProfileUpdateSuccess(user: updated, message: 'Password berhasil diperbarui'),
      ),
    );
  }
}