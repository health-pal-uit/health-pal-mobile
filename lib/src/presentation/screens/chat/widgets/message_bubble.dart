import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/domain/entities/user_chat_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final UserChatMessage message;
  final bool isOwnMessage;
  final bool showSenderName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isOwnMessage,
    this.showSenderName = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwnMessage) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage:
                  message.user.avatarUrl != null
                      ? NetworkImage(message.user.avatarUrl!)
                      : null,
              child:
                  message.user.avatarUrl == null
                      ? Text(
                        message.user.fullName?.substring(0, 1).toUpperCase() ??
                            'U',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isOwnMessage
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                if (showSenderName) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: Text(
                      message.user.fullName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isOwnMessage ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft:
                          isOwnMessage
                              ? const Radius.circular(16)
                              : const Radius.circular(4),
                      bottomRight:
                          isOwnMessage
                              ? const Radius.circular(4)
                              : const Radius.circular(16),
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
                      // Show image if media_url is present
                      if (message.mediaUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            message.mediaUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  color:
                                      isOwnMessage
                                          ? Colors.white
                                          : AppColors.primary,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 100,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.error,
                                  color:
                                      isOwnMessage
                                          ? Colors.white
                                          : Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        if (message.content.isNotEmpty)
                          const SizedBox(height: 8),
                      ],
                      if (message.content.isNotEmpty)
                        Text(
                          message.content,
                          style: TextStyle(
                            fontSize: 15,
                            color: isOwnMessage ? Colors.white : Colors.black87,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              isOwnMessage
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isOwnMessage) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat.jm().format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat.jm().format(dateTime)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }
}
