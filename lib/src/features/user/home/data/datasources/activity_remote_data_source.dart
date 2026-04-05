import 'package:dio/dio.dart';

abstract class ActivityRemoteDataSource {
  Future<List<dynamic>> getActivities({int page = 1, int limit = 20});
  Future<List<dynamic>> searchActivities({
    required String name,
    int page = 1,
    int limit = 20,
  });
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final Dio dio;

  ActivityRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getActivities({int page = 1, int limit = 20}) async {
    try {
      final response = await dio.get(
        '/activities',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data is List) {
          return data;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to fetch activities');
      }
    } catch (e) {
      throw Exception('Failed to fetch activities: $e');
    }
  }

  @override
  Future<List<dynamic>> searchActivities({
    required String name,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dio.post(
        '/activities/search',
        data: {'name': name},
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];

        if (data is List) {
          return data;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to search activities');
      }
    } catch (e) {
      throw Exception('Failed to search activities: $e');
    }
  }
}
