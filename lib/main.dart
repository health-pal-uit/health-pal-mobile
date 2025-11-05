import 'package:da1/src/app.dart';
import 'package:da1/src/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:da1/src/presentation/bloc/auth/auth.dart';
import 'package:da1/src/data/repositories/auth_repository_impl.dart';
import 'package:da1/src/data/datasources/auth_local_data_source.dart';
import 'package:da1/src/data/datasources/auth_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  final Dio dio = Dio();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final AuthLocalDataSource localDataSource = AuthLocalDataSourceImpl(
    storage: secureStorage,
  );
  final AuthRemoteDataSource remoteDataSource = AuthRemoteDataSourceImpl(
    dio: dio,
  );
  final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  final AuthBloc authBloc = AuthBloc(authRepository: authRepository);

  runApp(
    BlocProvider<AuthBloc>(create: (context) => authBloc, child: const App()),
  );
}
