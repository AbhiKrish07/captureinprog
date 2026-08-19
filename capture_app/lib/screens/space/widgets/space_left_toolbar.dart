import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';

class SpaceLeftToolbar extends StatelessWidget {
  const SpaceLeftToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: LibraryDesignSystem.textPrimary,
        border: Border(
          right: BorderSide(color: LibraryDesignSystem.borderDark, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // We can use IconButton with a subtle hover effect (SplashRadius controls it partially)
          _ToolbarIcon(icon: Icons.near_me_outlined, tooltip: 'Select', isActive: true),
          _ToolbarIcon(icon: Icons.draw_outlined, tooltip: 'Draw / Annotate'),
          _ToolbarIcon(icon: Icons.text_fields, tooltip: 'Text Block'),
          _ToolbarIcon(icon: Icons.arrow_outward, tooltip: 'Connector'),
          _ToolbarIcon(icon: Icons.image_outlined, tooltip: 'Insert Image/File'),
          _ToolbarIcon(icon: Icons.search, tooltip: 'Search'),
          const Spacer(),
          _ToolbarIcon(icon: Icons.more_horiz, tooltip: 'More Actions'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;

  const _ToolbarIcon({
    required this.icon,
    required this.tooltip,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.blue : LibraryDesignSystem.textSecondary;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          hoverColor: LibraryDesignSystem.surface,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}