import 'package:dio/dio.dart';

abstract class FitnessGoalRemoteDataSource {
  Future<Map<String, dynamic>> createFitnessGoal(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getFitnessGoal();
  Future<Map<String, dynamic>> updateFitnessGoal(Map<String, dynamic> data);
}

class FitnessGoalRemoteDataSourceImpl implements FitnessGoalRemoteDataSource {
  final Dio dio;

  FitnessGoalRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> createFitnessGoal(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.post('/fitness-goals', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return response.data;
        } else {
          return {'success': true};
        }
      } else {
        throw Exception('Failed to create fitness goal');
      }
    } catch (e) {
      throw Exception('Failed to create fitness goal: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getFitnessGoal() async {
    try {
      final response = await dio.get('/fitness-goals/current');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch fitness goal');
      }
    } catch (e) {
      throw Exception('Failed to fetch fitness goal: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> updateFitnessGoal(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.patch('/fitness-goals/current', data: data);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update fitness goal');
      }
    } catch (e) {
      throw Exception('Failed to update fitness goal: $e');
    }
  }
}
