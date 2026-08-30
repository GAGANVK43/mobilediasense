abstract class ChatbotRepository {
  Future<Map<String, dynamic>> queryChatbot({
    required String message,
    Map<String, dynamic>? context,
  });
}
