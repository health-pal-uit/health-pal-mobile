import 'package:da1/src/core/errors/failure.dart';
import 'package:da1/src/data/datasources/device_remote_data_source.dart';
import 'package:dartz/dartz.dart';

abstract class DeviceRepository {
  Future<Either<Failure, void>> registerDevice({
    required String deviceId,
    required String pushToken,
  });
}

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource remoteDataSource;

  DeviceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> registerDevice({
    required String deviceId,
    required String pushToken,
  }) async {
    try {
      await remoteDataSource.registerDevice(
        deviceId: deviceId,
        pushToken: pushToken,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
