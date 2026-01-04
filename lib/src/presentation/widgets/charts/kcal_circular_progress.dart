import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';

class KcalCircularProgressCard extends StatefulWidget {
  final int consumed;
  final int needed;
  final int burned;
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
  final int? proteinPercentages;
  final int? fatPercentages;
  final int? carbsPercentages;
  final VoidCallback? onDietTypePressed;
  final VoidCallback? onRecommendationsPressed;

  const KcalCircularProgressCard({
    super.key,
    required this.consumed,
    required this.needed,
    required this.burned,
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
    this.proteinPercentages,
    this.fatPercentages,
    this.carbsPercentages,
    this.onDietTypePressed,
    this.onRecommendationsPressed,
  });

  @override
  State<KcalCircularProgressCard> createState() =>
      _KcalCircularProgressCardState();
}

class _KcalCircularProgressCardState extends State<KcalCircularProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.needed - widget.consumed;
    final carbsCurrent = widget.carbs?.round() ?? 0;
    final proteinCurrent = widget.protein?.round() ?? 0;
    final fatCurrent = widget.fat?.round() ?? 0;
    final fiberCurrent = widget.fiber?.round() ?? 0;
    final dietTypeDisplay = widget.dietTypeName ?? 'Balanced';

    int carbsGoalValue;
    int proteinGoalValue;
    int fatGoalValue;

    if (widget.proteinPercentages != null &&
        widget.fatPercentages != null &&
        widget.carbsPercentages != null) {
      proteinGoalValue =
          ((widget.needed * widget.proteinPercentages! / 100) / 4).round();
      fatGoalValue =
          ((widget.needed * widget.fatPercentages! / 100) / 9).round();
      carbsGoalValue =
          ((widget.needed * widget.carbsPercentages! / 100) / 4).round();
    } else {
      carbsGoalValue = widget.carbsGoal ?? 301;
      proteinGoalValue = widget.proteinGoal ?? 138;
      fatGoalValue = widget.fatGoal ?? 72;
    }

    final fiberGoalValue = widget.fiberGoal ?? 32;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calories & Nutrition',
                style: AppTypography.headline.copyWith(fontSize: 18),
              ),
              if (widget.onRecommendationsPressed != null)
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: GestureDetector(
                        onTap: widget.onRecommendationsPressed,
                        child: ShaderMask(
                          shaderCallback:
                              (bounds) => LinearGradient(
                                colors: [
                                  Colors.pink.shade300,
                                  Colors.blue.shade300,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: const [0.2, 0.9],
                              ).createShader(bounds),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final size = constraints.maxWidth.clamp(100.0, 150.0);
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: size,
                                height: size,
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
                                width: size,
                                height: size,
                                child: CircularProgressIndicator(
                                  value:
                                      widget.needed > 0
                                          ? (widget.consumed / widget.needed)
                                              .clamp(0.0, 1.0)
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
                                    '${widget.consumed}',
                                    style: AppTypography.headline.copyWith(
                                      fontSize: 28,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
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
                      widget.needed.toString(),
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
                      widget.burned.toString(),
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
              onTap: widget.onDietTypePressed,
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
}
