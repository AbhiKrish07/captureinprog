// lib/screens/library/widgets/recent_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/library_design_system.dart';
import '../../../models/capture.dart';
import '../../../widgets/capture_context_menu.dart';

class RecentItem extends ConsumerStatefulWidget {
  final Capture capture;
  final String title;
  final String subtitle;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const RecentItem({
    required this.capture,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    this.onTap,
    super.key,
  });

  @override
  ConsumerState<RecentItem> createState() => _RecentItemState();
}

class _RecentItemState extends ConsumerState<RecentItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: () => showCaptureContextMenu(context, ref, widget.capture),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: LibraryDesignSystem.spacingM,
            horizontal: LibraryDesignSystem.spacingM,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? LibraryDesignSystem.surfaceLight
                : LibraryDesignSystem.surface,
            borderRadius: BorderRadius.circular(LibraryDesignSystem.radiusM),
            border: Border.all(
              color: LibraryDesignSystem.borderDark,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(
                    LibraryDesignSystem.radiusS,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: widget.iconColor,
                ),
              ),
              SizedBox(width: LibraryDesignSystem.spacingM),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: LibraryDesignSystem.recentItemTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: LibraryDesignSystem.recentItemMeta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: LibraryDesignSystem.spacingM),

              // Time
              Text(
                widget.timeAgo,
                style: LibraryDesignSystem.recentItemMeta,
              ),
              SizedBox(width: LibraryDesignSystem.spacingS),
              
              // More button
              GestureDetector(
                onTap: () => showCaptureContextMenu(context, ref, widget.capture),
                child: Icon(Icons.more_vert, size: 20, color: LibraryDesignSystem.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
