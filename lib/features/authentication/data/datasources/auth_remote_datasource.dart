import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/auth_tokens.dart';
import '../models/user_model.dart';
import '../models/user_profile_stats.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokens> register({
    required String fullName,
    required String email,
    required String password,
    int? age,
    String? gender,
  });

  Future<AuthTokens> login({
    required String email,
    required String password,
  });

  Future<UserModel> getProfile();
  Future<UserProfileStats> getProfileWithStats();
  Future<UserModel> updateProfile({String? fullName, int? age, String? gender});
  Future<void> changePassword({required String currentPassword, required String newPassword});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<AuthTokens> register({
    required String fullName,
    required String email,
    required String password,
    int? age,
    String? gender,
  }) async {
    final response = await _client.post(
      ApiEndpoints.register,
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'age': age,
        'gender': gender,
      },
    );
    final apiRes = ApiResponse<AuthTokens>.fromJson(
      response.data,
      (json) => AuthTokens.fromJson(json as Map<String, dynamic>),
    );
    if (!apiRes.success || apiRes.data == null) {
      throw Exception(apiRes.message);
    }
    return apiRes.data!;
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    final apiRes = ApiResponse<AuthTokens>.fromJson(
      response.data,
      (json) => AuthTokens.fromJson(json as Map<String, dynamic>),
    );
    if (!apiRes.success || apiRes.data == null) {
      throw Exception(apiRes.message);
    }
    return apiRes.data!;
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await _client.get(ApiEndpoints.userMe);
    final apiRes = ApiResponse<UserModel>.fromJson(
      response.data,
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    if (!apiRes.success || apiRes.data == null) {
      throw Exception(apiRes.message);
    }
    return apiRes.data!;
  }

  @override
  Future<UserProfileStats> getProfileWithStats() async {
    final response = await _client.get(ApiEndpoints.userProfile);
    final apiRes = ApiResponse<UserProfileStats>.fromJson(
      response.data,
      (json) => UserProfileStats.fromJson(json as Map<String, dynamic>),
    );
    if (!apiRes.success || apiRes.data == null) {
      throw Exception(apiRes.message);
    }
    return apiRes.data!;
  }

  @override
  Future<UserModel> updateProfile({String? fullName, int? age, String? gender}) async {
    final response = await _client.put(
      ApiEndpoints.userProfile,
      data: {
        if (fullName != null) 'full_name': fullName,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
      },
    );
    final apiRes = ApiResponse<UserModel>.fromJson(
      response.data,
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    if (!apiRes.success || apiRes.data == null) {
      throw Exception(apiRes.message);
    }
    return apiRes.data!;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.put(
      ApiEndpoints.userChangePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }
}
