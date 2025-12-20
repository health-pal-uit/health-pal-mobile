import 'package:da1/src/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:da1/src/domain/entities/chat_message.dart';
import 'package:intl/intl.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFFFA9500) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isUser ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          isUser
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.person, color: Colors.grey[600], size: 18),
            ),
          ],
        ],
      ),
    );
  }
}
