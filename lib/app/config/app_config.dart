import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'DiaSense';
  static const String appVersion = '1.0.0';
  
  // Dynamic base URL:
  // - Web / Desktop: http://127.0.0.1:8000
  // - Physical Mobile: http://192.168.1.79:8000
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    return 'http://192.168.1.79:8000';
  }
  
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 15;
  
  static String activeBaseUrl = defaultBaseUrl;
}
