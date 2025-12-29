import 'package:da1/src/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddActionBottomSheet extends StatelessWidget {
  const AddActionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _quickAction(
                context: context,
                color: Colors.amber,
                icon: Icons.search,
                label: "Log Food",
                onTap: () {
                  Navigator.pop(context);
                  context.push('/foodSearch');
                },
              ),
              _quickAction(
                context: context,
                color: Colors.redAccent,
                icon: Icons.camera_alt,
                label: "Meal Scan",
                onTap: () {
                  Navigator.pop(context);
                  context.push('/meal-scan');
                },
              ),
              _quickAction(
                context: context,
                color: Colors.blue,
                icon: Icons.qr_code_scanner,
                label: "Barcode Scan",
                onTap: () {
                  // TODO: Implement barcode scan
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _menuItem(Icons.local_drink, "Water"),
          _menuItem(Icons.local_fire_department, "Exercise"),
          _menuItem(Icons.monitor_weight, "Weight"),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _quickAction({
    required BuildContext context,
    required Color color,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 32, color: Colors.black),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimary),
          const SizedBox(width: 14),
          Text(
            text,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
