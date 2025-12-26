import 'package:da1/src/presentation/widgets/profile/profile_item.dart';
import 'package:da1/src/presentation/widgets/profile/profile_section.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: "Support & About",
      items: [
        ProfileItem(
          icon: LucideIcons.messageCircleQuestionMark,
          text: "Help & Support",
          onTap: () {
            // TODO: Navigate to help
          },
        ),
        ProfileItem(
          icon: LucideIcons.receiptText,
          text: "Term & Conditions",
          onTap: () {
            // TODO: Navigate to terms
          },
        ),
        ProfileItem(
          icon: LucideIcons.circleAlert,
          text: "About Health Pal",
          onTap: () {
            // TODO: Navigate to about
          },
        ),
      ],
    );
  }
}
