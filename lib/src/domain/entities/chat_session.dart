import 'package:da1/src/domain/entities/chat_participant.dart';

class ChatSession {
  final String id;
  final String title;
  final bool isGroup;
  final String status; // 'chat' or 'consult'
  final List<ChatParticipant> participants;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatSession({
    required this.id,
    required this.title,
    required this.isGroup,
    required this.status,
    required this.participants,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      title: json['title'] as String,
      isGroup: json['is_group'] as bool? ?? false,
      status: json['status'] as String? ?? 'chat',
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((p) => ChatParticipant.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
