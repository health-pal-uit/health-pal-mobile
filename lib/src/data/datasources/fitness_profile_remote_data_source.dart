import 'package:dio/dio.dart';

abstract class FitnessProfileRemoteDataSource {
  Future<List<dynamic>> getFitnessProfiles();
  Future<Map<String, dynamic>> createFitnessProfile(Map<String, dynamic> data);
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
}
