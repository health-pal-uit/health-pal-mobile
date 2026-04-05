import 'package:da1/src/config/routes.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FitnessProfileScreen extends StatefulWidget {
  const FitnessProfileScreen({super.key});

  @override
  State<FitnessProfileScreen> createState() => _FitnessProfileScreenState();
}

class _FitnessProfileScreenState extends State<FitnessProfileScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _fitnessProfile;
  Map<String, dynamic>? _fitnessGoal;
  Map<String, dynamic>? _userData;
  bool _isGoogleFitConnected = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.wait([
      _loadFitnessProfile(),
      _loadFitnessGoal(),
      _loadGoogleFitStatus(),
      _loadUserData(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadFitnessProfile() async {
    final repository = AppRoutes.getFitnessProfileRepository();
    if (repository == null) return;

    try {
      final result = await repository.getMyFitnessProfile();
      result.fold(
        (failure) {
          setState(() {
            _errorMessage = failure.message;
          });
        },
        (response) {
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
              _fitnessProfile = profile;
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadFitnessGoal() async {
    final repository = AppRoutes.getFitnessGoalRepository();
    if (repository == null) return;

    try {
      final result = await repository.getFitnessGoal();
      result.fold(
        (failure) {
          // It's okay if there's no goal yet
        },
        (response) {
          setState(() {
            _fitnessGoal = response['data'] as Map<String, dynamic>?;
          });
        },
      );
    } catch (e) {
      // Silent fail for fitness goal
    }
  }

  Future<void> _loadGoogleFitStatus() async {
    final repository = AppRoutes.getGoogleFitRepository();
    if (repository == null) return;

    try {
      final result = await repository.getConnectionStatus();
      result.fold(
        (failure) {
          // Silent fail - assume not connected
          setState(() {
            _isGoogleFitConnected = false;
          });
        },
        (isConnected) {
          setState(() {
            _isGoogleFitConnected = isConnected;
          });
        },
      );
    } catch (e) {
      // Silent fail - assume not connected
      setState(() {
        _isGoogleFitConnected = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    final repository = AppRoutes.getUserRepository();
    if (repository == null) return;

    try {
      final result = await repository.getUserProfile();
      result.fold(
        (failure) {
          // Silent fail - user data is optional
        },
        (userData) {
          setState(() {
            _userData = userData['data'] as Map<String, dynamic>?;
            // Update Google Fit connection status from user data if available
            if (_userData != null &&
                _userData!.containsKey('google_fit_connected_at')) {
              _isGoogleFitConnected =
                  _userData!['google_fit_connected_at'] != null;
            }
          });
        },
      );
    } catch (e) {
      // Silent fail - user data is optional
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Fitness Profile',
          style: AppTypography.headline.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Colors.black),
            onPressed: _loadAllData,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : _errorMessage != null
              ? _buildErrorState()
              : _buildProfileContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.circleAlert, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTypography.body.copyWith(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAllData,
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildHeaderCard(),
          const SizedBox(height: 16),

          // Body Metrics Section
          if (_fitnessProfile != null) ...[
            _buildSectionTitle('Body Metrics'),
            const SizedBox(height: 12),
            _buildBodyMetricsCard(),
            const SizedBox(height: 16),
          ],

          // Activity & Fitness Section
          if (_fitnessProfile != null) ...[
            _buildSectionTitle('Activity & Fitness'),
            const SizedBox(height: 12),
            _buildActivityMetricsCard(),
            const SizedBox(height: 16),
          ],

          // Goals Section
          if (_fitnessGoal != null) ...[
            _buildSectionTitle('Current Goals'),
            const SizedBox(height: 12),
            _buildGoalsCard(),
            const SizedBox(height: 16),
          ],

          // Nutrition Preferences
          if (_fitnessProfile != null &&
              _fitnessProfile!['diet_type'] != null) ...[
            _buildSectionTitle('Nutrition Preferences'),
            const SizedBox(height: 12),
            _buildNutritionCard(),
            const SizedBox(height: 16),
          ],

          // Health Integration
          _buildSectionTitle('Health Integration'),
          const SizedBox(height: 12),
          _buildHealthIntegrationCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.headline.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildHeaderCard() {
    final age = _calculateAge();
    // Use gender from user data if available, otherwise fallback to fitness profile
    final genderData = _userData?['gender'];
    final genderFromProfile = _fitnessProfile?['gender'] as bool?;

    String genderText;
    bool? genderIcon;

    // Handle gender as either String or bool
    if (genderData != null) {
      if (genderData is String) {
        genderText =
            genderData == 'male'
                ? 'Male'
                : genderData == 'female'
                ? 'Female'
                : 'Not specified';
        genderIcon =
            genderData == 'male'
                ? true
                : genderData == 'female'
                ? false
                : null;
      } else if (genderData is bool) {
        genderText = genderData ? 'Male' : 'Female';
        genderIcon = genderData;
      } else {
        genderText = 'Not specified';
        genderIcon = null;
      }
    } else if (genderFromProfile != null) {
      genderText = genderFromProfile ? 'Male' : 'Female';
      genderIcon = genderFromProfile;
    } else {
      genderText = 'Not specified';
      genderIcon = null;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Icon(
                  genderIcon == true ? LucideIcons.user : LucideIcons.userRound,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Profile',
                      style: AppTypography.headline.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(genderText, LucideIcons.user),
                        if (age != null) ...[
                          const SizedBox(width: 8),
                          _buildInfoChip('$age', LucideIcons.calendar),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.body.copyWith(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMetricsCard() {
    final heightInMeters = _fitnessProfile?['height_m'] as num?;
    final height =
        heightInMeters != null ? (heightInMeters * 100).toInt() : null;
    final weight = _fitnessProfile?['weight_kg'] as num?;
    final targetWeight = _fitnessProfile?['target_weight_kg'] as num?;
    // Use BMI from API if available, otherwise calculate
    final apiBmi = _fitnessProfile?['bmi'] as num?;
    final bmi =
        apiBmi?.toDouble() ??
        (heightInMeters != null && weight != null
            ? _calculateBMI(heightInMeters * 100, weight.toDouble())
            : null);

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
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Height',
                  height != null ? '${height.toInt()} cm' : 'N/A',
                  LucideIcons.ruler,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Weight',
                  weight != null ? '${weight.toStringAsFixed(1)} kg' : 'N/A',
                  LucideIcons.weight,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Target Weight',
                  targetWeight != null
                      ? '${targetWeight.toStringAsFixed(1)} kg'
                      : 'N/A',
                  LucideIcons.target,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'BMI',
                  bmi != null ? bmi.toStringAsFixed(1) : 'N/A',
                  LucideIcons.activity,
                  _getBMIColor(bmi),
                ),
              ),
            ],
          ),
          if (bmi != null) ...[
            const SizedBox(height: 12),
            _buildBMIIndicator(bmi),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityMetricsCard() {
    final activityLevel = _fitnessProfile?['activity_level'] as String?;
    final tdee = _fitnessProfile?['tdee_kcal'] as num?;
    final bmr = _fitnessProfile?['bmr'] as num?;
    final bodyFat = _fitnessProfile?['body_fat_percentages'] as num?;

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
        children: [
          _buildActivityLevelDisplay(activityLevel),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'TDEE',
                  tdee != null ? '${tdee.toInt()} kcal' : 'N/A',
                  LucideIcons.flame,
                  Colors.red,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'BMR',
                  bmr != null ? '${bmr.toInt()} kcal' : 'N/A',
                  LucideIcons.battery,
                  Colors.purple,
                ),
              ),
            ],
          ),
          if (bodyFat != null) ...[
            const SizedBox(height: 16),
            _buildMetricItem(
              'Body Fat',
              '${bodyFat.toStringAsFixed(1)}%',
              LucideIcons.chartPie,
              Colors.amber,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityLevelDisplay(String? activityLevel) {
    final levelText = _getActivityLevelText(activityLevel);
    final levelDescription = _getActivityLevelDescription(activityLevel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.zap, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity Level',
                  style: AppTypography.body.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  levelText,
                  style: AppTypography.headline.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (levelDescription != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    levelDescription,
                    style: AppTypography.body.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsCard() {
    final goalType = _fitnessGoal?['goal_type'] as String?;
    final targetKcal = _fitnessGoal?['target_kcal'] as num?;
    final targetProtein = _fitnessGoal?['target_protein_gr'] as num?;
    final targetFat = _fitnessGoal?['target_fat_gr'] as num?;
    final targetCarbs = _fitnessGoal?['target_carbs_gr'] as num?;
    final targetFiber = _fitnessGoal?['target_fiber_gr'] as num?;

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
        children: [
          // Goal type
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.blue.shade400],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.target, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Goal Type',
                        style: AppTypography.body.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getGoalTypeText(goalType),
                        style: AppTypography.headline.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Daily calorie target
          _buildMetricItem(
            'Daily Calorie Target',
            targetKcal != null ? '${targetKcal.toInt()} kcal' : 'N/A',
            LucideIcons.flame,
            Colors.red,
          ),
          const SizedBox(height: 16),

          // Macros
          Text(
            'Daily Macros Target',
            style: AppTypography.body.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMacroItem(
                  'Protein',
                  targetProtein != null ? '${targetProtein}g' : 'N/A',
                  Colors.red.shade400,
                ),
              ),
              Expanded(
                child: _buildMacroItem(
                  'Fat',
                  targetFat != null ? '${targetFat}g' : 'N/A',
                  Colors.orange.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMacroItem(
                  'Carbs',
                  targetCarbs != null ? '${targetCarbs}g' : 'N/A',
                  Colors.blue.shade400,
                ),
              ),
              Expanded(
                child: _buildMacroItem(
                  'Fiber',
                  targetFiber != null ? '${targetFiber}g' : 'N/A',
                  Colors.green.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard() {
    final dietType = _fitnessProfile?['diet_type'] as Map<String, dynamic>?;
    if (dietType == null) return const SizedBox.shrink();

    final dietName = dietType['name'] as String? ?? 'Unknown';
    final dietDescription = dietType['description'] as String?;
    final proteinPct = dietType['protein_percentages'] as num?;
    final fatPct = dietType['fat_percentages'] as num?;
    final carbsPct = dietType['carbs_percentages'] as num?;

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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.apple,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diet Type',
                      style: AppTypography.body.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dietName,
                      style: AppTypography.headline.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (dietDescription != null) ...[
            const SizedBox(height: 12),
            Text(
              dietDescription,
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Macro Distribution',
            style: AppTypography.body.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMacroPercentageItem(
                  'Protein',
                  proteinPct != null ? '$proteinPct%' : 'N/A',
                  Colors.red.shade400,
                ),
              ),
              Expanded(
                child: _buildMacroPercentageItem(
                  'Fat',
                  fatPct != null ? '$fatPct%' : 'N/A',
                  Colors.orange.shade400,
                ),
              ),
              Expanded(
                child: _buildMacroPercentageItem(
                  'Carbs',
                  carbsPct != null ? '$carbsPct%' : 'N/A',
                  Colors.blue.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthIntegrationCard() {
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.smartphone,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google Fit',
                      style: AppTypography.headline.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isGoogleFitConnected ? 'Connected' : 'Not connected',
                      style: AppTypography.body.copyWith(
                        fontSize: 12,
                        color:
                            _isGoogleFitConnected
                                ? Colors.green
                                : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _isGoogleFitConnected
                    ? LucideIcons.circleCheck
                    : LucideIcons.circle,
                color: _isGoogleFitConnected ? Colors.green : Colors.grey,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.body.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.headline.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.headline.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroPercentageItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: AppTypography.headline.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.body.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBMIIndicator(double bmi) {
    String category;
    Color categoryColor;

    if (bmi < 18.5) {
      category = 'Underweight';
      categoryColor = Colors.blue;
    } else if (bmi < 25) {
      category = 'Normal';
      categoryColor = Colors.green;
    } else if (bmi < 30) {
      category = 'Overweight';
      categoryColor = Colors.orange;
    } else {
      category = 'Obese';
      categoryColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.info, size: 16, color: categoryColor),
          const SizedBox(width: 8),
          Text(
            category,
            style: AppTypography.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: categoryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  int? _calculateAge() {
    // Prioritize birth_date from user data, fallback to fitness profile
    final birthDate =
        (_userData?['birth_date'] ?? _fitnessProfile?['birth_date']) as String?;
    if (birthDate == null) return null;

    try {
      final birth = DateTime.parse(birthDate);
      final today = DateTime.now();
      int age = today.year - birth.year;
      if (today.month < birth.month ||
          (today.month == birth.month && today.day < birth.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  double? _calculateBMI(double? height, double? weight) {
    if (height == null || weight == null || height == 0) return null;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  Color _getBMIColor(double? bmi) {
    if (bmi == null) return Colors.grey;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getActivityLevelText(String? level) {
    switch (level?.toLowerCase()) {
      case 'sedentary':
        return 'Sedentary';
      case 'lightly_active':
        return 'Lightly Active';
      case 'moderately_active':
        return 'Moderately Active';
      case 'very_active':
        return 'Very Active';
      case 'extra_active':
        return 'Extra Active';
      default:
        return 'Not Set';
    }
  }

  String? _getActivityLevelDescription(String? level) {
    switch (level?.toLowerCase()) {
      case 'sedentary':
        return 'Little or no exercise';
      case 'lightly_active':
        return 'Light exercise 1-3 days/week';
      case 'moderately_active':
        return 'Moderate exercise 3-5 days/week';
      case 'very_active':
        return 'Heavy exercise 6-7 days/week';
      case 'extra_active':
        return 'Very heavy exercise & physical job';
      default:
        return null;
    }
  }

  String _getGoalTypeText(String? goalType) {
    switch (goalType?.toLowerCase()) {
      case 'cut':
        return 'Cut (Lose Weight)';
      case 'bulk':
        return 'Bulk (Gain Weight)';
      case 'maintain':
        return 'Maintain Weight';
      case 'recovery':
        return 'Recovery';
      case 'gain_muscles':
        return 'Gain Muscles';
      default:
        return 'Not Set';
    }
  }
}
