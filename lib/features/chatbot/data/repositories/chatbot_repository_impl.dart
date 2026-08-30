import '../datasources/chatbot_remote_datasource.dart';
import '../../domain/repositories/chatbot_repository.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemoteDataSource _remoteDataSource;

  ChatbotRepositoryImpl(this._remoteDataSource);

  @override
  Future<Map<String, dynamic>> queryChatbot({
    required String message,
    Map<String, dynamic>? context,
  }) {
    return _remoteDataSource.queryChatbot(message: message, context: context);
  }
}
