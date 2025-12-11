import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/auth_local_data_source.dart';
import 'package:da1/src/data/datasources/auth_remote_data_source.dart';
import 'package:da1/src/data/repositories/auth_repository.dart';
import 'package:da1/src/domain/entities/user.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:da1/src/config/api_config.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginResponse = await remoteDataSource.login(
        email: email,
        password: password,
      );

      await localDataSource.saveToken(loginResponse.accessToken);

      Map<String, dynamic> decodedToken = JwtDecoder.decode(
        loginResponse.accessToken,
      );

      final String userId = decodedToken['sub'];
      final String userEmail = decodedToken['email'];

      final user = User(id: userId, email: userEmail);

      return Right(user);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi không xác định'));
    } on FormatException catch (e) {
      return Left(ServerFailure('Lỗi giải mã token: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signUp({
    required String username,
    required String password,
    required String email,
  }) async {
    try {
      await remoteDataSource.signUp(
        username: username,
        password: password,
        email: email,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi không xác định'));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.deleteToken();
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkVerification(String email) async {
    try {
      final isVerified = await remoteDataSource.checkVerification(email);
      return Right(isVerified);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi không xác định'));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() {
    // TODO: Triển khai logic getCurrentUser ở đây
    // Ví dụ: kiểm tra token, gọi API /me, trả về Right(User) hoặc Left(Failure)
    throw UnimplementedError('Hàm getCurrentUser chưa được triển khai');
  }

  @override
  Future<Either<Failure, User>> loginWithGoogle() async {
    try {
      const redirectUrl = 'da1://auth/callback';
      final authUrl = Uri.parse(
        '${ApiConfig.baseUrl}auth/google/login?redirectUrl=$redirectUrl',
      );
      final launched = await launchUrl(
        authUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        return Left(ServerFailure('Could not launch browser'));
      }

      return Left(ServerFailure('GOOGLE_AUTH_PENDING'));
    } catch (e) {
      return Left(
        ServerFailure('Failed to start Google sign-in: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, User>> processGoogleToken(String token) async {
    try {
      await localDataSource.saveToken(token);

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final String userId = decodedToken['sub'];
      final String userEmail = decodedToken['email'];

      final user = User(id: userId, email: userEmail);

      return Right(user);
    } on FormatException catch (e) {
      return Left(ServerFailure('Lỗi giải mã token: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }
}
