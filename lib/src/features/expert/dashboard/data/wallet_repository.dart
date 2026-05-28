import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_local_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WalletRepository {
  late final Dio _dio;
  final AuthLocalDataSource _localDataSource;

  WalletRepository({AuthLocalDataSource? localDataSource})
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

  Future<String> getWalletBalance() async {
    try {
      final response = await _dio.get('/wallets/balance');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        return data['balance']?.toString() ?? '0';
      }
      return '0';
    } catch (e) {
      debugPrint('Error while fetching wallet balance: $e');
      return '0';
    }
  }
}
