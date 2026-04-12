import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:equatable/equatable.dart';

/// Base class untuk semua use case yang async.
///
/// [Type] = tipe return sukses.
/// [Params] = parameter input.
///
/// ```dart
/// class LoginUseCase extends UseCase<AuthToken, LoginParams> {
///   @override
///   Future<Either<Failure, AuthToken>> call(LoginParams params) async { ... }
/// }
/// ```
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base class untuk use case yang tidak butuh parameter.
abstract class NoParamUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Base class untuk use case yang mengembalikan Stream.
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// Parameter kosong — digunakan oleh [UseCase] yang tidak butuh input.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
