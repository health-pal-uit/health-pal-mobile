import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/config/routes.dart';
import 'package:da1/src/presentation/widgets/charts/kcal_circular_progress.dart';
import 'package:da1/src/presentation/widgets/charts/steps_progress.dart';
import 'package:da1/src/presentation/widgets/charts/water_intake.dart';
import 'package:da1/src/presentation/widgets/home_items/workout_card.dart';
import 'package:da1/src/presentation/widgets/home_items/meal_diary_card.dart';
import 'package:da1/src/presentation/widgets/diet_type_bottom_sheet.dart';
import 'package:da1/src/domain/entities/diet_type.dart';
import 'package:da1/src/presentation/screens/home/exercise/challenges_screen.dart';
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
  List<DietType> dietTypes = [];
  bool isLoadingDietTypes = true;
  Map<String, dynamic>? fitnessProfile;
  bool hasClaimableItems = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(LoadCurrentUser());
    _loadFitnessProfile();
    _loadDailyLog();
    _loadFitnessGoal();
    _loadDietTypes();
    _checkClaimableItems();
  }

  Future<void> _checkClaimableItems() async {
    bool hasClaimable = false;

    // Check challenges
    final challengeRepo = AppRoutes.getChallengeRepository();
    if (challengeRepo != null) {
      final challengeResult = await challengeRepo.getChallenges();
      challengeResult.fold((error) {}, (challenges) {
        hasClaimable = challenges.any((c) => c.canClaim);
      });
    }

    // Check medals if no claimable challenge found
    if (!hasClaimable) {
      final medalRepo = AppRoutes.getMedalRepository();
      if (medalRepo != null) {
        final medalResult = await medalRepo.getMedals();
        medalResult.fold((error) {}, (medals) {
          hasClaimable = medals.any((m) => m.canClaim);
        });
      }
    }

    if (mounted) {
      setState(() {
        hasClaimableItems = hasClaimable;
      });
    }
  }

  Future<void> _loadDietTypes() async {
    final repository = AppRoutes.getDietTypeRepository();
    if (repository == null) {
      if (mounted) {
        setState(() {
          isLoadingDietTypes = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Diet type repository not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final result = await repository.getDietTypes();
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              isLoadingDietTypes = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load diet types: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (types) {
          if (mounted) {
            setState(() {
              dietTypes = types;
              isLoadingDietTypes = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingDietTypes = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading diet types: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDietTypeBottomSheet() {
    if (dietTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading diet types, please wait...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get current diet type ID from fitness profile
    String? currentDietTypeId;

    if (fitnessProfile != null && fitnessProfile!['diet_type'] != null) {
      final dietType = fitnessProfile!['diet_type'] as Map<String, dynamic>?;
      currentDietTypeId = dietType?['id'] as String?;
    }

    final targetKcal =
        fitnessGoal != null
            ? (fitnessGoal!['target_kcal'] as num?)?.toInt() ?? 2000
            : 2000;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DietTypeBottomSheet(
            dietTypes: dietTypes,
            currentDietTypeId: currentDietTypeId,
            totalKcal: targetKcal,
          ),
    ).then((selectedDietType) {
      if (selectedDietType != null && selectedDietType is DietType) {
        _updateFitnessGoalDietType(selectedDietType);
      }
    });
  }

  Future<void> _updateFitnessGoalDietType(DietType dietType) async {
    final repository = AppRoutes.getFitnessProfileRepository();
    if (repository == null) return;

    try {
      final payload = {'diet_type_id': dietType.id};

      final result = await repository.updateFitnessProfile(payload);
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (response) {
          if (mounted) {
            _loadFitnessProfile();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Diet type updated to: ${dietType.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating diet type: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadFitnessProfile() async {
    final repository = AppRoutes.getFitnessProfileRepository();
    if (repository == null) return;

    try {
      final result = await repository.getMyFitnessProfile();
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              isLoadingTdee = false;
            });
          }
        },
        (response) {
          if (mounted) {
            // Handle both single profile and array of profiles
            dynamic profileData = response['data'];
            Map<String, dynamic>? profile;

            if (profileData is List && profileData.isNotEmpty) {
              // If data is a list, get the most recent profile (sorted by created_at)
              final profiles = List<Map<String, dynamic>>.from(profileData);
              profiles.sort((a, b) {
                final dateA = DateTime.parse(a['created_at'] as String);
                final dateB = DateTime.parse(b['created_at'] as String);
                return dateB.compareTo(dateA);
              });
              profile = profiles.first;
            } else if (profileData is Map<String, dynamic>) {
              profile = profileData;
            }

            if (profile != null) {
              setState(() {
                fitnessProfile = profile;
                tdeeKcal = profile!['tdee_kcal']?.toDouble();
                isLoadingTdee = false;
              });
            } else {
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
        DateFormat('d MMMM').format(selectedDate).toUpperCase();

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
                selectedDate:
                    '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                onAddMeal: (mealType) async {
                  final dateStr =
                      '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';
                  final result = await context.push(
                    '/foodSearch?mealType=$mealType&date=$dateStr',
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
    final now = DateTime.now();
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
    final dateLabel =
        isToday
            ? 'TODAY'
            : DateFormat('EEEE').format(selectedDate).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                '$dateLabel, $todayDate',
                style: AppTypography.body,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        LucideIcons.medal,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ChallengesScreen(),
                          ),
                        );
                        // Refresh notification status when returning
                        if (result == true || result == null) {
                          _checkClaimableItems();
                        }
                      },
                    ),
                    if (hasClaimableItems)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.calendar,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: null,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => context.push('/notifications'),
                ),
              ],
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
              final isToday =
                  date.day == now.day &&
                  date.month == now.month &&
                  date.year == now.year;

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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 45,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: AppTypography.headline.copyWith(
                                fontSize: 16,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      if (isToday && !isSelected)
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
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
    final needed =
        fitnessGoal != null
            ? (fitnessGoal!['target_kcal'] as num?)?.toInt() ?? 2000
            : tdeeKcal?.toInt() ?? 2000;

    final consumed =
        dailyLog != null ? (dailyLog!['total_kcal_eaten'] ?? 0).toInt() : 0;

    final burned =
        dailyLog != null ? (dailyLog!['total_kcal_burned'] ?? 0).toInt() : 0;

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

    String? dietTypeName;
    int? proteinPercentages;
    int? fatPercentages;
    int? carbsPercentages;

    if (fitnessProfile != null && fitnessProfile!['diet_type'] != null) {
      final dietType = fitnessProfile!['diet_type'] as Map<String, dynamic>?;
      dietTypeName = dietType?['name'] as String?;
      proteinPercentages = (dietType?['protein_percentages'] as num?)?.toInt();
      fatPercentages = (dietType?['fat_percentages'] as num?)?.toInt();
      carbsPercentages = (dietType?['carbs_percentages'] as num?)?.toInt();
    }

    return KcalCircularProgressCard(
      consumed: consumed,
      needed: needed,
      burned: burned,
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
      dietTypeName: dietTypeName,
      proteinPercentages: proteinPercentages,
      fatPercentages: fatPercentages,
      carbsPercentages: carbsPercentages,
      onDietTypePressed: _showDietTypeBottomSheet,
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
                  if (result == true && mounted) {
                    await _loadDailyLog();
                    setState(() {});
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
