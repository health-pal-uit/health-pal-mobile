import 'package:da1/src/presentation/screens/advisor/advisor_screen.dart';
import 'package:da1/src/presentation/screens/auth/email_verification_screen.dart';
import 'package:da1/src/presentation/screens/auth/forgot_password_screen.dart';
import 'package:da1/src/presentation/screens/auth/password_reset_waiting_screen.dart';
import 'package:da1/src/presentation/screens/auth/reset_password_screen.dart';
import 'package:da1/src/presentation/screens/auth/onboarding/onboarding_complete_screen.dart';
import 'package:da1/src/presentation/screens/auth/onboarding/onboarding_weight_screen.dart';
import 'package:da1/src/presentation/screens/auth/onboarding/onboarding_height_screen.dart';
import 'package:da1/src/presentation/screens/auth/onboarding/onboarding_body_measurements_screen.dart';
import 'package:da1/src/presentation/screens/auth/onboarding/onboarding_activity_level_screen.dart';
import 'package:da1/src/presentation/screens/auth/onboarding/onboarding_goal_type_screen.dart';
import 'package:da1/src/presentation/screens/auth/signup_screen.dart';
import 'package:da1/src/presentation/screens/auth/welcome/welcome_scroll_screen.dart';
import 'package:da1/src/presentation/screens/community/community_screen.dart';
import 'package:da1/src/presentation/screens/community/personal_profile_screen.dart';
import 'package:da1/src/presentation/screens/home/diet/food_search_screen.dart';
import 'package:da1/src/presentation/screens/home/diet/meal_scan_screen.dart';
import 'package:da1/src/presentation/screens/home/exercise/activity_analytics_screen.dart';
import 'package:da1/src/presentation/screens/home/exercise/add_activity_screen.dart';
import 'package:da1/src/presentation/screens/notifications/notifications_screen.dart';
import 'package:da1/src/presentation/screens/profile/integrations/google_fit_sync_screen.dart';
import 'package:da1/src/data/models/post_model.dart';
import 'package:da1/src/presentation/screens/home/step/steps_screen.dart';
import 'package:da1/src/presentation/screens/profile/profile_screen.dart';
import 'package:da1/src/presentation/screens/home/home_screen.dart';
import 'package:da1/src/presentation/screens/auth/login_screen.dart';
import 'package:da1/src/presentation/widgets/custom_bottom_nav.dart';
import 'package:da1/src/data/repositories/fitness_profile_repository.dart';
import 'package:da1/src/data/repositories/fitness_goal_repository.dart';
import 'package:da1/src/data/repositories/meal_repository.dart';
import 'package:da1/src/data/repositories/daily_meal_repository.dart';
import 'package:da1/src/data/repositories/daily_log_repository.dart';
import 'package:da1/src/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static FitnessProfileRepository? _fitnessProfileRepository;
  static FitnessGoalRepository? _fitnessGoalRepository;
  static MealRepository? _mealRepository;
  static DailyMealRepository? _dailyMealRepository;
  static DailyLogRepository? _dailyLogRepository;
  static AuthRepository? _authRepository;

  static void setFitnessProfileRepository(FitnessProfileRepository repository) {
    _fitnessProfileRepository = repository;
  }

  static FitnessProfileRepository? getFitnessProfileRepository() {
    return _fitnessProfileRepository;
  }

  static void setFitnessGoalRepository(FitnessGoalRepository repository) {
    _fitnessGoalRepository = repository;
  }

  static FitnessGoalRepository? getFitnessGoalRepository() {
    return _fitnessGoalRepository;
  }

  static void setMealRepository(MealRepository repository) {
    _mealRepository = repository;
  }

  static MealRepository? getMealRepository() {
    return _mealRepository;
  }

  static void setDailyMealRepository(DailyMealRepository repository) {
    _dailyMealRepository = repository;
  }

  static DailyMealRepository? getDailyMealRepository() {
    return _dailyMealRepository;
  }

  static void setDailyLogRepository(DailyLogRepository repository) {
    _dailyLogRepository = repository;
  }

  static DailyLogRepository? getDailyLogRepository() {
    return _dailyLogRepository;
  }

  static void setAuthRepository(AuthRepository repository) {
    _authRepository = repository;
  }

  static AuthRepository? getAuthRepository() {
    return _authRepository;
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      // Check if user has a valid token
      final hasToken = await _authRepository?.hasValidToken() ?? false;

      final isOnWelcomePage = state.matchedLocation == '/welcome';
      final isOnLoginPage = state.matchedLocation == '/login';
      final isOnSignupPage = state.matchedLocation == '/signup';
      final isOnAuthPages =
          isOnWelcomePage ||
          isOnLoginPage ||
          isOnSignupPage ||
          state.matchedLocation.startsWith('/email-verification') ||
          state.matchedLocation.startsWith('/forgot-password') ||
          state.matchedLocation.startsWith('/password-reset') ||
          state.matchedLocation.startsWith('/reset-password');

      // If not authenticated and trying to access protected route, go to welcome
      if (!hasToken && !isOnAuthPages) {
        return '/welcome';
      }

      // If authenticated and on auth pages, go to home
      if (hasToken && isOnAuthPages) {
        return '/';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScrollScreen(),
      ),
      GoRoute(
        path: '/onboarding-height',
        name: 'onboarding-height',
        builder: (context, state) => const OnboardingHeightScreen(),
      ),
      GoRoute(
        path: '/onboarding-weight',
        name: 'onboarding-weight',
        builder: (context, state) {
          final height = state.extra as double?;
          return OnboardingWeightScreen(height: height);
        },
      ),
      GoRoute(
        path: '/onboarding-body-measurements',
        name: 'onboarding-body-measurements',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return OnboardingBodyMeasurementsScreen(
            height: (data['height'] as num).toDouble(),
            weight: (data['weight'] as num).toDouble(),
          );
        },
      ),
      GoRoute(
        path: '/onboarding-activity',
        name: 'onboarding-activity',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          final measurements = {
            'height': (data['height'] as num).toDouble(),
            'weight': (data['weight'] as num).toDouble(),
            'waist':
                data['waist'] != null
                    ? (data['waist'] as num).toDouble()
                    : null,
            'hip': data['hip'] != null ? (data['hip'] as num).toDouble() : null,
            'neck':
                data['neck'] != null ? (data['neck'] as num).toDouble() : null,
          };
          return OnboardingActivityLevelScreen(measurements: measurements);
        },
      ),
      GoRoute(
        path: '/onboarding-goal',
        name: 'onboarding-goal',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return OnboardingGoalTypeScreen(previousData: data);
        },
      ),
      GoRoute(
        path: '/onboarding-complete',
        name: 'onboarding-complete',
        builder: (context, state) => const OnboardingCompleteScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/password-reset-waiting',
        name: 'password-reset-waiting',
        builder: (context, state) {
          final email = state.extra as String;
          return PasswordResetWaitingScreen(email: email);
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/email-verification',
        name: 'email-verification',
        builder: (context, state) {
          final email = state.extra as String;
          return EmailVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/foodSearch',
        name: 'foodSearch',
        builder: (context, state) {
          final mealType = state.uri.queryParameters['mealType'];
          return FoodSearchScreen(initialMealType: mealType);
        },
      ),
      GoRoute(
        path: '/meal-scan',
        name: 'meal-scan',
        builder: (context, state) => const MealScanScreen(),
      ),
      GoRoute(
        path: '/steps',
        name: 'steps',
        builder: (context, state) => StepsScreen(),
      ),
      GoRoute(
        path: '/add-activity',
        name: 'add-activity',
        builder: (context, state) => AddActivityScreen(),
      ),
      GoRoute(
        path: '/activity-analytics',
        name: 'activity-analytics',
        builder: (context, state) => ActivityAnalyticsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/google-fit-sync',
        name: 'google-fit-sync',
        builder: (context, state) => const GoogleFitSyncScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: CustomBottomNav(
              currentIndex: _calculateSelectedIndex(state),
              onTap: (index) => _onItemTapped(context, index),
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            redirect: (context, state) async {
              // Check if user has fitness profile
              if (_fitnessProfileRepository != null) {
                final result =
                    await _fitnessProfileRepository!.hasFitnessProfile();
                return result.fold(
                  (failure) => null, // If error, let user proceed to home
                  (hasProfile) {
                    if (!hasProfile) {
                      return '/onboarding-height';
                    }
                    return null; // null means no redirect, proceed to home
                  },
                );
              }
              return null;
            },
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/advisor',
            name: 'advisor',
            builder: (context, state) => AdvisorScreen(),
          ),
          GoRoute(
            path: '/community',
            name: 'community',
            builder: (context, state) => CommunityScreen(),
          ),
          GoRoute(
            path: '/personal-profile/:userId',
            name: 'personal-profile',
            builder: (context, state) {
              final userId = state.pathParameters['userId'];
              final user = state.extra as UserInfo?;
              return PersonalProfileScreen(userId: userId, user: user);
            },
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => ProfileScreen(),
          ),
        ],
      ),
    ],
  );

  static int _calculateSelectedIndex(GoRouterState state) {
    final location = state.uri.toString();
    if (location.startsWith('/advisor')) return 1;
    if (location.startsWith('/community')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  static void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/advisor');
        break;
      case 2:
        context.go('/community');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
