import 'package:da1/src/app.dart';
import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/config/env.dart';
import 'package:da1/src/config/routes.dart';
import 'package:da1/src/data/repositories/auth_repository.dart';
import 'package:da1/src/data/repositories/user_repository.dart';
import 'package:da1/src/data/repositories/user_repository_impl.dart';
import 'package:da1/src/data/datasources/user_remote_data_source.dart';
import 'package:da1/src/data/repositories/fitness_profile_repository.dart';
import 'package:da1/src/data/datasources/fitness_profile_remote_data_source.dart';
import 'package:da1/src/data/repositories/meal_repository.dart';
import 'package:da1/src/data/datasources/meal_remote_data_source.dart';
import 'package:da1/src/data/repositories/daily_meal_repository.dart';
import 'package:da1/src/data/datasources/daily_meal_remote_data_source.dart';
import 'package:da1/src/data/repositories/daily_log_repository.dart';
import 'package:da1/src/data/datasources/daily_log_remote_data_source.dart';
import 'package:da1/src/core/services/deep_link_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:da1/src/presentation/bloc/auth/auth.dart';
import 'package:da1/src/presentation/bloc/user/user.dart';
import 'package:da1/src/data/repositories/auth_repository_impl.dart';
import 'package:da1/src/data/datasources/auth_local_data_source.dart';
import 'package:da1/src/data/datasources/auth_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:da1/src/domain/entities/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

final deepLinkService = DeepLinkService();
String? _pendingResetPasswordDeepLink;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final AuthLocalDataSource localDataSource = AuthLocalDataSourceImpl(
    storage: secureStorage,
  );

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 5),
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await localDataSource.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ),
  );

  final AuthRemoteDataSource remoteDataSource = AuthRemoteDataSourceImpl(
    dio: dio,
  );
  final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  final UserRemoteDataSource userRemoteDataSource = UserRemoteDataSourceImpl(
    dio: dio,
  );
  final UserRepository userRepository = UserRepositoryImpl(
    remoteDataSource: userRemoteDataSource,
  );

  final FitnessProfileRemoteDataSource fitnessProfileRemoteDataSource =
      FitnessProfileRemoteDataSourceImpl(dio: dio);
  final FitnessProfileRepository fitnessProfileRepository =
      FitnessProfileRepositoryImpl(
        remoteDataSource: fitnessProfileRemoteDataSource,
      );

  final MealRemoteDataSource mealRemoteDataSource = MealRemoteDataSourceImpl(
    dio: dio,
  );
  final MealRepository mealRepository = MealRepositoryImpl(
    remoteDataSource: mealRemoteDataSource,
  );

  final DailyMealRemoteDataSource dailyMealRemoteDataSource =
      DailyMealRemoteDataSourceImpl(dio: dio);
  final DailyMealRepository dailyMealRepository = DailyMealRepositoryImpl(
    remoteDataSource: dailyMealRemoteDataSource,
  );

  final DailyLogRemoteDataSource dailyLogRemoteDataSource =
      DailyLogRemoteDataSourceImpl(dio: dio);
  final DailyLogRepository dailyLogRepository = DailyLogRepositoryImpl(
    remoteDataSource: dailyLogRemoteDataSource,
  );

  final AuthBloc authBloc = AuthBloc(authRepository: authRepository);
  final UserBloc userBloc = UserBloc(userRepository: userRepository);

  // Set repositories for routing
  AppRoutes.setFitnessProfileRepository(fitnessProfileRepository);
  AppRoutes.setMealRepository(mealRepository);
  AppRoutes.setDailyMealRepository(dailyMealRepository);
  AppRoutes.setDailyLogRepository(dailyLogRepository);

  deepLinkService.initDeepLinks(
    onTokenReceived: (String token) async {
      try {
        await localDataSource.saveToken(token);

        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final String userId = decodedToken['sub'];
        final String userEmail = decodedToken['email'];

        final user = User(id: userId, email: userEmail);

        authBloc.add(GoogleSignInSuccess(user));
      } catch (e) {
        authBloc.add(GoogleSignInFailed('Failed to process token: $e'));
      }
    },
    onError: (String error) {
      authBloc.add(GoogleSignInFailed(error));
    },
    onPasswordResetLink: (Uri uri) {
      _pendingResetPasswordDeepLink = '/reset-password';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pendingResetPasswordDeepLink != null) {
          AppRoutes.router.go(_pendingResetPasswordDeepLink!);
          _pendingResetPasswordDeepLink = null;
        }
      });
    },
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => authBloc),
        BlocProvider<UserBloc>(create: (context) => userBloc),
      ],
      child: const App(),
    ),
  );
}
