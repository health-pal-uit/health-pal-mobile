import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_local_data_source.dart';
import 'package:da1/src/features/user/profile/data/health_connect_service.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Failure {
  final String message;
  const Failure(this.message);
}

class HealthConnectRepository {
  late final Dio _dio;
  final AuthLocalDataSource _localDataSource;

  HealthConnectRepository({
    AuthLocalDataSource? localDataSource,
    HealthConnectService? healthConnectService,
  }) : _localDataSource =
           localDataSource ??
           AuthLocalDataSourceImpl(storage: const FlutterSecureStorage()),
       _dio = Dio(
         BaseOptions(
           baseUrl: ApiConfig.baseUrl,
           connectTimeout: const Duration(seconds: 30),
           receiveTimeout: const Duration(seconds: 30),
         ),
       ) {
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

  Future<Either<Failure, bool>> getConnectionStatus() async {
    try {
      final response = await _dio.get('/users/me');
      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['data'] as Map<String, dynamic>?;
        final isEnabled = userData?['health_connect_enabled'] == true;
        return Right(isEnabled);
      }
      return const Left(Failure('Failed to parse user connection status.'));
    } catch (e) {
      debugPrint('Error getting Health Connect status: $e');
      return Left(Failure('System error profile sync: ${e.toString()}'));
    }
  }

  Map<String, List<T>> allDataCast<T>(Map<String, List<dynamic>> original) {
    return original.map((key, value) => MapEntry(key, List<T>.from(value)));
  }
}
