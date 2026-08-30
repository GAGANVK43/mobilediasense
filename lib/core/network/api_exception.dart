import '../../app/config/app_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => message.isNotEmpty ? message : 'An error occurred ($statusCode)';

  String get userFriendlyMessage {
    if (statusCode == 0) {
      return 'Unable to connect to server. Please ensure backend is running at ${AppConfig.activeBaseUrl} and phone is on the same Wi-Fi.';
    }
    if (message.isNotEmpty && message != 'An error occurred') {
      return message;
    }
    if (statusCode == 401) return 'Invalid email or password.';
    if (statusCode == 403) return 'Access denied.';
    if (statusCode == 404) return 'The requested health record was not found.';
    if (statusCode == 422) return 'Please check the entered clinical parameters.';
    if (statusCode != null && statusCode! >= 500) {
      return 'DiaSense server is temporarily unavailable. Please try again.';
    }
    return message;
  }
}

class NetworkException extends ApiException {
  const NetworkException({String message = 'Unable to connect to server. Please check internet connection.'})
      : super(message: message, statusCode: 0);
}
