import 'package:capture_app/config/library_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/canvas_models.dart';
import '../providers/canvas_state.dart';

class CanvasGroupWidget extends ConsumerWidget {
  final CanvasGroup group;
  
  const CanvasGroupWidget({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(canvasCardsProvider);
    final groupCards = cards.where((c) => c.groupId == group.id).toList();

    if (groupCards.isEmpty) return const SizedBox.shrink();

    // Compute bounding box
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;

    for (final card in groupCards) {
      if (card.position.dx < minX) minX = card.position.dx;
      if (card.position.dy < minY) minY = card.position.dy;
      if (card.position.dx + card.size.width > maxX) maxX = card.position.dx + card.size.width;
      if (card.position.dy + card.size.height > maxY) maxY = card.position.dy + card.size.height;
    }

    const padding = 24.0;
    final headerHeight = 24.0;

    return Positioned(
      left: minX - padding,
      top: minY - padding - headerHeight - 8,
      width: (maxX - minX) + (padding * 2),
      height: (maxY - minY) + (padding * 2) + headerHeight + 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Header Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: group.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  group.title,
                  style: TextStyle(color: LibraryDesignSystem.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Icon(Icons.more_horiz, color: LibraryDesignSystem.textPrimary, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Group Border/Background
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: group.color.withValues(alpha: 0.05),
                border: Border.all(color: group.color.withValues(alpha: 0.3), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}