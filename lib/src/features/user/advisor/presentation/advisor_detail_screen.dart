import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/features/user/advisor/data/advisor_repository.dart';
import 'package:da1/src/features/user/advisor/domain/expert.dart';
import 'package:da1/src/features/user/advisor/domain/expert_rating.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AdvisorDetailScreen extends StatefulWidget {
  final Expert expert;

  const AdvisorDetailScreen({super.key, required this.expert});

  @override
  State<AdvisorDetailScreen> createState() => _AdvisorDetailScreenState();
}

class _AdvisorDetailScreenState extends State<AdvisorDetailScreen> {
  final AdvisorRepository _repository = AdvisorRepository();

  bool _isLoadingRatings = true;
  List<ExpertRating> _ratings = [];

  @override
  void initState() {
    super.initState();
    _fetchRatings();
  }

  Future<void> _fetchRatings() async {
    if (!mounted) return;
    setState(() => _isLoadingRatings = true);

    try {
      final ratingsList = await _repository.fetchExpertRatings(
        widget.expert.id,
      );

      if (!mounted) return;
      setState(() {
        _ratings = ratingsList;
        _isLoadingRatings = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingRatings = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load reviews. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // BOTTOM BOOKING BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rate',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Text(
                    '${widget.expert.tokenPerMinute} Tokens/min',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/bookings/new', extra: widget.expert);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage:
                                widget.expert.avatarUrl != null
                                    ? NetworkImage(widget.expert.avatarUrl!)
                                    : null,
                            child:
                                widget.expert.avatarUrl == null
                                    ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey[400],
                                    )
                                    : null,
                          ),
                        ),
                        if (widget.expert.isVerified)
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.expert.fullname ?? widget.expert.username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.expert.roleName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.expert.ratingAvg.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          ' (${widget.expert.ratingCount} reviews)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.expert.bio.isNotEmpty
                        ? widget.expert.bio
                        : 'No biography available.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Consultation Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildCommOption(Icons.chat_bubble_outline, 'Chat', true),
                      const SizedBox(width: 12),
                      _buildCommOption(Icons.call_outlined, 'Audio', true),
                      const SizedBox(width: 12),
                      _buildCommOption(
                        Icons.videocam_outlined,
                        'Video',
                        widget.expert.canDoVideo,
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(height: 1),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Patient Reviews',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!_isLoadingRatings && _ratings.isNotEmpty)
                        Text(
                          '${_ratings.length} Reviews',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          if (_isLoadingRatings)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_ratings.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 40.0,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reviews yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to book a session and leave a review!',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final rating = _ratings[index];
                return _buildReviewCard(rating);
              }, childCount: _ratings.length),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildReviewCard(ExpertRating rating) {
    final dateStr = DateFormat.yMMMd().format(rating.createdAt);

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage:
                    rating.clientAvatarUrl != null
                        ? NetworkImage(rating.clientAvatarUrl!)
                        : null,
                child:
                    rating.clientAvatarUrl == null
                        ? Icon(Icons.person, color: AppColors.primary, size: 20)
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.clientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.score
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              rating.comment!,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommOption(IconData icon, String label, bool isSupported) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSupported
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSupported
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : Colors.grey[200]!,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSupported ? AppColors.primary : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSupported ? AppColors.primary : Colors.grey[400],
                decoration:
                    isSupported
                        ? TextDecoration.none
                        : TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
