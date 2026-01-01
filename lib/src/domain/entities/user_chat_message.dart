import 'package:da1/src/domain/entities/user.dart';

enum MessageType { text, image, file }

class UserChatMessage {
  final String id;
  final String content;
  final MessageType messageType;
  final String? mediaUrl;
  final DateTime createdAt;
  final User user;
  final String chatSessionId;

  const UserChatMessage({
    required this.id,
    required this.content,
    required this.messageType,
    this.mediaUrl,
    required this.createdAt,
    required this.user,
    required this.chatSessionId,
  });

  factory UserChatMessage.fromJson(Map<String, dynamic> json) {
    return UserChatMessage(
      id: json['id'] as String,
      content: json['content'] as String? ?? '',
      messageType: _messageTypeFromString(json['message_type'] as String?),
      mediaUrl: json['media_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      chatSessionId: json['chat_session_id'] as String,
    );
  }

  static MessageType _messageTypeFromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }
}
