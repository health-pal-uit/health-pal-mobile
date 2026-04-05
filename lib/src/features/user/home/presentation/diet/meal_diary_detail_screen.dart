import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/config/routes.dart';
import 'package:da1/src/core/services/local_notification_service.dart';
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
  List<dynamic> _currentMeals = [];
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _currentMeals = List.from(widget.dailyMeals);
    _groupMealsByType();
  }

  void _groupMealsByType() {
    _groupedMeals.clear();
    _groupedMeals['breakfast'] = [];
    _groupedMeals['lunch'] = [];
    _groupedMeals['dinner'] = [];
    _groupedMeals['snack'] = [];

    for (final meal in _currentMeals) {
      final mealType = (meal['meal_type'] ?? '').toString().toLowerCase();
      if (_groupedMeals.containsKey(mealType)) {
        _groupedMeals[mealType]!.add(meal as Map<String, dynamic>);
      }
    }
  }

  Future<void> _deleteMeal(Map<String, dynamic> meal) async {
    final mealId = meal['id'] as String?;
    if (mealId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot delete meal: missing ID'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Meal'),
            content: const Text('Are you sure you want to delete this meal?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    final repository = AppRoutes.getDailyMealRepository();
    if (repository == null) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily meal repository not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final result = await repository.deleteDailyMeal(dailyMealId: mealId);
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _isDeleting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete meal: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (response) {
          if (mounted) {
            setState(() {
              _currentMeals.removeWhere((m) => m['id'] == mealId);
              _groupMealsByType();
              _isDeleting = false;
            });

            final mealDetail = meal['meal'] as Map<String, dynamic>?;
            final mealName = mealDetail?['name'] ?? 'Meal';

            LocalNotificationService().showSuccessNotification(
              title: 'Meal Deleted',
              body: '$mealName has been removed from your diary',
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Meal deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting meal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    final totalKcal = _currentMeals.fold<double>(
      0,
      (sum, meal) => sum + ((meal['total_kcal'] ?? 0) as num).toDouble(),
    );

    return Stack(
      children: [
        Scaffold(
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
                          '${_currentMeals.length} meals logged',
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
                child: ListView(
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
        ),
        if (_isDeleting)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
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

  void _showMealOptions(Map<String, dynamic> meal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(
                    LucideIcons.pencil,
                    color: AppColors.primary,
                  ),
                  title: const Text('Edit Meal'),
                  onTap: () {
                    Navigator.pop(context);
                    _editMeal(meal);
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.trash2, color: Colors.red),
                  title: const Text(
                    'Delete Meal',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteMeal(meal);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Future<void> _editMeal(Map<String, dynamic> meal) async {
    final mealDetail = meal['meal'] as Map<String, dynamic>?;
    final mealName = mealDetail?['name'] ?? 'Unknown';
    final currentQuantityKg = (meal['quantity_kg'] ?? 0) as num;
    final currentQuantityG = (currentQuantityKg.toDouble() * 1000).round();

    final quantityController = TextEditingController(
      text: currentQuantityG.toString(),
    );

    final result = await showDialog<double>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit $mealName'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adjust the portion size',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity (grams)',
                    suffixText: 'g',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newQuantityG = double.tryParse(quantityController.text);
                  if (newQuantityG != null && newQuantityG > 0) {
                    Navigator.pop(context, newQuantityG);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid quantity'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update'),
              ),
            ],
          ),
    );

    if (result == null) return;

    final newQuantityKg = result / 1000;
    if ((newQuantityKg - currentQuantityKg.toDouble()).abs() < 0.001) {
      return;
    }

    await _updateMealQuantity(meal, newQuantityKg);
  }

  Future<void> _updateMealQuantity(
    Map<String, dynamic> meal,
    double newQuantityKg,
  ) async {
    final mealId = meal['id'] as String?;
    if (mealId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot update meal: missing ID'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    final repository = AppRoutes.getDailyMealRepository();
    if (repository == null) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily meal repository not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final result = await repository.updateDailyMeal(
        dailyMealId: mealId,
        quantityKg: newQuantityKg,
      );

      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _isDeleting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update meal: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (response) {
          if (mounted) {
            final index = _currentMeals.indexWhere((m) => m['id'] == mealId);
            if (index != -1) {
              _currentMeals[index] = response;
            }

            setState(() {
              _groupMealsByType();
              _isDeleting = false;
            });

            final mealDetail = meal['meal'] as Map<String, dynamic>?;
            final mealName = mealDetail?['name'] ?? 'Meal';
            final quantityG = (newQuantityKg * 1000).round();

            LocalNotificationService().showSuccessNotification(
              title: 'Meal Updated',
              body: '$mealName quantity updated to ${quantityG}g',
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$mealName updated to ${quantityG}g'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pop(context, true);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating meal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMealItem(Map<String, dynamic> meal) {
    final mealDetail = meal['meal'] as Map<String, dynamic>?;
    final name = mealDetail?['name'] ?? 'Unknown';
    final imageUrl = mealDetail?['image_url'] as String?;
    final quantityKg = (meal['quantity_kg'] ?? 0) as num;
    final quantityG = (quantityKg.toDouble() * 1000).round();
    final totalKcal = (meal['total_kcal'] ?? 0) as num;

    return GestureDetector(
      onLongPress: () => _showMealOptions(meal),
      child: Container(
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
                child: Icon(
                  Icons.restaurant,
                  color: Colors.grey[600],
                  size: 28,
                ),
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
      ),
    );
  }
}
