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
          text: "Personal Health Information",
          onTap: () {
            // TODO: Navigate to personal health info
          },
        ),
        ProfileItem(
          icon: LucideIcons.mail,
          text: "Email Address",
          onTap: () {
            // TODO: Navigate to email settings
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
