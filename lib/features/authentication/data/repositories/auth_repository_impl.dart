import '../../../../core/storage/secure_storage_service.dart';
import '../models/auth_tokens.dart';
import '../models/user_model.dart';
import '../models/user_profile_stats.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _storageService;

  AuthRepositoryImpl(this._remoteDataSource, this._storageService);

  @override
  Future<AuthTokens> register({
    required String fullName,
    required String email,
    required String password,
    int? age,
    String? gender,
  }) async {
    final tokens = await _remoteDataSource.register(
      fullName: fullName,
      email: email,
      password: password,
      age: age,
      gender: gender,
    );
    await _storageService.saveAccessToken(tokens.accessToken);
    await _storageService.saveRefreshToken(tokens.refreshToken);
    await _storageService.saveUserMeta(
      userId: tokens.userId,
      email: tokens.email,
      name: tokens.fullName,
    );
    return tokens;
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final tokens = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    await _storageService.saveAccessToken(tokens.accessToken);
    await _storageService.saveRefreshToken(tokens.refreshToken);
    await _storageService.saveUserMeta(
      userId: tokens.userId,
      email: tokens.email,
      name: tokens.fullName,
    );
    return tokens;
  }

  @override
  Future<UserModel> getProfile() => _remoteDataSource.getProfile();

  @override
  Future<UserProfileStats> getProfileWithStats() => _remoteDataSource.getProfileWithStats();

  @override
  Future<UserModel> updateProfile({String? fullName, int? age, String? gender}) {
    return _remoteDataSource.updateProfile(fullName: fullName, age: age, gender: gender);
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) {
    return _remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> logout() async {
    await _storageService.clearSession();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
