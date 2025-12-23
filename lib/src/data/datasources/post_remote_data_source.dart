import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/data/models/post_model.dart';
import 'package:dio/dio.dart';

abstract class PostRemoteDataSource {
  Future<PostsResponse> getPosts();
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio dio;

  PostRemoteDataSourceImpl({required this.dio});

  @override
  Future<PostsResponse> getPosts() async {
    try {
      final response = await dio.get(ApiConfig.getPosts);
      return PostsResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final message = e.response?.statusMessage;

        if (statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        } else if (statusCode == 403) {
          throw Exception(
            'Forbidden: You don\'t have permission to access this resource',
          );
        } else {
          throw Exception('Failed to fetch posts ($statusCode): $message');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
