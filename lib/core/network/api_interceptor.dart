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
      options.headers['Authorization'] = 'Bearer ';
    }
    options.headers['Accept'] = 'application/json';
    return handler.next(options);
  }
}
