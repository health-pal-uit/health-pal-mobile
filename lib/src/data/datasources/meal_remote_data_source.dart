import 'package:dio/dio.dart';

abstract class MealRemoteDataSource {
  Future<List<dynamic>> searchMeals(String name);
}

class MealRemoteDataSourceImpl implements MealRemoteDataSource {
  final Dio dio;

  MealRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> searchMeals(String name) async {
    try {
      final response = await dio.post(
        '/meals/search',
        data: {'name': name},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // The response structure is nested: {data: {data: [...]}}
        final outerData = response.data['data'];
        final meals = outerData['data'] as List<dynamic>;
        return meals;
      }
      throw Exception('Failed to search meals - Status: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }
}
