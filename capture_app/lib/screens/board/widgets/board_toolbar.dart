import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';

class BoardToolbar extends StatelessWidget {
  const BoardToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.02),
            blurRadius: 10,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToolbarIcon(icon: Icons.navigation_outlined, isSelected: true),
          _ToolbarIcon(icon: Icons.back_hand_outlined),
          const SizedBox(width: 8),
          _ToolbarIcon(icon: Icons.square_outlined),
          _ToolbarIcon(icon: Icons.image_outlined),
          _ToolbarIcon(icon: Icons.text_fields),
          _ToolbarIcon(icon: Icons.sticky_note_2_outlined),
          _ToolbarIcon(icon: Icons.grid_view_rounded),
          
          Container(
            height: 24,
            width: 1,
            color: const Color(0xFFE5E7EB),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          
          _ToolbarIcon(icon: Icons.undo),
          _ToolbarIcon(icon: Icons.redo),
          
          Container(
            height: 24,
            width: 1,
            color: const Color(0xFFE5E7EB),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          
          _ToolbarIcon(icon: Icons.remove),
          Text(
            '100%',
            style: TextStyle(
              color: Color(0xFF374151),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          _ToolbarIcon(icon: Icons.add),
          
          const SizedBox(width: 8),
          _ToolbarIcon(icon: Icons.help_outline, color: const Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final Color? color;

  const _ToolbarIcon({
    required this.icon,
    this.isSelected = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF3E8FF) : Colors.transparent, // Purple tint if selected
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 20,
        color: isSelected 
            ? const Color(0xFF8B5CF6) // Purple accent
            : (color ?? const Color(0xFF4B5563)),
      ),
    );
  }
}