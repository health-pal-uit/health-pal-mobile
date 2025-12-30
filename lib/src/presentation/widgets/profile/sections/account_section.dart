import 'package:da1/src/presentation/widgets/profile/profile_item.dart';
import 'package:da1/src/presentation/widgets/profile/profile_section.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: "Account",
      items: [
        ProfileItem(
          icon: LucideIcons.user,
          text: "Personal Information",
          onTap: () {
            // TODO: Navigate to personal information
          },
        ),
        ProfileItem(
          icon: LucideIcons.lock,
          text: "Password Security",
          onTap: () {
            // TODO: Navigate to password settings
          },
        ),
      ],
    );
  }
}
