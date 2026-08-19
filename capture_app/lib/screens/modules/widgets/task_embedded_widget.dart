import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/library_design_system.dart';
import '../../../models/capture.dart';
import '../../../theme/app_colors.dart';
import '../providers/module_providers.dart';

class TaskEmbeddedWidget extends ConsumerWidget {
  final Capture capture;

  const TaskEmbeddedWidget({super.key, required this.capture});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadata = capture.metadata ?? {};
    final bool completed = metadata['completed'] == true;
    final String priority = metadata['priority'] ?? 'medium';
    // No need to parse dueDate unless we want to display it
    
    Color priorityColor;
    switch (priority) {
      case 'critical': priorityColor = const Color(0xFFEF4444); break;
      case 'high': priorityColor = AppColors.red; break;
      case 'medium': priorityColor = AppColors.yellow; break;
      case 'low': priorityColor = AppColors.green; break;
      default: priorityColor = AppColors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LibraryDesignSystem.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: completed ? AppColors.green.withValues(alpha: 0.3) : LibraryDesignSystem.borderDark,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(moduleCapturesProvider('todo').notifier).updateModuleCapture(
                capture.id,
                metadataUpdates: {'completed': !completed},
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed ? AppColors.green.withValues(alpha: 0.2) : Colors.transparent,
                border: Border.all(
                  color: completed ? AppColors.green : priorityColor.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: completed ? Icon(Icons.check, size: 12, color: AppColors.green) : null,
            ),
          ),
          const SizedBox(width: 10),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capture.title ?? 'Untitled Task',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: completed ? AppColors.textMuted : AppColors.textPrimary,
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (capture.content.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    capture.content,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
