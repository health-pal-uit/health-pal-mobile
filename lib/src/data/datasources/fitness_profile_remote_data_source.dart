import 'package:dio/dio.dart';

abstract class FitnessProfileRemoteDataSource {
  Future<List<dynamic>> getFitnessProfiles();
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
}
