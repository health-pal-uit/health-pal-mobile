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
  final String baseUrl = "http://10.0.2.2:3001";

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    // Dựa trên login.dto.ts, backend mong nhận { email, password }
    final response = await dio.post(
      '$baseUrl/auth/login',
      data: {'email': email, 'password': password},
    );
    // Parse JSON response thành Model
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
      '$baseUrl/auth/signup',
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
    // GET /auth/logout
    // Endpoint này có thể cần gửi kèm Access Token (xem mục 5)
    await dio.get('$baseUrl/auth/logout');
  }

  @override
  Future<bool> checkVerification(String email) async {
    final response = await dio.get('$baseUrl/auth/check-verification/$email');
    return response.data['data']['isVerified'];
  }
}
