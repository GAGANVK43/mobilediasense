import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _preferences;

  SecureStorageService({
    FlutterSecureStorage? secureStorage,
    required SharedPreferences preferences,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        ),
        _preferences = preferences;

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> saveUserMeta({
    required int userId,
    required String email,
    required String name,
  }) async {
    await _preferences.setInt(AppConstants.userIdKey, userId);
    await _preferences.setString(AppConstants.userEmailKey, email);
    await _preferences.setString(AppConstants.userNameKey, name);
  }

  int? getUserId() => _preferences.getInt(AppConstants.userIdKey);
  String? getUserEmail() => _preferences.getString(AppConstants.userEmailKey);
  String? getUserName() => _preferences.getString(AppConstants.userNameKey);

  Future<void> setHasSeenOnboarding(bool seen) async {
    await _preferences.setBool(AppConstants.hasSeenOnboardingKey, seen);
  }

  bool getHasSeenOnboarding() {
    return _preferences.getBool(AppConstants.hasSeenOnboardingKey) ?? false;
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    await _preferences.remove(AppConstants.userIdKey);
    await _preferences.remove(AppConstants.userEmailKey);
    await _preferences.remove(AppConstants.userNameKey);
  }
}
