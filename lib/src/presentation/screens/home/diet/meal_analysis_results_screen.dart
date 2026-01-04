import 'package:da1/src/config/routes.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/presentation/screens/home/diet/meal_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:io';

class MealAnalysisResultsScreen extends StatefulWidget {
  final List<String> detectedFoods;
  final File? imageFile;
  final String? selectedDate;
  final String? mealType;

  const MealAnalysisResultsScreen({
    super.key,
    required this.detectedFoods,
    this.imageFile,
    this.selectedDate,
    this.mealType,
  });

  @override
  State<MealAnalysisResultsScreen> createState() =>
      _MealAnalysisResultsScreenState();
}

class _MealAnalysisResultsScreenState extends State<MealAnalysisResultsScreen> {
  late String _selectedMealType;
  String? _selectedFood;
  final Map<String, List<Map<String, dynamic>>> _searchResultsCache = {};
  final Map<String, bool> _loadingStates = {};
  final Map<String, String?> _errorMessages = {};

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.mealType ?? 'Breakfast';

    // Set first food as selected by default
    if (widget.detectedFoods.isNotEmpty) {
      _selectedFood = widget.detectedFoods.first;
      _searchFood(_selectedFood!);
    }
  }

  Future<void> _searchFood(String foodName) async {
    if (_searchResultsCache.containsKey(foodName)) {
      return; // Already searched
    }

    setState(() {
      _loadingStates[foodName] = true;
      _errorMessages[foodName] = null;
    });

    final mealRepository = AppRoutes.getMealRepository();
    if (mealRepository == null) {
      setState(() {
        _loadingStates[foodName] = false;
        _errorMessages[foodName] = 'Repository not available';
      });
      return;
    }

    try {
      // Search both meals and ingredients
      final mealsResult = await mealRepository.searchMeals(foodName);
      final ingredientsResult = await mealRepository.searchIngredients(
        foodName,
      );

      final List<Map<String, dynamic>> combinedResults = [];

      mealsResult.fold((failure) {}, (meals) {
        for (final meal in meals) {
          final mealMap = meal as Map<String, dynamic>;
          mealMap['_isMeal'] = true;
          combinedResults.add(mealMap);
        }
      });

      ingredientsResult.fold((failure) {}, (ingredients) {
        for (final ing in ingredients) {
          final ingMap = ing as Map<String, dynamic>;
          ingMap['_isMeal'] = false;
          combinedResults.add(ingMap);
        }
      });

      if (mounted) {
        setState(() {
          _searchResultsCache[foodName] = combinedResults;
          _loadingStates[foodName] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingStates[foodName] = false;
          _errorMessages[foodName] = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        centerTitle: true,
        title: DropdownButton<String>(
          value: _selectedMealType,
          items:
              <String>[
                'Breakfast',
                'Lunch',
                'Dinner',
                'Snack',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedMealType = newValue;
              });
            }
          },
          style: AppTypography.headline,
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview
            if (widget.imageFile != null)
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(widget.imageFile!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Detected foods dropdown (if multiple foods detected)
            if (widget.detectedFoods.length > 1)
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFood,
                    isExpanded: true,
                    icon: const Icon(LucideIcons.chevronDown),
                    items:
                        widget.detectedFoods.map((String foodName) {
                          return DropdownMenuItem<String>(
                            value: foodName,
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.utensils,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    foodName,
                                    style: AppTypography.headline.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null && newValue != _selectedFood) {
                        setState(() {
                          _selectedFood = newValue;
                        });
                        _searchFood(newValue);
                      }
                    },
                  ),
                ),
              )
            else if (widget.detectedFoods.length == 1)
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.circleCheck,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Detected: ${widget.detectedFoods.first}',
                        style: AppTypography.headline.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.info,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tap any food to add it to your diary',
                      style: AppTypography.body.copyWith(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Results list
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child:
                    _selectedFood == null
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.packageX,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No food detected',
                                style: AppTypography.headline.copyWith(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView(
                          padding: const EdgeInsets.only(top: 16),
                          children: [_buildFoodSection(_selectedFood!)],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodSection(String foodName) {
    final isLoading = _loadingStates[foodName] ?? false;
    final errorMessage = _errorMessages[foodName];
    final results = _searchResultsCache[foodName] ?? [];

    // Separate meals and ingredients
    final meals = results.where((item) => item['_isMeal'] == true).toList();
    final ingredients =
        results.where((item) => item['_isMeal'] == false).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  foodName,
                  style: AppTypography.headline.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),

        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Error: $errorMessage',
              style: AppTypography.body.copyWith(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          )
        else if (!isLoading && results.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'No results found',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          )
        else ...[
          // Meals section
          if (meals.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Meals',
                style: AppTypography.headline.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            ...meals.map((item) => _buildFoodItem(item)),
          ],

          // Ingredients section
          if (ingredients.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Ingredients',
                style: AppTypography.headline.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
            ...ingredients.map((item) => _buildFoodItem(item)),
          ],
        ],

        const Divider(height: 24, thickness: 1),
      ],
    );
  }

  Widget _buildFoodItem(Map<String, dynamic> item) {
    final name = item['name'] as String? ?? 'Unknown';
    final kcalPer100g = item['kcal_per_100gr'] ?? 0;
    final imageUrl = item['image_url'] as String?;
    final isMeal = item['_isMeal'] as bool? ?? true;

    return ListTile(
      leading:
          imageUrl != null && imageUrl.isNotEmpty
              ? ClipRRect(
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
                        isMeal ? Icons.restaurant : LucideIcons.apple,
                        color: Colors.grey[600],
                        size: 28,
                      ),
                    );
                  },
                ),
              )
              : Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isMeal ? Icons.restaurant : LucideIcons.apple,
                  color: Colors.grey[600],
                  size: 28,
                ),
              ),
      title: Text(name, style: AppTypography.headline.copyWith(fontSize: 14)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${kcalPer100g.round()} cals per 100g',
                style: AppTypography.body.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color:
                  isMeal
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isMeal ? 'Meal' : 'Ingredient',
              style: TextStyle(
                color: isMeal ? AppColors.primary : Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.add_circle,
        color: AppColors.primary,
        size: 28,
      ),
      onTap: () async {
        final navigator = Navigator.of(context);

        final result = await navigator.push(
          MaterialPageRoute(
            builder:
                (context) => MealDetailScreen(
                  meal: item,
                  mealType: _selectedMealType,
                  selectedDate: widget.selectedDate,
                ),
          ),
        );

        if (result == true && mounted) {
          navigator.pop(true);
        }
      },
    );
  }
}
