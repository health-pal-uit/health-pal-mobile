import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:da1/src/domain/entities/challenge.dart';

class ChallengeDetailScreen extends StatelessWidget {
  final Challenge challenge;

  const ChallengeDetailScreen({super.key, required this.challenge});

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  double _calculateProgress() {
    if (challenge.progressPercent != null) {
      return (challenge.progressPercent! / 100).clamp(0.0, 1.0);
    }
    if (challenge.activityRecords.isEmpty) return 0.0;
    return challenge.activityRecords.length /
        (challenge.activityRecords.length + 5);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();
    final completedCount = challenge.activityRecords.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Challenge Details',
          style: AppTypography.headline.copyWith(fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            if (challenge.imageUrl != null)
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  challenge.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.emoji_events,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          challenge.name,
                          style: AppTypography.headline.copyWith(fontSize: 24),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(challenge.difficulty),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          challenge.difficulty.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (challenge.note != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      challenge.note!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Progress card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getDifficultyColor(
                            challenge.difficulty,
                          ).withValues(alpha: 0.1),
                          _getDifficultyColor(
                            challenge.difficulty,
                          ).withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getDifficultyColor(
                          challenge.difficulty,
                        ).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: AppTypography.headline.copyWith(
                                fontSize: 20,
                                color: _getDifficultyColor(
                                  challenge.difficulty,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getDifficultyColor(challenge.difficulty),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$completedCount activities completed',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Activities list header
                  Row(
                    children: [
                      Icon(
                        Icons.list_alt,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Activities',
                        style: AppTypography.headline.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Activities list
                  challenge.activityRecords.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No activities yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start working on this challenge!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: challenge.activityRecords.length,
                        itemBuilder: (context, index) {
                          final activityRecord =
                              challenge.activityRecords[index];
                          return _buildActivityCard(activityRecord, index);
                        },
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(dynamic activityRecord, int index) {
    String activityName = 'Activity ${index + 1}';
    String duration = '';
    String date = '';

    if (activityRecord is Map<String, dynamic>) {
      activityName = activityRecord['activity']?['name'] ?? activityName;
      if (activityRecord['duration_minutes'] != null) {
        final durationMinutes = activityRecord['duration_minutes'];
        duration = '$durationMinutes min';
      }
      if (activityRecord['created_at'] != null) {
        try {
          final dateTime = DateTime.parse(activityRecord['created_at']);
          date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
        } catch (e) {
          date = '';
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getDifficultyColor(
            challenge.difficulty,
          ).withValues(alpha: 0.2),
          child: Icon(
            Icons.check_circle,
            color: _getDifficultyColor(challenge.difficulty),
          ),
        ),
        title: Text(
          activityName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (duration.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (date.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
