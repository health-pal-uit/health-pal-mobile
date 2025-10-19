import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.timeAgo,
    required this.postText,
    required this.imageUrl,
    required this.likes,
    required this.comments,
  });

  final String avatarUrl;
  final String name;
  final String timeAgo;
  final String postText;
  final String imageUrl;
  final String likes;
  final String comments;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 12),
              Column(
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
              const Spacer(),
              const Icon(Icons.more_horiz),
            ],
          ),
          const SizedBox(height: 12),
          Text(postText, style: const TextStyle(fontSize: 16, height: 1.4)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _postActionButton(icon: Icons.favorite_border, text: likes),
              const SizedBox(width: 16),
              _postActionButton(
                icon: Icons.chat_bubble_outline,
                text: comments,
              ),
              const Spacer(),
              const Icon(Icons.share_outlined, color: Color(0xFF717182)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _postActionButton({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF717182), size: 22),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF717182), fontSize: 16),
        ),
      ],
    );
  }
}
