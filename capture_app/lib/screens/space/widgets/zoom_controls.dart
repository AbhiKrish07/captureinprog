import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/canvas_state.dart';

class ZoomControls extends ConsumerWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  
  const ZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoom = ref.watch(zoomLevelProvider);
    final percent = (zoom * 100).round();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: LibraryDesignSystem.textPrimary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: LibraryDesignSystem.textPrimary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove, size: 16),
                onPressed: onZoomOut,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                color: LibraryDesignSystem.textPrimary,
              ),
              Container(width: 1, height: 16, color: LibraryDesignSystem.borderDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: LibraryDesignSystem.textPrimary,
                  ),
                ),
              ),
              Container(width: 1, height: 16, color: LibraryDesignSystem.borderDark),
              IconButton(
                icon: Icon(Icons.add, size: 16),
                onPressed: onZoomIn,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                color: LibraryDesignSystem.textPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}