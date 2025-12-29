import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class OnboardingBodyMeasurementsScreen extends StatefulWidget {
  final double height;
  final double weight;

  const OnboardingBodyMeasurementsScreen({
    super.key,
    required this.height,
    required this.weight,
  });

  @override
  State<OnboardingBodyMeasurementsScreen> createState() =>
      _OnboardingBodyMeasurementsScreenState();
}

class _OnboardingBodyMeasurementsScreenState
    extends State<OnboardingBodyMeasurementsScreen> {
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();
  final TextEditingController _neckController = TextEditingController();

  final FocusNode _waistFocusNode = FocusNode();
  final FocusNode _hipFocusNode = FocusNode();
  final FocusNode _neckFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _waistFocusNode.addListener(() => setState(() {}));
    _hipFocusNode.addListener(() => setState(() {}));
    _neckFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _waistFocusNode.dispose();
    _hipFocusNode.dispose();
    _neckFocusNode.dispose();
    _waistController.dispose();
    _hipController.dispose();
    _neckController.dispose();
    super.dispose();
  }

  void _goNext() {
    context.pushNamed(
      'onboarding-activity',
      extra: {
        'height': widget.height,
        'weight': widget.weight,
        'waist': _waistController.text.trim().isNotEmpty
            ? double.parse(_waistController.text)
            : null,
        'hip': _hipController.text.trim().isNotEmpty
            ? double.parse(_hipController.text)
            : null,
        'neck': _neckController.text.trim().isNotEmpty
            ? double.parse(_neckController.text)
            : null,
      },
    );
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
                      color:
                          index <= 2
                              ? const Color(0xFFFA9500)
                              : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Body Measurements",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "These help us calculate your body composition (optional)",
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _waistController,
                focusNode: _waistFocusNode,
                label: "Waist circumference",
                hint: "Enter your waist size",
                suffix: "cm",
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _hipController,
                focusNode: _hipFocusNode,
                label: "Hip circumference",
                hint: "Enter your hip size",
                suffix: "cm",
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _neckController,
                focusNode: _neckFocusNode,
                label: "Neck circumference",
                hint: "Enter your neck size",
                suffix: "cm",
              ),
              const Spacer(),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/onboarding-weight'),
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
                      onPressed: _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "NEXT",
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: AppTypography.body,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  focusNode.hasFocus
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
              hintText: hint,
              suffixText: suffix,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.textSecondary,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
