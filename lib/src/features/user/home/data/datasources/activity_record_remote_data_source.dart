import 'package:dio/dio.dart';

abstract class ActivityRecordRemoteDataSource {
  Future<Map<String, dynamic>> createActivityRecord(Map<String, dynamic> data);
  Future<List<dynamic>> getActivityRecordsByDailyLog(String dailyLogId);
  Future<Map<String, dynamic>> updateActivityRecord({
    required String activityRecordId,
    required int durationMinutes,
  });
  Future<Map<String, dynamic>> deleteActivityRecord(String activityRecordId);
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

  @override
  Future<List<dynamic>> getActivityRecordsByDailyLog(String dailyLogId) async {
    try {
      final response = await dio.get(
        '/activity-records/daily-logs/$dailyLogId',
      );

      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      }
      throw Exception(
        'Failed to fetch activity records - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateActivityRecord({
    required String activityRecordId,
    required int durationMinutes,
  }) async {
    try {
      final requestData = {'duration_minutes': durationMinutes};

      final response = await dio.patch(
        '/activity-records/daily-logs/$activityRecordId',
        data: requestData,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception(
        'Failed to update activity record - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> deleteActivityRecord(
    String activityRecordId,
  ) async {
    try {
      final response = await dio.delete(
        '/activity-records/daily-logs/$activityRecordId',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception(
        'Failed to delete activity record - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }
}
