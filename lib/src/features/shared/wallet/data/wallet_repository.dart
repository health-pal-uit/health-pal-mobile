import 'package:da1/src/config/env.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_local_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'wallet_model.dart';
import 'transaction_model.dart';

class WalletRepository {
  late final Dio _dio;
  final AuthLocalDataSource _localDataSource;

  WalletRepository({AuthLocalDataSource? localDataSource})
    : _localDataSource =
          localDataSource ??
          AuthLocalDataSourceImpl(storage: const FlutterSecureStorage()) {
    String safeUrl = Env.backendApiUrl;
    if (safeUrl.endsWith('/')) {
      safeUrl = safeUrl.substring(0, safeUrl.length - 1);
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: '$safeUrl/',
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

  Future<WalletModel?> getWalletBalance() async {
    try {
      final response = await _dio.get('/wallets/balance');
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> responseData =
            response.data['data'] = response.data['data'] ?? response.data;

        return WalletModel.fromJson(responseData);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching wallet balance: $e');
      return null;
    }
  }

  Future<bool> topUpTokens(int amount) async {
    try {
      final response = await _dio.post(
        '/wallets/topup',
        data: {'token_amount': amount},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      String errMsg = 'System error occurred. Please try again.';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errMsg = e.response!.data['message'].toString();
      }
      throw Exception(errMsg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/wallets/transactions',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] is List) {
          return (data['data'] as List)
              .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      return [];
    }
  }
}
