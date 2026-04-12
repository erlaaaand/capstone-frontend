import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/user/domain/entities/user.dart';
import 'package:mobile_app/features/user/domain/repositories/user_repository.dart';

/// PATCH /api/v1/users/:id — perbarui nama dan/atau password.
///
/// Minimal satu field harus diisi: [fullName], atau
/// kombinasi [currentPassword] + [newPassword].
class UpdateUserUseCase extends UseCase<User, UpdateUserParams> {
  UpdateUserUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Either<Failure, User>> call(UpdateUserParams params) =>
      _repository.updateUser(
        id: params.id,
        fullName: params.fullName,
        currentPassword: params.currentPassword,
        newPassword: params.newPassword,
      );
}

class UpdateUserParams extends Equatable {
  const UpdateUserParams({
    required this.id,
    this.fullName,
    this.currentPassword,
    this.newPassword,
  });

  final String id;

  /// Nama lengkap baru. Kirim null untuk tidak mengubah.
  final String? fullName;

  /// Password saat ini — wajib ada jika [newPassword] diisi.
  final String? currentPassword;

  /// Password baru. Wajib disertai [currentPassword].
  final String? newPassword;

  /// Apakah ada perubahan password yang di-request.
  bool get hasPasswordChange =>
      currentPassword != null && newPassword != null;

  @override
  List<Object?> get props => [id, fullName, currentPassword, newPassword];
}
