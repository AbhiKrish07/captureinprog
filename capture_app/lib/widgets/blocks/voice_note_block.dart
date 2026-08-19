import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class VoiceNoteBlockWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const VoiceNoteBlockWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF141414), // Dark surface
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // Green Mic Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.greenDark.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.mic, color: AppColors.green, size: 24),
          ),
          const SizedBox(width: 16),
          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Waveform placeholder (using multiple vertical bars)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(20, (index) {
              // Create a pseudo-random looking waveform
              final heights = [4, 8, 12, 16, 10, 6, 14, 20, 12, 8, 16, 18, 10, 6, 12, 8, 14, 6, 4, 8];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 2,
                height: heights[index].toDouble(),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          ),
          const SizedBox(width: 16),
          // Play Button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_arrow_rounded, color: AppColors.textPrimary, size: 24),
          ),
        ],
      ),
    );
  }
}
