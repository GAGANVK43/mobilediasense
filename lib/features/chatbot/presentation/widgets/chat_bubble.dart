import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : (message.isError ? AppColors.riskHighBg : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppSpacing.radiusLg),
                  topRight: const Radius.circular(AppSpacing.radiusLg),
                  bottomLeft: Radius.circular(isUser ? AppSpacing.radiusLg : 2),
                  bottomRight: Radius.circular(isUser ? 2 : AppSpacing.radiusLg),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: message.isError
                            ? AppColors.riskHigh.withOpacity(0.3)
                            : AppColors.borderLight,
                      ),
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isUser
                          ? Colors.white
                          : (message.isError ? AppColors.riskHigh : AppColors.textPrimaryLight),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatDateTime(message.timestamp).split(',').last.trim(),
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser ? Colors.white70 : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 16, color: Color(0xFF475569)),
            ),
          ],
        ],
      ),
    );
  }
}
