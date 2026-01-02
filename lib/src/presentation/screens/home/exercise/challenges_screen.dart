import 'package:da1/src/config/routes.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:da1/src/domain/entities/challenge.dart';
import 'package:da1/src/presentation/screens/home/exercise/challenge_detail_screen.dart';
import 'package:da1/src/presentation/screens/home/exercise/medals_screen.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<Challenge> _challenges = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AppRoutes.getChallengeRepository()!.getChallenges();

    result.fold(
      (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.toString();
        });
      },
      (challenges) {
        setState(() {
          _challenges = challenges;
          _isLoading = false;
        });
      },
    );
  }

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

  double _calculateProgress(Challenge challenge) {
    // Use backend progress if available, otherwise calculate
    if (challenge.progressPercent != null) {
      return (challenge.progressPercent! / 100).clamp(0.0, 1.0);
    }
    // Fallback calculation
    if (challenge.activityRecords.isEmpty) return 0.0;
    final fallback = (challenge.activityRecords.length /
            (challenge.activityRecords.length + 5))
        .clamp(0.0, 1.0);
    return fallback;
  }

  void _navigateToDetail(Challenge challenge) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeDetailScreen(challenge: challenge),
      ),
    );

    // Refresh if challenge was finished
    if (result == true) {
      _hasChanges = true;
      _loadChallenges();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: PopupMenuButton<String>(
          offset: const Offset(0, 50),
          onSelected: (String value) {
            if (value == 'medals') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MedalsScreen()),
              );
            }
          },
          itemBuilder:
              (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'challenges',
                  child: Row(
                    children: [
                      Icon(Icons.flag, size: 20),
                      SizedBox(width: 8),
                      Text('Challenges'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'medals',
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events, size: 20),
                      SizedBox(width: 8),
                      Text('Medals'),
                    ],
                  ),
                ),
              ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Challenges',
                style: AppTypography.headline.copyWith(fontSize: 20),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, _hasChanges),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading challenges',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadChallenges,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _challenges.isEmpty
              ? Center(
                child: Text(
                  'No challenges available',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadChallenges,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _challenges.length,
                  itemBuilder: (context, index) {
                    final challenge = _challenges[index];
                    final progress = _calculateProgress(challenge);
                    final difficultyColor = _getDifficultyColor(
                      challenge.difficulty,
                    );

                    return GestureDetector(
                      onTap: () => _navigateToDetail(challenge),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                difficultyColor.withValues(alpha: 0.03),
                              ],
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image or trophy icon
                              Stack(
                                children: [
                                  if (challenge.imageUrl != null)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                      ),
                                      child: Image.network(
                                        challenge.imageUrl!,
                                        height: 160,
                                        width: 160,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return _buildPlaceholderImage(
                                            difficultyColor,
                                          );
                                        },
                                      ),
                                    )
                                  else
                                    _buildPlaceholderImage(difficultyColor),

                                  // Difficulty badge
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: difficultyColor,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        challenge.difficulty.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Challenge name
                                      Text(
                                        challenge.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      if (challenge.note != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          challenge.note!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],

                                      const SizedBox(height: 12),

                                      // Progress section
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Progress',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                    Text(
                                                      '${(progress * 100).toInt()}%',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: difficultyColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: LinearProgressIndicator(
                                                    value: progress,
                                                    minHeight: 8,
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(difficultyColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Status badge
                                      if (challenge.isFinished)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.blue.shade700,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'FINISHED',
                                                style: TextStyle(
                                                  color: Colors.blue.shade700,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else if (challenge.canClaim)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.emoji_events,
                                                color: Colors.green.shade700,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'READY TO CLAIM',
                                                style: TextStyle(
                                                  color: Colors.green.shade700,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      const SizedBox(height: 12),

                                      // Stats row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle_outline,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${challenge.activityRecords.length} activities',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Tap to view',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: difficultyColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 12,
                                                color: difficultyColor,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Widget _buildPlaceholderImage(Color color) {
    return Container(
      height: 160,
      width: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Center(child: Icon(Icons.emoji_events, size: 50, color: color)),
    );
  }
}
