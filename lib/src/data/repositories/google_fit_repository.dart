import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/google_fit_remote_data_source.dart';
import 'package:dartz/dartz.dart';

abstract class GoogleFitRepository {
  Future<Either<Failure, String>> connectGoogleFit();
  Future<Either<Failure, bool>> getConnectionStatus();
}

class GoogleFitRepositoryImpl implements GoogleFitRepository {
  final GoogleFitRemoteDataSource remoteDataSource;

  GoogleFitRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> connectGoogleFit() async {
    try {
      final url = await remoteDataSource.connectGoogleFit();
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> getConnectionStatus() async {
    try {
      final isConnected = await remoteDataSource.getConnectionStatus();
      return Right(isConnected);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
