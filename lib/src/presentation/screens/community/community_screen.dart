import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/presentation/widgets/community/post_card.dart';
import 'package:flutter/material.dart';

final List<Map<String, dynamic>> mockPosts = [
  {
    "avatarUrl": "https://i.pravatar.cc/150?img=1",
    "name": "Sarah Johnson",
    "timeAgo": "2h ago",
    "postText":
        "Just completed my 30-day yoga challenge! Feeling more flexible and centered than ever.",
    "imageUrl": "assets/images/welcome1.jpeg",
    "hashtags": ["#Yoga", "#Fitness", "#Wellness"],
    "likes": 234,
    "comments": 42,
    "showFollowButton": true,
  },
  {
    "avatarUrl": "https://i.pravatar.cc/150?img=2",
    "name": "Mike Chen",
    "timeAgo": "5h ago",
    "postText":
        "Meal prep Sunday! High protein, balanced macros, and delicious.",
    "imageUrl": "https://placehold.co/600x400/green/white?text=Meal+Prep",
    "hashtags": ["#Nutrition", "#MealPrep"],
    "likes": 189,
    "comments": 28,
    "showFollowButton": false,
  },
  {
    "avatarUrl": "https://i.pravatar.cc/150?img=3",
    "name": "Emma Rodriguez",
    "timeAgo": "8h ago",
    "postText":
        "New PR: 10K under 50 mins! Progress isn't linear — keep showing up!",
    "imageUrl": null,
    "hashtags": ["#Running", "#Cardio", "#Milestone"],
    "likes": 312,
    "comments": 56,
    "showFollowButton": true,
  },
];

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _allPosts = mockPosts;
  final List<Map<String, dynamic>> _followingPosts =
      mockPosts.where((p) => p['showFollowButton'] == false).toList();
  final List<Map<String, dynamic>> _trendingPosts = mockPosts.reversed.toList();

  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoadingMore = false;
      final newPost = {
        "avatarUrl": "https://i.pravatar.cc/150?img=${mockPosts.length + 1}",
        "name": "New User ${mockPosts.length + 1}",
        "timeAgo": "just now",
        "postText": "This is a new post loaded dynamically!",
        "imageUrl": null,
        "hashtags": ["#New", "#Dynamic"],
        "likes": 0,
        "comments": 0,
        "showFollowButton": true,
      };
      _allPosts.add(newPost);
      _trendingPosts.insert(0, newPost);
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildTabBar(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostList(_allPosts),
          _buildPostList(_followingPosts),
          _buildPostList(_trendingPosts),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: const Color(0xFF0A0A0A),
        indicator: const BoxDecoration(),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Following'),
          Tab(text: 'Trending'),
        ],
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        onTap: (index) => setState(() {}),
      ),
    );
  }

  Widget _buildPostList(List<Map<String, dynamic>> posts) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length + 1,
        itemBuilder: (context, index) {
          if (index == posts.length) {
            return _isLoadingMore
                ? const Center(child: CircularProgressIndicator())
                : _buildLoadMoreButton();
          }

          final post = posts[index];
          return PostCard(
            avatarUrl: post['avatarUrl'],
            name: post['name'],
            timeAgo: post['timeAgo'],
            postText: post['postText'],
            imageUrl: post['imageUrl'],
            hashtags: post['hashtags'],
            likes: post['likes'],
            comments: post['comments'],
            showFollowButton: post['showFollowButton'],
            onFollow: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Following ${post['name']}')),
              );
            },
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
