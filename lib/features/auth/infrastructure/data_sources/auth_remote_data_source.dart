import 'package:mobile_app/core/constants/api_endpoints.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/auth/infrastructure/models/auth_response_model.dart';
import 'package:mobile_app/features/auth/infrastructure/models/auth_user_model.dart';
import 'package:mobile_app/features/auth/infrastructure/models/login_request_model.dart';
import 'package:mobile_app/features/auth/infrastructure/models/register_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<AuthUserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: request.toJson(),
      );
      return AuthResponseModel.fromJson(response.data!);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        statusCode: 0,
        message: 'Gagal melakukan registrasi: $e',
      );
    }
  }

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      return AuthResponseModel.fromJson(response.data!);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        statusCode: 0,
        message: 'Gagal melakukan login: $e',
      );
    }
  }

  @override
  Future<AuthUserModel> getMe() async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        ApiEndpoints.authMe,
      );
      return AuthUserModel.fromJson(response.data!);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        statusCode: 0,
        message: 'Gagal mengambil data user: $e',
      );
    }
  }
}
