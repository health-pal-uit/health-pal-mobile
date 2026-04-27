import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_local_data_source.dart';
import 'package:da1/src/features/user/advisor/presentation/advisor_ai_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdvisorScreen extends StatefulWidget {
  const AdvisorScreen({super.key});

  @override
  State<AdvisorScreen> createState() => _AdvisorScreenState();
}

// Expert Model
class Expert {
  final String id;
  final String bio;
  final int tokenPerMinute;
  final String licenseId;
  final String? licenseUrl;
  final bool isVerified;
  final double ratingAvg;
  final int ratingCount;
  final String userId;
  final String username;
  final String? fullname;
  final String? avatarUrl;
  final String roleName;
  final bool canDoVideo;

  Expert({
    required this.id,
    required this.bio,
    required this.tokenPerMinute,
    required this.licenseId,
    this.licenseUrl,
    required this.isVerified,
    required this.ratingAvg,
    required this.ratingCount,
    required this.userId,
    required this.username,
    this.fullname,
    this.avatarUrl,
    required this.roleName,
    required this.canDoVideo,
  });

  factory Expert.fromJson(Map<String, dynamic> json) {
    return Expert(
      id: json['id'] ?? '',
      bio: json['bio'] ?? '',
      tokenPerMinute: json['token_per_minute'] ?? 0,
      licenseId: json['license_id'] ?? '',
      licenseUrl: json['license_url'],
      isVerified: json['is_verified'] ?? false,
      ratingAvg: (json['rating_avg'] ?? 0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
      userId: json['user']?['id'] ?? '',
      username: json['user']?['username'] ?? '',
      fullname: json['user']?['fullname'],
      avatarUrl: json['user']?['avatar_url'],
      roleName: json['expert_role']?['name'] ?? '',
      canDoVideo: json['expert_role']?['can_do_video'] ?? false,
    );
  }
}

class _AdvisorScreenState extends State<AdvisorScreen> {
  late final Dio _dio;
  List<Expert> _experts = [];
  bool _loadingExperts = false;

  @override
  void initState() {
    super.initState();

    final secureStorage = const FlutterSecureStorage();
    final localDataSource = AuthLocalDataSourceImpl(storage: secureStorage);

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExperts();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadExperts() async {
    if (!mounted) return;
    setState(() => _loadingExperts = true);

    try {
      final response = await _dio.get('/experts');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] is List) {
          final expertsList =
              (data['data'] as List)
                  .map((e) => Expert.fromJson(e as Map<String, dynamic>))
                  .toList();

          setState(() {
            _experts = expertsList;
            _loadingExperts = false;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingExperts = false);
      debugPrint('Error loading experts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find Expert Advisors',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect with health professionals',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Experts List
            Expanded(
              child:
                  _loadingExperts
                      ? const Center(child: CircularProgressIndicator())
                      : _experts.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Experts Available',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back soon',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _experts.length,
                        itemBuilder: (context, index) {
                          final expert = _experts[index];
                          return _buildExpertCard(expert);
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdvisorAiChatScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.smart_toy),
        label: const Text('AI Chat'),
        tooltip: 'Ask AI Advisor',
      ),
    );
  }

  Widget _buildExpertCard(Expert expert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Section - Avatar and Quick Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with Verified Badge
                Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border:
                            expert.isVerified
                                ? Border.all(color: Colors.green, width: 2)
                                : null,
                      ),
                      child:
                          expert.avatarUrl != null
                              ? ClipOval(
                                child: Image.network(
                                  expert.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Icon(
                                        Icons.person,
                                        color: AppColors.primary,
                                        size: 36,
                                      ),
                                ),
                              )
                              : Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 36,
                              ),
                    ),
                    if (expert.isVerified)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Name, Role and Rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expert.fullname ?? expert.username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          expert.roleName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$expert.ratingAvg.toStringAsFixed(1)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            ' (${expert.ratingCount})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          // Bio Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  expert.bio,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          // Fee and Action
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consultation Rate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1),
                            AppColors.primary.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${expert.tokenPerMinute} Tokens/min',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (expert.canDoVideo)
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Booking call with ${expert.fullname ?? expert.username}...',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.videocam, size: 18),
                    label: const Text(
                      'Book Call',
                      style: TextStyle(fontWeight: FontWeight.w600),
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
