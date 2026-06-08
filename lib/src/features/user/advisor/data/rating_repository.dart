import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_local_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RatingRepository {
  late final Dio _dio;
  final AuthLocalDataSource _localDataSource;

  RatingRepository({AuthLocalDataSource? localDataSource})
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

  Future<bool> submitReview({
    required String consultationId,
    required int score,
    required String comment,
  }) async {
    try {
      final response = await _dio.post(
        '/expert-ratings/me',
        data: {
          'consultation_id': consultationId,
          'score': score,
          'comment': comment,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      String errMsg = 'System error while submitting review.';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errMsg = e.response!.data['message'].toString();
      }
      debugPrint('HTTP Error submitting review: $errMsg');
      throw Exception(errMsg);
    } catch (e) {
      debugPrint('Exception submitting review: $e');
      throw Exception('System error: ${e.toString()}');
    }
  }
}
