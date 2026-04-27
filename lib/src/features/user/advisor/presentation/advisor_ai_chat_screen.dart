import 'dart:async';
import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/core/services/chat_service.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter/material.dart';
import 'package:da1/src/features/user/chat/domain/chat_message.dart';
import 'package:da1/src/features/user/advisor/presentation/widgets/chat_message_widget.dart';
import 'package:da1/src/features/user/advisor/presentation/widgets/empty_state_widget.dart';
import 'package:da1/src/features/user/advisor/presentation/widgets/typing_indicator.dart';
import 'package:da1/src/features/user/chat/data/datasources/chat_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdvisorAiChatScreen extends StatefulWidget {
  const AdvisorAiChatScreen({super.key});

  @override
  State<AdvisorAiChatScreen> createState() => _AdvisorAiChatScreenState();
}

class _AdvisorAiChatScreenState extends State<AdvisorAiChatScreen> {
  final _chatService = ChatService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late final ChatRemoteDataSource _chatDataSource;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      setState(() {});
    });

    final secureStorage = const FlutterSecureStorage();
    final localDataSource = AuthLocalDataSourceImpl(storage: secureStorage);

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await localDataSource.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    _chatDataSource = ChatRemoteDataSourceImpl(dio: dio);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatService.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Timer(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _getAIResponse(String userMessage) async {
    setState(() {
      _isTyping = true;
    });

    try {
      final response = await _chatDataSource.sendMessage(
        message: userMessage,
        history: _chatService.apiHistory,
      );

      if (!mounted) return;

      _chatService.updateApiHistory(response.history);

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response.reply,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );

      _chatService.addMessage(aiMessage);

      setState(() {
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isTyping = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get response: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    _chatService.addMessage(userMessage);
    setState(() {});

    _inputController.clear();
    _scrollToBottom();

    _getAIResponse(text);
  }

  void _newChat() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Start New Chat?'),
            content: const Text(
              'This will clear your current chat history. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _chatService.clearChat();
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Advisor',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_chatService.messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.black87),
              onPressed: _newChat,
              tooltip: 'New Chat',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _chatService.messages.isEmpty
                    ? EmptyStateWidget(
                      onSuggestionTap: (suggestion) {
                        final userMessage = ChatMessage(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          text: suggestion,
                          sender: MessageSender.user,
                          timestamp: DateTime.now(),
                        );

                        _chatService.addMessage(userMessage);
                        setState(() {});
                        _scrollToBottom();
                        _getAIResponse(suggestion);
                      },
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          _chatService.messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _chatService.messages.length) {
                          return ChatMessageWidget(
                            message: _chatService.messages[index],
                          );
                        } else {
                          return const TypingIndicator();
                        }
                      },
                    ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _inputController,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Type your question…',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        _inputController.text.trim().isEmpty
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, size: 20),
                    color: Colors.white,
                    onPressed:
                        _inputController.text.trim().isEmpty
                            ? null
                            : _handleSend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
