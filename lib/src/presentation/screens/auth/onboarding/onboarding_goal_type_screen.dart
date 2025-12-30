import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingGoalTypeScreen extends StatefulWidget {
  final Map<String, dynamic> previousData;

  const OnboardingGoalTypeScreen({super.key, required this.previousData});

  @override
  State<OnboardingGoalTypeScreen> createState() =>
      _OnboardingGoalTypeScreenState();
}

class _OnboardingGoalTypeScreenState extends State<OnboardingGoalTypeScreen> {
  String? _selectedGoalType;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _goalTypes = [
    {
      'value': 'cut',
      'title': 'Cut',
      'description': 'Lose weight and reduce body fat',
      'icon': Icons.trending_down,
      'color': Color(0xFFFF6B6B),
    },
    {
      'value': 'bulk',
      'title': 'Bulk',
      'description': 'Gain weight and build muscle mass',
      'icon': Icons.trending_up,
      'color': Color(0xFF4ECDC4),
    },
    {
      'value': 'maintain',
      'title': 'Maintain',
      'description': 'Maintain current weight and fitness',
      'icon': Icons.trending_flat,
      'color': Color(0xFF95E1D3),
    },
    {
      'value': 'recovery',
      'title': 'Recovery',
      'description': 'Focus on recovery and rehabilitation',
      'icon': Icons.healing,
      'color': Color(0xFFFFA07A),
    },
    {
      'value': 'gain_muscles',
      'title': 'Gain Muscles',
      'description': 'Build lean muscle and strength',
      'icon': Icons.fitness_center,
      'color': Color(0xFF6C5CE7),
    },
  ];

  Future<void> _createFitnessGoal() async {
    if (_selectedGoalType == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = AppRoutes.getFitnessGoalRepository();
      if (repository == null) {
        throw Exception('Fitness goal repository not available');
      }

      final payload = {'goal_type': _selectedGoalType};

      final result = await repository.createFitnessGoal(payload);

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
            context.go('/onboarding-complete');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating fitness goal: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
                  5,
                  (index) => Container(
                    width: screenWidth * 0.08,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Fitness Goal",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "What's your main fitness goal?",
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _goalTypes.length,
                  itemBuilder: (context, index) {
                    final goal = _goalTypes[index];
                    final isSelected = _selectedGoalType == goal['value'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGoalType = goal['value'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? (goal['color'] as Color).withValues(
                                    alpha: 0.1,
                                  )
                                  : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? goal['color'] as Color
                                    : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? goal['color'] as Color
                                        : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                goal['icon'] as IconData,
                                color: isSelected ? Colors.white : Colors.grey,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal['title']!,
                                    style: AppTypography.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    goal['description']!,
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color:
                                  isSelected
                                      ? goal['color'] as Color
                                      : Colors.grey,
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
                    onPressed: _isLoading ? null : () => context.pop(),
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
                          _selectedGoalType != null && !_isLoading
                              ? _createFitnessGoal
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _selectedGoalType != null && !_isLoading
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
