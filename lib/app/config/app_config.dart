import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'DiaSense';
  static const String appVersion = '1.0.0';
  
  // Production Live Render Backend API (Shared with Website & Supabase)
  static const String prodBaseUrl = 'https://diasense-ai-backend.onrender.com';
  
  // Local Development Fallback
  static const String devBaseUrl = 'http://192.168.1.79:8000';
  
  // Default to production cloud backend for standalone APK
  static String get defaultBaseUrl => prodBaseUrl;
  
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  
  static String activeBaseUrl = defaultBaseUrl;
}
