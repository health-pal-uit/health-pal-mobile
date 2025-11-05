import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/presentation/widgets/charts/kcal_circular_progress.dart';
import 'package:da1/src/presentation/widgets/charts/steps_progress.dart';
import 'package:da1/src/presentation/widgets/charts/water_intake.dart';
import 'package:da1/src/presentation/widgets/home_items/workout_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:da1/src/presentation/bloc/auth/auth.dart';
import 'package:da1/src/domain/entities/user.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    User? user;
    if (authState is Authenticated) {
      user = authState.user;
    }

    final String todayDate =
        DateFormat('d MMMM').format(DateTime.now()).toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, user, todayDate),
              const SizedBox(height: 30),
              _buildKcalCard(),
              const SizedBox(height: 20),
              _buildSmallCards(),
              const SizedBox(height: 30),
              _buildWorkoutSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user, String todayDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TODAY, $todayDate', style: AppTypography.body),
            IconButton(
              icon: const Icon(
                Icons.notifications_none_outlined,
                color: AppColors.textPrimary,
              ),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Welcome back,',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          user?.fullName ?? user?.email ?? 'User',
          style: AppTypography.headline,
        ),
      ],
    );
  }

  Widget _buildKcalCard() {
    return KcalCircularProgressCard(consumed: 300, needed: 1500, exercise: 30);
  }

  Widget _buildSmallCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        WaterIntakeWidget(),
        StepsWidget(goal: 10000, steps: 6000),
      ],
    );
  }

  Widget _buildWorkoutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Find Your Activity",
          style: AppTypography.headline.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: WorkoutCard(
                title: 'Workouts',
                subtitle: 'Sweating is self-care',
                icon: Icons.fitness_center,
                color: AppColors.primary,
                onTap: () => context.push('/add-activity'),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: WorkoutCard(
                title: 'Activity',
                subtitle: 'Track your progress',
                icon: Icons.analytics_outlined,
                color: Colors.blue,
                onTap: () => context.push('/activity-analytics'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: WorkoutCard(
                title: 'Log Food',
                subtitle: 'Track your meals',
                icon: LucideIcons.carrot,
                color: AppColors.primary,
                onTap: () => context.push('/foodSearch'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
