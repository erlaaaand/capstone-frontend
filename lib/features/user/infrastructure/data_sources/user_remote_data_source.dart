import 'package:mobile_app/core/constants/api_endpoints.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/user/infrastructure/models/update_user_request_model.dart';
import 'package:mobile_app/features/user/infrastructure/models/user_response_model.dart';

abstract class UserRemoteDataSource {
  Future<UserResponseModel> getMyProfile();
  Future<UserResponseModel> getUserById(String id);
  Future<UserResponseModel> updateUser({
    required String id,
    required UpdateUserRequestModel request,
  });
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<UserResponseModel> getMyProfile() async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        ApiEndpoints.usersMe,
      );
      return UserResponseModel.fromJson(response.data!);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        statusCode: 0,
        message: 'Gagal mengambil profil: $e',
      );
    }
  }

  @override
  Future<UserResponseModel> getUserById(String id) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        ApiEndpoints.userById(id),
      );
      return UserResponseModel.fromJson(response.data!);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        statusCode: 0,
        message: 'Gagal mengambil data user: $e',
      );
    }
  }

  @override
  Future<UserResponseModel> updateUser({
    required String id,
    required UpdateUserRequestModel request,
  }) async {
    try {
      final response = await _client.patch<Map<String, dynamic>>(
        ApiEndpoints.userById(id),
        data: request.toJson(),
      );
      return UserResponseModel.fromJson(response.data!);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        statusCode: 0,
        message: 'Gagal memperbarui profil: $e',
      );
    }
  }
}
