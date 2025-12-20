import 'package:da1/src/domain/entities/chat_message.dart';
import 'package:da1/src/data/models/chat_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final List<ChatMessage> _messages = [];
  List<ChatHistoryItem> _apiHistory = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<ChatHistoryItem> get apiHistory => List.unmodifiable(_apiHistory);

  void addMessage(ChatMessage message) {
    _messages.add(message);
  }

  void updateApiHistory(List<ChatHistoryItem> history) {
    _apiHistory = history;
  }

  void clearChat() {
    _messages.clear();
    _apiHistory = [];
  }
}
