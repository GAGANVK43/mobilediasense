import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/chatbot_remote_datasource.dart';
import '../../data/repositories/chatbot_repository_impl.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../../data/models/chat_message_model.dart';

final chatbotRepositoryProvider = Provider<ChatbotRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  final remote = ChatbotRemoteDataSourceImpl(dio);
  return ChatbotRepositoryImpl(remote);
});

class ChatbotState {
  final List<ChatMessageModel> messages;
  final bool isTyping;
  final String? error;

  const ChatbotState({
    this.messages = const [],
    this.isTyping = false,
    this.error,
  });

  ChatbotState copyWith({
    List<ChatMessageModel>? messages,
    bool? isTyping,
    String? error,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      error: error,
    );
  }
}

class ChatbotNotifier extends StateNotifier<ChatbotState> {
  final ChatbotRepository _repository;

  ChatbotNotifier(this._repository)
      : super(
          ChatbotState(
            messages: [
              ChatMessageModel(
                id: 'welcome',
                text: 'Hello! I am DiaSense AI Assistant 👋. You can ask me about diabetes risk, glycemic nutrition, meal choices, or interpreting your assessment results.',
                sender: MessageSender.ai,
                timestamp: DateTime.now(),
              ),
            ],
          ),
        );

  Future<void> sendMessage(String text, {Map<String, dynamic>? contextData}) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
      error: null,
    );

    try {
      final res = await _repository.queryChatbot(
        message: text.trim(),
        context: contextData,
      );

      final reply = res['reply']?.toString() ??
          res['response']?.toString() ??
          'I am here to assist with your diabetes and dietary questions.';

      final aiMsg = ChatMessageModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: reply,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isTyping: false,
      );
    } catch (e) {
      final errorMsg = ChatMessageModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: 'Unable to reach DiaSense AI server. Please try again.',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        isError: true,
      );

      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isTyping: false,
        error: e.toString(),
      );
    }
  }

  void clearChat() {
    state = ChatbotState(
      messages: [
        ChatMessageModel(
          id: 'welcome_reset',
          text: 'Chat history cleared. How can I help you today?',
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }
}

final chatbotProvider = StateNotifierProvider<ChatbotNotifier, ChatbotState>((ref) {
  final repo = ref.watch(chatbotRepositoryProvider);
  return ChatbotNotifier(repo);
});
