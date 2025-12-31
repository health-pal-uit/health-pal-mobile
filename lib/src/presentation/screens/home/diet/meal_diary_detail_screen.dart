import 'package:da1/src/config/routes.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MealDiaryDetailScreen extends StatefulWidget {
  final List<dynamic> dailyMeals;
  final String selectedDate;

  const MealDiaryDetailScreen({
    super.key,
    required this.dailyMeals,
    required this.selectedDate,
  });

  @override
  State<MealDiaryDetailScreen> createState() => _MealDiaryDetailScreenState();
}

class _MealDiaryDetailScreenState extends State<MealDiaryDetailScreen> {
  final Map<String, List<Map<String, dynamic>>> _groupedMeals = {};
  final Map<String, Map<String, dynamic>> _mealDetails = {};
  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    _groupMealsByType();
    _loadMealDetails();
  }

  void _groupMealsByType() {
    _groupedMeals.clear();
    _groupedMeals['breakfast'] = [];
    _groupedMeals['lunch'] = [];
    _groupedMeals['dinner'] = [];
    _groupedMeals['snack'] = [];

    for (final meal in widget.dailyMeals) {
      final mealType = (meal['meal_type'] ?? '').toString().toLowerCase();
      if (_groupedMeals.containsKey(mealType)) {
        _groupedMeals[mealType]!.add(meal as Map<String, dynamic>);
      }
    }
  }

  Future<void> _loadMealDetails() async {
    final repository = AppRoutes.getMealRepository();
    if (repository == null) {
      setState(() => _isLoadingDetails = false);
      return;
    }

    for (final meal in widget.dailyMeals) {
      final mealId = meal['meal_id'];
      if (mealId != null && !_mealDetails.containsKey(mealId)) {
        final result = await repository.getMealById(mealId);
        result.fold(
          (failure) {
            // Failed to load meal details
          },
          (mealDetail) {
            if (mounted) {
              setState(() {
                _mealDetails[mealId] = mealDetail;
              });
            }
          },
        );
      }
    }

    if (mounted) {
      setState(() => _isLoadingDetails = false);
    }
  }

  String _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return '🌮';
      case 'lunch':
        return '🍱';
      case 'dinner':
        return '🍽️';
      case 'snack':
        return '🥤';
      default:
        return '🍽️';
    }
  }

  String _formatMealType(String mealType) {
    return mealType[0].toUpperCase() + mealType.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final totalKcal = widget.dailyMeals.fold<double>(
      0,
      (sum, meal) => sum + ((meal['total_kcal'] ?? 0) as num).toDouble(),
    );

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        centerTitle: true,
        title: Text('Meal Diary', style: AppTypography.headline),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Date and Total Calories Header
          Container(
            margin: const EdgeInsets.all(24),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.selectedDate,
                      style: AppTypography.headline.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.dailyMeals.length} meals logged',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${totalKcal.round()}',
                      style: AppTypography.headline.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'calories',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Meals List by Type
          Expanded(
            child:
                _isLoadingDetails
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                    : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildMealTypeSection('breakfast'),
                        _buildMealTypeSection('lunch'),
                        _buildMealTypeSection('dinner'),
                        _buildMealTypeSection('snack'),
                        const SizedBox(height: 24),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeSection(String mealType) {
    final meals = _groupedMeals[mealType] ?? [];
    if (meals.isEmpty) return const SizedBox.shrink();

    final totalKcal = meals.fold<double>(
      0,
      (sum, meal) => sum + ((meal['total_kcal'] ?? 0) as num).toDouble(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(
                _getMealTypeIcon(mealType),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                _formatMealType(mealType),
                style: AppTypography.headline.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${totalKcal.round()} cal',
                style: AppTypography.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Meal Items
        ...meals.map((meal) => _buildMealItem(meal)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMealItem(Map<String, dynamic> meal) {
    final mealId = meal['meal_id'];
    final mealDetail = _mealDetails[mealId];
    final name = mealDetail?['name'] ?? 'Loading...';
    final imageUrl = mealDetail?['image_url'] as String?;
    final quantityKg = (meal['quantity_kg'] ?? 0) as num;
    final quantityG = (quantityKg.toDouble() * 1000).round();
    final totalKcal = (meal['total_kcal'] ?? 0) as num;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Meal Image
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.grey[600],
                      size: 28,
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.restaurant, color: Colors.grey[600], size: 28),
            ),

          const SizedBox(width: 12),

          // Meal Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${quantityG}g',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Calories
          Text(
            '${totalKcal.round()} cal',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
