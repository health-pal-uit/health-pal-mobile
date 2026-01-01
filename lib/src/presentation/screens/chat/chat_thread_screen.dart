import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/domain/entities/user_chat_message.dart';
import 'package:da1/src/domain/entities/chat_session.dart';
import 'package:da1/src/presentation/screens/chat/widgets/message_bubble.dart';
import 'package:da1/src/presentation/screens/chat/widgets/message_input.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChatThreadScreen extends StatefulWidget {
  final ChatSession session;

  const ChatThreadScreen({super.key, required this.session});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  List<UserChatMessage> messages = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      isLoading = true;
    });

    // TODO: Load messages from repository
    // final repository = AppRoutes.getChatMessageRepository();
    // final result = await repository.getMessages(widget.session.id);

    setState(() {
      isLoading = false;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get other user info (for 1-1 chat)
    final otherUser =
        widget.session.participants
            .firstWhere(
              (p) =>
                  p.user.id != 'current-user-id', // TODO: Get current user ID
              orElse: () => widget.session.participants.first,
            )
            .user;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage:
                  otherUser.avatarUrl != null
                      ? NetworkImage(otherUser.avatarUrl!)
                      : null,
              child:
                  otherUser.avatarUrl == null
                      ? Text(
                        otherUser.fullName?.substring(0, 1).toUpperCase() ??
                            'U',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.session.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  if (widget.session.isGroup)
                    Text(
                      '${widget.session.participants.length} members',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.ellipsisVertical, color: Colors.black),
            onPressed: () {
              // TODO: Show chat options (delete, mute, etc.)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                    : messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessageList(),
          ),
          MessageInput(
            sessionId: widget.session.id,
            onMessageSent: () {
              _loadMessages();
              Future.delayed(
                const Duration(milliseconds: 100),
                _scrollToBottom,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.messageCircle, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isOwnMessage =
            message.user.id == 'current-user-id'; // TODO: Get current user ID

        return MessageBubble(
          message: message,
          isOwnMessage: isOwnMessage,
          showSenderName: widget.session.isGroup && !isOwnMessage,
        );
      },
    );
  }
}
