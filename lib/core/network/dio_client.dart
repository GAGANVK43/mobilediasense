import 'dart:io';
import 'package:dio/dio.dart';
import '../../app/config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'api_interceptor.dart';
import 'api_exception.dart';

class DioClient {
  late final Dio dio;
  final SecureStorageService storageService;

  DioClient({required this.storageService}) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.activeBaseUrl,
        connectTimeout: Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout: Duration(seconds: AppConfig.receiveTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(ApiInterceptor(storageService));
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.put(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.delete(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  ApiException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.error is SocketException ||
        (error.error != null && error.error.toString().toLowerCase().contains('socket')) ||
        (error.error != null && error.error.toString().toLowerCase().contains('failed to fetch')) ||
        (error.error != null && error.error.toString().toLowerCase().contains('networkerror'))) {
      return const NetworkException();
    }

    final response = error.response;
    if (response != null && response.data is Map) {
      final map = response.data as Map;
      var message = map['message']?.toString();
      if (message == null || message.isEmpty) {
        final detail = map['detail'];
        if (detail is List && detail.isNotEmpty) {
          message = detail.map((e) => e['msg'] ?? e.toString()).join(', ');
        } else if (detail != null) {
          message = detail.toString();
        }
      }
      final errors = map['errors'];
      return ApiException(
        message: message ?? 'An error occurred',
        statusCode: response.statusCode,
        errors: errors,
      );
    }

    return ApiException(
      message: error.message ?? 'Unknown network error',
      statusCode: response?.statusCode,
    );
  }
}
