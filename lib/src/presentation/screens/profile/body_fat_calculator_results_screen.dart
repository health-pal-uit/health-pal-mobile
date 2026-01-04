import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BodyFatCalculatorResultsScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final String calculationMethod;

  const BodyFatCalculatorResultsScreen({
    super.key,
    required this.result,
    required this.calculationMethod,
  });

  @override
  Widget build(BuildContext context) {
    final bodyFat = result['body_fat_percentages'] as num?;
    final bmi = result['bmi'] as num?;
    final bmr = result['bmr'] as num?;
    final tdee = result['tdee_kcal'] as num?;
    final waist = result['waist_cm'] as num?;
    final hip = result['hip_cm'] as num?;
    final neck = result['neck_cm'] as num?;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Calculation Results',
          style: AppTypography.headline.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSuccessHeader(),
            const SizedBox(height: 24),
            if (bodyFat != null) _buildBodyFatCard(bodyFat),
            const SizedBox(height: 16),
            _buildMetricsGrid(bmi, bmr, tdee),
            const SizedBox(height: 16),
            _buildMeasurementsCard(waist, hip, neck),
            const SizedBox(height: 16),
            _buildMethodCard(),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
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
              LucideIcons.circleCheck,
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
                  'Calculation Complete',
                  style: AppTypography.headline.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your body composition results',
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

  Widget _buildBodyFatCard(num bodyFat) {
    final percentage = bodyFat.toDouble();
    final category = _getBodyFatCategory(percentage);
    final categoryColor = _getBodyFatColor(percentage);

    return Container(
      padding: const EdgeInsets.all(24),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.chartPie,
                  color: categoryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Body Fat Percentage',
                      style: AppTypography.body.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: AppTypography.headline.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(num? bmi, num? bmr, num? tdee) {
    return Row(
      children: [
        if (bmi != null)
          Expanded(
            child: _buildMetricCard(
              'BMI',
              bmi.toStringAsFixed(1),
              LucideIcons.activity,
              _getBMIColor(bmi.toDouble()),
            ),
          ),
        if (bmi != null && bmr != null) const SizedBox(width: 12),
        if (bmr != null)
          Expanded(
            child: _buildMetricCard(
              'BMR',
              '${bmr.toInt()}\nkcal',
              LucideIcons.battery,
              Colors.purple,
            ),
          ),
        if ((bmi != null || bmr != null) && tdee != null)
          const SizedBox(width: 12),
        if (tdee != null)
          Expanded(
            child: _buildMetricCard(
              'TDEE',
              '${tdee.toInt()}\nkcal',
              LucideIcons.flame,
              Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsCard(num? waist, num? hip, num? neck) {
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
                'Your Measurements',
                style: AppTypography.headline.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (waist != null)
            _buildMeasurementRow('Waist', '${waist.toInt()} cm', Colors.blue),
          if (waist != null && hip != null) const SizedBox(height: 12),
          if (hip != null)
            _buildMeasurementRow('Hip', '${hip.toInt()} cm', Colors.purple),
          if ((waist != null || hip != null) && neck != null)
            const SizedBox(height: 12),
          if (neck != null)
            _buildMeasurementRow('Neck', '${neck.toInt()} cm', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildMeasurementRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.body.copyWith(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.headline.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCard() {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.settings,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calculation Method',
                  style: AppTypography.body.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getMethodName(calculationMethod),
                  style: AppTypography.headline.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.check, size: 20),
              const SizedBox(width: 8),
              Text(
                'Done',
                style: AppTypography.headline.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.calculator, size: 20),
              const SizedBox(width: 8),
              Text(
                'Calculate Again',
                style: AppTypography.headline.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getBodyFatCategory(double bodyFat) {
    if (bodyFat < 6) return 'Essential Fat';
    if (bodyFat < 14) return 'Athletes';
    if (bodyFat < 18) return 'Fitness';
    if (bodyFat < 25) return 'Average';
    return 'Above Average';
  }

  Color _getBodyFatColor(double bodyFat) {
    if (bodyFat < 6) return Colors.red;
    if (bodyFat < 14) return Colors.green;
    if (bodyFat < 18) return Colors.blue;
    if (bodyFat < 25) return Colors.orange;
    return Colors.red.shade700;
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getMethodName(String method) {
    switch (method) {
      case 'us_navy':
        return 'US Navy Method';
      case 'ymca':
        return 'YMCA Method';
      case 'bmi':
        return 'BMI Method';
      default:
        return method;
    }
  }
}
