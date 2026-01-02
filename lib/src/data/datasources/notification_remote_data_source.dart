import 'package:dio/dio.dart';

abstract class NotificationRemoteDataSource {
  Future<Map<String, dynamic>> getNotifications({int page = 1, int limit = 10});
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;

  NotificationRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '/notifications',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(
        'Failed to get notifications - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await dio.patch('/notifications/markAsRead/$notificationId');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to mark notification as read - Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await dio.patch('/notifications/markAllAsRead');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to mark all notifications as read - Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await dio.delete('/notifications/$notificationId');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to delete notification - Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }
}
