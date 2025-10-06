import 'package:da1/src/presentation/screens/advisor/advisor_screen.dart';
import 'package:da1/src/presentation/screens/auth/signup_screen.dart';
import 'package:da1/src/presentation/screens/auth/welcome/welcome_scroll_screen.dart';
import 'package:da1/src/presentation/screens/community/community_screen.dart';
import 'package:da1/src/presentation/screens/home/diet/food_search_screen.dart';
import 'package:da1/src/presentation/screens/profile/profile_screen.dart';
import 'package:da1/src/presentation/screens/home/home_screen.dart';
import 'package:da1/src/presentation/screens/auth/login_screen.dart';
import 'package:da1/src/presentation/widgets/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/welcome',
    routes: [
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScrollScreen(),
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
        path: '/foodSearch',
        name: 'foodSearch',
        builder: (context, state) => FoodSearchScreen(),
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
