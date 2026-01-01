import 'package:da1/src/domain/entities/user.dart';

class ChatParticipant {
  final String id;
  final bool isAdmin;
  final DateTime joinedAt;
  final User user;

  const ChatParticipant({
    required this.id,
    required this.isAdmin,
    required this.joinedAt,
    required this.user,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'] as String,
      isAdmin: json['is_admin'] as bool? ?? false,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
