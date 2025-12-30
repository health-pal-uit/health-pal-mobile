import 'package:dio/dio.dart';

abstract class ActivityRemoteDataSource {
  Future<List<dynamic>> getActivities();
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final Dio dio;

  ActivityRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getActivities() async {
    try {
      List<dynamic> allActivities = [];
      int page = 1;
      int limit = 50;
      bool hasMore = true;

      while (hasMore) {
        final response = await dio.get(
          '/activities',
          queryParameters: {'page': page, 'limit': limit},
        );

        if (response.statusCode == 200) {
          final data = response.data['data'];

          if (data is List) {
            allActivities.addAll(data);

            // Check if there are more pages
            // If we received less than limit items, we've reached the end
            if (data.length < limit) {
              hasMore = false;
            } else {
              page++;
            }
          } else {
            // Handle case where data might be paginated object
            hasMore = false;
          }
        } else {
          throw Exception('Failed to fetch activities');
        }
      }

      return allActivities;
    } catch (e) {
      throw Exception('Failed to fetch activities: $e');
    }
  }
}
