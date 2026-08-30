class ApiEndpoints {
  static const String health = '/health';
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String authProfile = '/api/auth/profile';
  static const String userMe = '/api/user/me';
  static const String userProfile = '/api/user/profile';
  static const String userChangePassword = '/api/user/change-password';
  static const String dashboard = '/api/dashboard';
  static const String assessment = '/api/assessment';
  static const String assessmentHistory = '/api/assessment/history';
  static String assessmentById(int id) => '/api/assessment/';
  static const String prediction = '/api/prediction';
  static const String predictionLatest = '/api/prediction/latest';
  static const String predictionAccuracy = '/api/prediction/accuracy';
  static const String predictionHistory = '/api/prediction/history';
  static const String dietLatest = '/api/diet/latest';
  static String dietByPrediction(int id) => '/api/diet/';
  static const String chatbotQuery = '/api/chatbot/query';
  static const String foodAnalyzeText = '/api/food/analyze-text';
  static const String foodAnalyzeImage = '/api/food/analyze-image';
  static String reportById(int id) => '/api/reports/';
  static String reportPdf(int id) => '/api/reports//pdf';
  static const String nearbyCare = '/api/nearby-care';
  static const String nearbyCareGeocode = '/api/nearby-care/geocode';
}
