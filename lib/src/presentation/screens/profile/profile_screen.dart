import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text('Account & Settings', style: AppTypography.headline),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                            radius: 42,
                            backgroundImage: NetworkImage(
                              'https://placehold.co/84x84',
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.8,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => context.push('/personal-profile'),
                            child: Text(
                              'Duy Nguyen',
                              style: AppTypography.body,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'duyhuu1109@gmail.com',
                            style: AppTypography.caption,
                          ),
                          const SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Divider(
                    color: AppColors.primary.withValues(alpha: 0.13),
                    thickness: 2,
                  ),

                  _section(
                    title: "Account",
                    items: [
                      _item(LucideIcons.user, "Personal Health Information"),
                      _item(LucideIcons.mail, "Email Address"),
                      _item(LucideIcons.lock, "Password Security"),
                    ],
                  ),
                  _section(
                    title: "Health & Data",
                    items: [
                      _item(Icons.sync, "Sync with Google Fit"),
                      _item(LucideIcons.ruler, "Units of Measurement"),
                      _item(LucideIcons.shield, "Privacy & Data"),
                    ],
                  ),
                  _section(
                    title: "Preferences",
                    items: [
                      _item(
                        LucideIcons.bell,
                        "Notifications",
                        trailing: Switch(
                          value: notificationsEnabled,
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: AppColors.primary.withValues(
                            alpha: 0.4,
                          ),
                          onChanged: (val) {
                            setState(() => notificationsEnabled = val);
                          },
                        ),
                      ),
                      _item(
                        LucideIcons.moon,
                        "Dark Mode",
                        trailing: Switch(
                          value: darkModeEnabled,
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: AppColors.primary.withValues(
                            alpha: 0.4,
                          ),
                          onChanged: (val) {
                            setState(() => darkModeEnabled = val);
                          },
                        ),
                      ),

                      _item(LucideIcons.globe, "Language"),
                    ],
                  ),
                  _section(
                    title: "Support & About",
                    items: [
                      _item(
                        LucideIcons.messageCircleQuestionMark,
                        "Help & Support",
                      ),
                      _item(LucideIcons.receiptText, "Term & Conditions"),
                      _item(LucideIcons.circleAlert, "About Health Pal"),
                    ],
                  ),
                  _item(Icons.logout, "Logout"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _section({required String title, required List<Widget> items}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.body),
          const SizedBox(height: 4),
          ...items,
          Divider(
            color: AppColors.primary.withValues(alpha: 0.13),
            thickness: 2,
          ),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String text, {Widget? trailing}) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: CircleAvatar(
          backgroundColor: const Color(0x21FA9500),
          child: Icon(icon, color: const Color(0xFFFA9500)),
        ),
      ),
      title: Text(text, style: AppTypography.body),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
