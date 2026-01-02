import 'package:da1/src/config/routes.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/presentation/bloc/auth/auth_bloc.dart';
import 'package:da1/src/presentation/bloc/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MealDetailScreen extends StatefulWidget {
  final Map<String, dynamic> meal;
  final String mealType;
  final String? selectedDate; // Format: "DD/MM/YYYY"

  const MealDetailScreen({
    super.key,
    required this.meal,
    required this.mealType,
    this.selectedDate,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final TextEditingController _portionController = TextEditingController(
    text: '100',
  );
  String _selectedUnit = 'g';
  bool _isAdding = false;
  bool _isFavorited = false;
  bool _isLoadingFavorite = true;
  bool _isTogglingFavorite = false;
  String? _favId; // Store the favorite ID for deletion
  List<Map<String, dynamic>> _ingredientDetails = [];
  bool _isLoadingIngredients = false;

  // Common serving sizes
  final List<Map<String, dynamic>> _servingSizes = [
    {'label': '1 serving', 'grams': 100},
    {'label': '1 cup', 'grams': 150},
    {'label': '100g', 'grams': 100},
    {'label': '1 oz', 'grams': 28},
  ];

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _loadIngredients().then((_) {
      // Update portion controller after ingredients are loaded
      if (_hasMealWithIngredients && mounted) {
        setState(() {
          _portionController.text = _totalMealWeightInGrams.toInt().toString();
        });
      }
    });
  }

  @override
  void dispose() {
    _portionController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    final mealId = widget.meal['id'];
    if (mealId == null) {
      setState(() => _isLoadingFavorite = false);
      return;
    }

    // Check if meal already has fav_id from the list
    if (widget.meal['fav_id'] != null) {
      setState(() {
        _favId = widget.meal['fav_id'];
        _isFavorited = true;
        _isLoadingFavorite = false;
      });
      return;
    }

    final repository = AppRoutes.getMealRepository();
    if (repository == null) {
      setState(() => _isLoadingFavorite = false);
      return;
    }

    final result = await repository.checkIfFavorited(mealId);
    if (mounted) {
      result.fold((failure) => setState(() => _isLoadingFavorite = false), (
        isFavorited,
      ) {
        setState(() {
          _isFavorited = isFavorited;
          _isLoadingFavorite = false;
        });
        // If favorited, we need to get all favorites to find the fav_id
        if (isFavorited) {
          _getFavIdFromList();
        }
      });
    }
  }

  Future<void> _getFavIdFromList() async {
    final repository = AppRoutes.getMealRepository();
    if (repository == null) return;

    final result = await repository.getFavoriteMeals(page: 1, limit: 100);
    if (mounted) {
      result.fold(
        (failure) {
          // Failed to get fav_id
        },
        (meals) {
          final mealId = widget.meal['id'];
          final favMeal = meals.firstWhere(
            (meal) => meal['id'] == mealId,
            orElse: () => <String, dynamic>{},
          );
          if (favMeal.isNotEmpty && favMeal['fav_id'] != null) {
            setState(() => _favId = favMeal['fav_id']);
          }
        },
      );
    }
  }

  Future<void> _toggleFavorite() async {
    final mealId = widget.meal['id'];
    if (mealId == null || _isTogglingFavorite) return;

    // Get user ID from AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      }
      return;
    }
    final userId = authState.user.id;

    setState(() => _isTogglingFavorite = true);

    final repository = AppRoutes.getMealRepository();
    if (repository == null) {
      setState(() => _isTogglingFavorite = false);
      return;
    }

    final result =
        _isFavorited
            ? await repository.removeFavorite(_favId!)
            : await repository.addFavorite(userId, mealId);

    if (mounted) {
      setState(() => _isTogglingFavorite = false);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update favorite: ${failure.message}'),
            ),
          );
        },
        (_) {
          setState(() {
            _isFavorited = !_isFavorited;
            if (!_isFavorited) {
              _favId = null;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isFavorited ? 'Added to favorites' : 'Removed from favorites',
              ),
            ),
          );
          if (_isFavorited) {
            _checkFavoriteStatus();
          }
        },
      );
    }
  }

  Future<void> _loadIngredients() async {
    final ingredientsData = widget.meal['ingredients_data'] as List?;
    if (ingredientsData == null || ingredientsData.isEmpty) {
      return;
    }

    setState(() => _isLoadingIngredients = true);

    final repository = AppRoutes.getMealRepository();
    if (repository == null) {
      setState(() => _isLoadingIngredients = false);
      return;
    }

    final List<Map<String, dynamic>> loadedIngredients = [];

    for (final ingredientData in ingredientsData) {
      final ingredientId = ingredientData['ingredient_id'];
      final quantityKg = ingredientData['quantity_kg'];

      if (ingredientId != null) {
        final result = await repository.getIngredientById(ingredientId);
        result.fold(
          (failure) {
            // Silently fail for individual ingredients
          },
          (ingredient) {
            loadedIngredients.add({...ingredient, 'quantity_kg': quantityKg});
          },
        );
      }
    }

    if (mounted) {
      setState(() {
        _ingredientDetails = loadedIngredients;
        _isLoadingIngredients = false;
      });
    }
  }

  double get _portionSize {
    return double.tryParse(_portionController.text) ?? 100;
  }

  bool get _hasMealWithIngredients {
    return _ingredientDetails.isNotEmpty;
  }

  double get _totalMealWeightInGrams {
    if (!_hasMealWithIngredients) return 100.0;
    return _ingredientDetails.fold(0.0, (sum, ingredient) {
      final quantityKg = (ingredient['quantity_kg'] ?? 0).toDouble();
      return sum + (quantityKg * 1000);
    });
  }

  double _calculateTotalNutrientFromIngredients(String nutrientKey) {
    if (!_hasMealWithIngredients) return 0.0;

    return _ingredientDetails.fold(0.0, (sum, ingredient) {
      final nutrientPer100g = (ingredient[nutrientKey] ?? 0).toDouble();
      final quantityKg = (ingredient['quantity_kg'] ?? 0).toDouble();
      final quantityG = quantityKg * 1000;
      return sum + ((nutrientPer100g * quantityG) / 100);
    });
  }

  double _calculateNutrientPer100g(String nutrientKey) {
    if (!_hasMealWithIngredients) return 0.0;
    final totalNutrient = _calculateTotalNutrientFromIngredients(nutrientKey);
    final totalWeight = _totalMealWeightInGrams;
    if (totalWeight == 0) return 0.0;
    return (totalNutrient / totalWeight) * 100;
  }

  double _calculateNutrient(double per100g) {
    return (per100g * _portionSize) / 100;
  }

  Future<void> _addToMeal() async {
    final mealId = widget.meal['id'];
    if (mealId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid meal data')));
      return;
    }

    setState(() => _isAdding = true);

    final repository = AppRoutes.getDailyMealRepository();
    if (repository == null) {
      setState(() => _isAdding = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repository not initialized')),
        );
      }
      return;
    }

    final quantityKg = _portionSize / 1000;

    final loggedAt =
        widget.selectedDate ??
        (() {
          final now = DateTime.now();
          return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
        })();

    final result = await repository.addDailyMeal(
      mealId: mealId,
      mealType: widget.mealType.toLowerCase(),
      quantityKg: quantityKg,
      loggedAt: loggedAt,
    );

    if (mounted) {
      setState(() => _isAdding = false);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add meal: ${failure.message}')),
          );
        },
        (data) {
          final name = widget.meal['name'] ?? 'Unknown';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Added ${_portionSize.toStringAsFixed(0)}g of $name to ${widget.mealType}',
              ),
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.meal['name'] ?? 'Unknown';

    // Calculate nutrition values - use ingredients if available, otherwise use meal values
    final kcalPer100g =
        _hasMealWithIngredients
            ? _calculateNutrientPer100g('kcal_per_100gr')
            : (widget.meal['kcal_per_100gr'] ?? 0).toDouble();
    final proteinPer100g =
        _hasMealWithIngredients
            ? _calculateNutrientPer100g('protein_per_100gr')
            : (widget.meal['protein_per_100gr'] ?? 0).toDouble();
    final fatPer100g =
        _hasMealWithIngredients
            ? _calculateNutrientPer100g('fat_per_100gr')
            : (widget.meal['fat_per_100gr'] ?? 0).toDouble();
    final carbsPer100g =
        _hasMealWithIngredients
            ? _calculateNutrientPer100g('carbs_per_100gr')
            : (widget.meal['carbs_per_100gr'] ?? 0).toDouble();
    final fiberPer100g =
        _hasMealWithIngredients
            ? _calculateNutrientPer100g('fiber_per_100gr')
            : (widget.meal['fiber_per_100gr'] ?? 0).toDouble();
    final imageUrl = widget.meal['image_url'] as String?;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        centerTitle: true,
        title: Text(widget.mealType, style: AppTypography.headline),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child:
                _isLoadingFavorite
                    ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                    : IconButton(
                      icon: Icon(
                        _isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorited ? Colors.red : Colors.black,
                        size: 26,
                      ),
                      onPressed: _isTogglingFavorite ? null : _toggleFavorite,
                    ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal Image (if available)
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 200,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.restaurant,
                                  size: 64,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Meal Name Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTypography.headline.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.verified,
                              size: 16,
                              color:
                                  widget.meal['is_verified'] == true
                                      ? AppColors.primary
                                      : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.meal['is_verified'] == true
                                  ? 'Verified'
                                  : 'Not verified',
                              style: AppTypography.body.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ingredients Section (if meal has ingredients)
                  if (_ingredientDetails.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ingredients',
                            style: AppTypography.headline.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._ingredientDetails.map((ingredient) {
                            final name = ingredient['name'] ?? 'Unknown';
                            final quantityKg =
                                (ingredient['quantity_kg'] ?? 0).toDouble();
                            final quantityG = (quantityKg * 1000).toInt();
                            final kcalPer100g =
                                (ingredient['kcal_per_100gr'] ?? 0).toDouble();
                            final totalKcal = (kcalPer100g * quantityKg * 10)
                                .toStringAsFixed(0);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: AppTypography.body.copyWith(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${quantityG}g',
                                    style: AppTypography.body.copyWith(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '($totalKcal kcal)',
                                    style: AppTypography.body.copyWith(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_isLoadingIngredients)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  if (_isLoadingIngredients) const SizedBox(height: 16),

                  // Portion Size Selection
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portion Size',
                          style: AppTypography.headline.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quick serving sizes
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _servingSizes.map((serving) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _portionController.text =
                                          serving['grams'].toString();
                                      _selectedUnit = 'g';
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Text(
                                      serving['label'],
                                      style: AppTypography.body.copyWith(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Custom portion input
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _portionController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Amount',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                onChanged: (value) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[400]!),
                                ),
                                child: DropdownButton<String>(
                                  value: _selectedUnit,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items:
                                      ['g', 'oz', 'lb']
                                          .map(
                                            (unit) => DropdownMenuItem(
                                              value: unit,
                                              child: Text(unit),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _selectedUnit = value);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nutrition Facts
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nutrition Facts',
                          style: AppTypography.headline.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'per ${_portionSize.toStringAsFixed(0)}g',
                          style: AppTypography.body.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Calories
                        _buildNutrientRow(
                          'Calories',
                          _calculateNutrient(kcalPer100g).toStringAsFixed(0),
                          'kcal',
                          isCalories: true,
                        ),
                        const Divider(height: 24),

                        // Macros
                        _buildNutrientRow(
                          'Protein',
                          _calculateNutrient(proteinPer100g).toStringAsFixed(1),
                          'g',
                        ),
                        const SizedBox(height: 12),
                        _buildNutrientRow(
                          'Carbohydrates',
                          _calculateNutrient(carbsPer100g).toStringAsFixed(1),
                          'g',
                        ),
                        const SizedBox(height: 12),
                        _buildNutrientRow(
                          'Fat',
                          _calculateNutrient(fatPer100g).toStringAsFixed(1),
                          'g',
                        ),
                        const SizedBox(height: 12),
                        _buildNutrientRow(
                          'Fiber',
                          _calculateNutrient(fiberPer100g).toStringAsFixed(1),
                          'g',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add to meal button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAdding ? null : _addToMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isAdding
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Add to ${widget.mealType}',
                            style: AppTypography.headline.copyWith(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(
    String label,
    String value,
    String unit, {
    bool isCalories = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.body.copyWith(
            fontSize: isCalories ? 16 : 14,
            fontWeight: isCalories ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '$value $unit',
          style: AppTypography.headline.copyWith(
            fontSize: isCalories ? 18 : 14,
            fontWeight: isCalories ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
