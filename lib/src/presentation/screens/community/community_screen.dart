import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/data/datasources/post_remote_data_source.dart';
import 'package:da1/src/data/models/post_model.dart';
import 'package:da1/src/presentation/widgets/community/post_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  PostRemoteDataSource? _postDataSource;
  final _storage = const FlutterSecureStorage();

  List<PostModel> _allPosts = [];
  bool _isLoadingMore = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDataSource();
  }

  Future<void> _initializeDataSource() async {
    final token = await _storage.read(key: 'auth_token');

    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'No authentication token found. Please login first.';
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

    // Add authorization interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {}
          return handler.next(error);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
      ),
    );

    _postDataSource = PostRemoteDataSourceImpl(dio: dio);
    await _loadPosts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadPosts() async {
    if (_postDataSource == null) {
      setState(() {
        _errorMessage = 'Data source not initialized. Please login first.';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _postDataSource!.getPosts();

      setState(() {
        _allPosts = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadPosts();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    // Simulate loading more - trong thực tế bạn có thể implement pagination
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Community',
          style: TextStyle(
            color: Color(0xFFFA9500),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFFFA9500),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFA9500)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              'Failed to load posts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPosts,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFA9500),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_allPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.post_add, color: Colors.grey[400], size: 80),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share something!',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return _buildPostList(_allPosts);
  }

  Widget _buildPostList(List<PostModel> posts) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFFFA9500),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length + 1,
        itemBuilder: (context, index) {
          if (index == posts.length) {
            return _isLoadingMore
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: Color(0xFFFA9500)),
                  ),
                )
                : _buildLoadMoreButton();
          }

          final post = posts[index];
          return PostCard(
            avatarUrl: post.user.getAvatarUrl(),
            name: post.user.getDisplayName(),
            timeAgo: post.getTimeAgo(),
            postText: post.content,
            imageUrl: null, // API không trả về imageUrl, có thể bổ sung sau
            hashtags: post.getHashtags(),
            likes: 0, // API không trả về likes, có thể bổ sung sau
            comments: 0, // API không trả về comments, có thể bổ sung sau
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Center(
      child: TextButton(
        onPressed: _loadMore,
        child: const Text(
          'Load More Posts',
          style: TextStyle(
            color: Color(0xFFFA9500),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
