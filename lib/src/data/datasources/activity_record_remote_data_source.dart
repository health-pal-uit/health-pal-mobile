import 'package:dio/dio.dart';

abstract class ActivityRecordRemoteDataSource {
  Future<Map<String, dynamic>> createActivityRecord(Map<String, dynamic> data);
}

class ActivityRecordRemoteDataSourceImpl
    implements ActivityRecordRemoteDataSource {
  final Dio dio;

  ActivityRecordRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> createActivityRecord(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.post(
        '/activity-records/daily-logs',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception(
        'Failed to create activity record - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }
}
