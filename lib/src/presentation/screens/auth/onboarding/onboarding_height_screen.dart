import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class OnboardingHeightScreen extends StatefulWidget {
  const OnboardingHeightScreen({super.key});

  @override
  State<OnboardingHeightScreen> createState() => _OnboardingHeightScreenState();
}

class _OnboardingHeightScreenState extends State<OnboardingHeightScreen> {
  final TextEditingController _heightController = TextEditingController();
  final FocusNode _heightFocusNode = FocusNode();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _heightFocusNode.addListener(() {
      setState(() {});
    });
    _heightController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _heightFocusNode.dispose();
    _heightController.removeListener(_updateButtonState);
    _heightController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final isEnabled = _heightController.text.trim().isNotEmpty;
    if (_isButtonEnabled != isEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
    }
  }

  void _goNext() {
    if (_isButtonEnabled) {
      context.go('/onboarding-weight');
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
                  3,
                  (index) => Container(
                    width: screenWidth * 0.1,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          index <= 0
                              ? const Color(0xFFFA9500)
                              : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "What is your height?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
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
                  controller: _heightController,
                  focusNode: _heightFocusNode,
                  style: AppTypography.body,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        _heightFocusNode.hasFocus
                            ? AppColors.backgroundDark
                            : AppColors.backgroundLight,
                    hintText: "Enter your height",
                    suffixText: "cm",
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
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
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
        ),
      ),
    );
  }
}
