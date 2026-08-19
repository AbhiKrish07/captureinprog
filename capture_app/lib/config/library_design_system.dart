// lib/config/library_design_system.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LibraryDesignSystem {
  // Colors
  static Color get background => AppColors.background;
  static Color get surface => AppColors.surface;
  static Color get surfaceLight => AppColors.surfaceElevated;
  static Color get accentOrange => AppColors.orange;
  static Color get textPrimary => AppColors.textPrimary;
  static Color get textSecondary => AppColors.textSecondary;
  static Color get textMuted => AppColors.textTertiary;
  static Color get borderDark => AppColors.border;

  // Folder colors
  static Color get folderPurple => AppColors.violet;
  static Color get folderBlue => AppColors.blue;
  static Color get folderGreen => AppColors.green;
  static Color get folderOrange => AppColors.orange;
  static Color get folderGray => AppColors.textSecondary;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;

  // Duration
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);

  // Typography
  static TextStyle get titleLarge => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get subtitle => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle get sectionHeader => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get spaceCardTitle => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get spaceCardMeta => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle get spaceCardStatus => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: accentOrange,
  );

  static TextStyle get recentItemTitle => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle get recentItemMeta => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );
}
