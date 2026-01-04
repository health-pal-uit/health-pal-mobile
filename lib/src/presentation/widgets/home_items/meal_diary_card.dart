import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/presentation/screens/home/diet/meal_diary_detail_screen.dart';
import 'package:da1/src/presentation/screens/home/meal_recommendations_input_screen.dart';
import 'package:flutter/material.dart';

class MealDiaryCard extends StatefulWidget {
  final List<dynamic>? dailyMeals;
  final Function(String mealType)? onAddMeal;
  final String? selectedDate; // Format: "DD/MM/YYYY"

  const MealDiaryCard({
    super.key,
    this.dailyMeals,
    this.onAddMeal,
    this.selectedDate,
  });

  @override
  State<MealDiaryCard> createState() => _MealDiaryCardState();
}

class _MealDiaryCardState extends State<MealDiaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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

  int _getMealCount(String mealType) {
    if (widget.dailyMeals == null) return 0;
    return widget.dailyMeals!
        .where(
          (meal) =>
              meal['meal_type']?.toString().toLowerCase() ==
              mealType.toLowerCase(),
        )
        .length;
  }

  int _getMealKcal(String mealType) {
    if (widget.dailyMeals == null) return 0;
    final meals = widget.dailyMeals!.where(
      (meal) =>
          meal['meal_type']?.toString().toLowerCase() == mealType.toLowerCase(),
    );

    double totalKcal = 0;
    for (final meal in meals) {
      final mealKcal = (meal['total_kcal'] ?? 0) as num;
      totalKcal += mealKcal.toDouble();
    }

    return totalKcal.round();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meal Diary',
                style: AppTypography.headline.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const MealRecommendationsInputScreen(),
                          ),
                        );
                      },
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildMealButton(
                  icon: '🌮',
                  label: 'Breakfast',
                  color: const Color(0xFFFFE5C2),
                  count: _getMealCount('breakfast'),
                  kcal: _getMealKcal('breakfast'),
                ),
              ),
              Expanded(
                child: _buildMealButton(
                  icon: '🍱',
                  label: 'Lunch',
                  color: const Color(0xFFFFE5C2),
                  count: _getMealCount('lunch'),
                  kcal: _getMealKcal('lunch'),
                ),
              ),
              Expanded(
                child: _buildMealButton(
                  icon: '🍽️',
                  label: 'Dinner',
                  color: const Color(0xFFFFE5C2),
                  count: _getMealCount('dinner'),
                  kcal: _getMealKcal('dinner'),
                ),
              ),
              Expanded(
                child: _buildMealButton(
                  icon: '🥤',
                  label: 'Snack',
                  color: const Color(0xFFFFE5C2),
                  count: _getMealCount('snack'),
                  kcal: _getMealKcal('snack'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              if (widget.dailyMeals != null && widget.dailyMeals!.isNotEmpty) {
                final dateStr =
                    widget.selectedDate ??
                    (() {
                      final now = DateTime.now();
                      return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
                    })();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => MealDiaryDetailScreen(
                          dailyMeals: widget.dailyMeals!,
                          selectedDate: dateStr,
                        ),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Meal Details',
                    style: AppTypography.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealButton({
    required String icon,
    required String label,
    required Color color,
    required int count,
    required int kcal,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonSize = constraints.maxWidth * 0.85;
        return Column(
          children: [
            GestureDetector(
              onTap: () => widget.onAddMeal?.call(label),
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(icon, style: const TextStyle(fontSize: 32)),
                    ),
                    if (kcal > 0)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            '$kcal',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.body.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}
