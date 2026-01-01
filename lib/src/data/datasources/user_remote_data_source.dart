import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/data/models/user_model.dart';
import 'package:dio/dio.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> updateAvatar(String imagePath);
  Future<UserModel> updateProfile({String? imagePath, String? fullname});
  Future<Map<String, dynamic>> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
  });
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> updateAvatar(String imagePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      ),
    });

    try {
      final response = await dio.patch(
        ApiConfig.updateProfile,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      }
      throw Exception(
        'Failed to update avatar - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<UserModel> updateProfile({String? imagePath, String? fullname}) async {
    final Map<String, dynamic> formDataMap = {};

    if (imagePath != null) {
      formDataMap['image'] = await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      );
    }

    if (fullname != null) {
      formDataMap['fullname'] = fullname;
    }

    final formData = FormData.fromMap(formDataMap);

    try {
      final response = await dio.patch(
        ApiConfig.updateProfile,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      }
      throw Exception(
        'Failed to update profile - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dio.get(
        '/users/search',
        queryParameters: {'q': query, 'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        final users =
            data
                .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
                .toList();

        return {'users': users, 'hasMore': data.length >= limit};
      }

      throw Exception('Failed to search users');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to search users');
    }
  }
}
