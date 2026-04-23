import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ExpertPendingScreen extends StatelessWidget {
  const ExpertPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Account Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF7ED), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeaderIcon(),
                const SizedBox(height: 24),

                Text(
                  'Profile Under Review',
                  style: AppTypography.headline.copyWith(
                    fontSize: 24,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your expert profile is being verified by our admin team',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4A5565),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                _buildTimelineCard(),
                const SizedBox(height: 24),

                _buildReviewingItemsCard(),
                const SizedBox(height: 32),

                const Text(
                  "The verification process typically takes 24-48 hours. You'll receive an email notification once your profile is approved.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4A5565),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'If you have questions about your application status, contact our support team.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4A5565),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'support@healthcare.com',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                _buildButtons(context),
                const SizedBox(height: 24),

                const Text(
                  'You will not be able to accept consultations until your profile is approved',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        color: Color(0xFFFEF9C2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.clock, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFF085), width: 1.25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.calendarDays,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Expected Timeline',
                style: AppTypography.headline.copyWith(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                LucideIcons.hourglass,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 12),
              const Text(
                'Pending review completion',
                style: TextStyle(color: Color(0xFF6A7282), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                LucideIcons.calendarClock,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 12),
              const Text(
                'Typically 24 - 48 hours',
                style: TextStyle(
                  color: Color(0xFF4A5565),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewingItemsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1.25,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.fileSearch,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "What We're Reviewing",
                style: AppTypography.headline.copyWith(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBulletPoint('Medical qualifications and certifications'),
          const SizedBox(height: 8),
          _buildBulletPoint('Professional experience verification'),
          const SizedBox(height: 8),
          _buildBulletPoint('License and credential validation'),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4.0),
          child: Icon(LucideIcons.circleCheck, color: Colors.green, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4A5565),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              // TODO: delete this demo button after testing
              context.go('/expert/dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Continue to Dashboard (Demo)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              context.go('/');
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFD1D5DC), width: 1.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Back to Home',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
