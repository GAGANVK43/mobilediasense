import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

class ApiInterceptor extends Interceptor {
  final SecureStorageService _storageService;

  ApiInterceptor(this._storageService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      // FIX C1: Token was fetched but never appended — root cause of all
      // "Could not validate credentials" errors across every screen.
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // FIX H3: On 401 Unauthorized, clear stored session so user is
    // redirected to login instead of being stuck in a permanent error loop.
    if (err.response?.statusCode == 401) {
      _storageService.clearSession();
    }
    return handler.next(err);
  }
}
