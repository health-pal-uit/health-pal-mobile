import 'package:da1/src/config/routes.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:da1/src/domain/entities/medal.dart';

class MedalsScreen extends StatefulWidget {
  const MedalsScreen({super.key});

  @override
  State<MedalsScreen> createState() => _MedalsScreenState();
}

class _MedalsScreenState extends State<MedalsScreen> {
  List<Medal> _medals = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMedals();
  }

  Future<void> _loadMedals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AppRoutes.getMedalRepository()!.getMedals();

    result.fold(
      (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.toString();
        });
      },
      (medals) {
        setState(() {
          _medals = medals;
          _isLoading = false;
        });
      },
    );
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      default:
        return Colors.grey;
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
            if (value == 'challenges') {
              Navigator.pop(context);
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
                'Medals',
                style: AppTypography.headline.copyWith(fontSize: 20),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
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
                      'Error loading medals',
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
                      onPressed: _loadMedals,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _medals.isEmpty
              ? Center(
                child: Text(
                  'No medals available',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadMedals,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _medals.length,
                  itemBuilder: (context, index) {
                    final medal = _medals[index];
                    final tierColor = _getTierColor(medal.tier);

                    return Card(
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
                              tierColor.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Medal image
                            Stack(
                              children: [
                                if (medal.imageUrl != null)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      medal.imageUrl!,
                                      height: 160,
                                      width: 160,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return _buildPlaceholderImage(
                                          tierColor,
                                        );
                                      },
                                    ),
                                  )
                                else
                                  _buildPlaceholderImage(tierColor),

                                // Tier badge
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tierColor,
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
                                      medal.tier.toUpperCase(),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Medal name
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.emoji_events,
                                          color: tierColor,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            medal.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (medal.note != null &&
                                        medal.note!.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        medal.note!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],

                                    const SizedBox(height: 12),

                                    // Challenges info
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.flag,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${medal.challengesMedals.length} challenges',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Status
                                    if (medal.canClaim)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'CAN CLAIM',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    else if (medal.isFinished)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'COMPLETED',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[400],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'IN PROGRESS',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
