import 'package:flutter/material.dart';
import 'package:frontend_mob/core/theme/app_theme.dart';
import 'package:frontend_mob/core/theme/theme_mode_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle heading(BuildContext context) {
    final isDark = context.isDarkMode;
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle subHeading(BuildContext context) {
    final isDark = context.isDarkMode;
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle body(BuildContext context) {
    final isDark = context.isDarkMode;
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: isDark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary,
    );
  }

  static TextStyle button(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
  }
}
