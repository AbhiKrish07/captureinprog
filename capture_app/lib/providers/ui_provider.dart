import 'package:flutter_riverpod/flutter_riverpod.dart';

// Current bottom navigation index
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

// Show/hide capture input bottom sheet
final showCaptureInputProvider = StateProvider<bool>((ref) => false);

// Loading state for async operations
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Error message state
final errorMessageProvider = StateProvider<String?>((ref) => null);

// Clear error after delay
void clearError(WidgetRef ref, [Duration duration = const Duration(seconds: 3)]) {
  Future.delayed(duration, () {
    ref.read(errorMessageProvider.notifier).state = null;
  });
}
