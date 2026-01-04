import 'package:dio/dio.dart';

abstract class DeviceRemoteDataSource {
  Future<void> registerDevice({
    required String deviceId,
    required String pushToken,
  });
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final Dio dio;

  DeviceRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> registerDevice({
    required String deviceId,
    required String pushToken,
  }) async {
    try {
      final response = await dio.post(
        '/devices',
        data: {'device_id': deviceId, 'push_token': pushToken},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to register device - Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }
}
