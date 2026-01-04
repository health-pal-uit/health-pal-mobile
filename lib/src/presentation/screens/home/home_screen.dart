import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/config/routes.dart';
import 'package:da1/src/core/services/local_notification_service.dart';
import 'package:da1/src/presentation/widgets/charts/kcal_circular_progress.dart';
import 'package:da1/src/presentation/widgets/charts/steps_progress.dart';
import 'package:da1/src/presentation/widgets/charts/water_intake.dart';
import 'package:da1/src/presentation/widgets/home_items/workout_card.dart';
import 'package:da1/src/presentation/widgets/home_items/meal_diary_card.dart';
import 'package:da1/src/presentation/widgets/diet_type_bottom_sheet.dart';
import 'package:da1/src/domain/entities/diet_type.dart';
import 'package:da1/src/presentation/screens/home/exercise/challenges_screen.dart';
import 'package:da1/src/presentation/screens/home/fitness_recommendations_screen.dart';
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
  bool hasUnreadNotifications = false;
  List<dynamic> activityRecords = [];
  bool isLoadingActivityRecords = true;
  bool isDeletingActivity = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(LoadCurrentUser());
    _loadFitnessProfile();
    _loadDailyLog();
    _loadFitnessGoal();
    _loadDietTypes();
    _checkClaimableItems();
    _checkUnreadNotifications();
    _loadActivityRecords();
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

  Future<void> _checkUnreadNotifications() async {
    final notificationRepo = AppRoutes.getNotificationRepository();
    if (notificationRepo == null) return;

    final result = await notificationRepo.getNotifications(page: 1, limit: 10);
    result.fold((error) {}, (data) {
      final notifications = (data['data'] as List).cast<Map<String, dynamic>>();
      final hasUnread = notifications.any((n) => n['is_read'] == false);
      if (mounted) {
        setState(() {
          hasUnreadNotifications = hasUnread;
        });
      }
    });
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

  Future<void> _navigateToRecommendations() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                const FitnessRecommendationsScreen(),
      ),
    );

    // Reload fitness goal if recommendations were applied
    if (result == true && mounted) {
      _loadFitnessGoal();
      _loadDailyLog();
    }
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
            dynamic profileData = response['data'];
            Map<String, dynamic>? profile;

            if (profileData is List && profileData.isNotEmpty) {
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
            if (log['id'] != null) {
              _loadActivityRecords();
            }
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

  Future<void> _loadActivityRecords() async {
    if (dailyLog == null || dailyLog!['id'] == null) {
      if (mounted) {
        setState(() {
          activityRecords = [];
          isLoadingActivityRecords = false;
        });
      }
      return;
    }

    final repository = AppRoutes.getActivityRecordRepository();
    if (repository == null) {
      if (mounted) {
        setState(() {
          isLoadingActivityRecords = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        isLoadingActivityRecords = true;
      });
    }

    try {
      final result = await repository.getActivityRecordsByDailyLog(
        dailyLog!['id'],
      );
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              activityRecords = [];
              isLoadingActivityRecords = false;
            });
          }
        },
        (records) {
          if (mounted) {
            setState(() {
              activityRecords = records;
              isLoadingActivityRecords = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          activityRecords = [];
          isLoadingActivityRecords = false;
        });
      }
    }
  }

  void _showActivityOptions(Map<String, dynamic> record) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    LucideIcons.pencil,
                    color: AppColors.primary,
                  ),
                  title: const Text('Edit Duration'),
                  onTap: () {
                    Navigator.pop(context);
                    _editActivityDuration(record);
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.trash2, color: Colors.red),
                  title: const Text(
                    'Delete Activity',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteActivityRecord(record);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  Future<void> _editActivityDuration(Map<String, dynamic> record) async {
    final recordId = record['id'] as String?;
    final activity = record['activity'] as Map<String, dynamic>?;
    final currentDuration = (record['duration_minutes'] as num?)?.toInt() ?? 0;

    if (recordId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot edit activity: missing ID'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final controller = TextEditingController(text: currentDuration.toString());

    final newDuration = await showDialog<int>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit ${activity?['name'] ?? 'Activity'}'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                suffixText: 'min',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final duration = int.tryParse(controller.text);
                  if (duration != null && duration > 0) {
                    Navigator.pop(context, duration);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid duration'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (newDuration != null && newDuration != currentDuration) {
      await _updateActivityDuration(
        recordId,
        newDuration,
        activity?['name'] ?? 'Activity',
      );
    }
  }

  Future<void> _updateActivityDuration(
    String recordId,
    int durationMinutes,
    String activityName,
  ) async {
    setState(() {
      isDeletingActivity = true;
    });

    final repository = AppRoutes.getActivityRecordRepository();
    if (repository == null) {
      if (mounted) {
        setState(() {
          isDeletingActivity = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity record repository not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final result = await repository.updateActivityRecord(
        activityRecordId: recordId,
        durationMinutes: durationMinutes,
      );

      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              isDeletingActivity = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update activity: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );

            LocalNotificationService().showErrorNotification(
              title: 'Update Failed',
              body: 'Failed to update $activityName',
            );
          }
        },
        (response) {
          if (mounted) {
            setState(() {
              isDeletingActivity = false;
            });

            LocalNotificationService().showSuccessNotification(
              title: 'Activity Updated',
              body:
                  '$activityName duration updated to $durationMinutes minutes',
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Activity updated successfully'),
                backgroundColor: Colors.green,
              ),
            );

            _loadActivityRecords();
            _loadDailyLog();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          isDeletingActivity = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating activity: $e'),
            backgroundColor: Colors.red,
          ),
        );

        LocalNotificationService().showErrorNotification(
          title: 'Update Failed',
          body: 'Error updating $activityName',
        );
      }
    }
  }

  Future<void> _deleteActivityRecord(Map<String, dynamic> record) async {
    final recordId = record['id'] as String?;
    if (recordId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot delete activity: missing ID'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Activity'),
            content: const Text(
              'Are you sure you want to delete this activity?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() {
      isDeletingActivity = true;
    });

    final repository = AppRoutes.getActivityRecordRepository();
    if (repository == null) {
      if (mounted) {
        setState(() {
          isDeletingActivity = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity record repository not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final result = await repository.deleteActivityRecord(recordId);
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              isDeletingActivity = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete activity: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (response) {
          if (mounted) {
            setState(() {
              activityRecords.removeWhere((r) => r['id'] == recordId);
              isDeletingActivity = false;
            });

            final activity = record['activity'] as Map<String, dynamic>?;
            final activityName = activity?['name'] ?? 'Activity';

            LocalNotificationService().showSuccessNotification(
              title: 'Activity Deleted',
              body: '$activityName has been removed from your diary',
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Activity deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );

            _loadDailyLog();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          isDeletingActivity = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting activity: $e'),
            backgroundColor: Colors.red,
          ),
        );
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

    return Stack(
      children: [
        Scaffold(
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
                  _buildActivityDiaryCard(),
                  const SizedBox(height: 20),
                  _buildSmallCards(),
                  const SizedBox(height: 30),
                  _buildWorkoutSection(context),
                ],
              ),
            ),
          ),
        ),
        if (isDeletingActivity)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
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
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_outlined,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () async {
                        await context.push('/notifications');
                        // Refresh notification status when returning
                        _checkUnreadNotifications();
                      },
                    ),
                    if (hasUnreadNotifications)
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

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                    });
                    _loadDailyLog();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 65,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary.withValues(
                                  alpha: 0.3,
                                ),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
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
      onRecommendationsPressed: _navigateToRecommendations,
    );
  }

  Widget _buildSmallCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: WaterIntakeWidget()),
        const SizedBox(width: 20),
        Expanded(child: StepsWidget(goal: 10000, steps: 6000)),
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

  Widget _buildActivityDiaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity Diary',
                style: AppTypography.headline.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.plus, size: 20),
                onPressed: () async {
                  final result = await context.push('/add-activity');
                  if (result == true && mounted) {
                    await _loadActivityRecords();
                    setState(() {});
                  }
                },
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoadingActivityRecords)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (activityRecords.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.activity,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No activities recorded yet',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activityRecords.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final record = activityRecords[index] as Map<String, dynamic>;
                final activity = record['activity'] as Map<String, dynamic>?;
                final durationMinutes =
                    (record['duration_minutes'] as num?)?.toInt() ?? 0;
                final kcalBurned =
                    (record['kcal_burned'] as num?)?.toDouble() ?? 0.0;

                return GestureDetector(
                  onLongPress: () => _showActivityOptions(record),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.activity,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity?['name'] ?? 'Unknown Activity',
                              style: AppTypography.headline.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$durationMinutes min • ${kcalBurned.toStringAsFixed(1)} kcal',
                              style: AppTypography.body.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
