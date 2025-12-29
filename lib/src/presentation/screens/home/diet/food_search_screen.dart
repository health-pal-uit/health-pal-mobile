import 'package:da1/src/config/routes.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/presentation/screens/home/diet/meal_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  String _selectedMealType = 'Breakfast';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'My Meals', 'My Recipes'];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
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
      return _searchResults;
    }
    return _searchResults;
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
          actions: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text('02:59', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
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

    if (_searchController.text.trim().isEmpty) {
      return Center(
        child: Text(
          'Start typing to search for meals',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    if (_filteredResults.isEmpty) {
      return Center(
        child: Text(
          'No meals found',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredResults.length,
      itemBuilder: (context, index) {
        final meal = _filteredResults[index];
        final name = meal['name'] ?? 'Unknown';
        final kcalPer100g = meal['kcal_per_100gr'] ?? 0;

        return ListTile(
          title: Text(name),
          subtitle: Text('per 100g'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$kcalPer100g cals'),
              SizedBox(width: 8),
              Icon(Icons.add_circle, color: AppColors.primary, size: 28),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MealDetailScreen(
                      meal: meal,
                      mealType: _selectedMealType,
                    ),
              ),
            );
          },
        );
      },
      separatorBuilder:
          (context, index) => Divider(height: 1, indent: 16, endIndent: 16),
    );
  }
}
