import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/data/models/user_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<void> signUp({
    required String username,
    required String password,
    required String email,
    required String phone,
    required String fullname,
    required bool gender,
    required String birthday,
  });

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<bool> checkVerification(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      ApiConfig.login,
      data: {'email': email, 'password': password},
    );
    return LoginResponseModel.fromJson(response.data);
  }

  @override
  Future<void> signUp({
    required String username,
    required String password,
    required String email,
    required String phone,
    required String fullname,
    required bool gender,
    required String birthday,
  }) async {
    await dio.post(
      ApiConfig.signup,
      data: {
        'username': username,
        'password': password,
        'email': email,
        'phone': phone,
        'fullname': fullname,
        'gender': gender,
        'birth_date': birthday,
      },
    );
  }

  @override
  Future<void> logout() async {
    await dio.get(ApiConfig.logout);
  }

  @override
  Future<bool> checkVerification(String email) async {
    final response = await dio.get(
      ApiConfig.checkVerification.replaceFirst('{email}', email),
    );
    return response.data['data']['isVerified'];
  }
}
