import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_local_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ExpertSettingsRepository {
  late final Dio _dio;
  final AuthLocalDataSource _localDataSource;

  ExpertSettingsRepository({AuthLocalDataSource? localDataSource})
    : _localDataSource =
          localDataSource ??
          AuthLocalDataSourceImpl(storage: const FlutterSecureStorage()) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _localDataSource.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> getMyExpertProfile() async {
    try {
      final response = await _dio.get('/experts/me');
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching expert profile: $e');
      throw Exception('Failed to load profile data.');
    }
  }

  Future<bool> updateSettings({
    required String expertId,
    required String fullname,
    required String phone,
    required String bio,
    required int tokenPerMinute,
  }) async {
    try {
      final userFormData = FormData.fromMap({
        if (fullname.isNotEmpty) 'fullname': fullname,
        if (phone.isNotEmpty) 'phone': phone,
      });
      await _dio.patch('/users/me', data: userFormData);

      await _dio.patch(
        '/experts/$expertId',
        data: {'bio': bio, 'token_per_minute': tokenPerMinute},
      );

      return true;
    } on DioException catch (e) {
      String errMsg = 'System error occurred.';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errMsg = e.response!.data['message'].toString();
      }
      throw Exception(errMsg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
