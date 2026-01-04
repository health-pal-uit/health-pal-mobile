import 'package:da1/src/config/routes.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/presentation/screens/profile/body_fat_calculator_results_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BodyFatCalculatorScreen extends StatefulWidget {
  const BodyFatCalculatorScreen({super.key});

  @override
  State<BodyFatCalculatorScreen> createState() =>
      _BodyFatCalculatorScreenState();
}

class _BodyFatCalculatorScreenState extends State<BodyFatCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();
  final TextEditingController _neckController = TextEditingController();

  String _selectedMethod = 'us_navy';
  bool _isCalculating = false;

  @override
  void dispose() {
    _waistController.dispose();
    _hipController.dispose();
    _neckController.dispose();
    super.dispose();
  }

  Future<void> _calculateBodyFat() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    try {
      final repository = AppRoutes.getFitnessProfileRepository();
      if (repository == null) {
        throw Exception('Repository not available');
      }

      final data = {
        'waist_cm': double.parse(_waistController.text),
        'hip_cm': double.parse(_hipController.text),
        'neck_cm': double.parse(_neckController.text),
        'body_fat_calculating_method': _selectedMethod,
      };

      final result = await repository.calculateBodyFat(data);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (response) {
          if (mounted) {
            final resultData = response['data'] as Map<String, dynamic>?;
            if (resultData != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => BodyFatCalculatorResultsScreen(
                        result: resultData,
                        calculationMethod: _selectedMethod,
                      ),
                ),
              );
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCalculating = false;
        });
      }
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
          'Body Fat Calculator',
          style: AppTypography.headline.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildMethodSelector(),
              const SizedBox(height: 24),
              _buildInputFields(),
              const SizedBox(height: 24),
              _buildCalculateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.calculator,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calculate Body Fat',
                  style: AppTypography.headline.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter your measurements to estimate your body fat percentage',
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSelector() {
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
              const Icon(
                LucideIcons.settings,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Calculation Method',
                style: AppTypography.headline.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMethodOption(
            'us_navy',
            'US Navy Method',
            'Most commonly used method',
          ),
          const SizedBox(height: 12),
          _buildMethodOption(
            'ymca',
            'YMCA Method',
            'Alternative calculation approach',
          ),
          const SizedBox(height: 12),
          _buildMethodOption('bmi', 'BMI Method', 'Based on Body Mass Index'),
        ],
      ),
    );
  }

  Widget _buildMethodOption(String value, String title, String description) {
    final isSelected = _selectedMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primary
                    : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child:
                  isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headline.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTypography.body.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFields() {
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
              const Icon(LucideIcons.ruler, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Measurements',
                style: AppTypography.headline.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _waistController,
            label: 'Waist Circumference',
            hint: 'Enter waist measurement',
            suffix: 'cm',
            icon: LucideIcons.circle,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _hipController,
            label: 'Hip Circumference',
            hint: 'Enter hip measurement',
            suffix: 'cm',
            icon: LucideIcons.circle,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _neckController,
            label: 'Neck Circumference',
            hint: 'Enter neck measurement',
            suffix: 'cm',
            icon: LucideIcons.circle,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.body.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            suffixText: suffix,
            suffixStyle: AppTypography.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter $label';
            }
            final number = double.tryParse(value);
            if (number == null || number <= 0) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: _isCalculating ? null : _calculateBodyFat,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child:
          _isCalculating
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.calculator, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Calculate Body Fat',
                    style: AppTypography.headline.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
    );
  }
}
