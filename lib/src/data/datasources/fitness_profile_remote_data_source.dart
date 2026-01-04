import 'package:dio/dio.dart';

abstract class FitnessProfileRemoteDataSource {
  Future<List<dynamic>> getFitnessProfiles();
  Future<Map<String, dynamic>> createFitnessProfile(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getMyFitnessProfile();
  Future<Map<String, dynamic>> updateFitnessProfile(Map<String, dynamic> data);
  Future<Map<String, dynamic>> calculateBodyFat(Map<String, dynamic> data);
}

class FitnessProfileRemoteDataSourceImpl
    implements FitnessProfileRemoteDataSource {
  final Dio dio;

  FitnessProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getFitnessProfiles() async {
    try {
      final response = await dio.get('/fitness-profiles/my-profiles');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data;
      } else {
        throw Exception('Failed to fetch fitness profiles');
      }
    } catch (e) {
      throw Exception('Failed to fetch fitness profiles: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createFitnessProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      // Remove null values from the payload
      final cleanData = Map<String, dynamic>.from(data)
        ..removeWhere((key, value) => value == null);

      final response = await dio.post('/fitness-profiles', data: cleanData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle both direct data and wrapped response
        if (response.data is Map<String, dynamic>) {
          return response.data;
        } else {
          return {'success': true};
        }
      } else {
        throw Exception('Failed to create fitness profile');
      }
    } catch (e) {
      throw Exception('Failed to create fitness profile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getMyFitnessProfile() async {
    try {
      final response = await dio.get('/fitness-profiles/me');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch fitness profile');
      }
    } catch (e) {
      throw Exception('Failed to fetch fitness profile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> updateFitnessProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      // Remove null values from the payload
      final cleanData = Map<String, dynamic>.from(data)
        ..removeWhere((key, value) => value == null);

      final response = await dio.patch('/fitness-profiles/me', data: cleanData);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update fitness profile');
      }
    } catch (e) {
      throw Exception('Failed to update fitness profile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> calculateBodyFat(
    Map<String, dynamic> data,
  ) async {
    try {
      final cleanData = Map<String, dynamic>.from(data)
        ..removeWhere((key, value) => value == null);

      final response = await dio.patch(
        '/fitness-profiles/calculate-bfp',
        data: cleanData,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to calculate body fat percentage');
      }
    } catch (e) {
      throw Exception('Failed to calculate body fat percentage: $e');
    }
  }
}
