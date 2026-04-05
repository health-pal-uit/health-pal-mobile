import 'package:da1/src/config/routes.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreNotifications();
      }
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _hasMoreData = true;
    });

    final repository = AppRoutes.getNotificationRepository();
    if (repository == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Repository not initialized';
      });
      return;
    }

    final result = await repository.getNotifications(
      page: _currentPage,
      limit: _limit,
    );

    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
        (data) {
          final notifications =
              (data['data'] as List).cast<Map<String, dynamic>>();
          final total = data['total'] as int;

          setState(() {
            _isLoading = false;
            _notifications.clear();
            _notifications.addAll(notifications);
            _hasMoreData = _notifications.length < total;
          });
        },
      );
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    final repository = AppRoutes.getNotificationRepository();
    if (repository == null) {
      setState(() => _isLoadingMore = false);
      return;
    }

    final nextPage = _currentPage + 1;
    final result = await repository.getNotifications(
      page: nextPage,
      limit: _limit,
    );

    if (mounted) {
      result.fold(
        (failure) {
          setState(() => _isLoadingMore = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load more: ${failure.message}')),
          );
        },
        (data) {
          final notifications =
              (data['data'] as List).cast<Map<String, dynamic>>();
          final total = data['total'] as int;

          setState(() {
            _isLoadingMore = false;
            _currentPage = nextPage;
            _notifications.addAll(notifications);
            _hasMoreData = _notifications.length < total;
          });
        },
      );
    }
  }

  Future<void> _markAsRead(String id) async {
    final repository = AppRoutes.getNotificationRepository();
    if (repository == null) return;

    final result = await repository.markAsRead(id);

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to mark as read: ${failure.message}'),
            ),
          );
        }
      },
      (_) {
        setState(() {
          final index = _notifications.indexWhere((n) => n['id'] == id);
          if (index != -1) {
            _notifications[index]['is_read'] = true;
          }
        });
      },
    );
  }

  Future<void> _markAllAsRead() async {
    final repository = AppRoutes.getNotificationRepository();
    if (repository == null) return;

    final result = await repository.markAllAsRead();

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to mark all as read: ${failure.message}'),
            ),
          );
        }
      },
      (_) {
        setState(() {
          for (int i = 0; i < _notifications.length; i++) {
            _notifications[i]['is_read'] = true;
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All notifications marked as read')),
          );
        }
      },
    );
  }

  Future<void> _deleteNotification(String id) async {
    final repository = AppRoutes.getNotificationRepository();
    if (repository == null) return;

    final result = await repository.deleteNotification(id);

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to delete notification: ${failure.message}',
              ),
            ),
          );
        }
      },
      (_) {
        setState(() {
          _notifications.removeWhere((n) => n['id'] == id);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        _notifications.where((n) => n['is_read'] == false).length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: AppTypography.headline.copyWith(fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: AppTypography.body.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage!,
                style: AppTypography.body.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _notifications.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 1),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: AppTypography.headline.copyWith(
              fontSize: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final id = notification['id'] as String;
    final title = notification['title'] ?? '';
    final content = notification['content'] ?? '';
    final isRead = notification['is_read'] ?? false;
    final createdAt = DateTime.parse(notification['created_at']);

    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: () {
          if (!isRead) {
            _markAsRead(id);
          }
          // TODO: Navigate to relevant screen based on notification type
        },
        child: Container(
          color:
              isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.05),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(title),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.headline.copyWith(
                              fontSize: 15,
                              fontWeight:
                                  isRead ? FontWeight.w500 : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: AppTypography.body.copyWith(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(createdAt),
                      style: AppTypography.body.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(String title) {
    IconData icon;
    Color color;

    // Determine icon and color based on title/content
    if (title.contains('approved') || title.contains('✅')) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (title.contains('Lunch') ||
        title.contains('🍽️') ||
        title.contains('meal')) {
      icon = Icons.restaurant;
      color = Colors.orange;
    } else if (title.contains('workout') || title.contains('exercise')) {
      icon = Icons.fitness_center;
      color = AppColors.primary;
    } else if (title.contains('achievement') || title.contains('progress')) {
      icon = Icons.emoji_events;
      color = Colors.amber;
    } else {
      icon = Icons.notifications_active;
      color = Colors.blue;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}
