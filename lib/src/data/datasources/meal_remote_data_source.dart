import 'package:dio/dio.dart';

abstract class MealRemoteDataSource {
  Future<List<dynamic>> searchMeals(String name);
  Future<List<dynamic>> getFavoriteMeals({int page = 1, int limit = 10});
  Future<bool> checkIfFavorited(String mealId);
  Future<void> addFavorite(String userId, String mealId);
  Future<void> removeFavorite(String favId);
  Future<Map<String, dynamic>> getMealById(String mealId);
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
}
