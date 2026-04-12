import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/usecases/usecase.dart';
import 'package:mobile_app/features/user/domain/entities/user.dart';
import 'package:mobile_app/features/user/domain/repositories/user_repository.dart';

/// GET /api/v1/users/:id — profil user berdasarkan UUID.
class GetUserByIdUseCase extends UseCase<User, GetUserByIdParams> {
  GetUserByIdUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Either<Failure, User>> call(GetUserByIdParams params) =>
      _repository.getUserById(params.id);
}

class GetUserByIdParams extends Equatable {
  const GetUserByIdParams({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
