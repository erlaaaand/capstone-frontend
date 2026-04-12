/// Request body untuk `POST /auth/login`.
/// Sesuai schema `LoginDto` dari Swagger.
class LoginRequestModel {
  const LoginRequestModel({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
