import 'package:da1/src/presentation/screens/profile/body_fat_calculator_screen.dart';
import 'package:da1/src/presentation/screens/profile/fitness_profile_screen.dart';
import 'package:da1/src/presentation/widgets/profile/profile_item.dart';
import 'package:da1/src/presentation/widgets/profile/profile_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HealthDataSection extends StatelessWidget {
  const HealthDataSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: "Health & Data",
      items: [
        ProfileItem(
          icon: LucideIcons.activity,
          text: "Fitness Profile",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FitnessProfileScreen(),
              ),
            );
          },
        ),
        ProfileItem(
          icon: Icons.sync,
          text: "Sync with Google Fit",
          onTap: () => context.push('/google-fit-sync'),
        ),
        ProfileItem(
          icon: LucideIcons.calculator,
          text: "Body Fat Percentage Calculator",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BodyFatCalculatorScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
