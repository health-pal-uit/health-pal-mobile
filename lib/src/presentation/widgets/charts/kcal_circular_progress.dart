import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';

class KcalCircularProgressCard extends StatelessWidget {
  final int consumed;
  final int needed;
  final int exercise;
  final double? protein;
  final double? fat;
  final double? carbs;
  final double? fiber;
  final int? proteinGoal;
  final int? fatGoal;
  final int? carbsGoal;
  final int? fiberGoal;
  final String? goalType;
  final String? dietTypeName;
  final VoidCallback? onDietTypePressed;

  const KcalCircularProgressCard({
    super.key,
    required this.consumed,
    required this.needed,
    required this.exercise,
    this.protein,
    this.fat,
    this.carbs,
    this.fiber,
    this.proteinGoal,
    this.fatGoal,
    this.carbsGoal,
    this.fiberGoal,
    this.goalType,
    this.dietTypeName,
    this.onDietTypePressed,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = needed - consumed;
    final carbsCurrent = carbs?.round() ?? 0;
    final carbsGoalValue = carbsGoal ?? 301;
    final proteinCurrent = protein?.round() ?? 0;
    final proteinGoalValue = proteinGoal ?? 138;
    final fatCurrent = fat?.round() ?? 0;
    final fatGoalValue = fatGoal ?? 72;
    final fiberCurrent = fiber?.round() ?? 0;
    final fiberGoalValue = fiberGoal ?? 32;
    final dietTypeDisplay = dietTypeName ?? 'Balanced';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.backgroundLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calories & Nutrition',
            style: AppTypography.headline.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background circle
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 12,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey[300]!,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value:
                                  needed > 0
                                      ? (consumed / needed).clamp(0.0, 1.0)
                                      : 0.0,
                              strokeWidth: 12,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.orange,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Consumed',
                                style: AppTypography.body.copyWith(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$consumed',
                                style: AppTypography.headline.copyWith(
                                  fontSize: 28,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
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
              const SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildStatRow(
                      Icons.bolt,
                      'Required',
                      needed.toString(),
                      AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      Icons.restaurant,
                      'Remaining',
                      remaining.toString(),
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      Icons.local_fire_department,
                      'Burned',
                      exercise.toString(),
                      Colors.pink,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: Colors.grey[700], height: 1),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildMacroProgress(
                  '🌾 Carbs',
                  carbsCurrent,
                  carbsGoalValue,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroProgress(
                  '🍖 Proteins',
                  proteinCurrent,
                  proteinGoalValue,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMacroProgress(
                  '🥑 Fats',
                  fatCurrent,
                  fatGoalValue,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroProgress(
                  '🥬 Fiber',
                  fiberCurrent,
                  fiberGoalValue,
                  Colors.greenAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Center(
            child: GestureDetector(
              onTap: onDietTypePressed,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text.rich(
                      TextSpan(
                        text: 'Current diet type: ',
                        style: AppTypography.body.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: dietTypeDisplay,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.body.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.headline.copyWith(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroProgress(String label, int current, int goal, Color color) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.body.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$current/${goal}g',
              style: AppTypography.body.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // String _getGoalTypeDisplay(String? goalType) {
  //   if (goalType == null) return 'Balanced';
  //   switch (goalType) {
  //     case 'cut':
  //       return 'Cut';
  //     case 'bulk':
  //       return 'Bulk';
  //     case 'maintain':
  //       return 'Maintain';
  //     case 'recovery':
  //       return 'Recovery';
  //     case 'gain_muscles':
  //       return 'Gain Muscles';
  //     default:
  //       return 'Balanced';
  //   }
  // }
}
