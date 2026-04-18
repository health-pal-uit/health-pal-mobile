import 'package:dio/dio.dart';

abstract class DailyLogRemoteDataSource {
  Future<Map<String, dynamic>> getDailyLog(String date);
}

class DailyLogRemoteDataSourceImpl implements DailyLogRemoteDataSource {
  final Dio dio;

  DailyLogRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getDailyLog(String date) async {
    try {
      final response = await dio.get('/daily-logs/date/$date');

      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(
        'Failed to get daily log - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }
}
