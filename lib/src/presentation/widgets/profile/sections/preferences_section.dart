import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/presentation/widgets/profile/profile_item.dart';
import 'package:da1/src/presentation/widgets/profile/profile_section.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PreferencesSection extends StatefulWidget {
  const PreferencesSection({super.key});

  @override
  State<PreferencesSection> createState() => _PreferencesSectionState();
}

class _PreferencesSectionState extends State<PreferencesSection> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: "Preferences",
      items: [
        ProfileItem(
          icon: LucideIcons.bell,
          text: "Notifications",
          trailing: Switch(
            value: notificationsEnabled,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
            onChanged: (val) {
              setState(() => notificationsEnabled = val);
            },
          ),
        ),
        ProfileItem(
          icon: LucideIcons.moon,
          text: "Dark Mode",
          trailing: Switch(
            value: darkModeEnabled,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
            onChanged: (val) {
              setState(() => darkModeEnabled = val);
            },
          ),
        ),
        ProfileItem(
          icon: LucideIcons.globe,
          text: "Language",
          onTap: () {
            // TODO: Navigate to language settings
          },
        ),
      ],
    );
  }
}
