import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../config/design_system.dart';

class AiSummaryBlock extends StatelessWidget {
  const AiSummaryBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      decoration: BoxDecoration(
        color: const Color(0xFF13101C), // Deep purple tint
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(color: const Color(0xFF231E30), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                LucideIcons.sparkles,
                color: DesignSystem.accentViolet,
                size: 18,
              ),
              const SizedBox(width: DesignSystem.spacingS),
              Text(
                'AI Summary',
                style: DesignSystem.bodyLarge.copyWith(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Icon(
                Icons.more_horiz,
                color: DesignSystem.textSecondary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingM),
          
          // Bullet points
          _buildBulletPoint('Creators want simplicity and speed'),
          const SizedBox(height: DesignSystem.spacingS),
          _buildBulletPoint('AI can help with planning, designing and publishing'),
          const SizedBox(height: DesignSystem.spacingS),
          _buildBulletPoint('Focus on reducing manual work'),
          
          const SizedBox(height: DesignSystem.spacingM),
          
          // Footer
          Row(
            children: [
              Icon(
                LucideIcons.sparkles,
                color: DesignSystem.textSecondary,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Auto-generated',
                style: DesignSystem.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0, right: 8.0, left: 4.0),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: DesignSystem.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: DesignSystem.bodyLarge.copyWith(
              color: DesignSystem.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
