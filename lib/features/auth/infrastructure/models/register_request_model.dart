/// Request body untuk `POST /auth/register`.
/// Sesuai schema `RegisterDto` dari Swagger.
class RegisterRequestModel {
  const RegisterRequestModel({
    required this.email,
    required this.password,
    this.fullName,
  });

  final String email;
  final String password;
  final String? fullName;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        if (fullName != null && fullName!.isNotEmpty) 'fullName': fullName,
      };
}
