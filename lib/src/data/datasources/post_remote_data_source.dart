import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/data/models/comment_model.dart';
import 'package:da1/src/data/models/post_model.dart';
import 'package:dio/dio.dart';

abstract class PostRemoteDataSource {
  Future<PostsResponse> getPosts({required int page, required int limit});
  Future<void> reportPost(String postId);
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<CommentsResponse> getComments(String postId);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio dio;

  PostRemoteDataSourceImpl({required this.dio});

  @override
  Future<PostsResponse> getPosts({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await dio.get(
        ApiConfig.getPosts,
        queryParameters: {'page': page, 'limit': limit},
      );
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

  @override
  Future<void> reportPost(String postId) async {
    try {
      final endpoint = ApiConfig.reportPost(postId);

      await dio.get(endpoint);
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final message = e.response?.statusMessage;

        if (statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        } else if (statusCode == 400) {
          throw Exception('You have already reported this post');
        } else if (statusCode == 404) {
          throw Exception('Post not found or endpoint incorrect');
        } else {
          throw Exception('Failed to report post ($statusCode): $message');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<void> likePost(String postId) async {
    try {
      final endpoint = ApiConfig.likePost(postId);
      await dio.post(endpoint);
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final message = e.response?.statusMessage;

        if (statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        } else if (statusCode == 400) {
          throw Exception('You have already liked this post');
        } else if (statusCode == 404) {
          throw Exception('Post not found');
        } else {
          throw Exception('Failed to like post ($statusCode): $message');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<void> unlikePost(String postId) async {
    try {
      final endpoint = ApiConfig.unlikePost(postId);
      await dio.delete(endpoint);
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final message = e.response?.statusMessage;

        if (statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        } else if (statusCode == 400) {
          throw Exception('You have not liked this post');
        } else if (statusCode == 404) {
          throw Exception('Post not found');
        } else {
          throw Exception('Failed to unlike post ($statusCode): $message');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<CommentsResponse> getComments(String postId) async {
    try {
      final endpoint = ApiConfig.getComments(postId);
      final response = await dio.get(endpoint);
      return CommentsResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final message = e.response?.statusMessage;

        if (statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        } else if (statusCode == 404) {
          throw Exception('Post not found');
        } else {
          throw Exception('Failed to fetch comments ($statusCode): $message');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
