import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_local_data_source.dart';
import 'package:da1/src/features/user/advisor/domain/expert.dart';
import 'package:da1/src/features/user/advisor/domain/expert_rating.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdvisorRepository {
  late final Dio _dio;
  final AuthLocalDataSource _localDataSource;

  AdvisorRepository({AuthLocalDataSource? localDataSource})
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

  Future<List<Expert>> fetchExperts() async {
    try {
      final response = await _dio.get('/experts');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] is List) {
          return (data['data'] as List)
              .map((e) => Expert.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching experts in Repository: $e');
      throw Exception('Failed to load experts: $e');
    }
  }

  Future<List<ExpertRating>> fetchExpertRatings(String expertId) async {
    try {
      final response = await _dio.get('/experts/$expertId/ratings');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] is List) {
          return (data['data'] as List)
              .map((e) => ExpertRating.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching ratings for expert $expertId: $e');
      throw Exception('Failed to load ratings: $e');
    }
  }

  Future<bool> createBooking({
    required String expertId,
    required String callType,
    required String scheduledAt,
    required String clientNote,
  }) async {
    try {
      final payload = {
        "expert_id": expertId,
        "call_type": callType,
        "scheduled_at": scheduledAt,
        "client_note": clientNote,
      };

      final response = await _dio.post('/bookings/me', data: payload);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      String errMsg = 'There was an error, please try again later.';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errMsg = e.response!.data['message'].toString();
      }
      throw Exception(errMsg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
