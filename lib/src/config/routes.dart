import 'package:da1/src/presentation/screens/advisor/advisor_screen.dart';
import 'package:da1/src/presentation/screens/auth/signup_screen.dart';
import 'package:da1/src/presentation/screens/community/community_screen.dart';
import 'package:da1/src/presentation/screens/home/diet/food_search_screen.dart';
import 'package:da1/src/presentation/screens/profile/profile_screen.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/auth/login_screen.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
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
  );
}
