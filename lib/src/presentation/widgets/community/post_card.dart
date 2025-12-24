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
