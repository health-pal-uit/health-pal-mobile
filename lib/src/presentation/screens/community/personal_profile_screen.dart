import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/config/routes.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/data/datasources/post_remote_data_source.dart';
import 'package:da1/src/data/models/post_model.dart';
import 'package:da1/src/presentation/screens/chat/chat_thread_screen.dart';
import 'package:da1/src/presentation/widgets/community/post_card.dart';
import 'package:da1/src/presentation/widgets/community/stat_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PersonalProfileScreen extends StatefulWidget {
  final String? userId;
  final UserInfo? user;

  const PersonalProfileScreen({super.key, this.userId, this.user});

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  List<PostModel> _userPosts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _loadUserPosts();
    }
  }

  Future<void> _loadUserPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await const FlutterSecureStorage().read(key: 'auth_token');
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final dataSource = PostRemoteDataSourceImpl(dio: dio);
      final response = await dataSource.getUserPosts(widget.userId!);

      setState(() {
        _userPosts = response.data;
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _ProfileHeader(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileInfoSection(user: widget.user),
                    const SizedBox(height: 16),
                    const _ProfileBioSection(),
                    const SizedBox(height: 16),
                    _ActionButtons(userId: widget.userId, user: widget.user),
                    const SizedBox(height: 28),
                    const _HealthStatsSection(),
                    const SizedBox(height: 24),
                    const _ProfileTabs(),
                    const SizedBox(height: 16),
                    _buildPostsList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Failed to load posts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserPosts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_userPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.post_add, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No posts yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This user hasn\'t posted anything yet',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ..._userPosts.map(
          (post) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PostCard(
              avatarUrl: post.user.getAvatarUrl(),
              name: post.user.getDisplayName(),
              timeAgo: post.getTimeAgo(),
              postText: post.content,
              imageUrl: null,
              hashtags: post.getHashtags(),
              likes: post.likeCount,
              isLiked: post.isLikedByUser,
              attachType: post.attachType,
              attachMeal: post.attachMeal,
              attachChallenge: post.attachChallenge,
              attachMedal: post.attachMedal,
              attachIngredient: post.attachIngredient,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Profile', style: AppTypography.headline),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _ProfileInfoSection extends StatelessWidget {
  final UserInfo? user;

  const _ProfileInfoSection({this.user});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user?.avatarUrl;
    final displayName = user?.fullname ?? user?.username ?? 'User';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[300],
            image:
                avatarUrl != null && avatarUrl.isNotEmpty
                    ? DecorationImage(
                      image: NetworkImage(avatarUrl),
                      fit: BoxFit.cover,
                    )
                    : null,
          ),
          child:
              avatarUrl == null || avatarUrl.isEmpty
                  ? Icon(Icons.person, size: 48, color: Colors.grey[600])
                  : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName, style: AppTypography.body),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_StatItem(count: '89', label: 'Posts')],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.count, required this.label});
  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Color(0xFF0A0A0A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF717182), fontSize: 15),
        ),
      ],
    );
  }
}

class _ProfileBioSection extends StatelessWidget {
  const _ProfileBioSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fitness enthusiast 💪 | Marathon runner 🏃‍♂️ | Sharing my journey to a healthier lifestyle',
          style: TextStyle(color: Color(0xFF0A0A0A), fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF717182),
              size: 18,
            ),
            const SizedBox(width: 4),
            const Text(
              'Thu Duc, HCM City',
              style: TextStyle(color: Color(0xFF717182), fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButtons extends StatefulWidget {
  final String? userId;
  final UserInfo? user;

  const _ActionButtons({this.userId, this.user});

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {
  bool _isCreatingChat = false;

  Future<void> _createChatWithUser() async {
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User ID not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingChat = true;
    });

    final repository = AppRoutes.getChatSessionRepository();
    if (repository == null) {
      setState(() {
        _isCreatingChat = false;
      });
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

    final result = await repository.createSession(
      otherUserId: widget.userId!,
      title: widget.user?.fullname ?? widget.user?.username ?? 'Chat',
    );

    setState(() {
      _isCreatingChat = false;
    });

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
      (session) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatThreadScreen(session: session),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isCreatingChat ? null : _createChatWithUser,
            icon:
                _isCreatingChat
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0A0A0A),
                      ),
                    )
                    : const Icon(
                      Icons.mail_outline_rounded,
                      color: Color(0xFF0A0A0A),
                      size: 18,
                    ),
            label: Text(
              _isCreatingChat ? 'Opening...' : 'Message',
              style: const TextStyle(fontSize: 14, color: Color(0xFF0A0A0A)),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}

class _HealthStatsSection extends StatelessWidget {
  const _HealthStatsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Stats',
          style: TextStyle(
            color: Color(0xFF0A0A0A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.directions_run,
                title: 'Activity Level',
                value: 'Very Active',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.flag_outlined,
                title: 'Weekly Goal',
                value: '5 workouts',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.local_fire_department_outlined,
                title: 'Streak',
                value: '12 days',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileTabs extends StatefulWidget {
  const _ProfileTabs();

  @override
  State<_ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<_ProfileTabs> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _buildTab(index: 0, text: 'Posts'),
          _buildTab(index: 1, text: 'Medals'),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTab({required int index, required String text}) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF030213) : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: const Color(0xFF0A0A0A),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
