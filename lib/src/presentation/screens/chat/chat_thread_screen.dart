import 'dart:async';

import 'package:da1/src/config/routes.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/domain/entities/user_chat_message.dart';
import 'package:da1/src/domain/entities/chat_session.dart';
import 'package:da1/src/presentation/bloc/auth/auth_bloc.dart';
import 'package:da1/src/presentation/bloc/auth/auth_state.dart';
import 'package:da1/src/presentation/screens/chat/widgets/delete_chat_dialog.dart';
import 'package:da1/src/presentation/screens/chat/widgets/message_bubble.dart';
import 'package:da1/src/presentation/screens/chat/widgets/message_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool isLoadingMore = false;
  bool hasMore = true;
  int total = 0;
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // In reverse ListView, older messages are at maxScrollExtent
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 100 && !isLoadingMore && hasMore) {
      _loadOlderMessages();
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      isLoading = true;
    });

    final repository = AppRoutes.getChatMessageRepository();
    if (repository == null) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat message service not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final result = await repository.getRecentMessages(
      sessionId: widget.session.id,
      limit: 50,
    );

    result.fold(
      (error) {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (response) {
        setState(() {
          messages = response['messages'] as List<UserChatMessage>;
          total = response['total'] as int;
          hasMore = total > messages.length;
          isLoading = false;
        });
        // Scroll to bottom after messages are loaded
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
        // Start polling for new messages
        _startPolling();
      },
    );
  }

  Future<void> _loadOlderMessages() async {
    if (isLoadingMore || !hasMore) return;

    setState(() {
      isLoadingMore = true;
    });

    final repository = AppRoutes.getChatMessageRepository();
    if (repository == null) {
      setState(() {
        isLoadingMore = false;
      });
      return;
    }

    final remaining = total - messages.length;
    if (remaining <= 0) {
      setState(() {
        hasMore = false;
        isLoadingMore = false;
      });
      return;
    }

    final page = (remaining / 50).ceil();
    final result = await repository.getMessages(
      sessionId: widget.session.id,
      page: page,
      limit: 50,
    );

    result.fold(
      (error) {
        setState(() {
          isLoadingMore = false;
        });
      },
      (olderMessages) {
        setState(() {
          messages = [...olderMessages, ...messages];
          isLoadingMore = false;
          if (olderMessages.length < 50) {
            hasMore = false;
          }
        });
      },
    );
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _pollNewMessages();
    });
  }

  Future<void> _pollNewMessages() async {
    if (messages.isEmpty) return;

    final repository = AppRoutes.getChatMessageRepository();
    if (repository == null) return;

    final result = await repository.getRecentMessages(
      sessionId: widget.session.id,
      limit: 10,
    );

    result.fold(
      (error) {
        // Silently fail polling
      },
      (response) {
        final recentMessages = response['messages'] as List<UserChatMessage>;
        final newTotal = response['total'] as int;

        if (recentMessages.isEmpty) return;

        final latest = messages.last;
        final newMessages =
            recentMessages.where((m) {
              return m.createdAt.isAfter(latest.createdAt);
            }).toList();

        if (newMessages.isNotEmpty) {
          setState(() {
            messages = [...messages, ...newMessages];
            total = newTotal;
          });
          // Auto scroll to bottom for new messages
          Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
        }
      },
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // In reverse ListView, 0 is the bottom
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String? _getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.user.id;
    }
    return null;
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Delete Chat',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation();
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteChatDialog(),
    );

    if (confirmed == true) {
      _handleDeleteChat();
    }
  }

  Future<void> _handleDeleteChat() async {
    final repository = AppRoutes.getChatSessionRepository();
    if (repository == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat service not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show loading indicator
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
    );

    try {
      final result = await repository.deleteSession(widget.session.id);

      // Close loading indicator
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      result.fold(
        (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString().replaceAll('Exception: ', '')),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (_) {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _getCurrentUserId();

    // Get other user info (for 1-1 chat)
    final otherUser =
        widget.session.participants
            .firstWhere(
              (p) => p.user.id != currentUserId,
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
            onPressed: _showOptionsMenu,
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
    final currentUserId = _getCurrentUserId();

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom (which appears at top due to reverse)
        if (index == messages.length && isLoadingMore) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }

        // Reverse the index to show newest messages at bottom
        final messageIndex = messages.length - 1 - index;
        final message = messages[messageIndex];
        final isOwnMessage = message.user.id == currentUserId;

        return MessageBubble(
          message: message,
          isOwnMessage: isOwnMessage,
          showSenderName: widget.session.isGroup && !isOwnMessage,
        );
      },
    );
  }
}
