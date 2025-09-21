import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FoodSearchScreen extends StatelessWidget {
  final List<Map<String, dynamic>> mealHistory = [
    {"name": "Large Size Egg", "quantity": "3 eggs", "calories": 273},
    {"name": "Chicken Biryani", "quantity": "1 serving", "calories": 273},
    {"name": "Roti (Indian Bread)", "quantity": "100 g", "calories": 243},
    {"name": "Chicken Breast", "quantity": "1 cup", "calories": 74},
    {"name": "White Rice (Cooked)", "quantity": "100 g", "calories": 243},
    {"name": "Tea", "quantity": "1 cup", "calories": 64},
  ];

  FoodSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        centerTitle: true,
        title: DropdownButton<String>(
          value: 'Breakfast',
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
          onChanged: (_) {},
          style: AppTypography.headline,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
          color: AppColors.textPrimary,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('02:59', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 24,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 32,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(height: 8),
                        Text('Scan a Meal', style: AppTypography.body),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 24,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.barcode,
                          size: 32,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(height: 8),
                        Text('Scan a Barcode', style: AppTypography.body),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('All', style: TextStyle(color: Colors.teal)),
                  Text('My Meals'),
                  Text('My Recipes'),
                  Text('My Foods'),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: mealHistory.length,
                itemBuilder: (context, index) {
                  final meal = mealHistory[index];
                  return ListTile(
                    title: Text(meal['name']),
                    subtitle: Text(meal['quantity']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${meal['calories']} cals'),
                        Icon(Icons.add, color: Colors.teal),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
