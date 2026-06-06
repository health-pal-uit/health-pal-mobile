import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_local_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConsultationRepository {
  late final Dio _dio;
  final AuthLocalDataSource _localDataSource;

  ConsultationRepository({AuthLocalDataSource? localDataSource})
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

  Future<bool> createConsultation(String bookingId) async {
    try {
      final response = await _dio.post(
        '/consultations/me',
        data: {'booking_id': bookingId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      String errMsg =
          'System error when creating consultation, please try again.';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errMsg = e.response!.data['message'].toString();
      }
      throw Exception(errMsg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> endConsultation({
    required String consultationId,
    required int durationMinutes,
    required int tokensCharged,
    required String resultText,
  }) async {
    try {
      final response = await _dio.patch(
        '/consultations/$consultationId/end',
        data: {
          'duration_minutes': durationMinutes,
          'tokens_charged': tokensCharged,
          'result': resultText,
          'status': 'completed',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      String errMsg =
          'Can not end consultation due to system error, please try again.';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errMsg = e.response!.data['message'].toString();
      }
      debugPrint('HTTP Error: $errMsg');
      throw Exception(errMsg);
    } catch (e) {
      debugPrint('Exception error: $e');
      throw Exception('Unknown error: ${e.toString()}');
    }
  }
}
