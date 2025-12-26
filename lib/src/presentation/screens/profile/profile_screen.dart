import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/domain/entities/user.dart';
import 'package:da1/src/presentation/bloc/auth/auth.dart';
import 'package:da1/src/presentation/widgets/profile/profile_header.dart';
import 'package:da1/src/presentation/widgets/profile/profile_item.dart';
import 'package:da1/src/presentation/widgets/profile/sections/account_section.dart';
import 'package:da1/src/presentation/widgets/profile/sections/health_data_section.dart';
import 'package:da1/src/presentation/widgets/profile/sections/preferences_section.dart';
import 'package:da1/src/presentation/widgets/profile/sections/support_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(LoadCurrentUser());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    User? user;
    if (authState is Authenticated) {
      user = authState.user;
    }
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text('Account & Settings', style: AppTypography.headline),
                  const SizedBox(height: 16),

                  // Profile Header with user data
                  ProfileHeader(user: user),

                  const SizedBox(height: 12),
                  Divider(
                    color: AppColors.primary.withValues(alpha: 0.13),
                    thickness: 2,
                  ),

                  // Account Section
                  const AccountSection(),

                  // Health & Data Section
                  const HealthDataSection(),

                  // Preferences Section
                  const PreferencesSection(),

                  // Support & About Section
                  const SupportSection(),

                  // Logout
                  GestureDetector(
                    onTap: () {
                      context.read<AuthBloc>().add(SignOutRequested());
                      context.go('/login');
                    },
                    child: ProfileItem(icon: Icons.logout, text: "Logout"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
