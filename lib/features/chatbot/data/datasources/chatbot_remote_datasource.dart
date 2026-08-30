import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';

abstract class ChatbotRemoteDataSource {
  Future<Map<String, dynamic>> queryChatbot({
    required String message,
    Map<String, dynamic>? context,
  });
}

class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  final DioClient _client;

  ChatbotRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> queryChatbot({
    required String message,
    Map<String, dynamic>? context,
  }) async {
    final response = await _client.post(
      ApiEndpoints.chatbotQuery,
      data: {
        'message': message,
        if (context != null) 'context': context,
      },
    );
    final apiRes = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
    if (!apiRes.success || apiRes.data == null) {
      throw Exception(apiRes.message);
    }
    return apiRes.data!;
  }
}
