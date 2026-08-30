import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/user_profile_stats.dart';

// Storage Provider
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  throw UnimplementedError('Initialize via ProviderScope overrides');
});

// Dio Client Provider
final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storageService: storage);
});

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  final storage = ref.watch(secureStorageProvider);
  final remote = AuthRemoteDataSourceImpl(dio);
  return AuthRepositoryImpl(remote, storage);
});

// Auth State Enum
enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final UserProfileStats? profileStats;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.profileStats,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    UserProfileStats? profileStats,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      profileStats: profileStats ?? this.profileStats,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SecureStorageService _storage;

  AuthNotifier(this._repository, this._storage) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final isAuth = await _repository.isAuthenticated();
    if (isAuth) {
      final cachedEmail = _storage.getUserEmail();
      final cachedName = _storage.getUserName();
      final cachedId = _storage.getUserId();
      // Restore authenticated session immediately from local storage
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: UserModel(
          id: cachedId ?? 0,
          fullName: cachedName ?? 'User',
          email: cachedEmail ?? '',
        ),
      );

      // Silently refresh profile in background
      try {
        final profile = await _repository.getProfile();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: profile,
        );
      } catch (e) {
        // Network / cold-start error: keep user authenticated with cached credentials
        if (e is ApiException && e.statusCode == 401) {
          await _repository.logout();
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final tokens = await _repository.login(email: email, password: password);
      final user = UserModel(
        id: tokens.userId,
        fullName: tokens.fullName,
        email: tokens.email,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.userFriendlyMessage,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    int? age,
    String? gender,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final tokens = await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
        age: age,
        gender: gender,
      );
      final user = UserModel(
        id: tokens.userId,
        fullName: tokens.fullName,
        email: tokens.email,
        age: age,
        gender: gender,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.userFriendlyMessage,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> loadProfileStats() async {
    try {
      final stats = await _repository.getProfileWithStats();
      state = state.copyWith(profileStats: stats, user: stats.user);
    } catch (_) {}
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(repo, storage);
});
