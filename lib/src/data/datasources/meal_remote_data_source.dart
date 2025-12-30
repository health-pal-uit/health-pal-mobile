import 'package:dio/dio.dart';

abstract class MealRemoteDataSource {
  Future<List<dynamic>> searchMeals(String name);
  Future<List<dynamic>> getFavoriteMeals({int page = 1, int limit = 10});
  Future<bool> checkIfFavorited(String mealId);
  Future<void> toggleFavorite(String mealId);
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
        // Extract the meal object from each favorite
        return favMeals.map((fav) => fav['meal']).toList();
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
  Future<void> toggleFavorite(String mealId) async {
    try {
      final response = await dio.post('/fav-meals/$mealId');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to toggle favorite - Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }
}
