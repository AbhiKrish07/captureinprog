import 'package:flutter/material.dart';

class DesignSystem {
  // Colors
  static const Color backgroundDark = Color(0xFF080808);
  static const Color surfaceDark = Color(0xFF1a1a1a);
  static const Color accentOrange = Color(0xFFe8593c);
  static const Color accentViolet = Color(0xFF7C6EF7);
  static const Color textPrimary = Color(0xFFf0ede8);
  static const Color textSecondary = Color(0xFFb3afa8);
  static const Color textTertiary = Color(0xFF6B6A68);
  static const Color borderDark = Color(0xFF2a2a2a);
  static const Color errorRed = Color(0xFFe57373);
  static const Color surfaceGreen = Color(0xFF1e2e22);
  static const Color accentGreen = Color(0xFF4caf50);

  // Typography
  static TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    fontFamily: 'InstrumentSerif',
    color: textPrimary,
  );

  static TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontFamily: 'DMMono',
    letterSpacing: 0.5,
    color: textSecondary,
  );

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;

  // Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;

  // Duration
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
}
