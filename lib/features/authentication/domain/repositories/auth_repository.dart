import '../../data/models/auth_tokens.dart';
import '../../data/models/user_model.dart';
import '../../data/models/user_profile_stats.dart';

abstract class AuthRepository {
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
  Future<void> logout();
  Future<bool> isAuthenticated();
}
