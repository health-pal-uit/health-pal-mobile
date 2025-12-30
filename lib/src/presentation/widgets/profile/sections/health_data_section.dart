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
            // TODO: Navigate to fitness profile
          },
        ),
        ProfileItem(
          icon: Icons.sync,
          text: "Sync with Google Fit",
          onTap: () => context.push('/google-fit-sync'),
        ),
        ProfileItem(
          icon: LucideIcons.shield,
          text: "Privacy & Data",
          onTap: () {
            // TODO: Navigate to privacy settings
          },
        ),
      ],
    );
  }
}
