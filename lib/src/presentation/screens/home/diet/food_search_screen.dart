import 'package:da1/src/config/routes.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/presentation/screens/home/diet/meal_detail_screen.dart';
import 'package:da1/src/presentation/screens/home/diet/create_recipe_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FoodSearchScreen extends StatefulWidget {
  final String? initialMealType;
  final String? selectedDate; // Format: "DD/MM/YYYY"

  const FoodSearchScreen({super.key, this.initialMealType, this.selectedDate});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  late String _selectedMealType;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _favoriteResults = [];
  List<Map<String, dynamic>> _userRecipes = [];
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'Favorites', 'My Meals'];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.initialMealType ?? 'Breakfast';
    _searchController.addListener(_onSearchChanged);
    _loadFavoriteMeals();
    _loadUserRecipes();
  }

  Future<void> _loadFavoriteMeals() async {
    final repository = AppRoutes.getMealRepository();
    if (repository == null) return;

    final result = await repository.getFavoriteMeals(page: 1, limit: 100);
    if (mounted) {
      result.fold(
        (failure) {
          // Silently fail for favorites
        },
        (meals) {
          setState(() {
            _favoriteResults = meals.cast<Map<String, dynamic>>();
          });
        },
      );
    }
  }

  Future<void> _loadUserRecipes() async {
    final repository = AppRoutes.getMealRepository();
    if (repository == null) return;

    final result = await repository.getUserContributions();
    if (mounted) {
      result.fold(
        (failure) {
          // Silently fail for user recipes
        },
        (recipes) {
          setState(() {
            _userRecipes = recipes.cast<Map<String, dynamic>>();
          });
        },
      );
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _searchMeals(query);
    } else {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
    }
  }

  Future<void> _searchMeals(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repository = AppRoutes.getMealRepository();
    if (repository == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Repository not initialized';
      });
      return;
    }

    final result = await repository.searchMeals(query);

    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
            _searchResults = [];
          });
        },
        (meals) {
          setState(() {
            _isLoading = false;
            _searchResults = meals.cast<Map<String, dynamic>>();
          });
        },
      );
    }
  }

  List<Map<String, dynamic>> get _filteredResults {
    if (_selectedTabIndex == 0) {
      // All tab - show search results
      return _searchResults;
    } else if (_selectedTabIndex == 1) {
      // Favorites tab - show favorites filtered by search if any
      if (_searchController.text.trim().isEmpty) {
        return _favoriteResults;
      }
      final query = _searchController.text.trim().toLowerCase();
      return _favoriteResults.where((meal) {
        final name = (meal['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    } else if (_selectedTabIndex == 2) {
      final pendingRecipes =
          _userRecipes.where((recipe) {
            final status = recipe['status'] as String?;
            return status == 'PENDING';
          }).toList();

      if (_searchController.text.trim().isEmpty) {
        return pendingRecipes;
      }
      final query = _searchController.text.trim().toLowerCase();
      return pendingRecipes.where((recipe) {
        final name = (recipe['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
              TabBar(
                tabAlignment: TabAlignment.center,
                padding: EdgeInsets.zero,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3.0,
                onTap: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                tabs: _tabs.map((tabName) => Tab(text: tabName)).toList(),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton:
            _selectedTabIndex == 2
                ? FloatingActionButton.extended(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateRecipeScreen(),
                      ),
                    );
                    // Reload user recipes if a new recipe was created
                    if (result == true && mounted) {
                      _loadUserRecipes();
                    }
                  },
                  backgroundColor: AppColors.primary,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Create Recipe',
                    style: TextStyle(color: Colors.white),
                  ),
                )
                : null,
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            style: AppTypography.body.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Handle empty search for All tab
    if (_searchController.text.trim().isEmpty && _selectedTabIndex == 0) {
      return Center(
        child: Text(
          'Start typing to search for meals',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    // Handle empty results
    if (_filteredResults.isEmpty) {
      if (_selectedTabIndex == 1) {
        // Favorites tab - no favorites
        return Center(
          child: Text(
            'No favorite meals yet',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        );
      } else if (_selectedTabIndex == 2) {
        // My Meals tab - no pending recipes
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No pending meals',
                style: AppTypography.headline.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a meal to see it here!',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }
      return Center(
        child: Text(
          'No meals found',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: _selectedTabIndex == 2 ? 80 : 0),
      itemCount: _filteredResults.length,
      itemBuilder: (context, index) {
        final meal = _filteredResults[index];
        final name = meal['name'] ?? 'Unknown';
        final kcalPer100g = meal['kcal_per_100gr'] ?? 0;
        final imageUrl = meal['image_url'] as String?;
        final status = meal['status'] as String?;
        final isPending = status == 'PENDING';

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
                            Icons.restaurant,
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
                      Icons.restaurant,
                      color: Colors.grey[600],
                      size: 28,
                    ),
                  ),
          title: Text(name),
          subtitle: Row(
            children: [
              const Flexible(
                child: Text('per 100g', overflow: TextOverflow.ellipsis),
              ),
              if (isPending) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  '${kcalPer100g.round()} cals',
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
            ],
          ),
          onTap: () async {
            if (!context.mounted) return;

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MealDetailScreen(
                      meal: meal,
                      mealType: _selectedMealType,
                      selectedDate: widget.selectedDate,
                    ),
              ),
            );

            // Reload favorites and user recipes when returning from meal detail
            if (context.mounted) {
              _loadFavoriteMeals();
              _loadUserRecipes();
            }

            if (result == true && context.mounted) {
              Navigator.pop(context, true);
            }
          },
        );
      },
      separatorBuilder:
          (context, index) =>
              const Divider(height: 1, indent: 16, endIndent: 16),
    );
  }
}
