import 'package:dio/dio.dart';

abstract class MealRemoteDataSource {
  Future<List<dynamic>> searchMeals(String name);
  Future<List<dynamic>> searchIngredients(String name);
  Future<List<dynamic>> getFavoriteMeals({int page = 1, int limit = 10});
  Future<bool> checkIfFavorited(String mealId);
  Future<void> addFavorite(String userId, String mealId);
  Future<void> removeFavorite(String favId);
  Future<Map<String, dynamic>> getMealById(String mealId);
  Future<List<dynamic>> getUserContributions();
  Future<Map<String, dynamic>> createMealContribution(
    Map<String, dynamic> data,
    String? imagePath,
  );
}

class MealRemoteDataSourceImpl implements MealRemoteDataSource {
  final Dio dio;

  MealRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> searchMeals(String name) async {
    try {
      final response = await dio.post('/meals/search', data: {'name': name});

      if (response.statusCode == 200 || response.statusCode == 201) {
        // The response structure is nested: {data: {data: [...]}}
        final outerData = response.data['data'];
        final meals = outerData['data'] as List<dynamic>;
        return meals;
      }
      throw Exception(
        'Failed to search meals - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> searchIngredients(String name) async {
    try {
      final response = await dio.post(
        '/ingredients/search',
        data: {'name': name},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final outerData = response.data['data'];
        final ingredients = outerData['data'] as List<dynamic>;
        return ingredients;
      }
      throw Exception(
        'Failed to search ingredients - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> getFavoriteMeals({int page = 1, int limit = 10}) async {
    try {
      final response = await dio.get(
        '/fav-meals/user',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final outerData = response.data['data'];
        final favMeals = outerData['data'] as List<dynamic>;
        // Return the favorite object with both id and meal data
        return favMeals.map((fav) {
          final meal = fav['meal'] as Map<String, dynamic>;
          // Add the favorite ID to the meal object
          meal['fav_id'] = fav['id'];
          return meal;
        }).toList();
      }
      throw Exception(
        'Failed to get favorite meals - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<bool> checkIfFavorited(String mealId) async {
    try {
      final response = await dio.get('/fav-meals/user/$mealId');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data['favorited'] as bool;
      }
      throw Exception(
        'Failed to check favorite status - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<void> addFavorite(String userId, String mealId) async {
    try {
      final response = await dio.post(
        '/fav-meals',
        data: {'user_id': userId, 'meal_id': mealId},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to add favorite - Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<void> removeFavorite(String favId) async {
    try {
      final response = await dio.delete('/fav-meals/$favId');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to remove favorite - Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getMealById(String mealId) async {
    try {
      final response = await dio.get('/meals/$mealId');

      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(
        'Failed to get meal details - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> getUserContributions() async {
    try {
      final response = await dio.get('/food-vision/contributions/me');

      if (response.statusCode == 200) {
        final outerData = response.data['data'];
        final contributions = outerData['data'] as List<dynamic>;
        return contributions;
      }
      throw Exception(
        'Failed to get user contributions - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createMealContribution(
    Map<String, dynamic> data,
    String? imagePath,
  ) async {
    try {
      final hasIngredients = data.containsKey('ingredients');
      final endpoint =
          hasIngredients
              ? '/contribution-meals/ingredients'
              : '/contribution-meals';

      dynamic requestData;

      if (imagePath != null || hasIngredients) {
        final formDataMap = <String, dynamic>{};

        // Add image if present
        if (imagePath != null) {
          formDataMap['image'] = await MultipartFile.fromFile(imagePath);
        }

        // Handle ingredients mode
        if (hasIngredients) {
          final ingredients = data['ingredients'] as List;

          // Add meal fields with 'meal.' prefix
          formDataMap['meal.name'] = data['name'];
          formDataMap['meal.notes'] = data['notes'] ?? '';
          formDataMap['meal.opt'] = 'new';

          // Add tag
          final tags = data['tags'] as List?;
          if (tags != null && tags.isNotEmpty) {
            formDataMap['meal.tags[0]'] = tags.first;
          }

          // Add ingredients with array notation
          for (int i = 0; i < ingredients.length; i++) {
            final ing = ingredients[i] as Map<String, dynamic>;
            formDataMap['ingredients[$i].ingredient_id'] = ing['ingredient_id'];
            formDataMap['ingredients[$i].quantity_kg'] =
                (ing['amount'] as num) / 1000; // Convert g to kg
          }
        } else {
          // Simple mode - add fields directly
          data.forEach((key, value) {
            if (key == 'tags' && value is List && value.isNotEmpty) {
              formDataMap[key] = value.first;
            } else if (value is! List) {
              formDataMap[key] = value;
            }
          });
        }
        requestData = FormData.fromMap(formDataMap);
      } else {
        requestData = data;
      }

      final response = await dio.post(endpoint, data: requestData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(
        'Failed to create contribution - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }
}
