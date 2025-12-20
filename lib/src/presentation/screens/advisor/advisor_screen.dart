import 'dart:async';
import 'dart:math';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:da1/src/domain/entities/chat_message.dart';
import 'package:da1/src/presentation/screens/advisor/widgets/chat_message_widget.dart';
import 'package:da1/src/presentation/screens/advisor/widgets/empty_state_widget.dart';
import 'package:da1/src/presentation/screens/advisor/widgets/typing_indicator.dart';

class AdvisorScreen extends StatefulWidget {
  const AdvisorScreen({super.key});

  @override
  State<AdvisorScreen> createState() => _AdvisorScreenState();
}

class _AdvisorScreenState extends State<AdvisorScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<String> _aiResponses = [
    "That's a great question! Based on your situation, I'd recommend starting with small, manageable steps. Would you like me to break this down further?",
    "I understand your concern. Let me help you think through this systematically. Here are a few key points to consider...",
    "Interesting! Here's what I think: this approach could work well if you focus on consistency and patience. What specific aspect would you like to explore more?",
    "Thank you for sharing that. From an advisory perspective, I'd suggest prioritizing your goals first. Would you like some specific strategies?",
    "That makes sense. Here's my take: combining both approaches might give you the best results. Let me explain why...",
  ];

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      setState(() {});
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

  void _simulateAIResponse(String userMessage) {
    setState(() {
      _isTyping = true;
    });

    final random = Random();
    final delay = 1000 + random.nextInt(1000);

    Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;

      final randomResponse = _aiResponses[random.nextInt(_aiResponses.length)];

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: randomResponse,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
        _isTyping = false;
      });

      _scrollToBottom();
    });
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

    setState(() {
      _messages.add(userMessage);
    });

    _inputController.clear();
    _scrollToBottom();

    _simulateAIResponse(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Messages Area
            Expanded(
              child:
                  _messages.isEmpty
                      ? const EmptyStateWidget()
                      : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < _messages.length) {
                            return ChatMessageWidget(message: _messages[index]);
                          } else {
                            return const TypingIndicator();
                          }
                        },
                      ),
            ),

            // Input Area
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
                  IconButton(
                    icon: Icon(Icons.mic, color: Colors.grey[400]),
                    onPressed: () {},
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
