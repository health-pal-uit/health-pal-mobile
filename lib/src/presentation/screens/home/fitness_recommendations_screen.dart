import 'package:da1/src/config/routes.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FitnessRecommendationsScreen extends StatefulWidget {
  const FitnessRecommendationsScreen({super.key});

  @override
  State<FitnessRecommendationsScreen> createState() =>
      _FitnessRecommendationsScreenState();
}

class _FitnessRecommendationsScreenState
    extends State<FitnessRecommendationsScreen> {
  bool _isLoading = true;
  bool _isApplying = false;
  String? _errorMessage;
  Map<String, dynamic>? _recommendations;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repository = AppRoutes.getFitnessGoalRepository();
    if (repository == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Repository not available';
      });
      return;
    }

    final result = await repository.getRecommendations();

    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
        (data) {
          setState(() {
            _isLoading = false;
            _recommendations = data['data'] as Map<String, dynamic>?;
          });
        },
      );
    }
  }

  Future<void> _applyRecommendations() async {
    if (_recommendations == null) return;

    setState(() {
      _isApplying = true;
    });

    final repository = AppRoutes.getFitnessGoalRepository();
    if (repository == null) {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Repository not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final updateData = {
      'goal_type': _recommendations!['goal_type'],
      'target_kcal': _recommendations!['target_kcal'],
      'target_protein_gr': _recommendations!['target_protein_gr'],
      'target_fat_gr': _recommendations!['target_fat_gr'],
      'target_carbs_gr': _recommendations!['target_carbs_gr'],
      'target_fiber_gr': _recommendations!['target_fiber_gr'],
    };

    final result = await repository.updateFitnessGoal(updateData);

    if (mounted) {
      setState(() {
        _isApplying = false;
      });

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to apply: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recommendations applied successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        },
      );
    }
  }

  String _getGoalTypeLabel(String goalType) {
    switch (goalType.toLowerCase()) {
      case 'lose':
        return 'Lose Weight';
      case 'gain':
        return 'Gain Weight';
      case 'maintain':
        return 'Maintain Weight';
      default:
        return goalType;
    }
  }

  IconData _getGoalTypeIcon(String goalType) {
    switch (goalType.toLowerCase()) {
      case 'lose':
        return LucideIcons.trendingDown;
      case 'gain':
        return LucideIcons.trendingUp;
      case 'maintain':
        return LucideIcons.minus;
      default:
        return LucideIcons.target;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        centerTitle: true,
        title: Text(
          'Fitness Recommendations',
          style: AppTypography.headline.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.circleAlert,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: AppTypography.body.copyWith(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadRecommendations,
                          icon: const Icon(LucideIcons.refreshCw),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildRecommendationsContent(),
    );
  }

  Widget _buildRecommendationsContent() {
    if (_recommendations == null) {
      return const Center(
        child: Text('No recommendations available'),
      );
    }

    final goalType = _recommendations!['goal_type'] as String? ?? 'maintain';
    final targetKcal = _recommendations!['target_kcal'] ?? 0;
    final targetProtein = _recommendations!['target_protein_gr'] ?? 0;
    final targetFat = _recommendations!['target_fat_gr'] ?? 0;
    final targetCarbs = _recommendations!['target_carbs_gr'] ?? 0;
    final targetFiber = _recommendations!['target_fiber_gr'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.pink.shade300,
                  Colors.blue.shade200,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.sparkles,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Personalized goals based on your fitness profile',
                    style: AppTypography.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Goal Type Card
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getGoalTypeIcon(goalType),
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommended Goal',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getGoalTypeLabel(goalType),
                          style: AppTypography.headline.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Calorie Goal Card
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Calorie Target',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${targetKcal.round()}',
                      style: AppTypography.headline.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'kcal',
                        style: AppTypography.body.copyWith(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Macros Title
          Text(
            'Macronutrients',
            style: AppTypography.headline.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Macros Grid
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMacroRow(
                  'Protein',
                  targetProtein,
                  'g',
                  Colors.red.shade400,
                  LucideIcons.beef,
                ),
                const Divider(height: 24),
                _buildMacroRow(
                  'Fat',
                  targetFat,
                  'g',
                  Colors.orange.shade400,
                  LucideIcons.droplet,
                ),
                const Divider(height: 24),
                _buildMacroRow(
                  'Carbs',
                  targetCarbs,
                  'g',
                  Colors.blue.shade400,
                  LucideIcons.wheat,
                ),
                const Divider(height: 24),
                _buildMacroRow(
                  'Fiber',
                  targetFiber,
                  'g',
                  Colors.green.shade400,
                  LucideIcons.apple,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isApplying ? null : _applyRecommendations,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isApplying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.check,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Apply Recommendations',
                          style: AppTypography.headline.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMacroRow(
    String label,
    dynamic value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.headline.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '${value.round()} $unit',
          style: AppTypography.headline.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
