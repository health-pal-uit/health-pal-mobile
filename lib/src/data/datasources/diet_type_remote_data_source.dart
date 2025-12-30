import 'package:dio/dio.dart';

abstract class DietTypeRemoteDataSource {
  Future<List<dynamic>> getDietTypes();
}

class DietTypeRemoteDataSourceImpl implements DietTypeRemoteDataSource {
  final Dio dio;

  DietTypeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getDietTypes() async {
    try {
      final response = await dio.get('/diet-types');

      if (response.statusCode == 200) {
        return response.data['data']['data'] as List<dynamic>;
      } else {
        throw Exception('Failed to fetch diet types');
      }
    } catch (e) {
      throw Exception('Failed to fetch diet types: $e');
    }
  }
}
