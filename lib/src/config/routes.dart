import 'package:da1/src/features/expert/auth/presentation/expert_registration_screen.dart';
import 'package:da1/src/features/user/advisor/presentation/advisor_screen.dart';
import 'package:da1/src/features/shared/auth/presentation/auth/email_verification_screen.dart';
import 'package:da1/src/features/shared/auth/presentation/auth/forgot_password_screen.dart';
import 'package:da1/src/features/shared/auth/presentation/auth/password_reset_waiting_screen.dart';
import 'package:da1/src/features/shared/auth/presentation/auth/reset_password_screen.dart';
import 'package:da1/src/features/shared/auth/presentation/auth/onboarding/onboarding_complete_screen.dart';
import 'package:da1/src/features/shared/auth/presentation/auth/onboarding/onboarding_weight_screen.dart';
import 'package:da1/src/features/shared/auth/presentation/auth/onboarding/onboarding_height_screen.dart';
import 'package:da1/src/features/shared/auth/presentation/auth/onboarding/onboarding_body_measurements_screen.dart';
import 'package:da1/src/features/shared/auth/presentation/auth/onboarding/onboarding_activity_level_screen.dart';
import 'package:da1/src/features/shared/auth/presentation/auth/onboarding/onboarding_goal_type_screen.dart';
import 'package:da1/src/features/shared/auth/presentation/auth/signup_screen.dart';
import 'package:da1/src/features/shared/auth/presentation/auth/welcome/welcome_scroll_screen.dart';
import 'package:da1/src/features/user/community/presentation/community_screen.dart';
import 'package:da1/src/features/user/community/presentation/personal_profile_screen.dart';
import 'package:da1/src/features/user/home/presentation/diet/food_search_screen.dart';
import 'package:da1/src/features/user/home/presentation/diet/meal_scan_screen.dart';
import 'package:da1/src/features/user/home/presentation/exercise/activity_analytics_screen.dart';
import 'package:da1/src/features/user/home/presentation/exercise/add_activity_screen.dart';
import 'package:da1/src/features/user/notifications/presentation/notifications_screen.dart';
import 'package:da1/src/features/user/profile/presentation/integrations/google_fit_sync_screen.dart';
import 'package:da1/src/features/user/community/data/post_model.dart';
import 'package:da1/src/features/user/home/presentation/step/steps_screen.dart';
import 'package:da1/src/features/user/profile/presentation/profile_screen.dart';
import 'package:da1/src/features/user/home/presentation/home_screen.dart';
import 'package:da1/src/features/shared/auth/presentation/auth/login_screen.dart';
import 'package:da1/src/features/user/home/presentation/widgets/custom_bottom_nav.dart';
import 'package:da1/src/features/user/profile/data/fitness_profile_repository.dart';
import 'package:da1/src/features/user/profile/data/google_fit_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:da1/src/core/bloc/auth/auth_bloc.dart';
import 'package:da1/src/core/bloc/auth/auth_state.dart';
import 'package:da1/src/core/models/user.dart';

class AppRoutes {
  static FitnessProfileRepository? _fitnessProfileRepository;

  static void setFitnessProfileRepository(FitnessProfileRepository repository) {
    _fitnessProfileRepository = repository;
  }

  static GoRouter createRouter(
    AuthBloc authBloc,
    FitnessProfileRepository fitnessProfileRepo,
    GoogleFitRepository googleFitRepo,
  ) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),

      redirect: (context, state) async {
        final authState = authBloc.state;
        final bool isAuthenticated = authState is Authenticated;
        final UserRole? role = authState.role;

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

        if (!isAuthenticated && !isOnAuthPages) {
          return '/welcome';
        }

        if (isAuthenticated && isOnAuthPages) {
          if (role == UserRole.expert) return '/expert/dashboard';
          if (role == UserRole.pendingExpert) return '/expert/pending';
          return '/';
        }

        final isExpertRoute = state.matchedLocation.startsWith('/expert');
        if (isExpertRoute &&
            role != UserRole.expert &&
            role != UserRole.pendingExpert) {
          return '/';
        }

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
          redirect: (context, state) async {
            if (_fitnessProfileRepository != null) {
              final result = await fitnessProfileRepo.hasFitnessProfile();
              return result.fold(
                (failure) => null,
                (hasProfile) => hasProfile ? '/' : null,
              );
            }
            return null;
          },
          builder: (context, state) => const OnboardingHeightScreen(),
        ),
        GoRoute(
          path: '/onboarding-weight',
          name: 'onboarding-weight',
          redirect: (context, state) async {
            if (_fitnessProfileRepository != null) {
              final result = await fitnessProfileRepo.hasFitnessProfile();
              return result.fold(
                (failure) => null,
                (hasProfile) => hasProfile ? '/' : null,
              );
            }
            return null;
          },
          builder: (context, state) {
            final height = state.extra as double?;
            return OnboardingWeightScreen(height: height);
          },
        ),
        GoRoute(
          path: '/onboarding-body-measurements',
          name: 'onboarding-body-measurements',
          redirect: (context, state) async {
            if (_fitnessProfileRepository != null) {
              final result = await fitnessProfileRepo.hasFitnessProfile();
              return result.fold(
                (failure) => null,
                (hasProfile) => hasProfile ? '/' : null,
              );
            }
            return null;
          },
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
          redirect: (context, state) async {
            if (_fitnessProfileRepository != null) {
              final result = await fitnessProfileRepo.hasFitnessProfile();
              return result.fold(
                (failure) => null,
                (hasProfile) => hasProfile ? '/' : null,
              );
            }
            return null;
          },
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            final measurements = {
              'height': (data['height'] as num).toDouble(),
              'weight': (data['weight'] as num).toDouble(),
              'waist':
                  data['waist'] != null
                      ? (data['waist'] as num).toDouble()
                      : null,
              'hip':
                  data['hip'] != null ? (data['hip'] as num).toDouble() : null,
              'neck':
                  data['neck'] != null
                      ? (data['neck'] as num).toDouble()
                      : null,
            };
            return OnboardingActivityLevelScreen(measurements: measurements);
          },
        ),
        GoRoute(
          path: '/onboarding-goal',
          name: 'onboarding-goal',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>? ?? {};
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
            final data = (state.extra as Map<String, dynamic>?) ?? {};
            return EmailVerificationScreen(data: data);
          },
        ),
        GoRoute(
          path: '/foodSearch',
          name: 'foodSearch',
          builder: (context, state) {
            final mealType = state.uri.queryParameters['mealType'];
            final date = state.uri.queryParameters['date'];
            return FoodSearchScreen(
              initialMealType: mealType,
              selectedDate: date,
            );
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
          builder:
              (context, state) =>
                  GoogleFitSyncScreen(googleFitRepository: googleFitRepo),
        ),

        GoRoute(
          path: '/expert/dashboard',
          name: 'expert-dashboard',
          builder:
              (context, state) => const Scaffold(
                body: Center(
                  child: Text('Trang Quản lý Chuyên gia (Dashboard)'),
                ),
              ),
        ),
        GoRoute(
          path: '/expert/pending',
          name: 'expert-pending',
          builder:
              (context, state) => const Scaffold(
                body: Center(
                  child: Text('Tài khoản chuyên gia đang chờ duyệt'),
                ),
              ),
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
                if (_fitnessProfileRepository != null) {
                  final result =
                      await _fitnessProfileRepository!.hasFitnessProfile();
                  return result.fold((failure) => null, (hasProfile) {
                    if (!hasProfile) {
                      return '/onboarding-height';
                    }
                    return null;
                  });
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
            GoRoute(
              path: '/expert/signup',
              name: 'expert-signup',
              builder: (context, state) => const ExpertRegistrationScreen(),
            ),
          ],
        ),
      ],
    );
  }

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

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
