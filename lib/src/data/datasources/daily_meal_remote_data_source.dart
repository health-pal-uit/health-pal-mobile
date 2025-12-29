import 'package:dio/dio.dart';

abstract class DailyMealRemoteDataSource {
  Future<Map<String, dynamic>> addDailyMeal({
    required String mealId,
    required String mealType,
    required double quantityKg,
    required String loggedAt,
  });
}

class DailyMealRemoteDataSourceImpl implements DailyMealRemoteDataSource {
  final Dio dio;

  DailyMealRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> addDailyMeal({
    required String mealId,
    required String mealType,
    required double quantityKg,
    required String loggedAt,
  }) async {
    try {
      final requestData = {
        'meal_id': mealId,
        'meal_type': mealType,
        'quantity_kg': quantityKg,
        'logged_at': loggedAt,
      };

      final response = await dio.post('/daily-meals', data: requestData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(
        'Failed to add daily meal - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }
}
