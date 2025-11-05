import 'package:da1/src/core/errors/exceptions.dart';
import 'package:da1/src/data/datasources/auth_local_data_source.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;

  AuthInterceptor({required this.localDataSource});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path.contains('/auth/login') ||
        options.path.contains('/auth/signup')) {
      return handler.next(options);
    }

    final token = await localDataSource.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await localDataSource.deleteToken();
      return handler.reject(UnauthorizedException(err.requestOptions));
    }
    return handler.next(err);
  }
}
