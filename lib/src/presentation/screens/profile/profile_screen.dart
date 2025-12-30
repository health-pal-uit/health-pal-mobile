import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/domain/entities/user.dart';
import 'package:da1/src/presentation/bloc/auth/auth.dart';
import 'package:da1/src/presentation/bloc/user/user.dart';
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
  bool _isLoadingDialogShown = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(LoadCurrentUser());
  }

  void _handleAvatarChange(String imagePath) {
    context.read<UserBloc>().add(UpdateAvatarRequested(imagePath));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    User? user;
    if (authState is Authenticated) {
      user = authState.user;
    }
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              // Navigate to root, which will trigger router redirect to welcome
              Future.microtask(() {
                if (context.mounted) {
                  context.go('/');
                }
              });
            }
          },
        ),
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserLoading) {
              _isLoadingDialogShown = true;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (dialogContext) => PopScope(
                      canPop: false,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
              );
            } else {
              if (_isLoadingDialogShown) {
                _isLoadingDialogShown = false;
                Navigator.of(context, rootNavigator: true).pop();
              }

              if (state is UserAvatarUpdated) {
                if (mounted) {
                  context.read<AuthBloc>().add(LoadCurrentUser());
                }
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                Future.delayed(const Duration(milliseconds: 100), () {
                  if (!mounted) return;

                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Avatar updated successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                });
              } else if (state is UserFailure) {
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                Future.delayed(const Duration(milliseconds: 100), () {
                  if (!mounted) return;

                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                });
              }
            }
          },
        ),
      ],
      child: Scaffold(
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

                    ProfileHeader(
                      user: user,
                      onAvatarChanged: _handleAvatarChange,
                    ),

                    const SizedBox(height: 12),
                    Divider(
                      color: AppColors.primary.withValues(alpha: 0.13),
                      thickness: 2,
                    ),
                    const AccountSection(),
                    const HealthDataSection(),
                    const PreferencesSection(),
                    const SupportSection(),

                    GestureDetector(
                      onTap: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true && context.mounted) {
                          context.read<AuthBloc>().add(SignOutRequested());
                        }
                      },
                      child: ProfileItem(icon: Icons.logout, text: "Logout"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
