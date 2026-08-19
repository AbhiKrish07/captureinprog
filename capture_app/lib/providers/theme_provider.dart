import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    AppColors.isDarkMode = false;
  }

  void toggleTheme() {
    state = !state;
    AppColors.isDarkMode = state;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});
