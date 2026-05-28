import 'package:da1/src/app.dart';
import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/config/env.dart';
import 'package:da1/src/config/routes.dart';
import 'package:da1/src/features/expert/auth/data/datasources/expert_remote_data_source.dart';
import 'package:da1/src/features/expert/auth/data/expert_repository.dart';
import 'package:da1/src/features/shared/auth/data/auth_repository.dart';
import 'package:da1/src/features/user/home/data/user_repository.dart';
import 'package:da1/src/features/user/home/data/datasources/user_repository_impl.dart';
import 'package:da1/src/features/user/home/data/datasources/user_remote_data_source.dart';
import 'package:da1/src/features/user/profile/data/fitness_profile_repository.dart';
import 'package:da1/src/features/user/profile/data/datasources/fitness_profile_remote_data_source.dart';
import 'package:da1/src/features/shared/auth/data/fitness_goal_repository.dart';
import 'package:da1/src/features/shared/auth/data/datasources/fitness_goal_remote_data_source.dart';
import 'package:da1/src/features/user/home/data/meal_repository.dart';
import 'package:da1/src/features/user/home/data/datasources/meal_remote_data_source.dart';
import 'package:da1/src/features/user/home/data/daily_meal_repository.dart';
import 'package:da1/src/features/user/home/data/datasources/daily_meal_remote_data_source.dart';
import 'package:da1/src/features/user/home/data/daily_log_repository.dart';
import 'package:da1/src/features/user/home/data/datasources/daily_log_remote_data_source.dart';
import 'package:da1/src/features/user/home/data/diet_type_repository.dart';
import 'package:da1/src/features/user/home/data/datasources/diet_type_remote_data_source.dart';
import 'package:da1/src/features/user/home/data/activity_repository.dart';
import 'package:da1/src/features/user/home/data/datasources/activity_remote_data_source.dart';
import 'package:da1/src/features/user/home/data/activity_record_repository.dart';
import 'package:da1/src/features/user/home/data/datasources/activity_record_remote_data_source.dart';
import 'package:da1/src/features/user/chat/data/chat_session_repository.dart';
import 'package:da1/src/features/user/chat/data/datasources/chat_session_remote_data_source.dart';
import 'package:da1/src/features/user/chat/data/chat_message_repository.dart';
import 'package:da1/src/features/user/chat/data/datasources/chat_message_remote_data_source.dart';
import 'package:da1/src/features/user/home/data/challenge_repository.dart';
import 'package:da1/src/features/user/home/data/datasources/challenge_remote_data_source.dart';
import 'package:da1/src/features/user/home/data/medal_repository.dart';
import 'package:da1/src/features/user/home/data/datasources/medal_remote_data_source.dart';
import 'package:da1/src/features/user/notifications/data/notification_repository.dart';
import 'package:da1/src/features/user/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:da1/src/features/user/profile/data/google_fit_repository.dart';
import 'package:da1/src/features/user/profile/data/datasources/google_fit_remote_data_source.dart';
import 'package:da1/src/features/shared/notifications/data/device_repository.dart';
import 'package:da1/src/features/shared/notifications/data/datasources/device_remote_data_source.dart';
import 'package:da1/src/core/services/deep_link_service.dart';
import 'package:da1/src/core/services/local_notification_service.dart';
import 'package:da1/src/core/services/device_registration_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:da1/src/core/bloc/auth/auth.dart';
import 'package:da1/src/core/bloc/user/user.dart';
import 'package:da1/src/features/shared/auth/data/auth_repository_impl.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_local_data_source.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:da1/src/core/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'firebase_options.dart';

final deepLinkService = DeepLinkService();
String? _pendingResetPasswordDeepLink;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(
    DeviceRegistrationService.backgroundMessageHandler,
  );

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
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
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

  final FitnessGoalRemoteDataSource fitnessGoalRemoteDataSource =
      FitnessGoalRemoteDataSourceImpl(dio: dio);
  final FitnessGoalRepository fitnessGoalRepository = FitnessGoalRepositoryImpl(
    remoteDataSource: fitnessGoalRemoteDataSource,
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

  final DietTypeRemoteDataSource dietTypeRemoteDataSource =
      DietTypeRemoteDataSourceImpl(dio: dio);
  final DietTypeRepository dietTypeRepository = DietTypeRepositoryImpl(
    remoteDataSource: dietTypeRemoteDataSource,
  );

  final ActivityRemoteDataSource activityRemoteDataSource =
      ActivityRemoteDataSourceImpl(dio: dio);
  final ActivityRepository activityRepository = ActivityRepositoryImpl(
    remoteDataSource: activityRemoteDataSource,
  );

  final ActivityRecordRemoteDataSource activityRecordRemoteDataSource =
      ActivityRecordRemoteDataSourceImpl(dio: dio);
  final ActivityRecordRepository activityRecordRepository =
      ActivityRecordRepositoryImpl(
        remoteDataSource: activityRecordRemoteDataSource,
      );

  final ChatSessionRemoteDataSource chatSessionRemoteDataSource =
      ChatSessionRemoteDataSourceImpl(dio: dio);
  final ChatSessionRepository chatSessionRepository = ChatSessionRepositoryImpl(
    remoteDataSource: chatSessionRemoteDataSource,
  );

  final ChatMessageRemoteDataSource chatMessageRemoteDataSource =
      ChatMessageRemoteDataSourceImpl(dio: dio);
  final ChatMessageRepository chatMessageRepository = ChatMessageRepositoryImpl(
    remoteDataSource: chatMessageRemoteDataSource,
  );

  final ChallengeRemoteDataSource challengeRemoteDataSource =
      ChallengeRemoteDataSourceImpl(dio: dio);
  final ChallengeRepository challengeRepository = ChallengeRepositoryImpl(
    remoteDataSource: challengeRemoteDataSource,
  );

  final MedalRemoteDataSource medalRemoteDataSource = MedalRemoteDataSourceImpl(
    dio: dio,
  );
  final MedalRepository medalRepository = MedalRepositoryImpl(
    remoteDataSource: medalRemoteDataSource,
  );

  final NotificationRemoteDataSource notificationRemoteDataSource =
      NotificationRemoteDataSourceImpl(dio: dio);
  final NotificationRepository notificationRepository =
      NotificationRepositoryImpl(
        remoteDataSource: notificationRemoteDataSource,
      );

  final GoogleFitRemoteDataSource googleFitRemoteDataSource =
      GoogleFitRemoteDataSourceImpl(dio: dio);
  final GoogleFitRepository googleFitRepository = GoogleFitRepositoryImpl(
    remoteDataSource: googleFitRemoteDataSource,
  );

  final DeviceRemoteDataSource deviceRemoteDataSource =
      DeviceRemoteDataSourceImpl(dio: dio);
  final DeviceRepository deviceRepository = DeviceRepositoryImpl(
    remoteDataSource: deviceRemoteDataSource,
  );

  final expertRemoteDataSource = ExpertRemoteDataSourceImpl(dio: dio);
  final ExpertRepository expertRepository = ExpertRepositoryImpl(
    remoteDataSource: expertRemoteDataSource,
  );

  final AuthBloc authBloc = AuthBloc(authRepository: authRepository);
  final UserBloc userBloc = UserBloc(userRepository: userRepository);

  final GoRouter appRouter = AppRoutes.createRouter(
    authBloc,
    fitnessProfileRepository,
    googleFitRepository,
  );

  // Initialize local notifications with tap handler
  await LocalNotificationService().initialize(
    onNotificationTap: (postId) {
      // Navigate to community screen when notification is tapped
      if (postId != null) {
        appRouter.go('/community');
      }
    },
  );
  // Check authentication status on app startup
  authBloc.add(CheckAuthStatus());

  // Register device for push notifications after a short delay
  // to ensure user is authenticated
  Future.delayed(const Duration(seconds: 2), () async {
    final token = await secureStorage.read(key: 'auth_token');
    if (token != null) {
      final deviceService = DeviceRegistrationService(
        deviceRepository: deviceRepository,
      );
      await deviceService.registerDevice();
      deviceService.setupForegroundMessageHandler();

      // Handle notification taps when app is in background
      deviceService.setupNotificationTapHandler((postId) {
        if (postId != null) {
          appRouter.go('/community');
        }
      });

      // Handle notification when app was terminated
      await deviceService.handleInitialMessage((postId) {
        if (postId != null) {
          appRouter.go('/community');
        }
      });
    }
  });

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
          appRouter.go(_pendingResetPasswordDeepLink!);
          _pendingResetPasswordDeepLink = null;
        }
      });
    },
    onGoogleFitCallback: (Uri uri) {
      // Google Fit OAuth callback - connection is handled server-side
      // Navigate back to the Google Fit sync screen after checking auth
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check if user is authenticated
        final currentState = authBloc.state;
        if (currentState is Authenticated) {
          // User is signed in, navigate to Google Fit sync screen
          appRouter.go('/google-fit-sync');
        } else {
          // User is not signed in, navigate to home
          appRouter.go('/');
        }
      });
    },
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthLocalDataSource>(
          create: (context) => localDataSource,
        ),
        RepositoryProvider<FitnessGoalRepository>(
          create: (context) => fitnessGoalRepository,
        ),
        RepositoryProvider<MealRepository>(create: (context) => mealRepository),
        RepositoryProvider<DailyMealRepository>(
          create: (context) => dailyMealRepository,
        ),
        RepositoryProvider<DailyLogRepository>(
          create: (context) => dailyLogRepository,
        ),
        RepositoryProvider<DietTypeRepository>(
          create: (context) => dietTypeRepository,
        ),
        RepositoryProvider<ActivityRepository>(
          create: (context) => activityRepository,
        ),
        RepositoryProvider<ActivityRecordRepository>(
          create: (context) => activityRecordRepository,
        ),
        RepositoryProvider<ChatSessionRepository>(
          create: (context) => chatSessionRepository,
        ),
        RepositoryProvider<ChatMessageRepository>(
          create: (context) => chatMessageRepository,
        ),
        RepositoryProvider<ChallengeRepository>(
          create: (context) => challengeRepository,
        ),
        RepositoryProvider<MedalRepository>(
          create: (context) => medalRepository,
        ),
        RepositoryProvider<NotificationRepository>(
          create: (context) => notificationRepository,
        ),
        RepositoryProvider<FitnessProfileRepository>(
          create: (context) => fitnessProfileRepository,
        ),
        RepositoryProvider<GoogleFitRepository>(
          create: (context) => googleFitRepository,
        ),
        RepositoryProvider<AuthRepository>(create: (context) => authRepository),
        RepositoryProvider<UserRepository>(create: (context) => userRepository),
        RepositoryProvider<ExpertRepository>(
          create: (context) => expertRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (context) => authBloc),
          BlocProvider<UserBloc>(create: (context) => userBloc),
        ],
        child: App(appRouter: appRouter),
      ),
    ),
  );
}
