import 'dart:async';
import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/core/services/chat_service.dart';
import 'package:da1/src/data/datasources/auth_local_data_source.dart';
import 'package:flutter/material.dart';
import 'package:da1/src/domain/entities/chat_message.dart';
import 'package:da1/src/presentation/screens/advisor/widgets/chat_message_widget.dart';
import 'package:da1/src/presentation/screens/advisor/widgets/clear_chat_dialog.dart';
import 'package:da1/src/presentation/screens/advisor/widgets/empty_state_widget.dart';
import 'package:da1/src/presentation/screens/advisor/widgets/typing_indicator.dart';
import 'package:da1/src/data/datasources/chat_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdvisorScreen extends StatefulWidget {
  const AdvisorScreen({super.key});

  @override
  State<AdvisorScreen> createState() => _AdvisorScreenState();
}

class _AdvisorScreenState extends State<AdvisorScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Advisor',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ask anything, get instant advice',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_chatService.messages.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => ClearChatDialog(
                                onConfirm: () {
                                  setState(() {
                                    _chatService.clearChat();
                                  });
                                },
                              ),
                        );
                      },
                      tooltip: 'New Session',
                    ),
                ],
              ),
            ),

            Expanded(
              child:
                  _chatService.messages.isEmpty
                      ? const EmptyStateWidget()
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
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey[400]),
                    onPressed: () {},
                  ),
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
                  const SizedBox(width: 4),
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
      ),
    );
  }
}
