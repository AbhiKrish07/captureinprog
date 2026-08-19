import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool isDarkMode = false;

  // Backgrounds
  static Color get background => isDarkMode ? Color(0xFF000000) : Color(0xFFFFFFFF);
  static Color get card => isDarkMode ? Color(0xFF000000) : Color(0xFFF9F9F9);
  static Color get cardHover => isDarkMode ? Color(0xFF000000) : Color(0xFFF0F0F0);
  static Color get surface => isDarkMode ? Color(0xFF000000) : Color(0xFFF5F5F5);
  static Color get surfaceElevated => isDarkMode ? Color(0xFF000000) : Color(0xFFFFFFFF);
  static Color get input => isDarkMode ? Color(0xFF000000) : Color(0xFFF3F3F3);

  // Borders
  static Color get border => isDarkMode ? Color(0xFF262626) : Color(0xFFEBEBEB);
  static Color get borderSubtle => isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFF5F5F5);
  static Color get borderFocused => isDarkMode ? Color(0xFFFF5E00) : Color(0xFF466352);

  // Accents
  static Color get orange => isDarkMode ? Color(0xFFFF5E00) : Color(0xFFD89E6E); 
  static Color get orangeDark => isDarkMode ? Color(0xFFD94A00) : Color(0xFFA67A53);
  static Color get violet => isDarkMode ? Color(0xFF8B5CF6) : Color(0xFFA574C4);
  static Color get violetDark => isDarkMode ? Color(0xFF6D28D9) : Color(0xFF7A5494);
  static Color get green => isDarkMode ? Color(0xFF10B981) : Color(0xFF466352); 
  static Color get greenDark => isDarkMode ? Color(0xFF059669) : Color(0xFF1E3F20); 
  static Color get greenMuted => isDarkMode ? Color(0xFF064E3B) : Color(0xFF628169); 
  static Color get blue => isDarkMode ? Color(0xFF3B82F6) : Color(0xFF5B7DB1); 
  static Color get red => isDarkMode ? Color(0xFFEF4444) : Color(0xFFC8665E); 
  static Color get yellow => isDarkMode ? Color(0xFFF59E0B) : Color(0xFFE6C153);
  static Color get pink => isDarkMode ? Color(0xFFEC4899) : Color(0xFFD481A6);
  static Color get cyan => isDarkMode ? Color(0xFF06B6D4) : Color(0xFF7EBDC2);

  // Text
  static Color get textPrimary => isDarkMode ? Color(0xFFFFFFFF) : Color(0xFF1A1A1A);
  static Color get textSecondary => isDarkMode ? Color(0xFFA1A1AA) : Color(0xFF707070);
  static Color get textTertiary => isDarkMode ? Color(0xFF71717A) : Color(0xFFA0A0A0);
  static Color get textMuted => isDarkMode ? Color(0xFF52525B) : Color(0xFFC0C0C0);

  // Specific
  static Color get proBadge => isDarkMode ? Color(0xFFFF5E00) : Color(0xFF1E3F20);
  static Color get terminalGreen => isDarkMode ? Color(0xFF10B981) : Color(0xFF466352);
  static Color get codeKeyword => isDarkMode ? Color(0xFF8B5CF6) : Color(0xFFA574C4);
  static Color get codeString => isDarkMode ? Color(0xFF10B981) : Color(0xFF628169);
  static Color get codeFunction => isDarkMode ? Color(0xFF3B82F6) : Color(0xFF5B7DB1);
  static Color get codeComment => isDarkMode ? Color(0xFF71717A) : Color(0xFFA0A0A0);
  static Color get codeNumber => isDarkMode ? Color(0xFFF59E0B) : Color(0xFFD89E6E);
  static Color get codeTag => isDarkMode ? Color(0xFFEF4444) : Color(0xFFC8665E);

  // Gradients
  static LinearGradient get orangeGradient => LinearGradient(
    colors: [orange, orangeDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get violetGradient => LinearGradient(
    colors: [violet, violetDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get surfaceGradient => LinearGradient(
    colors: [surfaceElevated, surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
