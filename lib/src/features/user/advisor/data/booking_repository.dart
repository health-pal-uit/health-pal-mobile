import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_local_data_source.dart';
import 'package:da1/src/features/user/advisor/domain/booking.dart';
import 'package:dio/dio.dart';
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

  Future<List<Booking>> fetchMyBookings() async {
    try {
      final response = await _dio.get('/bookings/me');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> dataList =
            response.data['data'] is List
                ? response.data['data']
                : response.data;
        return dataList.map((e) => Booking.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load bookings: $e');
    }
  }

  Future<void> cancelBooking({
    required String bookingId,
    required String status,
  }) async {
    try {
      if (status == 'pending') {
        await _dio.patch('/bookings/me/$bookingId/deny');
      } else {
        await _dio.delete('/bookings/$bookingId');
      }
    } on DioException catch (e) {
      String errMsg =
          e.response?.data?['message']?.toString() ??
          'Failed to cancel appointment.';
      throw Exception(errMsg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> fetchConsultationDetails(
    String consultationId,
  ) async {
    try {
      final response = await _dio.get('/consultations/$consultationId');
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to parse consultation details.');
    } on DioException catch (e) {
      String errMsg =
          e.response?.data?['message']?.toString() ??
          'Failed to fetch consultation details.';
      throw Exception(errMsg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
