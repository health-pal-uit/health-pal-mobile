import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingActivityLevelScreen extends StatefulWidget {
  final Map<String, double?> measurements;

  const OnboardingActivityLevelScreen({super.key, required this.measurements});

  @override
  State<OnboardingActivityLevelScreen> createState() =>
      _OnboardingActivityLevelScreenState();
}

class _OnboardingActivityLevelScreenState
    extends State<OnboardingActivityLevelScreen> {
  String? _selectedActivityLevel;
  bool _isLoading = false;

  final List<Map<String, String>> _activityLevels = [
    {
      'value': 'sedentary',
      'title': 'Sedentary',
      'description': 'Little or no exercise',
    },
    {
      'value': 'lightly_active',
      'title': 'Lightly Active',
      'description': 'Light exercise 1-3 days/week',
    },
    {
      'value': 'moderately',
      'title': 'Moderately Active',
      'description': 'Moderate exercise 3-5 days/week',
    },
    {
      'value': 'active',
      'title': 'Active',
      'description': 'Hard exercise 6-7 days/week',
    },
    {
      'value': 'very_active',
      'title': 'Very Active',
      'description': 'Very hard exercise & physical job',
    },
  ];

  Future<void> _createFitnessProfile() async {
    if (_selectedActivityLevel == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = AppRoutes.getFitnessProfileRepository();
      if (repository == null) {
        throw Exception('Fitness profile repository not available');
      }

      // Build the payload, only including non-null optional fields
      final payload = <String, dynamic>{
        'weight_kg': widget.measurements['weight'],
        'height_m': widget.measurements['height']! / 100, // Convert cm to m
        'activity_level': _selectedActivityLevel,
      };

      // Add optional measurements only if they're not null
      if (widget.measurements['waist'] != null) {
        payload['waist_cm'] = (widget.measurements['waist'] as double).toInt();
      }
      if (widget.measurements['hip'] != null) {
        payload['hip_cm'] = (widget.measurements['hip'] as double).toInt();
      }
      if (widget.measurements['neck'] != null) {
        payload['neck_cm'] = (widget.measurements['neck'] as double).toInt();
      }

      final result = await repository.createFitnessProfile(payload);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${failure.message}')),
            );
          }
        },
        (response) {
          if (mounted) {
            context.go('/onboarding-complete');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: screenWidth * 0.08,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFA9500),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Activity Level",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Select your typical activity level",
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _activityLevels.length,
                  itemBuilder: (context, index) {
                    final level = _activityLevels[index];
                    final isSelected = _selectedActivityLevel == level['value'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedActivityLevel = level['value'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color:
                                  isSelected ? AppColors.primary : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    level['title']!,
                                    style: AppTypography.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    level['description']!,
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () => context.pushNamed(
                              'onboarding-body-measurements',
                              extra: {
                                'height': widget.measurements['height'],
                                'weight': widget.measurements['weight'],
                              },
                            ),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: const Color(0xFFFFE5C2),
                      padding: const EdgeInsets.all(12),
                      elevation: 0,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 30,
                    child: ElevatedButton(
                      onPressed:
                          _selectedActivityLevel != null && !_isLoading
                              ? _createFitnessProfile
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _selectedActivityLevel != null && !_isLoading
                                ? AppColors.primary
                                : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                "COMPLETE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
