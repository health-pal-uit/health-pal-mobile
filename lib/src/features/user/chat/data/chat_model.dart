class ChatHistoryItem {
  final String role;
  final String content;

  ChatHistoryItem({required this.role, required this.content});

  Map<String, dynamic> toJson() {
    return {'role': role, 'content': content};
  }

  factory ChatHistoryItem.fromJson(Map<String, dynamic> json) {
    return ChatHistoryItem(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }
}

class ChatRequest {
  final String message;
  final List<ChatHistoryItem> history;

  ChatRequest({required this.message, required this.history});

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'history': history.map((h) => h.toJson()).toList(),
    };
  }
}

class ChatResponse {
  final String reply;
  final List<ChatHistoryItem> history;
  final String message;
  final int statusCode;

  ChatResponse({
    required this.reply,
    required this.history,
    required this.message,
    required this.statusCode,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ChatResponse(
      reply: data['reply'] as String,
      history:
          (data['history'] as List)
              .map((h) => ChatHistoryItem.fromJson(h as Map<String, dynamic>))
              .toList(),
      message: json['message'] as String,
      statusCode: json['statusCode'] as int,
    );
  }
}
