import 'package:equatable/equatable.dart';

enum MessageSender { user, ai, system }

class ChatMessageModel extends Equatable {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isError;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isError = false,
  });

  @override
  List<Object?> get props => [id, text, sender, timestamp, isError];
}
