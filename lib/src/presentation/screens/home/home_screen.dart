import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/config/routes.dart';
import 'package:da1/src/presentation/widgets/charts/kcal_circular_progress.dart';
import 'package:da1/src/presentation/widgets/charts/steps_progress.dart';
import 'package:da1/src/presentation/widgets/charts/water_intake.dart';
import 'package:da1/src/presentation/widgets/home_items/workout_card.dart';
import 'package:da1/src/presentation/widgets/home_items/meal_diary_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:da1/src/presentation/bloc/auth/auth.dart';
import 'package:da1/src/domain/entities/user.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  double? tdeeKcal;
  bool isLoadingTdee = true;
  Map<String, dynamic>? dailyLog;
  bool isLoadingDailyLog = true;
  Map<String, dynamic>? fitnessGoal;
  bool isLoadingFitnessGoal = true;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(LoadCurrentUser());
    _loadFitnessProfile();
    _loadDailyLog();
    _loadFitnessGoal();
  }

  Future<void> _loadFitnessProfile() async {
    final repository = AppRoutes.getFitnessProfileRepository();
    if (repository == null) return;

    try {
      final result = await repository.hasFitnessProfile();
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              isLoadingTdee = false;
            });
          }
        },
        (hasProfile) async {
          if (hasProfile) {
            final fitnessProfilesResult = await repository.getFitnessProfiles();
            fitnessProfilesResult.fold(
              (failure) {
                if (mounted) {
                  setState(() {
                    isLoadingTdee = false;
                  });
                }
              },
              (profiles) {
                if (mounted && profiles.isNotEmpty) {
                  final profile = profiles[0];
                  setState(() {
                    tdeeKcal = profile['tdee_kcal']?.toDouble();
                    isLoadingTdee = false;
                  });
                }
              },
            );
          } else {
            if (mounted) {
              setState(() {
                isLoadingTdee = false;
              });
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingTdee = false;
        });
      }
    }
  }

  Future<void> _loadDailyLog() async {
    final repository = AppRoutes.getDailyLogRepository();
    if (repository == null) {
      return;
    }

    if (mounted) {
      setState(() {
        isLoadingDailyLog = true;
      });
    }

    try {
      final dateStr =
          '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}';

      final result = await repository.getDailyLog(dateStr);
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              isLoadingDailyLog = false;
            });
          }
        },
        (log) {
          if (mounted) {
            setState(() {
              dailyLog = log;
              isLoadingDailyLog = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingDailyLog = false;
        });
      }
    }
  }

  Future<void> _loadFitnessGoal() async {
    final repository = AppRoutes.getFitnessGoalRepository();
    if (repository == null) {
      if (mounted) {
        setState(() {
          isLoadingFitnessGoal = false;
        });
      }
      return;
    }

    try {
      final result = await repository.getFitnessGoal();
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              isLoadingFitnessGoal = false;
            });
          }
        },
        (goal) {
          if (mounted) {
            setState(() {
              fitnessGoal = goal['data'];
              isLoadingFitnessGoal = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingFitnessGoal = false;
        });
      }
    }
  }

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
              const SizedBox(height: 20),
              _buildDaysList(),
              const SizedBox(height: 30),
              _buildKcalCard(),
              const SizedBox(height: 20),
              MealDiaryCard(
                dailyMeals: dailyLog?['daily_meals'] as List<dynamic>?,
                onAddMeal: (mealType) async {
                  final result = await context.push(
                    '/foodSearch?mealType=$mealType',
                  );
                  if (result == true && mounted) {
                    await _loadDailyLog();
                    setState(() {});
                  }
                },
              ),
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
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TODAY, $todayDate', style: AppTypography.body),
            IconButton(
              icon: const Icon(
                Icons.notifications_none_outlined,
                color: AppColors.textPrimary,
              ),
              onPressed: () => context.push('/notifications'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            text: 'Welcome back, ',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            children: [
              TextSpan(
                text: user?.username ?? user?.fullName ?? 'User',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaysList() {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final totalWeeks = 41;
    final initialWeek = 20;

    return SizedBox(
      height: 70,
      child: PageView.builder(
        itemCount: totalWeeks,
        controller: PageController(
          initialPage: initialWeek,
          viewportFraction: 1.0,
        ),
        itemBuilder: (context, weekIndex) {
          final weekStart = currentWeekStart.add(
            Duration(days: (weekIndex - initialWeek) * 7),
          );

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (dayIndex) {
              final date = weekStart.add(Duration(days: dayIndex));
              final isSelected =
                  date.day == selectedDate.day &&
                  date.month == selectedDate.month &&
                  date.year == selectedDate.year;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                  });
                  _loadDailyLog();
                },
                child: Container(
                  width: 45,
                  height: 65,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color:
                          isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat(
                          'E',
                        ).format(date).substring(0, 2).toUpperCase(),
                        style: AppTypography.body.copyWith(
                          fontSize: 11,
                          color:
                              isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: AppTypography.headline.copyWith(
                          fontSize: 16,
                          color:
                              isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildKcalCard() {
    // Use target_kcal from fitness goal if available, fallback to tdeeKcal
    final needed =
        fitnessGoal != null
            ? (fitnessGoal!['target_kcal'] as num?)?.toInt() ?? 2000
            : tdeeKcal?.toInt() ?? 2000;

    final consumed =
        dailyLog != null ? (dailyLog!['total_kcal_eaten'] ?? 0).toInt() : 0;

    // Get macro nutrients from daily log
    final protein =
        dailyLog != null
            ? (dailyLog!['total_protein_gr'] as num?)?.toDouble()
            : null;
    final fat =
        dailyLog != null
            ? (dailyLog!['total_fat_gr'] as num?)?.toDouble()
            : null;
    final carbs =
        dailyLog != null
            ? (dailyLog!['total_carbs_gr'] as num?)?.toDouble()
            : null;
    final fiber =
        dailyLog != null
            ? (dailyLog!['total_fiber_gr'] as num?)?.toDouble()
            : null;

    return KcalCircularProgressCard(
      consumed: consumed,
      needed: needed,
      exercise: 30,
      protein: protein,
      fat: fat,
      carbs: carbs,
      fiber: fiber,
      proteinGoal:
          fitnessGoal != null
              ? (fitnessGoal!['target_protein_gr'] as num?)?.toInt()
              : null,
      fatGoal:
          fitnessGoal != null
              ? (fitnessGoal!['target_fat_gr'] as num?)?.toInt()
              : null,
      carbsGoal:
          fitnessGoal != null
              ? (fitnessGoal!['target_carbs_gr'] as num?)?.toInt()
              : null,
      fiberGoal:
          fitnessGoal != null
              ? (fitnessGoal!['target_fiber_gr'] as num?)?.toInt()
              : null,
      goalType:
          fitnessGoal != null ? fitnessGoal!['goal_type'] as String? : null,
    );
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
                onTap: () async {
                  final result = await context.push('/foodSearch');
                  // Reload daily log if a meal was added
                  if (result == true && mounted) {
                    await _loadDailyLog();
                    setState(() {}); // Force rebuild
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
