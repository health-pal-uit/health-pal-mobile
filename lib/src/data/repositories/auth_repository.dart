import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> signUp({
    required String username,
    required String password,
    required String email,
  });

  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> checkVerification(String email);
  Future<Either<Failure, User>> loginWithGoogle();
  Future<Either<Failure, User>> getCurrentUser();
}
