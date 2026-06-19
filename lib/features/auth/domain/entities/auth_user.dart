import 'package:equatable/equatable.dart';
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.email,
    this.fullName,
  });

  final String id;

  final String email;

  final String? fullName;

  @override
  List<Object?> get props => [id, email, fullName];
}
