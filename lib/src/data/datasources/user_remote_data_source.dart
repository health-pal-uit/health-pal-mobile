import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/data/models/user_model.dart';
import 'package:dio/dio.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> updateAvatar(String imagePath);
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

    final response = await dio.patch(ApiConfig.updateProfile, data: formData);

    return UserModel.fromJson(response.data['data']);
  }
}
