import 'package:dio/dio.dart';

abstract class GoogleFitRemoteDataSource {
  Future<String> connectGoogleFit();
  Future<bool> getConnectionStatus();
  Future<bool> disconnectGoogleFit();
}

class GoogleFitRemoteDataSourceImpl implements GoogleFitRemoteDataSource {
  final Dio dio;

  GoogleFitRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> connectGoogleFit() async {
    try {
      // Don't follow redirects - we want to capture the redirect URL
      final response = await dio.get(
        '/google-fit/connect',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 400,
        ),
      );

      // Check if it's a redirect (302, 301, etc.)
      if (response.statusCode == 302 ||
          response.statusCode == 301 ||
          response.statusCode == 303 ||
          response.statusCode == 307 ||
          response.statusCode == 308) {
        final location = response.headers.value('location');
        if (location != null) {
          return location;
        }
        throw Exception('Redirect response but no Location header found');
      }

      if (response.statusCode == 200) {
        // Handle different response structures
        if (response.data is String) {
          return response.data as String;
        } else if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;

          // Check if there's a 'data' wrapper
          if (data.containsKey('data')) {
            final innerData = data['data'];
            if (innerData is String) {
              return innerData;
            } else if (innerData is Map<String, dynamic>) {
              return innerData['url'] as String;
            }
          }
          // Direct url in response
          if (data.containsKey('url')) {
            return data['url'] as String;
          }
        }
        throw Exception('Unexpected response format: ${response.data}');
      }
      throw Exception(
        'Failed to connect to Google Fit - Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<bool> getConnectionStatus() async {
    try {
      final response = await dio.get('/google-fit/status');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('data')) {
          final innerData = data['data'] as Map<String, dynamic>;
          final connected = innerData['connected'] as bool;
          return connected;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> disconnectGoogleFit() async {
    try {
      final response = await dio.delete('/google-fit/disconnect');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('data')) {
          final innerData = data['data'] as Map<String, dynamic>;
          return innerData['success'] as bool? ?? true;
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
