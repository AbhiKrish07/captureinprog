import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_colors.dart';

enum ShortcutTargetType {
  space,
  file,
  folder,
  module,
}

class AppShortcut {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  final ShortcutTargetType type;

  AppShortcut({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
    required this.type,
  });
}

class ShortcutsNotifier extends StateNotifier<List<AppShortcut>> {
  ShortcutsNotifier() : super([]) {
    _initDefaults();
  }

  void _initDefaults() {
    state = [
      AppShortcut(
        id: 'default-focus',
        label: 'Focus',
        icon: Icons.center_focus_strong,
        color: AppColors.orange,
        route: '/modules/focus',
        type: ShortcutTargetType.module,
      ),
      AppShortcut(
        id: 'default-tasks',
        label: 'Tasks',
        icon: Icons.check_circle_outline,
        color: AppColors.green,
        route: '/modules/tasks',
        type: ShortcutTargetType.module,
      ),
      AppShortcut(
        id: 'default-forge',
        label: 'Forge',
        icon: Icons.code,
        color: AppColors.blue,
        route: '/modules/forge',
        type: ShortcutTargetType.module,
      ),
      AppShortcut(
        id: 'default-calendar',
        label: 'Calendar',
        icon: Icons.calendar_today,
        color: AppColors.red,
        route: '/modules/calendar',
        type: ShortcutTargetType.module,
      ),
    ];
  }

  void addShortcut({
    required String label,
    required IconData icon,
    required Color color,
    required String route,
    required ShortcutTargetType type,
  }) {
    final newShortcut = AppShortcut(
      id: const Uuid().v4(),
      label: label,
      icon: icon,
      color: color,
      route: route,
      type: type,
    );
    state = [...state, newShortcut];
  }

  void removeShortcut(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final shortcutsProvider = StateNotifierProvider<ShortcutsNotifier, List<AppShortcut>>((ref) {
  return ShortcutsNotifier();
});
