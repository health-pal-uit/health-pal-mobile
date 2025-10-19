import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/presentation/widgets/charts/kcal_circular_progress.dart';
import 'package:da1/src/presentation/widgets/charts/steps_progress.dart';
import 'package:da1/src/presentation/widgets/charts/water_intake.dart';
import 'package:da1/src/presentation/widgets/home_items/workout_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TODAY, 22 SEPTEMBER', style: AppTypography.body),
                      Icon(
                        Icons.notifications_none_outlined,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  KcalCircularProgressCard(
                    consumed: 300,
                    needed: 1500,
                    exercise: 30,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WaterIntakeWidget(),
                      StepsWidget(goal: 10000, steps: 6000),
                    ],
                  ),
                  SizedBox(height: 20),
                  WorkoutCard(
                    title: 'Workouts',
                    subtitle: 'Sweating is self-care',
                    icon: Icons.fitness_center,
                    color: AppColors.primary,
                    onTap: () => context.push('/add-activity'),
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
