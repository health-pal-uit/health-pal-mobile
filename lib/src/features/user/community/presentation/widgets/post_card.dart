import 'package:da1/src/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.timeAgo,
    required this.postText,
    this.imageUrl,
    this.hashtags = const [],
    required this.likes,
    this.isLiked = false,
    this.onMorePressed,
    this.onLikePressed,
    this.onCommentPressed,
    this.userId,
    this.onUserTap,
    this.attachType,
    this.attachMeal,
    this.attachChallenge,
    this.attachMedal,
    this.attachIngredient,
  });

  final String avatarUrl;
  final String name;
  final String timeAgo;
  final String postText;
  final String? imageUrl;
  final List<String> hashtags;
  final int likes;
  final bool isLiked;
  final VoidCallback? onMorePressed;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final String? userId;
  final VoidCallback? onUserTap;
  final String? attachType;
  final Map<String, dynamic>? attachMeal;
  final Map<String, dynamic>? attachChallenge;
  final Map<String, dynamic>? attachMedal;
  final Map<String, dynamic>? attachIngredient;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          Text(postText, style: const TextStyle(fontSize: 16, height: 1.5)),
          if (imageUrl != null) ...[const SizedBox(height: 12), _buildImage()],
          if (_hasAttachment()) ...[
            const SizedBox(height: 12),
            _buildAttachmentCard(),
          ],
          if (hashtags.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildHashtags(),
          ],
          const SizedBox(height: 12),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: onUserTap,
          child: CircleAvatar(
            radius: 23,
            backgroundImage: NetworkImage(avatarUrl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: onUserTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: Color(0xFF717182),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: onMorePressed,
          child: const Icon(Icons.more_horiz, color: Color(0xFF717182)),
        ),
      ],
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl!,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 180,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      ),
    );
  }

  Widget _buildHashtags() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children:
          hashtags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x19FA9500),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
    );
  }

  bool _hasAttachment() {
    return attachMeal != null ||
        attachChallenge != null ||
        attachMedal != null ||
        attachIngredient != null;
  }

  Widget _buildAttachmentCard() {
    if (attachMeal != null) return _buildMealCard();
    if (attachChallenge != null) return _buildChallengeCard();
    if (attachMedal != null) return _buildMedalCard();
    if (attachIngredient != null) return _buildIngredientCard();
    return const SizedBox.shrink();
  }

  Widget _buildMealCard() {
    final name = attachMeal!['name'] as String?;
    final kcal = attachMeal!['kcal_per_100gr'] as num?;
    final imageUrl = attachMeal!['image_url'] as String?;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                imageUrl != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stack) => const Icon(
                              Icons.restaurant,
                              color: AppColors.primary,
                              size: 30,
                            ),
                      ),
                    )
                    : const Icon(
                      Icons.restaurant,
                      color: AppColors.primary,
                      size: 30,
                    ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.restaurant, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Meal',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  name ?? 'Unknown Meal',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (kcal != null)
                  Text(
                    '${kcal.toInt()} kcal/100g',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard() {
    final name = attachChallenge!['name'] as String?;
    final difficulty = attachChallenge!['difficulty'] as String?;
    final imageUrl = attachChallenge!['image_url'] as String?;

    Color difficultyColor;
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        difficultyColor = Colors.green;
        break;
      case 'medium':
        difficultyColor = Colors.orange;
        break;
      case 'hard':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: difficultyColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                imageUrl != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stack) => Icon(
                              Icons.emoji_events,
                              color: difficultyColor,
                              size: 30,
                            ),
                      ),
                    )
                    : Icon(
                      Icons.emoji_events,
                      color: difficultyColor,
                      size: 30,
                    ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Challenge',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  name ?? 'Unknown Challenge',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (difficulty != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: difficultyColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      difficulty.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: difficultyColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalCard() {
    final name = attachMedal!['name'] as String?;
    final tier = attachMedal!['tier'] as String?;
    final imageUrl = attachMedal!['image_url'] as String?;

    Color tierColor;
    switch (tier?.toLowerCase()) {
      case 'bronze':
        tierColor = const Color(0xFFCD7F32);
        break;
      case 'silver':
        tierColor = const Color(0xFFC0C0C0);
        break;
      case 'gold':
        tierColor = const Color(0xFFFFD700);
        break;
      default:
        tierColor = Colors.amber;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: tierColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                imageUrl != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stack) => Icon(
                              Icons.emoji_events,
                              color: tierColor,
                              size: 30,
                            ),
                      ),
                    )
                    : Icon(Icons.emoji_events, color: tierColor, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.military_tech,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Medal',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  name ?? 'Unknown Medal',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tier != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tier.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: tierColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientCard() {
    final name = attachIngredient!['name'] as String?;
    final kcal = attachIngredient!['kcal_per_100gr'] as num?;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.set_meal, color: Colors.green, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.eco, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Ingredient',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  name ?? 'Unknown Ingredient',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (kcal != null)
                  Text(
                    '${kcal.toInt()} kcal/100g',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        GestureDetector(
          onTap: onLikePressed,
          child: _actionItem(
            isLiked ? Icons.favorite : Icons.favorite_border,
            likes.toString(),
            color: isLiked ? AppColors.primary : const Color(0xFF717182),
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: onCommentPressed,
          child: const Icon(
            Icons.chat_bubble_outline,
            color: Color(0xFF717182),
            size: 22,
          ),
        ),
        const Spacer(),
        const Icon(Icons.share_outlined, color: Color(0xFF717182), size: 22),
      ],
    );
  }

  Widget _actionItem(IconData icon, String count, {Color? color}) {
    final iconColor = color ?? const Color(0xFF717182);
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 6),
        Text(count, style: TextStyle(color: iconColor, fontSize: 16)),
      ],
    );
  }
}
