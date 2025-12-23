import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/data/datasources/post_remote_data_source.dart';
import 'package:da1/src/data/models/comment_model.dart';
import 'package:da1/src/data/models/post_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CommentsBottomSheet extends StatefulWidget {
  final PostModel post;

  const CommentsBottomSheet({super.key, required this.post});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();

  static void show(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(post: post),
    );
  }
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final _commentController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  PostRemoteDataSource? _postDataSource;

  List<CommentModel> _comments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadComments();
  }

  Future<void> _initializeAndLoadComments() async {
    final token = await _storage.read(key: 'auth_token');

    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'No authentication token found';
        _isLoading = false;
      });
      return;
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
      ),
    );

    _postDataSource = PostRemoteDataSourceImpl(dio: dio);
    await _loadComments();
  }

  Future<void> _loadComments() async {
    if (_postDataSource == null) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _postDataSource!.getComments(widget.post.id);

      setState(() {
        _comments = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder:
          (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildCommentsList(scrollController)),
                _buildCommentInput(),
              ],
            ),
          ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Text(
            'Comments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(ScrollController scrollController) {
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
            Icon(Icons.error_outline, color: Colors.grey[400], size: 48),
            const SizedBox(height: 12),
            Text(
              'Failed to load comments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!.replaceAll('Exception: ', ''),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadComments,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, color: Colors.grey[400], size: 64),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to comment!',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comment = _comments[index];
        return _buildCommentItem(
          comment.user.getAvatarUrl(),
          comment.user.getDisplayName(),
          comment.content,
          comment.getTimeAgo(),
        );
      },
    );
  }

  Widget _buildCommentItem(
    String avatarUrl,
    String username,
    String comment,
    String timeAgo,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(avatarUrl),
            backgroundColor: Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.primary),
              onPressed: _sendComment,
            ),
          ],
        ),
      ),
    );
  }

  void _sendComment() {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    // TODO: Implement send comment API

    _commentController.clear();
  }
}
