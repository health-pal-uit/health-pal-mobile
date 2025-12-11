import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/data/models/user_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<void> signUp({
    required String username,
    required String password,
    required String email,
  });

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<bool> checkVerification(String email);

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<void> verifyResetToken(String token);
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
  }) async {
    await dio.post(
      ApiConfig.signup,
      data: {'username': username, 'password': password, 'email': email},
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

  @override
  Future<void> forgotPassword(String email) async {
    await dio.post('/auth/forgot-password', data: {'email': email});
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await dio.post(
      '/auth/reset-password',
      data: {'token': token, 'newPassword': newPassword},
    );
  }

  @override
  Future<void> verifyResetToken(String token) async {
    await dio.get('/auth/verify-reset-token/$token');
  }
}
