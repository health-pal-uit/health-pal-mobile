import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/features/expert/dashboard/data/booking_model.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_local_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BookingRepository {
  late final Dio _dio;
  final AuthLocalDataSource _localDataSource;

  BookingRepository({AuthLocalDataSource? localDataSource})
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

  Future<List<BookingModel>> getPendingBookings() async {
    try {
      final response = await _dio.get('/bookings/me/pending');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] is List) {
          return (data['data'] as List)
              .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching pending bookings: $e');
      throw Exception('Failed to load pending bookings: $e');
    }
  }

  Future<bool> acceptBooking(String bookingId) async {
    try {
      final response = await _dio.patch('/bookings/me/$bookingId/verify');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      String errMsg = 'System error while accepting booking, please try again.';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errMsg = e.response!.data['message'].toString();
      }
      throw Exception(errMsg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> declineBooking(String bookingId) async {
    try {
      final response = await _dio.patch('/bookings/me/$bookingId/deny');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      String errMsg = 'System error while declining booking, please try again.';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errMsg = e.response!.data['message'].toString();
      }
      throw Exception(errMsg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
