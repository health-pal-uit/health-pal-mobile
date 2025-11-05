import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  String _selectedMealType = 'Breakfast';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allMealHistory = [
    {
      "name": "Large Size Egg",
      "quantity": "3 eggs",
      "calories": 273,
      "tab": "My Foods",
    },
    {
      "name": "Chicken Biryani",
      "quantity": "1 serving",
      "calories": 273,
      "tab": "My Meals",
    },
    {
      "name": "Roti (Indian Bread)",
      "quantity": "100 g",
      "calories": 243,
      "tab": "My Foods",
    },
    {
      "name": "Chicken Breast",
      "quantity": "1 cup",
      "calories": 74,
      "tab": "My Foods",
    },
    {
      "name": "Protein Shake",
      "quantity": "1 serving",
      "calories": 180,
      "tab": "My Recipes",
    },
    {
      "name": "White Rice (Cooked)",
      "quantity": "100 g",
      "calories": 243,
      "tab": "My Foods",
    },
    {"name": "Tea", "quantity": "1 cup", "calories": 64, "tab": "My Foods"},
  ];

  late List<Map<String, dynamic>> _filteredMealHistory;
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'My Meals', 'My Recipes'];

  @override
  void initState() {
    super.initState();
    _filteredMealHistory = _allMealHistory;
    _searchController.addListener(_filterMeals);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterMeals);
    _searchController.dispose();
    super.dispose();
  }

  void _filterMeals() {
    final query = _searchController.text.toLowerCase();
    final currentTab = _tabs[_selectedTabIndex];

    setState(() {
      _filteredMealHistory =
          _allMealHistory.where((meal) {
            final nameMatches = meal['name'].toLowerCase().contains(query);
            final tabMatches =
                (currentTab == 'All' || meal['tab'] == currentTab);
            return nameMatches && tabMatches;
          }).toList();
    });
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
            icon: Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            color: AppColors.textPrimary,
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildScanButton(
                      context,
                      icon: Icons.camera_alt,
                      text: 'Scan a Meal',
                      onPressed: () {},
                    ),
                    SizedBox(width: 16),
                    _buildScanButton(
                      context,
                      icon: FontAwesomeIcons.barcode,
                      text: 'Scan a Barcode',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              TabBar(
                tabAlignment: TabAlignment.center,
                padding: EdgeInsets.zero,
                isScrollable: true,
                labelColor: Colors.teal,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: Colors.teal,
                indicatorWeight: 3.0,
                onTap: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                  _filterMeals();
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
                  child: ListView.separated(
                    itemCount: _filteredMealHistory.length,
                    itemBuilder: (context, index) {
                      final meal = _filteredMealHistory[index];
                      return ListTile(
                        title: Text(meal['name']),
                        subtitle: Text(meal['quantity']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${meal['calories']} cals'),
                            SizedBox(width: 8),
                            Icon(
                              Icons.add_circle,
                              color: Colors.teal,
                              size: 28,
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder:
                        (context, index) =>
                            Divider(height: 1, indent: 16, endIndent: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: AppColors.textPrimary),
            SizedBox(height: 8),
            Text(text, style: AppTypography.body),
          ],
        ),
      ),
    );
  }
}
