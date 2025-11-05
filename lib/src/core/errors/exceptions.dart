import 'package:dio/dio.dart';

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class UnauthorizedException extends DioException {
  UnauthorizedException(RequestOptions requestOptions)
    : super(requestOptions: requestOptions);

  @override
  String get message => 'Login session expired';
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}
