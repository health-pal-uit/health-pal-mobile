import 'package:da1/src/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTypography {
  static TextStyle get headline => TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static TextStyle get body =>
      TextStyle(fontSize: 16.sp, color: AppColors.textSecondary);
  static TextStyle get caption =>
      TextStyle(fontSize: 12.sp, color: AppColors.textSecondary);
}
