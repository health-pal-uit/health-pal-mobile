import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileItem({
    super.key,
    required this.icon,
    required this.text,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: CircleAvatar(
          backgroundColor: const Color(0x21FA9500),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
      ),
      title: Text(text, style: AppTypography.body),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      onTap: onTap,
    );
  }
}
