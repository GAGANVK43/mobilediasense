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
  // FIX C4: Was returning '/api/assessment/' — missing $id
  static String assessmentById(int id) => '/api/assessment/$id';
  static const String prediction = '/api/prediction';
  static const String predictionLatest = '/api/prediction/latest';
  static const String predictionAccuracy = '/api/prediction/accuracy';
  static const String predictionHistory = '/api/prediction/history';
  static const String dietLatest = '/api/diet/latest';
  // FIX C4: Was returning '/api/diet/' — missing $id
  static String dietByPrediction(int id) => '/api/diet/$id';
  static const String chatbotQuery = '/api/chatbot/query';
  static const String foodAnalyzeText = '/api/food/analyze-text';
  static const String foodAnalyzeImage = '/api/food/analyze-image';
  // FIX C4: Was returning '/api/reports/' — missing $id
  static String reportById(int id) => '/api/reports/$id';
  // FIX C4: Was returning '/api/reports//pdf' — double slash, missing $id
  static String reportPdf(int id) => '/api/reports/$id/pdf';
  static const String nearbyCare = '/api/nearby-care';
  static const String nearbyCareGeocode = '/api/nearby-care/geocode';
}

